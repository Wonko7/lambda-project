(define-module (wonko systems enterprise)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services shells)
  #:use-module (gnu system privilege)
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
  #:use-module (wonko services networking)
  #:use-module (wonko bootloader grub)
  #:export (%enterprise-os))

(use-package-modules xorg xdisorg)
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
             " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7"))))))))

(define %wonko-home
  (home-environment
    (inherit %vanilla-wonko-home)
    (services
     (append
      (list %dance-commander-shepherd-service)
      machine-home-services
      %vanilla-wonko-services))))

(define %media-station-home
  (home-environment
    (inherit %media-station-home)
    (services
     (append
      machine-home-services
      %media-station-home-services))))

(define %enterprise-os
  (operating-system

    (inherit %laptop-os)
    (host-name "enterprise")
    (bootloader
     (bootloader-configuration
      (bootloader   my-grub-efi-bootloader)
      (targets      '("/boot"))
      (extra-initrd "/_live/@guix-root/root/keys-to-the-kingdom.cpio")))
    (kernel-arguments (append '("resume_offset=5841087")
                              (operating-system-user-kernel-arguments %laptop-os)))

    (services
     (cons*
      (service slim-service-type (slim-configuration
                                   (inherit wonko-slim-config)
                                   (xorg-configuration amdgpu-xorg-config)))
      (service noautostart-slim-service-type (slim-configuration
                                               (inherit media-station-slim-config)
                                               (xorg-configuration amdgpu-xorg-config)))
      (service guix-home-service-type
               `((,(crew-name %wonko) ,%wonko-home)
                 (,(crew-name %media) ,%media-station-home)))
      (service kmonad-service-type kmonad-laptop-config)
      (service kmonad-service-type kmonad-ergodox-config)
      (service kmonad-service-type kmonad-bullshit-config)
      (service screen-locker-service-type
               (screen-locker-configuration
                 (name "xscreensaver")
                 (program (file-append xscreensaver
                                       "/libexec/xscreensaver/xscreensaver-auth"))
                 (allow-empty-password? #f)))


      (service dhcpcd-service-type (dhcpcd-configuration))
      (service iwd-service-type (iwd-configuration
                                  (interfaces '("wlan0"))))
      (service wireguard-service-type
               (wireguard-configuration
                 (inherit %star-fleet-client-config)
                 (addresses (net-peer-addr-to/24 %enterprise-net-peer))))
      (simple-service 'azirevpn-service
                      shepherd-root-service-type
                      azirevpn-fr-service)
      (simple-service 'wait-for-wan-service
                      shepherd-root-service-type
                      wait-for-wan-service)

      (modify-services %laptop-services
        (delete wpa-supplicant-service-type)
        (delete network-manager-service-type))))

    (mapped-devices
     (list (mapped-device
            (source (uuid "125bf330-ff27-45d1-9cce-1dd96cb14975"))
            (target "vault")
            (type luks-device-mapping)
            (arguments '(#:key-file "/root/keys-to-the-kingdom.bin")))))
    (file-systems (cons*
                   (file-system
                     (mount-point "/boot")
                     (device (uuid "6C21-E416"
                                   'fat32))
                     (type "vfat"))
                   (append
                    (make-vault-subvolumes mapped-devices)
                    %base-file-systems)))
    (swap-devices
     (list (make-default-swap file-systems)))))

%wonko-home
%enterprise-os
