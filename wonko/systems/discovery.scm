(define-module (wonko systems discovery)
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
  #:use-module (wonko services xorg)
  #:use-module (wonko homes)
  #:use-module (wonko systems)
  #:export (%discovery-wonko-home
            %discovery-os))

(use-package-modules xorg)

(define %discovery-wonko-home
  (home-environment
   (inherit %vanilla-wonko-home)
   (services
    (cons*
     (simple-service
      'config-files
      home-files-service-type
      `((".x-config"
         ,(program-file
           "x-config"
           (cmd+arg->script
            `((xrandr . "--dpi 96")
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1")
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7")))))))
     %vanilla-wonko-services))))

(define %discovery-os
  (operating-system
    (inherit %removable-laptop-os)
    (host-name "discovery")
    (services (cons* (service noautostart-slim-service-type wonko-slim-config)
                     (service guix-home-service-type
                              `(("wonko" ,%discovery-wonko-home)))
                     %laptop-services))
    (mapped-devices
     (list (mapped-device
            (source (uuid "125bf330-ff27-45d1-9cce-1dd96cb14975"))
            (target "vault")
            (type luks-device-mapping))))

    (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                              (make-vault-subvolume args mapped-devices))))
                    (cons*
                     (file-system
                       (mount-point "/boot")
                       (device (uuid "6C21-E416"
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

%discovery-wonko-home
