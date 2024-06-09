(define-module (lambda systems)
  #:use-modules (guix build utils)
  #:use-modules (guix gexp)
  #:use-modules (ice-9 format)
  #:use-modules (ice-9 match)
  #:use-modules (srfi srfi-1)
  #:use-modules (srfi srfi-11)
  #:use-modules (srfi srfi-88)
  #:use-modules (nongnu packages linux)
  #:use-modules (nongnu system linux-initrd)
  #:use-modules ;; my stuff
  #:use-modules (lambda defs)
  #:use-modules (lambda spock)
  #:use-modules (lambda crew)
  #:use-modules (lambda pkgs)
  #:use-modules (lambda xorg)
  #:export (laptop-os
            wonko-slim-config))


(use-service-modules shepherd xorg sddm desktop networking ssh xorg)
(use-package-modules base linux emacs emacs-xyz shells bash networking display-managers xdisorg suckless fonts)

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
                      (url "https://gitlab.com/wonko7/w7-guix-channel"))
                     (introduction
                      (make-channel-introduction
                       "e6afee0a2c3e941e186b2a9035c0217e5e94e9d5"
                       (openpgp-fingerprint
                        "FF23 0627 4DFE CF36 3AD8  677C 613C 8B66 6DBE 0AEB")))
                     %default-channels))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; services

(define wonko-slim-config (slim-configuration
                           (display ":9")
                           (vt "vt9")
                           (auto-login? #t)
                           (default-user (crew-name %wonko))
                           (xorg-configuration (xorg-configuration
                                                (keyboard-layout (crew-kb %wonko))))))
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

(define %laptop-services
  (cons*
   (service bluetooth-service-type
            (bluetooth-configuration (auto-enable? #t)))

   (extra-special-file "/etc/guix/channels.scm" (scheme-file "_" %channels))
   (service guix-publish-service-type
            (guix-publish-configuration
             (host "0.0.0.0")
             (port 1337)
             (advertise? #t)))

   (simple-service 'fleet-hosts-entries hosts-service-type
                   (list
                    (host "192.168.1.1" "daban-urnud.local")
                    (host "192.168.1.3" "yggdrasill.local")
                    (host "192.168.1.4" "rocinante.local")
                    (host "192.168.1.6" "enterprise.local")
                    (host "192.168.1.9" "nispe.local")))
   (service tor-service-type)
   (service openssh-service-type (openssh-configuration
                                  (authorized-keys
                                   `(("wonko" ,(local-file "data/ssh/rocinante.pub"))
                                     ("wonko" ,(local-file "data/ssh/yggdrasill.pub"))
                                     ("wonko" ,(local-file "data/ssh/enterprise.pub"))
                                     ("wonko" ,(local-file "data/ssh/discovery.pub"))))
                                  (x11-forwarding? #t)
                                  (password-authentication? #f)))

   (modify-services %desktop-services
     (delete gdm-service-type)
     (elogind-service-type config =>
                           (elogind-configuration
                            (handle-power-key 'ignore) ;; FIXME: 'hibernate?
                            (handle-lid-switch 'suspend)
                            (handle-lid-switch-docked  'suspend)
                            (handle-lid-switch-external-power 'suspend)))
     (guix-service-type config =>
                        (guix-configuration
                         (discover? #t)
                         (substitute-urls
                          (cons* "https://substitutes.nonguix.org"
                                 %default-substitute-urls))
                         (authorized-keys
                          (append
                           (list (local-file "./data/substitutes/enterprise.pub")
                                 (local-file "./data/substitutes/rocinante.pub")
                                 (local-file "./data/substitutes/yggdrasill.pub")
                                 (local-file "./data/substitutes/nonguix.pub"))
                           %default-authorized-guix-keys)))))))

(define-public %laptop-fstab
  ;; missing /boot !
  (let ((btrfs-vault-subvol (lambda (args)
                                 (let-values (((mount-p sv-name) (car+cdr args)))
                                   (file-system
                                     (device "/dev/mapper/vault")
                                     (mount-point mount-p)
                                     (type "btrfs")
                                     (options (string-append "subvol=_live/@"
                                                             sv-name))
                                     (needed-for-boot? (equal? "/" mount-p))
                                     (dependencies mapped-devices))))))
       (append
        (list ;; (file-system
              ;;   (mount-point "/boot")
              ;;   (device (uuid (assoc-ref (ship-uuids ship) 'efi)
              ;;                 'fat32))
              ;;   (type "vfat"))
              (file-system
                (mount-point "/mnt/vault")
                (device "/dev/mapper/vault")
                (type "btrfs")
                (dependencies mapped-devices))
              (file-system
                (mount-point "/tmp")
                (device "none")
                (type "tmpfs")
                (check? #f)))
        (map btrfs-vault-subvol
             `(("/" . "guix-root")
               ("/home" . "guix-home")
               ("/code" . "code")
               ("/data" . "data")
               ("/work" . "work")
               ("/junkyard" . "junkyard")))
        %base-file-systems)))

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
      ;; (bootloader grub-efi-bootloader)
      (bootloader grub-efi-bootloader)
      (targets    '("/boot"))
      (keyboard-layout keyboard-layout)))

    (host-name "discovery")
    (issue (string-append (spock-say "live long & prosper!") "\n   o===8 ["
                          (ship-name ship)
                          "] project-lambda / GNU Guix / Fat Cock Enthusiaste 8===o\n\n"))

    (users (map crew->user-account %crew))

    (packages (append
               %git-world
               %utils-world
               %os-disk-world
               %os-net-world
               %os-misc-world
               %base-packages))

    (services %laptop-services)

    (setuid-programs
     (cons*
      ;; FIXME dumpcap?
      (setuid-program (program (file-append (@ (gnu packages linux) brightnessctl)
                                            "/bin/brightnessctl")))
      %setuid-programs))

    (mapped-devices
     (list (mapped-device
            (source (uuid "f5b4b690-2701-4b25-b009-ae1af0d31b39"))
            (target "vault")
            (type luks-device-mapping))))

    (file-systems %laptop-fstab)

    (swap-devices
     (list (swap-space
             (target "/mnt/vault/swap/swapfile")
             (dependencies (filter (file-system-mount-point-predicate "/mnt/vault")
                                   file-systems)))))))
