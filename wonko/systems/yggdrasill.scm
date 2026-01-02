(define-module (wonko systems yggdrasill)
  #:use-module (gnu)
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
  #:export (%yggdrasill-os))

(use-package-modules xorg)
(use-service-modules
 desktop xorg sddm
 networking ssh vpn
 guix shepherd)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".x-config"
       ,(program-file
         "x-config"
         #~(system
            (string-append
             #$setxkbmap "/bin/setxkbmap -option compose:ralt us;"
             #$xrandr "/bin/xrandr --dpi 288;"
             #$xinput "/bin/xinput"
             " set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Click Method Enabled' 0 1;"
             #$xinput "/bin/xinput"
             " set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Accel Speed' 1.0"))))))))

(define %wonko-home
  (home-environment
    (inherit %vanilla-wonko-home)
    (services
     (append
      (list %dance-commander-shepherd-service)
      machine-home-services
      %highdpi-wonko-services))))

(define %media-station-home
  (home-environment
    (inherit %media-station-wonko-home)
    (services
     (append
      machine-home-services
      %media-station-wonko-services))))

(define %yggdrasill-os
  (operating-system

    (inherit %removable-laptop-os) ;; internal drive but EFI discovery is wonky
    (host-name "yggdrasill")
    (kernel-arguments (append '("resume_offset=93852928")
                              (operating-system-user-kernel-arguments %laptop-os)))

    (services (cons* (service slim-service-type wonko-slim-config)
                     (service noautostart-slim-service-type media-station-slim-config)
                     (service guix-home-service-type
                              `((,(crew-name %wonko) ,%wonko-home)
                                (,(crew-name %media) ,%media-station-home)))
                     (service kmonad-service-type kmonad-laptop-config)
                     (service kmonad-service-type kmonad-ergodox-config)
                     (service kmonad-service-type kmonad-bullshit-config)

                     (service wireguard-service-type
                              (wireguard-configuration
                                (addresses '("10.42.0.2/24"))
                                (peers
                                 (list
                                  (wireguard-peer
                                    (name "sly")
                                    (public-key "U7UZuuT33d22P8lRCcvF8RbS1/PKhBQUeYhyOhmVoGY=")
                                    (endpoint "[2a01:e0a:b5a:de71::1]:51820")
                                    (allowed-ips '("0.0.0.0/0"))
                                    (keep-alive 60))))))

                     %laptop-services))

    (mapped-devices
     (list (mapped-device
             (source (uuid "077c1391-b290-4921-ae90-f8e3cec68113"))
             (target "vault")
             (type luks-device-mapping)
             (arguments '(#:key-file "/root/keys-to-the-kingdom.bin")))))
    (file-systems (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "77DE-0AE2"
                                   'fat32))
                     (type "vfat"))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))
    (swap-devices
     (list (make-default-swap file-systems)))))

%wonko-home
%yggdrasill-os
