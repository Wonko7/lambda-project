(define-module (fleet)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu)
  #:use-module (gnu packages xorg)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  ;; my stuff
  #:use-module (defs)
  #:use-module (dotfiles)
  #:export (ship
            ship-name
            ship-net
            ship-class
            ship-media-station?
            ship-uuids
            ship-kb
            ship-grub
            ship-grub-target
            ship-font
            ship-wallpaper
            ship-x-config
            ship-gdk-scale
            ship-gdk-dpi-scale
            ship-feh-font-size
            ship-rxvt-font-size
            ship-picom-radius
            ship-dunst-width
            ship-dunst-font-size
            ship-emacs-font-size
            ship-emacs-divider-width
            ship-emacs-modeline-height
            ship-emacs-tag-height
            ship-emacs-tag-font-size
            ship-emacs-tag-radius
            ship-emacs-tag-padding
            ship-emacs-org-habit-preceding-days
            ship-emacs-org-agenda-tags-column))

(use-service-modules desktop networking ssh xorg)

(define-record-type* <ship>
  ship make-ship
  ship?
  this-ship
  ;; common
  (name ship-name (sanitize (check string?)))
  (media-station ship-media-station? (sanitize (check boolean?)))
  ;; os
  (net ship-net (sanitize (check list?)))
  (uuids ship-uuids (sanitize (check list?)))
  (class ship-class (sanitize (check symbol?))) ;; FIXME?
  (kb ship-kb (sanitize (check keyboard-layout?)))
  (grub ship-grub (sanitize (check bootloader?)))
  (grub-target ship-grub-target (sanitize (check list?)))
  ;; home
  (font ship-font (sanitize (check string?)))
  (wallpaper ship-wallpaper (sanitize (check string?)))
  (x-config ship-x-config (sanitize (check gexp?)))
  (dpi ship-dpi (sanitize (check number?)))
  (gdk-scale ship-gdk-scale (sanitize (check number?)))
  (gdk-dpi-scale ship-gdk-dpi-scale (sanitize (check number?)))
  (feh-font-size ship-feh-font-size (sanitize (check number?)))
  (rxvt-font-size ship-rxvt-font-size (sanitize (check number?)))
  (picom-radius ship-picom-radius (sanitize (check number?)))
  (dunst-width ship-dunst-width (sanitize (check number?)))
  (dunst-font-size ship-dunst-font-size (sanitize (check number?)))
  ;; emacs
  (emacs-font-size       ship-emacs-font-size       (sanitize (check number?)))
  (emacs-divider-width   ship-emacs-divider-width   (sanitize (check number?)))
  (emacs-modeline-height ship-emacs-modeline-height (sanitize (check number?)))
  (emacs-tag-height      ship-emacs-tag-height      (sanitize (check number?)))
  (emacs-tag-font-size   ship-emacs-tag-font-size   (sanitize (check number?)))
  (emacs-tag-radius      ship-emacs-tag-radius      (sanitize (check number?)))
  (emacs-tag-padding     ship-emacs-tag-padding     (sanitize (check number?)))
  (emacs-org-agenda-tags-column ship-emacs-org-agenda-tags-column
                                (sanitize (check number?)))
  (emacs-org-habit-preceding-days ship-emacs-org-habit-preceding-days
                                  (sanitize (check number?))))


