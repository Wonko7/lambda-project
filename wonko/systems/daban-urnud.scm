(define-module (wonko systems daban-urnud)
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
  #:export (%daban-urnud-os))

(use-package-modules xorg)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".config/x-config/ship.xmodmap"
       ,(local-file
         (string-append %lambda-project "/misc/enterprise.xmodmap")))
      (".x-config"
       ,(program-file
         "x-config"
         #~(system
            (string-append
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1;"
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7"))))))))

(define %wonko-home
  (home-environment
   (inherit %vanilla-wonko-home)
   (services
    (append
     machine-home-services
     %vanilla-wonko-services))))

(define %media-station-home
  (home-environment
   (inherit %media-station-wonko-home)
   (services
    (append
     machine-home-services
     %media-station-wonko-services))))

(define %daban-urnud-os
  (operating-system
    (inherit %laptop-os)
    (host-name "daban-urnud")
    (services (cons* (service slim-service-type wonko-slim-config)
                     (service slim-service-type media-station-slim-config)
                     (service guix-home-service-type
                              `((,(crew-name %wonko) ,%wonko-home)
                                (,(crew-name %media) ,%media-station-home)))
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
                      %base-file-systems))))))

%wonko-home
%daban-urnud-os
