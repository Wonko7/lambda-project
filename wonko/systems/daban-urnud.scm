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

(define %daban-urnud-wonko-home
  (home-environment
   (inherit %vanilla-wonko-home)
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
            `((xrandr . "--dpi 96") ;; FIXME this is tmp:
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1")
              (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7")))))))
     %vanilla-wonko-services))))

(operating-system
  (inherit %laptop-os)
  (host-name "daban-urnud")
  (services (cons* (service noautostart-slim-service-type wonko-slim-config)
                   (service guix-home-service-type
                            `(("wonko" ,%daban-urnud-wonko-home)))
                   %laptop-services))
  (mapped-devices
   (list (mapped-device
          (source (uuid "0a59dd11-43cf-4043-bcb6-932ad861fb2b"))
          (target "vault")
          (type luks-device-mapping))))

  (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                            (make-vault-subvolume args mapped-devices))))
                  (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "D4BC-780D"
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
