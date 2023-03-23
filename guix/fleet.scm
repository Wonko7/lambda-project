(define-module (fleet)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages xorg)
  #:use-module (dotfiles)
  #:export (ship
            ship-name
            ship-font
            ship-wallpaper
            ship-x-config
            ship-gdk-scale
            ship-gdk-dpi-scale
            ship-st-font-size
            ship-dunst-font-size
            ship-emacs-font-size
            ship-emacs-modeline-height
            ;; ship-xsettingsd-config
            ))

(define-public %font "JetBrains Mono")
(define-public %wallpaper "/data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png")

(define (check predicate)
  (lambda (v)
    (if (predicate v)
        v
        (display (string-append "bad ship value : " v)))))

(define-record-type* <ship>
  ship make-ship
  ship?
  this-ship
  (name ship-name (sanitize (check string?)))
  (font ship-font (sanitize (check string?)))
  (wallpaper ship-wallpaper (sanitize (check string?)))
  ;; (xsettingsd-config ship-xsettingsd-config (sanitize (check string?)))
  (x-config ship-x-config (sanitize (check gexp?)))
  (dpi ship-dpi (sanitize (check number?)))
  (gdk-scale ship-gdk-scale (sanitize (check number?)))
  (gdk-dpi-scale ship-gdk-dpi-scale (sanitize (check number?)))
  (st-font-size ship-st-font-size (sanitize (check number?)))
  (dunst-font-size ship-dunst-font-size (sanitize (check number?)))
  (emacs-font-size ship-emacs-font-size (sanitize (check number?)))
  (emacs-modeline-height ship-emacs-modeline-height (sanitize (check number?))))

(define-public %yggdrasill
  (ship
   (name "yggdrasill")
   (font %font)
   (wallpaper %wallpaper)
   (emacs-modeline-height 5)
   (emacs-font-size 80)
   (st-font-size 8)
   (dunst-font-size 8)
   (gdk-scale 1)
   (gdk-dpi-scale 1.5)
   (dpi 288)
   (x-config
    (cmd+arg->script `((xrandr . "--dpi 288")
                       (xinput . "set-prop 14 'libinput Click Method Enabled' 0 1")
                       (xinput . "set-prop 14 'libinput Accel Speed' 1.0"))))))

;; wonko@rocinante ~$ xdpyinfo | grep -B2 resolution
;; screen #0:
;;   dimensions:    1920x1080 pixels (508x285 millimeters)
;;   resolution:    96x96 dots per inch

(define-public %rocinante
  (ship
   (inherit %yggdrasill)
   (name "rocinante")
   (emacs-font-size 120)
   (emacs-modeline-height 40)
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
   (x-config
    (cmd+arg->script
     `((xrandr . "--dpi 96")
       (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1")
       (xinput . "set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7"))))))

(define-public (host->nameship hn)
  (eval-string (string-append "%" hn)))
