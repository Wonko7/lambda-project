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
                    %base-file-systems)))))
