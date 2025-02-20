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
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko dotfiles)
  #:use-module (wonko homes)
  #:use-module (wonko systems)
  #:use-module (wonko services xorg)
  #:use-module (wonko services kmonad)
  #:export (%rocinante-os))

(use-package-modules xorg)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".x-config"
       ,(program-file
         "x-config"
         #~(begin
             (system
              (string-append
               #$setxkbmap "/bin/setxkbmap -option compose:ralt us;"
               #$xrandr "/bin/xrandr --dpi 96;"
               #$xinput "/bin/xinput"
               " set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1;"
               #$xinput "/bin/xinput"
               " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7")))))))))

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

(define %rocinante-os
  (operating-system
    (inherit %laptop-os)
    (host-name "rocinante")
    (locale "fr_FR.utf8")
    (services (cons* (service slim-service-type
                              (slim-configuration
                               (display ":10")
                               (vt "vt10")
                               (auto-login? #t)
                               (default-user (crew-name %tina))
                               (xorg-configuration (xorg-configuration
                                                    (keyboard-layout %fr-kb))))) ;; FIXME
                     (service noautostart-slim-service-type wonko-slim-config)
                     (service noautostart-slim-service-type media-station-slim-config)
                     (service guix-home-service-type
                              `((,(crew-name %tina)  ,%tina-home)
                                (,(crew-name %wonko) ,%wonko-home)
                                (,(crew-name %media) ,%media-station-home)))
                     (service kmonad-service-type kmonad-fr-laptop-config)
                     (service kmonad-service-type kmonad-ergodox-config)
                     (service kmonad-service-type kmonad-bullshit-config)
                     %laptop-services))
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

%wonko-home
%rocinante-os
