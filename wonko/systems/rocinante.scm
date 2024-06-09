(use-modules ;; (gnu services)
             (gnu services shepherd)
             (gnu services desktop)
             (gnu services xorg)
             (gnu services sddm)
             (gnu services networking)
             (gnu services ssh)
             (gnu home services)
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
             (wonko homes)
             (wonko systems))

(define %rocinante-wonko-home
  (home-environment
   (inherit %wonko-home)
   (services
    (cons*
     (service
      home-bash-service-type
      (home-bash-configuration
       (inherit %wonko-bash-config)
       (environment-variables
        (cons*
         ("GDK_SCALE" . "1")
         ("GDK_DPI_SCALE" . "1")
         %wonko-env))))
     (simple-service
      'config-files
      home-files-service-type
      `((".x-config"
         ,(program-file
           "x-config"
           (cmd+arg->script
            `((xrandr . "--dpi 96")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 0.7")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Enabled' 1")
              (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Drag Lock Enabled' 1")))))
        ;; package this better;
        (".config/feh/themes"
         ,(let ((fsz "15"))
            (mixed-text-file
             "feh_symlink_name_is_theme_name"
             "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
             " --fontpath " "/home/wonko/.guix-home/profile/share/fonts/truetype/"
             " --menu-font JetBrainsMono-Regular/" fsz
             " --font JetBrainsMono-Regular/" fsz "\n")))
        (".config/x-config/ship.xmodmap"
         ,(local-file
           (string-append %lambda-project "/misc/rocinante.xmodmap"))) ;; FIXME
        (".Xresources"
         ,(plain-file "Xresources" (xresources-configuration %font 10)))
        (".config/picom/picom.conf"
         ,(plain-file "picom.conf" (picom-configuration 10)))
        (".config/dunst/dunstrc"
         ,(plain-file "dunstrc"
                      (dunst-configuration
                       %font
                       12)))))

     %wonko-services))))

(operating-system
  (inherit %laptop-os)
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
                   (list
                    (service guix-home-service-type
                             `(("wonko" ,%rocinante-wonko-home)
                               ("tina" ,%tina-home)))
                    %laptop-services))

  (mapped-devices
   (list (mapped-device
          (source (uuid "f5b4b690-2701-4b25-b009-ae1af0d31b39"))
          (target "vault")
          (type luks-device-mapping))))
  (file-systems
   (cons* (file-system
            (mount-point "/boot")
            (device (uuid (assoc-ref (ship-uuids ship) 'efi)
                          'fat32))
            (type "vfat"))
          %laptop-fstab)))