(define-public %yggdrasill
  (ship
   (name "yggdrasill")
   (font %font)
   ;; os
   (class 'desktop-laptop)
   (media-station #f)
   (kb %dvorak-kb)
   (net `((wg42 . "10.42.0.3")
          (local . "192.168.1.3")))
   (uuids `((vault . "077c1391-b290-4921-ae90-f8e3cec68113")
            (efi . "77DE-0AE2")))
   (grub grub-efi-removable-bootloader)
   (grub-target '("/boot"))
   ;; home
   (wallpaper %wallpaper)
   (emacs-org-habit-preceding-days 47)
   (emacs-org-agenda-tags-column 80)
   (emacs-modeline-height 75)
   (emacs-divider-width 5)
   (emacs-font-size 80)
   (emacs-tag-height 0.47)
   (emacs-tag-font-size 4.9)
   (emacs-tag-radius 6)
   (emacs-tag-padding 4.0)
   (rxvt-font-size 8)
   (feh-font-size 20)
   (dunst-font-size 8)
   (dunst-width 175)
   (picom-radius 25)
   (gdk-scale 1)
   (gdk-dpi-scale 1.5)
   (dpi 288)
   (x-config
    (cmd+arg->script
     `((xrandr . "--dpi 288")
       (xinput . "set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Click Method Enabled' 0 1")
       (xinput . "set-prop 'DELL07E6:00 06CB:76AF Touchpad' 'libinput Accel Speed' 1.0"))))))

(define-public %rocinante
  (ship
   (inherit %yggdrasill)
   (name "rocinante")
   (media-station #f)
   ;; os
   (kb %fr-kb)
   (net `((wg42 . "10.42.0.4")
          (local . "192.168.1.4")))
   (uuids `((vault . "ec7a9b12-4611-469c-8a6f-aadf4d525d5e")
            (efi . "918C-B182")))
   (grub grub-efi-bootloader)
   (grub-target '("/boot"))
   ;; home
   (emacs-font-size 120)
   (emacs-divider-width 2)
   (emacs-modeline-height 40)
   (emacs-org-agenda-tags-column 78)
   (emacs-org-habit-preceding-days 43)
   (emacs-tag-height 0.95)
   (emacs-tag-font-size 11)
   (emacs-tag-radius 10)
   (emacs-tag-padding 15)
   (dunst-font-size 12)
   (dunst-width 300)
   (picom-radius 10)
   (dpi 96)
   (gdk-scale 1)
   (gdk-dpi-scale 1)
   (x-config
    (cmd+arg->script
     `((xrandr . "--dpi 96")
       (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 0.7")
       (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Enabled' 1")
       (xinput . "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Drag Lock Enabled' 1"))))))

(define-public %enterprise
  (ship
   (inherit %rocinante)
   (name "enterprise")
   (media-station #t)
   ;; os
   (kb %dvorak-kb)
   (net `((wg42 . "10.42.0.6")
          (local . "192.168.1.6")))
   (uuids `((vault . "125bf330-ff27-45d1-9cce-1dd96cb14975")
            (efi . "6C21-E416")))
   (grub grub-efi-bootloader)
   (grub-target '("/boot"))
   ;; home
   (x-config
    (cmd+arg->script
     `((xrandr . "--dpi 96")
       (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1")
       (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7"))))))

(define-public %discovery
  (ship
   (inherit %yggdrasill)
   (name "discovery")
   (media-station #f)
   (grub grub-efi-removable-bootloader)
   (grub-target '("/boot")) ;; think this through if you're initialising from another system
   (uuids `((vault . "f5b4b690-2701-4b25-b009-ae1af0d31b39")
            (efi . "4ACA-0700")))
   (net `((wg42 . "10.42.0.20") ;; should be ignored, not part of %fleet
          (local . "192.168.1.20")))))

(define-public %fleet (list %yggdrasill
                            %rocinante
                            %enterprise))

(define-public (hostname->ship hn)
  (if (not hn)
      #f
      (eval-string (string-append "%" hn))))

;; nispe .9
(define-public (fleet->hosts machines)
  "make /etc/hosts file with fleet IPs."
  ;; FIXME refactor this, can't be arsed right now
  (apply append
         (map (lambda (ship)
                (let ((ip-42 (assoc-ref (ship-net ship) 'wg42))
                      (ip-local (assoc-ref (ship-net ship) 'local))
                      (hostname (ship-name ship)))
                  (append (if ip-42
                              (list (host ip-42
                                          (string-append (ship-name ship) ".starfleet.local")))
                              '())
                          (if ip-local
                              (list (host ip-local
                                          (string-append (ship-name ship) ".local")))
                              '()))))
              machines)))
