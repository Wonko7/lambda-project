(define-module (wonko systems)
  #:use-module (gnu)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (guix channels)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (guix monads)
  #:use-module (guix store)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nongnu packages firmware)
  #:use-module (gnu system setuid)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko spock)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko pkgs)
  #:use-module (wonko services xorg)
  #:use-module (wonko services file-sharing)
  #:export (%laptop-os
            wonko-slim-config
            %laptop-services
            %laptop-fstab))

(use-service-modules dbus shepherd xorg sddm desktop networking ssh xorg
                     file-sharing)
(use-package-modules base linux
                     emacs emacs-xyz shells bash
                     networking display-managers xdisorg suckless fonts
                     ;; guix dev deps:
                     package-management gnupg)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; channels

(define %channels ;; this will pull latest
  (cons*
   (channel
    (name 'nonguix)
    (url "https://gitlab.com/nonguix/nonguix")
    (introduction
     (make-channel-introduction
      "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
      (openpgp-fingerprint
       "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
   %default-channels))

(define %channels ;; this is pinned, generated with `guix describe -f channels`
  (list (channel
         (name 'nonguix)
         (url "https://gitlab.com/nonguix/nonguix")
         (branch "master")
         (commit
          "ac1f7b074ea47e8a330e3475732c2e905928df35")
         (introduction
          (make-channel-introduction
           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
           (openpgp-fingerprint
            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
         (name 'guix-forge)
         (url "https://git.systemreboot.net/guix-forge/")
         (branch "main")
         (commit
          "bcb3e2353b9f6b5ac7bc89d639e630c12049fc42")
         (introduction
          (make-channel-introduction
           "0432e37b20dd678a02efee21adf0b9525a670310"
           (openpgp-fingerprint
            "7F73 0343 F2F0 9F3C 77BF  79D3 2E25 EE8B 6180 2BB3"))))
        (channel
         (name 'guix)
         (url "https://git.savannah.gnu.org/git/guix.git")
         (branch "master")
         (commit
          "f9726d5498e63a433fdd3398a4439089072482d5")
         (introduction
          (make-channel-introduction
           "9edb3f66fd807b096b48283debdcddccfea34bad"
           (openpgp-fingerprint
            "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vault subvolumes

(define-public (make-vault-subvolumes mapped-devices)
  (map (lambda (args)
         (let-values (((mount-p sv-name) (car+cdr args)))
           (file-system
             (device "/dev/mapper/vault")
             (mount-point mount-p)
             (type "btrfs")
             (options (string-append "subvol=_live/@"
                                     sv-name))
             (needed-for-boot? (equal? "/" mount-p))
             (dependencies mapped-devices))))
       `(("/" . "guix-root")
         ("/home" . "guix-home")
         ("/code" . "code")
         ("/data" . "data")
         ("/work" . "work")
         ("/junkyard" . "junkyard"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; slim services:

(define-public wonko-slim-config
  (slim-configuration
   (display ":9")
   (vt "vt9")
   (auto-login? #t)
   (default-user (crew-name %wonko))
   ;; FIXME: this should break nothing, xsession does setxkbmap.
   (xorg-configuration (xorg-configuration
                        (keyboard-layout %us-kb)))
   ))

(define-public media-station-slim-config
  (slim-configuration
   (display ":11")
   (vt "vt11")
   (auto-login? #t)
   (default-user (crew-name %media))
   (xorg-configuration (xorg-configuration
                        (keyboard-layout %us-kb)))
   ))

;; (service noautostart-slim-service-type wonko-slim-config)
;; (service slim-service-type wonko-slim-config)
;; (service
;;     slim-service-type
;;     (slim-configuration
;;      (display ":10")
;;      (vt "vt10")
;;      (auto-login? #t)
;;      (default-user (crew-name %tina))
;;      (xorg-configuration (xorg-configuration
;;                           (keyboard-layout (crew-kb %tina))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extra-profiles-service:

(define (make-extra-profile-service-type profile-name)
  ;; The service that populates the system's profile---i.e.,
  ;; /run/current-system/profile-name.  It is extended by package lists.
  (define (packages->profile-entry packages)
    "Return a system entry for the profile containing PACKAGES."
    ;; XXX: 'mlet' is needed here for one reason: to get the proper
    ;; '%current-target' and '%current-target-system' bindings when
    ;; 'packages->manifest' is called, and thus when the 'package-inputs'
    ;; etc. procedures are called on PACKAGES.  That way, conditionals in those
    ;; inputs see the "correct" value of these two parameters.  See
    ;; <https://issues.guix.gnu.org/44952>.
    (mlet %store-monad ((_ (current-target-system)))
      (return `((,(string-append profile-name "-profile")
                 ,(profile
                   (content (packages->manifest packages))))))))
  (service-type (name (string->symbol
                       (string-append profile-name "-extra-profile")))
                (extensions
                 (list (service-extension system-service-type
                                          packages->profile-entry)))
                (compose concatenate)
                (extend append)
                (default-value '())
                (description
                 "This is @dfn{extra profile}, available as
@file{/run/gep/profile}.  It contains packages that you like.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; laptop services

(define-public %laptop-services
  (cons*
   (simple-service 'fwupd-polkit polkit-service-type (list fwupd-nonfree))

   (service bluetooth-service-type
            (bluetooth-configuration (auto-enable? #t)))

   (service guix-publish-service-type
            (guix-publish-configuration
             (host "0.0.0.0")
             (port 1337)
             (advertise? #t)))

   (simple-service 'fleet-hosts-entries hosts-service-type %fleet-hosts)

   (service openssh-service-type
            (openssh-configuration
             (authorized-keys
              (cons*
               (list
                "root"
                (local-file
                 (string-append %lambda-project
                                "/wonko/data/ssh/one-ring-to-rule-them-all.pub")))
               (append-map (lambda (u)
                             (map (lambda (hn)
                                    (list u (local-file
                                             (string-append %lambda-project
                                                            "/wonko/data/ssh/" hn ".pub"))))
                                  (cons "discovery" %fleet-names)))
                           '("wonko" "media"))))
             (x11-forwarding? #t)
             (password-authentication? #f)
             (permit-root-login #t)))

   (service tor-service-type)

   (service (make-extra-profile-service-type "comms")   %borked-comms-world)
   ;; I want this to be used rather than the old utils in extra-profiles
   ;; ... which is still a useful fallback, but isn't often updated.
   (service (make-extra-profile-service-type "utils")   (append
                                                         %dev-world
                                                         %git-world
                                                         %utils-world))
   (service (make-extra-profile-service-type "desktop") %desktop-world)
   (service (make-extra-profile-service-type "web")     %web-world)
   (service (make-extra-profile-service-type "img")     %image-edition-world)

   (modify-services
       %desktop-services
     (delete gdm-service-type)
     (console-font-service-type config => ;; TODO: separate services for highdpi?
                                (map (lambda (tty)
                                       `(,tty
                                         . ,(file-append font-terminus
                                                         "/share/consolefonts/ter-132n")))
                                     '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))
     (elogind-service-type config =>
                           (elogind-configuration
                            (handle-power-key 'ignore) ;; FIXME: 'hibernate?
                            (handle-lid-switch 'suspend)
                            (handle-lid-switch-docked  'suspend)
                            (handle-lid-switch-external-power 'suspend)))
     (guix-service-type config =>
                        (guix-configuration
                         (discover? #t)
                         (channels %channels)
                         (guix (guix-for-channels %channels))
                         (substitute-urls
                          (cons* "https://substitutes.nonguix.org"
                                 %default-substitute-urls))
                         (authorized-keys
                          (append
                           (map (lambda (hn)
                                  (local-file
                                   (string-append %lambda-project
                                                  "/wonko/data/substitutes/" hn ".pub")))
                                (cons "nonguix" %fleet-names))
                           %default-authorized-guix-keys)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; laptop-os and declinations

(define-public %laptop-os
  (operating-system
    (locale "en_GB.utf8")
    (timezone "Europe/Paris")
    (keyboard-layout %us-kb)

    (kernel linux)
    (kernel-arguments '("net.ifnames=0" "biosdevname=0"))
    (initrd microcode-initrd)
    (firmware (list linux-firmware))
    (bootloader
     (bootloader-configuration
      ;; choose wisely:
      ;; grub-efi-removable-bootloader =>
      ;;   use when installing on external device:
      ;;   expects /mnt/boot/efi to exist & be mounted
      ;; grub-efi-bootloader => for local machine
      ;;
      ;; (bootloader grub-efi-removable-bootloader)
      ;; (targets '("/mnt/tmp-efi/"))
      (bootloader grub-efi-bootloader)
      (targets    '("/boot"))
      (keyboard-layout keyboard-layout)))

    (host-name "discovery")
    (issue (string-append (spock-say "live long & prosper!") "\n\n"))
    (users (append (map crew->user-account %crew)
                   %base-user-accounts))

    (packages
     (append
      (map second (package-propagated-inputs guix)) ;; system wide guix dev deps.
      %git-world
      %utils-world
      %os-disk-world
      %os-net-world
      %os-misc-world
      %os-nonfree
      %xorg-world
      %base-packages))

    (services %laptop-services)

    (setuid-programs
     (cons*
      ;; FIXME dumpcap?
      (setuid-program (program (file-append (@ (gnu packages linux) brightnessctl)
                                            "/bin/brightnessctl")))
      %setuid-programs))

    (file-systems '())

    (swap-devices
     (list (swap-space
            (target "/mnt/vault/swap/swapfile")
            (dependencies (filter (file-system-mount-point-predicate "/mnt/vault")
                                  file-systems)))))))

(define-public %removable-laptop-os
  (operating-system
    (inherit %laptop-os)
    (bootloader
     (bootloader-configuration
      (bootloader grub-efi-removable-bootloader)
      (targets    '("/boot"))
      (keyboard-layout %us-kb)))))

(define-public %removable-laptop-os-init-from-external
  (operating-system
    (inherit %laptop-os)
    (bootloader
     (bootloader-configuration
      (bootloader grub-efi-removable-bootloader)
      (targets '("/mnt/tmp-efi/"))
      (keyboard-layout %us-kb)))))

(define-public %media-station-services
  (cons*
   (service noautostart-transmission-daemon-service-type
            (transmission-daemon-configuration
             (rpc-authentication-required? #f)
             (rpc-whitelist-enabled? #t)
             (rpc-host-whitelist (map (lambda (hn)
                                        (string-append hn ".local"))
                                      %fleet-names))
             (rpc-whitelist '("::1" "127.0.0.1" "192.168.1.*"))
             (umask #o000)
             (download-dir "/mnt/trantor/media/inbox")))
   (modify-services %laptop-services
     (elogind-service-type config =>
                           (elogind-configuration
                            (handle-power-key 'ignore) ;; FIXME: 'hibernate?
                            (handle-lid-switch 'ignore)
                            (handle-lid-switch-docked 'ignore)
                            (handle-lid-switch-external-power 'ignore))))))

(define-public %media-station-os
  (operating-system
    (inherit %laptop-os)
    (services %media-station-services)))

;; FIXME: add media station stuff.
