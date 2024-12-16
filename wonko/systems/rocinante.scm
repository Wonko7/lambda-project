(define-module (wonko systems rocinante)
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
  #:export (%rocinante-wonko-home
            %rocinante-os))

(use-package-modules xorg)

(define %rocinante-wonko-home
  (home-environment
   (inherit %media-station-wonko-home)
   (services
    (cons*
     (simple-service
      'config-files
      home-files-service-type
      `((".config/x-config/ship.xmodmap"
         ,(local-file
           (string-append %lambda-project "/misc/rocinante.xmodmap")))
        (".x-config"
         ,(program-file
           "x-config"
           (cmd+arg->script
            `((xrandr . "--dpi 96")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 0.7")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Enabled' 1")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Drag Lock Enabled' 1")))))))
     %media-station-wonko-services))))

(define %rocinante-os
  (operating-system
    (inherit %media-station-os)
    (host-name "rocinante")
    (services (cons* (service slim-service-type
                              (slim-configuration
                               (display ":10")
                               (vt "vt10")
                               (auto-login? #t)
                               (default-user (crew-name %tina))
                               (xorg-configuration (xorg-configuration
                                                    (keyboard-layout (crew-kb %tina))))))
                     (service noautostart-slim-service-type wonko-slim-config)
                     (service guix-home-service-type
                              `(("wonko" ,%rocinante-wonko-home)
                                ("tina" ,%tina-home)))
                     %media-station-services))
    (mapped-devices
     (list (mapped-device
            (source (uuid "ec7a9b12-4611-469c-8a6f-aadf4d525d5e"))
            (target "vault")
            (type luks-device-mapping))))

    (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                              (make-vault-subvolume args mapped-devices))))
                    (cons*
                     (file-system
                       (mount-point "/boot")
                       (device (uuid "918C-B182"
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

%rocinante-wonko-home
%rocinante-os
