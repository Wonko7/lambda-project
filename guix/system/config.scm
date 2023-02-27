(use-modules (gnu)
             (gnu packages)
             (gnu packages base)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages networking)
             (gnu packages xdisorg)
             (gnu packages suckless)
             (gnu packages fonts)
             (gnu system setuid)
             (gnu services desktop)
             (gnu services xorg)
             (gnu services networking)
             (gnu services ssh)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (guix gexp)
             (ice-9 format)
             (srfi srfi-1)
             (srfi srfi-88)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules desktop networking ssh xorg)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spock

(define spock
  (let ((spock '("                                      :                                 :       \n"
                 "                                    :                                   :       \n"
                 "                                    :  RRVIttIti+==iiii++iii++=;:,       :      \n"
                 "                                    : IBMMMMWWWWMMMMMBXXVVYYIi=;:,        :     \n"
                 "                                    : tBBMMMWWWMMMMMMBXXXVYIti;;;:,,      :     \n"
                 "                                    t YXIXBMMWMMBMBBRXVIi+==;::;::::       ,    \n"
                 "   live long & prosper             ;t IVYt+=+iIIVMBYi=:,,,=i+=;:::::,      ;;   \n"
                 "                                   YX=YVIt+=,,:=VWBt;::::=,,:::;;;:;:     ;;;   \n"
                 "                                   VMiXRttItIVRBBWRi:.tXXVVYItiIi==;:   ;;;;    \n"
                 "                                   =XIBWMMMBBBMRMBXi;,tXXRRXXXVYYt+;;: ;;;;;    \n"
                 "                                    =iBWWMMBBMBBWBY;;;,YXRRRRXXVIi;;;:;,;;;=    \n"
                 "                                     iXMMMMMWWBMWMY+;=+IXRRXXVYIi;:;;:,,;;=     \n"
                 "                                     iBRBBMMMMYYXV+:,:;+XRXXVIt+;;:;++::;;;     \n"
                 "                                     =MRRRBMMBBYtt;::::;+VXVIi=;;;:;=+;;;;=     \n"
                 "                                      XBRBBBBBMMBRRVItttYYYYt=;;;;;;==:;=       \n"
                 "                                       VRRRRRBRRRRXRVYYIttiti=::;:::=;=         \n"
                 "                                        YRRRRXXVIIYIiitt+++ii=:;:::;==          \n"
                 "                                        +XRRXIIIIYVVI;i+=;=tt=;::::;:;          \n"
                 "                                         tRRXXVYti++==;;;=iYt;:::::,;;          \n"
                 "                                          IXRRXVVVVYYItiitIIi=:::;,::;          \n"
                 "                                           tVXRRRBBRXVYYYIti;::::,::::          \n"
                 "                                            YVYVYYYYYItti+=:,,,,,:::::;         \n"
                 "                                            YRVI+==;;;;;:,,,,,,,:::::::         \n")))
    (apply string-append spock)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; channels

(define %channels #~(cons*
                     (channel
                      (name 'nonguix)
                      (url "https://gitlab.com/nonguix/nonguix")
                      (introduction
                       (make-channel-introduction
                        "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                        (openpgp-fingerprint
                         "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
                     (channel
                      (name 'w7)
                      (url "https://gitlab.com/wonko7/w7-guix-channel")
                      (introduction
                       (make-channel-introduction
                        "e6afee0a2c3e941e186b2a9035c0217e5e94e9d5"
                        (openpgp-fingerprint
                         "FF23 0627 4DFE CF36 3AD8  677C 613C 8B66 6DBE 0AEB"))))
                     %default-channels))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hosts & hostname

(define (nassq alist ks)
  "get data from nested map"
  (fold (lambda (k al) (assq-ref al k)) alist ks))

(define (fleet-hosts machines)
  "make /etc/hosts file with fleet IPs."
  (filter identity
          (map (lambda (k)
                 (let ((ip (nassq machines `(,k #:net #:wg42))))
                   (if ip
                       (host ip
                             (string-append (keyword->string k) ".underage.wang"))
                       #f)))
               (map first machines))))

;;(define hostname "discovery")
(define hostname (getenv "HOSTNAME"))

(define %host
  (cond ((or (string=? hostname "rocinante")
             (string=? hostname "enterprise")
             (string=? hostname "discovery")
             (string=? hostname "yggdrasill"))
         (begin
           (display (string-append "building for " hostname "\n"))
           (string->keyword hostname)))
        (#t (error (string-append "unknown host: " hostname "\n") 69))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; machine data:

(define fleet-data
  (let ((initial  `((#:enterprise .
                     ((#:services . ,%desktop-services)
                      (#:net .
                       ((#:wg42 . "10.42.0.6")))
                      (#:uuids .
                       ((#:vault . "125bf330-ff27-45d1-9cce-1dd96cb14975")
                        (#:efi . "6C21-E416")))))
                    (#:yggdrasill .
                     ((#:services . ,%desktop-services)
                      (#:net .
                       ((#:wg42 . "10.42.0.3")))
                      (#:uuids .
                       ((#:vault . "077c1391-b290-4921-ae90-f8e3cec68113")
                        (#:efi . "77DE-0AE2")))))
                    (#:rocinante .
                     ((#:services . ,%desktop-services)
                      (#:net .
                       ((#:wg42 . "10.42.0.4")))
                      (#:uuids .
                       ((#:vault . "ec7a9b12-4611-469c-8a6f-aadf4d525d5e")
                        (#:efi . "918C-B182")))))
                    (#:discovery .
                     ((#:services . ,%base-services)
                      (#:uuids .
                       ((#:vault . "")
                        (#:efi . ""))))))))
    initial))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OS

(define %my-keyboard-layout
  (if (equal? %host #:rocinante)
      (keyboard-layout "fr" "azerty" #:options '("ctrl:nocaps"))
      (keyboard-layout "us" "dvorak" #:options '("ctrl:nocaps"))))

(define %my-services
  (let* ((%my-base (nassq fleet-data `(,%host #:services)))

         (fleet-desktop-base
          (list
           (bluetooth-service #:auto-enable? #t)
           (service slim-service-type (slim-configuration
                                       (display ":0")
                                       (vt "vt7")
                                       (auto-login? #t)
                                       (default-user "wonko")
                                       (xorg-configuration (xorg-configuration
                                                            (keyboard-layout %my-keyboard-layout)))))))

         (fleet-permanent-base
          (list (service guix-publish-service-type
                                              (guix-publish-configuration
                                               (host "0.0.0.0")
                                               (port 1337)
                                               (advertise? #t)))))

         (fleet-base
          (cons*
           (simple-service 'fleet-hosts-entries hosts-service-type
                           (fleet-hosts fleet-data))

           (service tor-service-type)

           (service openssh-service-type (openssh-configuration
                                          (authorized-keys
                                           `(("wonko" ,(local-file "data/ssh/yggdrasill.pub"))))
                                          (x11-forwarding? #t)
                                          (password-authentication? #f)))

           (extra-special-file "/etc/guix/channels.scm" (scheme-file "_" %channels))

           (modify-services %my-base
             (delete gdm-service-type)

             (guix-service-type config =>
                                (guix-configuration
                                 (discover? #t)
                                 (substitute-urls
                                  (append (list ;; "192.168.1.106" ;; FIXME yggdrassil
                                           "https://substitutes.nonguix.org" )
                                          %default-substitute-urls))
                                 (authorized-keys
                                  (append (list (local-file "./data/substitutes/yggdrasill.pub")
                                                (local-file "./data/substitutes/nonguix.pub"))
                                          %default-authorized-guix-keys))))

             (elogind-service-type config =>
                                   (elogind-configuration
                                    (handle-power-key 'ignore) ;; 'hibernate?
                                    (handle-lid-switch 'suspend)
                                    (handle-lid-switch-docked 'suspend)
                                    (handle-lid-switch-external-power 'suspend)))

             (console-font-service-type config =>
                                        (map (lambda (tty)
                                               `(,tty .
                                                      ,(file-append font-terminus "/share/consolefonts/ter-132n")))
                                             '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6"))))))

         (naked-networking-services
          (list
           (service network-manager-service-type)
           (service wpa-supplicant-service-type))))

    (if (equal? %host #:discovery)
        (append fleet-base naked-networking-services)
        (append fleet-base fleet-permanent-base fleet-desktop-base))))

(operating-system
  (locale "en_GB.utf8")
  (timezone "Europe/Paris")
  (keyboard-layout %my-keyboard-layout)

  (kernel linux)
  (kernel-arguments '("net.ifnames=0" "biosdevname=0"))
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets '("/boot"))
    (keyboard-layout keyboard-layout)))

  (issue (string-append spock "\n   o===8 [" hostname "] project-lambda / GNU Guix / Fat Cock Enthusiaste 8===o\n\n"))
  (host-name hostname)

  (users (cons* (user-account
                 (name "wonko")
                 (comment "wonko")
                 (group "users")
                 (home-directory "/home/wonko")
                 (shell (file-append bash "/bin/bash"))
                 (supplementary-groups
                  '("lp" "wheel" "netdev" "audio" "video")))
                (user-account
                 (name "tina")
                 (comment "Tina")
                 (group "users")
                 (home-directory "/home/tina")
                 (shell (file-append bash "/bin/bash"))
                 (supplementary-groups
                  '("netdev" "audio" "video")))
                %base-user-accounts))

  (packages
   (append
    (map specification->package
         (append (if (equal? %host #:discovery)
                     '()
                     '("emacs-exwm" "emacs-desktop-environment")) ;; desktop
                 '("nss-certs" "isc-dhcp" "wireguard-tools" "iproute2" "iw"
                   "emacs"
                   "font-terminus"
                   "git" "rsync" "bash-completion"
                   "cryptsetup" "btrfs-progs" "dosfstools" "network-manager")))
    %base-packages))

  (services %my-services)

  (setuid-programs
   (cons*
    ;; emacs: dumpcap?
    (setuid-program (program (file-append (@ (gnu packages linux) brightnessctl) "/bin/brightnessctl")))
    %setuid-programs))

  (mapped-devices
   (if (equal? %host #:discovery)
       '()
       (list (mapped-device
              (source
               (uuid (nassq fleet-data `(,%host #:uuids #:vault))))
              (target "vault")
              (type luks-device-mapping)))))

  (file-systems
   (if (equal? %host #:discovery)
       %base-file-systems
       (cons* (file-system
                (mount-point "/boot")
                (device (uuid (nassq fleet-data `(,%host #:uuids #:efi)) 'fat32))
                (type "vfat"))
              (file-system
                (device "/dev/mapper/vault")
                (mount-point "/")
                (type "btrfs")
                (options "subvol=_live/@guix-root")
                (needed-for-boot? #t)
                (dependencies mapped-devices))
              (file-system
                (mount-point "/mnt/vault")
                (device "/dev/mapper/vault")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/home")
                (device "/dev/mapper/vault")
                (options "subvol=_live/@guix-home")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/code")
                (device "/dev/mapper/vault")
                (options "subvol=_live/@code")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/data")
                (device "/dev/mapper/vault")
                (options "subvol=_live/@data")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/work")
                (device "/dev/mapper/vault")
                (options "subvol=_live/@work")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/junkyard")
                (device "/dev/mapper/vault")
                (options "subvol=_live/@junkyard")
                (type "btrfs")
                (dependencies mapped-devices))
              %base-file-systems)))

  ;; fixme: take care of making this?
  ;; idem @btrfs subvol
  (swap-devices
   (if (equal? %host #:discovery)
       '()
       (list (swap-space
              (target "/mnt/vault/swap/swapfile")
              (dependencies (filter (file-system-mount-point-predicate "/mnt/vault")
                                    file-systems)))))))
