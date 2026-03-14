(define-module (wonko systems rocinante)
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
  #:export (%rocinante-os))

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
             #$xrandr "/bin/xrandr --dpi 96;"
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1;"
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.8"))))))))

(define %wonko-home
  (home-environment
   (inherit %vanilla-wonko-home)
   (services
    (append
     machine-home-services
     %vanilla-wonko-services))))

(define %media-station-home
  (home-environment
    (inherit %media-station-home)
    (services
     (append
      machine-home-services
      %media-station-home-services))))

(define %rocinante-os
  (operating-system

    (inherit %laptop-os)
    (host-name "rocinante")
    (locale "fr_FR.utf8")
    (kernel-arguments (append '("resume_offset=5591216")
                              (operating-system-user-kernel-arguments %laptop-os)))

    (services
     (cons*
      ;; homes
      (service guix-home-service-type
               `((,(crew-name %tina)  ,%tina-home)
                 (,(crew-name %wonko) ,%wonko-home)
                 (,(crew-name %media) ,%media-station-home)))
      ;; kbd
      (service kmonad-service-type kmonad-fr-laptop-config)
      (service kmonad-service-type kmonad-ergodox-config)
      (service kmonad-service-type kmonad-bullshit-config)
      ;; X
      (service slim-service-type
               (slim-configuration
                 (display ":10")
                 (vt "vt10")
                 (auto-login? #t)
                 (default-user (crew-name %tina))
                 (xorg-configuration (xorg-configuration
                                       (keyboard-layout %fr-kb))))) ;; FIXME
      (service xfce-desktop-service-type)
      (service noautostart-slim-service-type wonko-slim-config)
      (service noautostart-slim-service-type media-station-slim-config)
      ;; net : NetworkManager and its applet.
      (service network-manager-service-type)
      (service wpa-supplicant-service-type)
      (simple-service 'network-manager-applet
                      profile-service-type
                      (list network-manager-applet))
      (service wireguard-service-type
               (wireguard-configuration
                 (inherit %star-fleet-client-config)
                 (addresses (net-peer-addr-to/24 %rocinante-net-peer))))

      %laptop-services))

    (mapped-devices
     (list (mapped-device
             (source (uuid "ec7a9b12-4611-469c-8a6f-aadf4d525d5e"))
             (target "vault")
             (type luks-device-mapping)
             (arguments '(#:key-file "/root/keys-to-the-kingdom.bin")))))
    (file-systems (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "918C-B182"
                                   'fat32))
                     (type "vfat"))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))
    (swap-devices
     (list (make-default-swap file-systems)))))

%wonko-home
%rocinante-os
