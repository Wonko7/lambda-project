(use-modules (gnu)
             (gnu services shepherd)
             (gnu services desktop)
             (gnu services xorg)
             (gnu services sddm)
             (gnu services networking)
             (gnu services ssh)
             (gnu services guix)
             (gnu home)
             (gnu home services)
             (gnu home services shepherd)
             (gnu home services shells)
             (guix build utils)
             (guix gexp)
             (ice-9 format)
             (ice-9 match)
             (srfi srfi-1)
             (srfi srfi-11)
             (srfi srfi-88)
             ;; my stuff
             (wonko defs)
             (wonko crew)
             (wonko fleet)
             (wonko dotfiles)
             (wonko xorg)
             (wonko homes)
             (wonko systems))

(use-package-modules xorg)

(define %yggdrasill-wonko-home
  (home-environment
   (inherit %highdpi-wonko-home)))

(operating-system
  (inherit %laptop-os)
  (host-name "rocinante")
  (services (cons* (service slim-service-type wonko-slim-config)
                   (service guix-home-service-type
                            `(("wonko" ,%yggdrasill-wonko-home)))
                   %laptop-services))
  (mapped-devices
   (list (mapped-device
          (source (uuid "077c1391-b290-4921-ae90-f8e3cec68113"))
          (target "vault")
          (type luks-device-mapping))))

  (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                            (make-vault-subvolume args mapped-devices))))
                  (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "77DE-0AE2"
                                   'fat32))
                     (type "vfat"))
                   (file-system
                     (mount-point "/mnt/vault")
                     (device "/dev/mapper/vault")
                     (type "btrfs")
                     (dependencies mapped-devices))
                   (file-system
                     (mount-point "/tmp")
                     (device "none")
                     (type "tmpfs")
                     (check? #f))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))))
