(define-module (fleet)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages xorg)
  #:export (ship
            ship-name
            ship-font
            ship-x-config
            ship-st-font-size
            ship-dunst-font-size
            ship-emacs-font-size
            ship-emacs-modeline-height
            ship-gdk-scale
            ship-xsettingsd-config))

(define-public %font "JetBrains Mono")

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
  (xsettingsd-config ship-xsettingsd-config (sanitize (check string?)))
  (x-config ship-x-config (sanitize (check gexp?)))
  (st-font-size ship-st-font-size (sanitize (check number?)))
  (dunst-font-size ship-dunst-font-size (sanitize (check number?)))
  (emacs-font-size ship-emacs-font-size (sanitize (check number?)))
  (emacs-modeline-height ship-emacs-modeline-height (sanitize (check number?)))
  (gdk-scale ship-gdk-scale (sanitize (check number?))))

;; (define-public %rocinante
;;   (ship
;;    (name "rocinante")
;;    (emacs-modeline-height 40)
;;    (emacs-font-size 150)
;;    (dunst-font-size )
;;    (st-font-size )
;;    (gdk-scale 1)))

(define-public %yggdrasill
  (ship
   (name "yggdrasill")
   (font %font)
   (emacs-modeline-height 5)
   (emacs-font-size 80)
   (dunst-font-size 22)
   (st-font-size 25)
   (gdk-scale 1)
   (x-config
    #~(format #f "~a ~a; ~a ~a; ~a ~a"
              #$(file-append xrandr "/bin/xrandr")
              "--dpi 288"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Click Method Enabled' 0 1"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Accel Speed' 1.0"))
   (xsettingsd-config
    (string-append
     "Net/ThemeName \"Breeze-Dark\"\n"
     "Net/IconThemeName \"breeze-dark\"\n"
     "Xft/Antialias 1\n"
     ;; "Xft/DPI 9216\n"
     ;; "Xft/DPI 288\n"
     ;;  Gtk/CursorThemeName
     "Xft/HintStyle \"hintfull\"\n"
     "Xft/Hinting 1\n"
     "Xft/RGBA \"rgb\"\n"
     "Xft/lcdfilter \"none\"\n"
     "Gtk/FontName \"NotoSans NF 16\""
     ))))
;;;
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
   (gdk-scale 1)
   (x-config
    #~(format #f "~a ~a; ~a ~a; ~a ~a"
              #$(file-append xinput "/bin/xinput")
              "set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Speed' 0.7"
              #$(file-append xinput "/bin/xinput")
              "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Enabled' 1"
              #$(file-append xinput "/bin/xinput")
              "set-prop 'SynPS/2 Synaptics TouchPad' 'Tapping Drag Lock Enabled' 1"))
   (xsettingsd-config
    (string-append
     "Xft/Antialias 1\n"
     "Xft/DPI 96\n"
     ;;  Gtk/CursorThemeName
     "Xft/HintStyle \"hintfull\"\n"
     "Xft/Hinting 1\n"
     "Xft/RGBA \"rgb\"\n"
     "Xft/lcdfilter \"none\"\n"))))

(define-public %enterprise
  (ship
   (inherit %rocinante)
   (name "enterprise")
   (x-config
    #~(format #f "~a ~a; ~a ~a"
              #$(file-append xinput "/bin/xinput")
              "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Accel Speed' 0.7"))))

(define-public (host->nameship hn)
  (eval-string (string-append "%" hn)))
