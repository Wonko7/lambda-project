(use-modules (gnu)
             (gnu packages)
             (gnu packages base)
             (gnu packages linux)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages shells)
             (gnu packages bash)
             (gnu packages networking)
             (gnu packages display-managers)
             (gnu packages xdisorg)
             (gnu packages suckless)
             (gnu packages fonts)
             (gnu system setuid)
             (gnu services desktop)
             (gnu services xorg)
             (gnu services sddm)
             (gnu services networking)
             (gnu services ssh)
             (guix build utils)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (guix gexp)
             (ice-9 format)
             (srfi srfi-1)
             (srfi srfi-11)
             (srfi srfi-88)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             ;; my stuff
             (defs)
             (spock)
             (crew)
             (fleet)
             (pkgs)
             (stateful-prelude))

(use-service-modules desktop networking ssh xorg)

(display (spock-say (string-append "building OS for " (ship-name %ship)))
         (current-error-port))
(newline (current-error-port))

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
;; helpers

(define (desktop? ship)
  (equal? (ship-class ship) 'desktop-laptop))

(define (ephemeral? ship)
  (equal? (ship-class ship) 'ephemeral))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; services

(define (ship->services ship) ;; also depends on %fleet and %wonko
  (let* ((fleet-desktop-base (list
                              (service bluetooth-service-type)
                              (service
                               slim-service-type
                               (slim-configuration
                                (display ":9")
                                (vt "vt9")
                                (auto-login? #t)
                                (default-user (crew-name %wonko))
                                (xorg-configuration (xorg-configuration
                                                     (keyboard-layout (crew-kb %wonko))))))
                              (service
                               slim-service-type
                               (slim-configuration
                                (display ":10")
                                (vt "vt10")
                                (auto-login? #t) ;; FIXME
                                (default-user (crew-name %tina))
                                (xorg-configuration (xorg-configuration
                                                     (keyboard-layout (crew-kb %tina))))))))

         (fleet-permanent-base (list (service guix-publish-service-type
                                              (guix-publish-configuration
                                               (host "0.0.0.0")
                                               (port 1337)
                                               (advertise? #t)))))

         (basic-networking-services (list
                                     (service network-manager-service-type)
                                     (service wpa-supplicant-service-type)))

         (lid-switch-action (if (ship-media-station? ship)
                                'ignore
                                'suspend))

         (fleet-base
          (cons*
           (simple-service 'fleet-hosts-entries hosts-service-type
                           (append
                            (fleet->hosts %fleet)
                            (list (host "192.168.1.9" "nispe.local"))))
           (service tor-service-type)
           (service openssh-service-type (openssh-configuration
                                          (authorized-keys
                                           `(("wonko" ,(local-file "data/ssh/yggdrasill.pub"))
                                             ("wonko" ,(local-file "data/ssh/enterprise.pub"))))
                                          (x11-forwarding? #t)
                                          (password-authentication? #f)))
           (extra-special-file "/etc/guix/channels.scm" (scheme-file "_" %channels))
           (extra-special-file
            "/usr/local/bin/make-default-btrfs-subvols"
            (program-file
             "make-default-btrfs-subvols"
             (with-imported-modules
                 '((spock)
                   ;;(guix utils)
                   ;;(ice-9 match)
                   (srfi srfi-1))
               #~(begin
                   (use-modules
                    (spock)
                    (ice-9 match))
                   (display
                    (spock-say "making BTRFS SUBVOLS on "))
                   (newline)
                   (let* ((args (program-arguments))
                          (sdX  (second args))
                          (subvols '("code" "data" "junkyard" "work"))
                          (btrfs #$(file-append btrfs-progs "/bin/btrfs"))
                          (mkdir #$(file-append coreutils "/bin/mkdir"))
                          (mk-dirs (lambda (x)
                                     x)))
                     ;; (map mk-dirs subvols)
                     ;; (map mk-subvols subvols)
                     (display
                      (format #t "~a\n" args))
                     (display
                      (format #t "~a\n" (second args))))))))
           (modify-services (if (desktop? ship)
                                (modify-services %desktop-services
                                  (delete gdm-service-type)
                                  (elogind-service-type config =>
                                   (elogind-configuration
                                    (handle-power-key 'ignore) ;; FIXME: 'hibernate?
                                    (handle-lid-switch lid-switch-action)
                                    (handle-lid-switch-docked  lid-switch-action)
                                    (handle-lid-switch-external-power lid-switch-action))))
                                %base-services)
             (guix-service-type config =>
                                (guix-configuration
                                 (discover? (not (ephemeral? ship)))
                                 (substitute-urls
                                  (append
                                   (if (ephemeral? ship)
                                       (map (lambda (s) ;; no discovery on discovery. heh.
                                              (string-append "http://"
                                                             (assoc-ref (ship-net s) 'local)
                                                             ":1337"))
                                            fleet)
                                       '())
                                   (list
                                    "https://substitutes.nonguix.org")
                                   %default-substitute-urls))
                                 (authorized-keys
                                  (append (list (local-file "./data/substitutes/yggdrasill.pub")
                                                (local-file "./data/substitutes/nonguix.pub"))
                                          %default-authorized-guix-keys))))

             (console-font-service-type
              config => (map (lambda (tty)
                               `(,tty
                                 . ,(file-append font-terminus "/share/consolefonts/ter-132n")))
                             '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))))))

    (cond ((desktop? ship)   (append fleet-base fleet-permanent-base fleet-desktop-base))
          ((ephemeral? ship) (append fleet-base basic-networking-services)))))

(define (ship->os ship);; also depends on %crew & %wonko
  (operating-system
    (locale "en_GB.utf8")
    (timezone "Europe/Paris")
    (keyboard-layout (ship-kb ship))

    (kernel linux)
    (kernel-arguments '("net.ifnames=0" "biosdevname=0"))
    (initrd microcode-initrd)
    (firmware (list linux-firmware))
    (bootloader
     (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (targets '("/boot"))
      (keyboard-layout keyboard-layout)))

    (host-name (ship-name ship))
    (issue (string-append (spock-say "live long & prosper!") "\n   o===8 ["
                          (ship-name ship)
                          "] project-lambda / GNU Guix / Fat Cock Enthusiaste 8===o\n\n"))

    (users (map crew->user-account %crew))

    (packages (append %xfce-world ;; FIXME put this in Tina's world
                      %utils-world
                      %os-disk-world
                      %os-net-world
                      %os-misc-world
                      %base-packages))

    (services (ship->services ship))

    (setuid-programs
     (cons*
      ;; FIXME dumpcap? ping?
      (setuid-program (program (file-append (@ (gnu packages linux) brightnessctl)
                                            "/bin/brightnessctl")))
      %setuid-programs))

    (mapped-devices
     (if (ephemeral? ship)
         '()
         (list (mapped-device
                (source (uuid (assoc-ref (ship-uuids ship) 'vault)))
                (target "vault")
                (type luks-device-mapping)))))

    (file-systems
     (if (ephemeral? ship)
         %base-file-systems
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
            (list (file-system
                    (mount-point "/boot")
                    (device (uuid (assoc-ref (ship-uuids ship) 'efi)
                                  'fat32))
                    (type "vfat"))
                  (file-system
                    (mount-point "/mnt/vault")
                    (device "/dev/mapper/vault")
                    (type "btrfs")
                    (dependencies mapped-devices)))
            (map btrfs-vault-subvol
                 `(("/" . "guix-root")
                   ("/home" . "guix-home")
                   ("/code" . "code")
                   ("/data" . "data")
                   ("/work" . "work")
                   ("/junkyard" . "junkyard")))
            %base-file-systems))))

    ;; FIXME: take care of making this? idem @btrfs subvol
    (swap-devices
     (if (ephemeral? ship)
         '()
         (list (swap-space
                (target "/mnt/vault/swap/swapfile")
                (dependencies (filter (file-system-mount-point-predicate "/mnt/vault")
                                      file-systems))))))))

(ship->os %ship)
