(define-module (wonko systems of-course-i-still-love-you)
  #:use-module (gnu)
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
  #:use-module (wonko services mail)
  #:use-module (wonko services networking)
  #:use-module (wonko packages mail)
  #:use-module (wonko services emacs)
  #:use-module (maxipassat services ci)
  #:use-module (maxipassat systems ci)
  #:export (%of-course-i-still-love-you-wonko-home
            %of-course-i-still-love-you-os))

(use-package-modules file-systems xorg machine-learning synergy
                     ;; public net:
                     admin linux vpn)
(use-service-modules linux nfs
                     desktop xorg sddm
                     networking ssh vpn
                     guix shepherd
                     ;; public net:
                     certbot configuration sysctl web
                     mail)

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
                          "-f" "enterprise.local")
                    #:log-file #$(home-log-path "synergy")))
          (stop #~(make-kill-destructor))
          (documentation "can't be arsed to move IRL"))))
      (append
       machine-home-services
       (cons*
        (simple-service 'guix-build-options-bash home-bash-service-type
                        (home-bash-extension
                          (environment-variables
                           '(("GUIX_BUILD_OPTIONS" . "-M 8")))))
        %highdpi-wonko-services))))))

(define %media-station-home
  (home-environment
    (inherit %media-station-home)
    (services
     (append
      machine-home-services
      %media-station-home-services))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; skynet:

(define skynet-llm-service
  (list
   (shepherd-service
     (provision '(skynet))
     (requirement '(user-processes udev networking file-systems)) ;; FIXME: could wait for wan, or local net? 192 eth0 addr not ready when this is initially started.
     (documentation "start skynet llm")
     ;; phi 4
     ;; (start #~(make-forkexec-constructor
     ;;           (list (string-append #$llama-cpp "/bin/llama-server")
     ;;                 "--host" "0"
     ;;                 "--port" "6060"
     ;;                 "-ngl" "256"
     ;;                 "-m" "/code/llms/phi-4-bf16.gguf")))
     ;; gemma 3
     (start #~(make-forkexec-constructor
               (list (string-append #$llama-cpp "/bin/llama-server")
                     "--host" "0"
                     "--port" "6060"
                     "--model" "unsloth/gemma-3-27b-it/gemma-3-27b-it-UD-Q4_K_XL.gguf"
                     "--mmproj" "unsloth/gemma-3-27b-it/mmproj-BF16.gguf"
                     "--ctx-size" "16384"
                     "--n-gpu-layers" "256"
                     "--seed" "3407"
                     "--prio" "2"
                     "--temp" "1.0"
                     "--repeat-penalty" "1.0"
                     "--min-p" "0.01"
                     "--top-k" "64"
                     "--top-p" "0.95")
               #:directory "/code/llms"))
     (stop #~(make-kill-destructor)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; public facing services network config:

(define wan-vpn-service
  (append
   wan-vpn-service
   (list
    (shepherd-service
      (requirement '(networking user-processes wan-vpn)) ;;  wait-for-wan
      (provision '(wan-vpn-web-hosting-routing))
      (start #~(lambda _
                 (invoke (string-append #$iproute "/sbin/ip")
                         "-6" "rule" "add" "priority" "1010" "to"
                         "2a01:e0a:b5a:de71::1" "lookup" "main")
                 (invoke (string-append #$iproute "/sbin/ip")
                         "-6" "rule" "add" "priority" "1010" "from"
                         "2a01:e0a:b5a:de71::1" "lookup" "main")
                 (invoke (string-append #$iproute "/sbin/ip")
                         "rule" "add" "priority" "1010" "to"
                         "192.168.1.101" "lookup" "main")
                 (invoke (string-append #$iproute "/sbin/ip")
                         "rule" "add" "priority" "1010" "from"
                         "192.168.1.101" "lookup" "main")))
      (stop #~(lambda _
                (invoke (string-append #$iproute "/sbin/ip")
                        "-6" "rule" "del" "priority" "1010" "to"
                        "2a01:e0a:b5a:de71::1" "lookup" "main")
                (invoke (string-append #$iproute "/sbin/ip")
                        "-6" "rule" "del" "priority" "1010" "from"
                        "2a01:e0a:b5a:de71::1" "lookup" "main")
                (invoke (string-append #$iproute "/sbin/ip")
                        "rule" "del" "priority" "1010" "to"
                        "192.168.1.101" "lookup" "main")
                (invoke (string-append #$iproute "/sbin/ip")
                        "rule" "del" "priority" "1010" "from"
                        "192.168.1.101" "lookup" "main")))
      (documentation "wan-vpn wg")))))

(define %nftables-ruleset
  (plain-file "nftables.conf" "\
## for masquerading example: https://www.procustodibus.com/blog/2021/11/wireguard-nftables/
table inet firewall {

    chain inbound_ipv4 {
        icmp type echo-request limit rate 5/second accept
        # accept everything on local network, 101 is public facing:
        ip daddr != 192.168.1.101 accept
        tcp dport { 25, 80, 443, 465 } accept
    }

    chain inbound_ipv6 {
        icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
        icmpv6 type echo-request limit rate 5/second accept

        ip6 daddr != 2a01:e0a:b5a:de71::/64 accept # accept on non public
        tcp dport { 25, 80, 443, 465 } accept # only accept these on public facing ipv6
        udp dport { 51820 } accept   # only accept these on public facing ipv6
    }

    chain inbound {
        type filter hook input priority 0; policy drop;
        ct state vmap { established : accept, related : accept, invalid : drop }

        # Allow loopback traffic.
        iifname lo accept
        # drop connections to lo not coming from lo
        iif != lo ip daddr 127.0.0.1/8 drop
        iif != lo ip6 daddr ::1/128 drop

        # Jump to chain according to layer 3 protocol using a verdict map
        meta protocol vmap { ip : jump inbound_ipv4, ip6 : jump inbound_ipv6 }
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state vmap { invalid : drop, established : accept, related : accept }
        iifname star-fleet oifname star-fleet ct state new accept
    }
    # no need to define output chain, default policy is accept if undefined.
}
"))

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
        ###AdvOnLink on;             # Says to a host: 'Everyone sharing this prefix is on the same,' 'local link as you.'
        AdvAutonomous off;         # Says to a host: 'Use this prefix to autoconfigure your address.'
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
                              (compose list radvd-shepherd-service))))
    (default-value (radvd-configuration))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the OS

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
     (cons*
      ;; zfs
      (simple-service 'zfs-loader kernel-module-loader-service-type '("zfs"))
      (simple-service 'zfs-shepherd-services
                      shepherd-root-service-type
                      zfs-shepherd-services)
      (simple-service 'zfs-sheperd-services-user-processes
                      user-processes-service-type
                      '(zfs-automount))
      ;; homes
      (service guix-home-service-type
               `((,(crew-name %wonko) ,%of-course-i-still-love-you-wonko-home)
                 (,(crew-name %media) ,%media-station-home)))
      ;; kbd
      (service kmonad-service-type (kmonad-configuration
                                    (keymaps (list kmonad-ergodox-config
                                                   kmonad-bullshit-config))))
      ;; X
      (service slim-service-type (slim-configuration
                                   (inherit wonko-slim-config)
                                   (xorg-configuration noamdgpu-noflip-xorg-config)))
      (service slim-service-type (slim-configuration
                                   (inherit media-station-slim-config)
                                   (xorg-configuration noamdgpu-noflip-xorg-config)))
      ;; llm
      (simple-service 'skynet-llm-service
                      shepherd-root-service-type
                      skynet-llm-service)
      ;; export agenda
      (service export-agenda-service-type)

      ;; <!-- public net stuff:
      (service certbot-service-type
               (certbot-configuration
                 (certificates
                  (list
                   (certificate-configuration
                    (domains '("mail.maxipass.at"))
                    (deploy-hook exim-deploy-hook))
                   (certificate-configuration
                    (domains '("maxipass.at" "www.maxipass.at")))))))

      (service
       nginx-service-type
       (nginx-configuration
         (server-blocks
          (list (nginx-server-configuration
                  (server-name '("www.maxipass.at"))
                  (listen '("443 ssl" "[::]:443 ssl"))
                  (root (string-append
                         (maxipassat-ci-base-path mp-prod-config)
                         "/static"))
                  (ssl-certificate "/etc/letsencrypt/live/maxipass.at/fullchain.pem")
                  (ssl-certificate-key "/etc/letsencrypt/live/maxipass.at/privkey.pem")
                  (locations
                   (list
                    (nginx-location-configuration
                      (uri "/www/")
                      (body `(,(string-append
                                "root "
                                (maxipassat-ci-base-path mp-prod-config) "/static;"))))
                    (nginx-location-configuration
                      (uri "/so/")
                      (body `("root /data/www/static-org/www;"
                              "auth_basic \"ahahah you didn't say the magic word\";"
                              "auth_basic_user_file /data/www/static-org/.htpasswd;")))
                    (nginx-location-configuration
                      (uri "/")
                      (body `(,(string-append "proxy_pass http://127.0.0.1:"
                                              (number->string
                                               (maxipassat-ci-port mp-prod-config))
                                              ";")
                              "proxy_set_header Host $host;"
                              "proxy_set_header X-Real-IP $remote_addr;"
                              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                              "proxy_set_header X-Forwarded-Proto $scheme;"))))))))))

      (service maxipassat-container-ci-service-type mp-staging-config)
      (service maxipassat-container-ci-service-type mp-preprod-config)
      (service maxipassat-container-ci-service-type mp-prod-config)

      ;; email
      (service mail-aliases-service-type '(("william" "wonko@maxipass.at")
                                           ("webmaster" "wonko@maxipass.at")
                                           ("dance-commander" "wonko@maxipass.at")))
      (service dovecot-service-type
               (dovecot-configuration
                 (mail-location "maildir:~/.mail")
                 ;; for pigeonhole example /code/guix/gnu/tests/mail.scm
                 ;; (extensions (list dovecot-pigeonhole))
                 (services
                  (list
                   (service-configuration
                     (kind "imap-login")
                     (client-limit 0)
                     (process-limit 0)
                     (listeners
                      (list
                       (inet-listener-configuration (protocol "imaps")
                                                    (port 993)
                                                    (ssl? #t)))))
                   (service-configuration
                     (kind "lmtp")
                     (client-limit 1)
                     (process-limit 0)
                     (listeners
                      (list
                       (inet-listener-configuration (protocol "lmtp")
                                                    (port 2525)
                                                    (ssl? #f)))))
                   (service-configuration
                     (kind "auth")
                     (service-count 0)
                     (client-limit 0)
                     (process-limit 1)
                     (listeners
                      (list (unix-listener-configuration (path "auth-userdb")))))
                   (service-configuration
                     (kind "auth-worker")
                     (client-limit 1)
                     (process-limit 0))
                   (service-configuration
                     (kind "dict")
                     (client-limit 1)
                     (process-limit 0)
                     (listeners (list (unix-listener-configuration (path "dict")))))))
                 ;; (mail-debug? #t)
                 (auth-username-format "%n")
                 (protocols
                  (list (protocol-configuration
                          (name "lmtp"))
                        (protocol-configuration
                          (name "imap")
                          ;; (mail-plugins '("$mail_plugins" "imap_sieve"))
                          ;; (imap-metadata? #t)
                          )))))
      (service exim-service-type
               (exim-configuration
                 (package exim-content-scan)
                 (config-file
                  (local-file
                   (string-append %lambda-project "/misc/exim.conf")))))
      (service rspamd-service-type)

      ;; local net
      (simple-service 'resolv-service
                      shepherd-root-service-type
                      resolv-service)
      (service nftables-service-type (nftables-configuration
                                       (ruleset %nftables-ruleset)))
      (service radvd-service-type (radvd-configuration
                                   (config-file %radvd-config)))
      (service dhcpcd-service-type (dhcpcd-configuration
                                     (no-hook '("resolv.conf"))
                                     (interfaces '("eth0"))))
      (service static-networking-service-type
               (list
                (static-networking
                  (provision '(static-net-conf))
                  (addresses
                   (list (network-address
                           (device "eth0")
                           (value "2a01:e0a:b5a:de71::1/64"))
                         (network-address
                           (device "eth0")
                           (value (net-peer-ip6-local-address %of-course-i-still-love-you-net-peer)))
                         (network-address
                           (device "eth0")
                           (value "192.168.1.101/24"))))
                  (routes
                   (list (network-route
                           (destination "2000::/3")
                           (gateway "2a01:e0a:b5a:de70::1")))))))

      (service wireguard-service-type
               (wireguard-configuration
                 (interface "star-fleet")
                 (addresses (net-peer-addr-to/24 %of-course-i-still-love-you-net-peer))
                 (peers
                  (map net-to-wg-peer
                       (filter (lambda (h)
                                 (not (equal? h %of-course-i-still-love-you-net-peer)))
                               %star-fleet-hosts)))))

      ;; (simple-service 'wait-for-wan-service
      ;;                 shepherd-root-service-type
      ;;                 wait-for-wan-service)

      (simple-service 'wan-vpn-service
                      shepherd-root-service-type
                      wan-vpn-service)

      (modify-services %media-station-os-services
        (sysctl-service-type
         config =>
         (sysctl-configuration
           (settings (append '(("net.ipv6.conf.all.forwarding" . "1")
                               ("net.ipv4.ip_forward" . "1"))
                             %default-sysctl-settings))))
        ;; public net stuff -->

        (guix-publish-service-type
         config =>
         (guix-publish-configuration
           (inherit config)
           (advertise? #f)
           (host (net-peer-wg-address %of-course-i-still-love-you-net-peer))))

        (elogind-service-type
         config =>
         (elogind-configuration
           (inherit config)
           (handle-power-key 'reboot))))))

    (mapped-devices
     (list (mapped-device
             (source (uuid "becf9b67-d7fc-4e3d-a334-1c684567c98c"))
             (target "vault")
             (type luks-device-mapping)
             (arguments '(#:key-file "/root/keys-to-the-kingdom.bin"
                          #:allow-discards? #t)))))
    (file-systems (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "3073-DA9D"
                                   'fat32))
                     (type "vfat"))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))
    (swap-devices
     (list (make-default-swap file-systems)))))

%of-course-i-still-love-you-wonko-home
%of-course-i-still-love-you-os
