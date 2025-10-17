(define-module (wonko systems enterprise)
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
  #:use-module (wonko bootloader grub)
  #:export (%enterprise-os))

(use-package-modules xorg)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".x-config"
       ,(program-file
         "x-config"
         #~(string-append
            #$setxkbmap "/bin/setxkbmap -option compose:ralt us;"
            #$xrandr "/bin/xrandr --dpi 96;"
            #$xinput "/bin/xinput"
            " set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1;"
            #$xinput "/bin/xinput"
            " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7")))))))

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

(define %enterprise-os
  (operating-system
    (inherit %laptop-os)
    ;; (keyboard-layout "us" "dvorak" #:options '("ctrl:nocaps"))
    (host-name "enterprise")
    (bootloader
      (bootloader-configuration
        (bootloader my-grub-efi-bootloader)
        (targets    '("/boot"))))
    (services
     (cons*
      (service slim-service-type wonko-slim-config)
      (service noautostart-slim-service-type media-station-slim-config)
      (service guix-home-service-type
               `((,(crew-name %wonko) ,%wonko-home)
                 (,(crew-name %media) ,%media-station-home)))
      (service kmonad-service-type kmonad-laptop-config)
      (service kmonad-service-type kmonad-ergodox-config)
      (service kmonad-service-type kmonad-bullshit-config)
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

%wonko-home
%enterprise-os
