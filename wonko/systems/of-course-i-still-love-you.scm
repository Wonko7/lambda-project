(define-module (wonko systems of-course-i-still-love-you)
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
  #:use-module (nongnu packages linux)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages)
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
  #:use-module (wonko services kmonad)
  #:use-module (wonko services xorg)
  #:export (%of-course-i-still-love-you-wonko-home
            %of-course-i-still-love-you-os))

(use-package-modules xorg)
(use-service-modules nfs)

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
             #$setxkbmap "/bin/setxkbmap -option compose:ralt us;"))))))))

(define %of-course-i-still-love-you-wonko-home
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

(define %of-course-i-still-love-you-os
  (operating-system
    (inherit %laptop-os)
    (kernel linux-lts)
    (host-name "of-course-i-still-love-you")
    (keyboard-layout %us-kb)
    (services
     (let ((xorg-cfg (xorg-configuration
                      (keyboard-layout %us-kb)
                      (modules (filter
                                (lambda (p)
                                  ;; remove amdgpu and non supported by current-system
                                  (and (not (equal? p xf86-video-amdgpu))
                                       (member (%current-system)
                                               (package-supported-systems p))))
                                %default-xorg-modules))
                      (extra-config '("Section \"Device\"\n"
                                      "  Option \"SWcursor\"\n"
                                      "  Identifier \"Card1\"\n"
                                      "EndSection\n")))))
       (cons*
        (service slim-service-type (slim-configuration
                                    (inherit wonko-slim-config)
                                    (xorg-configuration xorg-cfg)))
        (service slim-service-type (slim-configuration
                                    (inherit media-station-slim-config)
                                    (xorg-configuration xorg-cfg)
                                    (auto-login? #t)))
        (service guix-home-service-type
                 `((,(crew-name %wonko) ,%of-course-i-still-love-you-wonko-home)
                   (,(crew-name %media) ,%media-station-home)))
        (service kmonad-service-type kmonad-ergodox-config)
        (service kmonad-service-type kmonad-bullshit-config)
        ;; (service nfs-service-type
        ;;          (nfs-configuration
        ;;           (exports
        ;;            '(("/junkyard/media"
        ;;               "*(rw,sync,no_root_squash,no_subtree_check)")))))
        %media-station-services)))
    (mapped-devices
     (list (mapped-device
            (source (uuid "becf9b67-d7fc-4e3d-a334-1c684567c98c"))
            (target "vault")
            (type luks-device-mapping))))
    (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                              (make-vault-subvolume args mapped-devices))))
                    (cons*
                     (file-system
                       (mount-point "/boot")
                       (device (uuid "3073-DA9D"
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

%of-course-i-still-love-you-wonko-home
%of-course-i-still-love-you-os
