(define-module (wonko systems of-course-i-still-love-you)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sddm)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services guix)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services shells)
  #:use-module (nongnu packages linux)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko dotfiles)
  #:use-module (wonko homes)
  #:use-module (wonko systems)
  #:use-module (wonko services kmonad)
  #:use-module (wonko services xorg)
  #:export (%of-course-i-still-love-you-wonko-home
            %of-course-i-still-love-you-os))

(use-package-modules file-systems xorg machine-learning synergy
                     ;; public net:
                     admin linux)
(use-service-modules linux nfs
                     ;; public net:
                     configuration sysctl)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".x-config"
       ,(program-file
         "x-config"
         #~(system
            (string-append
             #$setxkbmap "/bin/setxkbmap -option compose:ralt us;"))))))))

(define %of-course-i-still-love-you-wonko-home
  (home-environment
    (inherit %vanilla-wonko-home)
    (services
     (cons*
      (simple-service
       'of-course-i-still-love-you-shepherd home-shepherd-service-type
       (list
        (shepherd-service
          (provision '(synergyc))
          (auto-start? #f)
          (start #~(make-forkexec-constructor
                    (list #$(file-append synergy "/bin/synergyc")
                          "-n" "media-station"
                          "-f" "yggdrasill.local")
                    #:log-file #$(home-log-path "synergy")))
          (stop #~(make-kill-destructor))
          (documentation "can't be arsed to move IRL"))))
      (append
       machine-home-services
       %vanilla-wonko-services)))))

(define %media-station-home
  (home-environment
    (inherit %media-station-wonko-home)
    (services
     (append
      machine-home-services
      %media-station-wonko-services))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; zfs

;; followed:
;; https://www.reddit.com/r/GUIX/comments/s7qu25/guide_using_zfs_on_guix/
;; https://gitlab.com/nonguix/nonguix/-/issues/347

(define zfs-lts
  (package
    (inherit zfs)
    (arguments
     (cons* #:linux linux-lts
            (package-arguments zfs)))))

(define zfs-shepherd-services
  (let ((zpool (file-append zfs-lts "/sbin/zpool"))
        (zfs (file-append zfs-lts "/sbin/zfs"))
        (scheme-modules `((srfi srfi-1)
                          (srfi srfi-34)
                          (srfi srfi-35)
                          (rnrs io ports)
                          ,@%default-modules)))
    (define zfs-scan
      (shepherd-service
        (provision '(zfs-scan))
        (documentation "Scans for ZFS pools.")
        (requirement '(kernel-module-loader udev))
        (modules scheme-modules)
        (start #~(lambda _
                   (invoke/quiet #$zpool "import" "-a" "-N")))
        (stop #~(const #f))))
    (define zfs-automount
      (shepherd-service
        (provision '(zfs-automount))
        (documentation "Automounts ZFS data sets.")
        (requirement '(zfs-scan))
        (modules scheme-modules)
        (start #~(lambda _
                   (with-output-to-port (current-error-port)
                     (lambda ()
                       (invoke #$zfs "mount" "-a" "-l")))))
        (stop #~(lambda _
                  (chdir "/")
                  (invoke/quiet #$zfs "unmount" "-a" "-f") #f))))
    ;; (define zfs-zed
    ;;   (shepherd-service ...))
    (list zfs-scan zfs-automount)))

(define skynet-llm-service
  (list
   (shepherd-service
     (provision '(skynet))
     (requirement '(user-processes networking file-systems))
     (documentation "start skynet llm")
     (start #~(make-forkexec-constructor
               (list (string-append #$llama-cpp "/bin/llama-server")
                     "--host" "192.168.1.7"
                     "--port" "6060"
                     "-ngl" "256"
                     "-m" "/code/llms/phi-4-q4.gguf")))
     (stop #~(make-kill-destructor)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; public facing services network config:

(define %nftables-ruleset
  (plain-file "nftables.conf" "\
table inet firewall {

    chain inbound_ipv4 {
        # icmp type echo-request limit rate 5/second accept
        accept # accept everything on local network
    }

    chain inbound_ipv6 {
        # accept neighbour discovery otherwise connectivity breaks
        #
        icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept

        # accepting ping (icmpv6-echo-request) for diagnostic purposes.
        # However, it also lets probes discover this host is alive.
        # This sample accepts them within a certain rate limit:
        #
        icmpv6 type echo-request limit rate 5/second accept
        ip6 daddr != 2a01:e0a:b5a:de71::/64 accept # accept on non public
        tcp dport { 80, 443 } accept # only accept these on public facing ipv6
    }

    chain inbound {

        # By default, drop all traffic unless it meets a filter
        # criteria specified by the rules that follow below.
        type filter hook input priority 0; policy drop;

        # Allow traffic from established and related packets, drop invalid
        ct state vmap { established : accept, related : accept, invalid : drop }

        # Allow loopback traffic.
        iifname lo accept
        # drop connections to lo not coming from lo
        iif != lo ip daddr 127.0.0.1/8 drop
        iif != lo ip6 daddr ::1/128 drop

        # Jump to chain according to layer 3 protocol using a verdict map
        meta protocol vmap { ip : jump inbound_ipv4, ip6 : jump inbound_ipv6 }

        # Allow SSH on port TCP/22 and allow HTTP(S) TCP/80 and TCP/443
        # for IPv4 and IPv6.
        # tcp dport { 22, 80, 443} accept

        # Uncomment to enable logging of denied inbound traffic
        # log prefix \"[nftables] Inbound Denied: \" counter drop
    }

    chain forward {
        # Drop everything (assumes this device is not a router)
        type filter hook forward priority 0; policy drop;
    }

    # no need to define output chain, default policy is accept if undefined.
} "))

(define %radvd-config
  (plain-file "radvd.conf" "\
interface eth0                    # identifies the interface we are advertising on
{                                 # if you need, you can have multiple interfaces defined

    AdvSendAdvert on;             # this simply means that we are sending advertisements

    MinRtrAdvInterval 5;          # these options control how often advertisements are sent
    MaxRtrAdvInterval 15;         # these aren't mandatory, but valuable settings
                                  # I will discuss them in a moment

    prefix 2a01:e0a:b5a:de71::/64 # netmask length must be '/64' (see RFC 2462, sect 5.5.3, page 18)
    {
        AdvOnLink on;             # Says to a host: 'Everyone sharing this prefix is on the same,' 'local link as you.'
        AdvAutonomous on;         # Says to a host: 'Use this prefix to autoconfigure your address.'
    };
};"))

(define-configuration/no-serialization radvd-configuration
  (config-file
   (file-like %radvd-config)
   "A file-like object containing radvd config."))

(define (radvd-shepherd-service config)
  (match-record config <radvd-configuration>
                (config-file)
    (shepherd-service
      (documentation "Linux IPv6 Router Advertisement Daemon (radvd)")
      (provision '(radvd))
      (start #~(make-forkexec-constructor
                `(#$(file-append radvd "/sbin/radvd")
                  "-n" "-C" #$config-file)))
      (stop #~(make-kill-destructor)))))


(define radvd-service-type
  (service-type
    (name 'radvd)
    (description "radvd")
    (extensions
     (list (service-extension shepherd-root-service-type
                              (compose list radvd-shepherd-service))
           ;; (service-extension profile-service-type
           ;;                    (compose list radvd-configuration))
           ))
    (default-value (radvd-configuration))))


(define %of-course-i-still-love-you-os
  (operating-system

    (inherit %laptop-os)
    (kernel linux-lts)
    (kernel-loadable-modules (list (list zfs-lts "module")))
    (kernel-arguments (append '("resume_offset=215422318")
                              (operating-system-user-kernel-arguments %laptop-os)))
    (host-name "of-course-i-still-love-you")
    (keyboard-layout %us-kb)

    (packages (cons*
               zfs-lts
               (operating-system-packages %laptop-os)))

    (services
     (let ((xorg-cfg (xorg-configuration
                       (keyboard-layout %us-kb)
                       (modules (filter
                                 (lambda (p)
                                   ;; remove amdgpu and non supported by current-system
                                   (and (not (equal? p xf86-video-amdgpu))
                                        (member (%current-system)
                                                (package-supported-systems p))))
                                 %default-xorg-modules))
                       (extra-config '("Section \"Device\"\n"
                                       "  Identifier \"Card1\"\n"
                                       "  Option \"SWcursor\"\n"
                                       "  Option \"AsyncFlipSecondaries\" \"false\"\n"
                                       "EndSection\n")))))
       (cons*
        ;; zfs
        (simple-service 'zfs-loader kernel-module-loader-service-type '("zfs"))
        (simple-service 'zfs-shepherd-services
                        shepherd-root-service-type
                        zfs-shepherd-services)
        (simple-service 'zfs-sheperd-services-user-processes
                        user-processes-service-type
                        '(zfs-automount))

        ;; my users & desktop usage:
        (service slim-service-type (slim-configuration
                                     (inherit wonko-slim-config)
                                     (xorg-configuration xorg-cfg)))
        (service slim-service-type (slim-configuration
                                     (inherit media-station-slim-config)
                                     (xorg-configuration xorg-cfg)
                                     (auto-login? #t)))
        (service guix-home-service-type
                 `((,(crew-name %wonko) ,%of-course-i-still-love-you-wonko-home)
                   (,(crew-name %media) ,%media-station-home)))
        (service kmonad-service-type kmonad-ergodox-config)
        (service kmonad-service-type kmonad-bullshit-config)
        (simple-service 'skynet-llm-service
                        shepherd-root-service-type
                        skynet-llm-service)

        ;; <!-- public net stuff:
        (service nftables-service-type (nftables-configuration
                                         (ruleset %nftables-ruleset)))
        (service radvd-service-type (radvd-configuration
                                     (config-file %radvd)))
        (modify-services %media-station-services
          (sysctl-service-type
           config =>
           (sysctl-configuration
             (settings (append '(("net.ipv6.conf.all.forwarding" . "1"))
                               %default-sysctl-settings))))
          ;; okkkkk... nm did not like this, will probably end nuking nm.
          ;; (static-networking-service-type
          ;;  config =>
          ;;  (list
          ;;   (static-networking
          ;;     (addresses
          ;;      (cons (network-address
          ;;              (device "eth0")
          ;;              (value "2a01:e0a:b5a:de71::1/64"))
          ;;            (static-networking-addresses %loopback-static-networking)))
          ;;     (routes
          ;;      (list (network-route
          ;;              (destination "2000::/3")
          ;;              (gateway "2a01:e0a:b5a:de70::1"))))
          ;;     (provision '(loopback)))))
          ;; public net stuff -->
          ))))

    (mapped-devices
     (list (mapped-device
             (source (uuid "becf9b67-d7fc-4e3d-a334-1c684567c98c"))
             (target "vault")
             (type luks-device-mapping)
             (arguments '(#:key-file "/root/keys-to-the-kingdom.bin")))))
    (file-systems (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "3073-DA9D"
                                   'fat32))
                     (type "vfat"))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))))

%of-course-i-still-love-you-wonko-home
%of-course-i-still-love-you-os
