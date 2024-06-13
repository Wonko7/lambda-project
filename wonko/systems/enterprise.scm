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

(define %enterprise-wonko-home
  (home-environment
   (inherit %media-station-wonko-home)
   (services
    (cons*
     (simple-service
      'config-files
      home-files-service-type
      `((".config/x-config/ship.xmodmap"
         ,(local-file
           (string-append %lambda-project "/misc/enterprise.xmodmap")))
        (".x-config"
         ,(program-file
           "x-config"
           (cmd+arg->script
            `((xrandr . "--dpi 96")
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1")
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7")))))))
     %media-station-wonko-services))))

(operating-system
  (inherit %media-station-os)
  (host-name "enterprise")
  (services (cons* (service slim-service-type wonko-slim-config)
                   (service guix-home-service-type
                            `(("wonko" ,%enterprise-wonko-home)))
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
                   (file-system
                     (mount-point "/tmp")
                     (device "none")
                     (type "tmpfs")
                     (check? #f))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))))
