(define-module (wonko systems yggdrasill)
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
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-88)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko dotfiles)
  #:use-module (wonko xorg)
  #:use-module (wonko homes)
  #:use-module (wonko systems)
  #:export (%yggdrasill-wonko-home
            %yggdrasill-os))

(use-package-modules xorg)

(define %yggdrasill-wonko-home
  (home-environment
   (inherit %highdpi-wonko-home)
   (services
    (cons*
     (simple-service
      'config-files
      home-files-service-type
      `((".config/x-config/ship.xmodmap"
         ,(local-file
           (string-append %lambda-project "/misc/yggdrasill.xmodmap")))
        (".x-config"
         ,(program-file
           "x-config"
           (cmd+arg->script
            `((xrandr . "--dpi 288")
              (xinput . "set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Click Method Enabled' 0 1")
              (xinput . "set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Accel Speed' 1.0")))))))
     %highdpi-wonko-services))))

(define %yggdrasill-os
  (operating-system
    (inherit %removable-laptop-os) ;; internal drive but EFI discovery is wonky
    (host-name "yggdrasill")
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
                     (append
                      (make-vault-subvolumes mapped-devices)
                      %base-file-systems))))))

%yggdrasill-wonko-home
%yggdrasill-os
