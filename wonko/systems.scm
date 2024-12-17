(define-module (wonko systems)
  #:use-module (gnu)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (guix channels)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-88)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nongnu packages firmware)
  #:use-module (gnu system setuid)
  #:use-module (gnu packages package-management)
  #:use-module (guix channels)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko spock)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko pkgs)
  #:use-module (wonko xorg)
  #:export (%laptop-os
            wonko-slim-config
            %laptop-services
            %laptop-fstab))


(use-service-modules dbus shepherd xorg sddm desktop networking ssh xorg)
(use-package-modules base linux emacs emacs-xyz shells bash networking display-managers xdisorg suckless fonts)

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
   (channel
    (name 'w7)
    (url "https://gitlab.com/wonko7/w7-guix-channel")
    (introduction
     (make-channel-introduction
      "e6afee0a2c3e941e186b2a9035c0217e5e94e9d5"
      (openpgp-fingerprint
       "FF23 0627 4DFE CF36 3AD8  677C 613C 8B66 6DBE 0AEB"))))
   %default-channels))

(define %channels ;; this is pinned, generated with `guix describe -f channels`
  (list (channel
         (name 'nonguix)
         (url "https://gitlab.com/nonguix/nonguix")
         (branch "master")
         (commit
          "10e3c2bcaedaba121eec0e255d366a080082cf0a")
         (introduction
          (make-channel-introduction
           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
           (openpgp-fingerprint
            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
         (name 'w7)
         (url "https://gitlab.com/wonko7/w7-guix-channel")
         (branch "master")
         (commit
          "069aba5ac5b306d29435f1882a10dce825404dc1")
         (introduction
          (make-channel-introduction
           "e6afee0a2c3e941e186b2a9035c0217e5e94e9d5"
           (openpgp-fingerprint
            "FF23 0627 4DFE CF36 3AD8  677C 613C 8B66 6DBE 0AEB"))))
        (channel
         (name 'guix)
         (url "https://git.savannah.gnu.org/git/guix.git")
         (branch "master")
         (commit
          "942942ee75542e684baaccdd26372cfa6e2bc2a2")
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
;; services

(define-public wonko-slim-config
  (slim-configuration
   (display ":9")
   (vt "vt9")
   (auto-login? #t)
   (default-user (crew-name %wonko))
   (xorg-configuration (xorg-configuration
                        (keyboard-layout (crew-kb %wonko))))))

(define-public media-station-slim-config
  (slim-configuration
   (display ":11")
   (vt "vt11")
   (auto-login? #f)
   (default-user (crew-name %media))
   (xorg-configuration (xorg-configuration
                        (keyboard-layout (crew-kb %media))))))

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

   (modify-services %desktop-services
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

(define-public %laptop-os
  (operating-system
    (locale "en_GB.utf8")
    (timezone "Europe/Paris")
    (keyboard-layout %dvorak-kb)

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
    (users (map crew->user-account %crew))

    (packages (append
               %git-world
               %utils-world
               %os-disk-world
               %os-net-world
               %os-misc-world
               %os-nonfree
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
      (keyboard-layout %dvorak-kb)))))

(define-public %uskb-removable-laptop-os
  (operating-system
    (inherit %laptop-os)
    (keyboard-layout %dvorak-kb)
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
      (keyboard-layout %dvorak-kb)))))

(define-public %media-station-services
  (modify-services %laptop-services
                   (elogind-service-type config =>
                                         (elogind-configuration
                                          (handle-power-key 'ignore) ;; FIXME: 'hibernate?
                                          (handle-lid-switch 'ignore)
                                          (handle-lid-switch-docked 'ignore)
                                          (handle-lid-switch-external-power 'ignore)))))

(define-public %media-station-os
  (operating-system
   (inherit %laptop-os)
   (services %media-station-services)))

;; FIXME: add media station stuff.
