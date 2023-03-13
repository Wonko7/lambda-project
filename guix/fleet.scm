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
            ;; host->nameship
            ))

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
   (emacs-font-size 250)
   (dunst-font-size 22)
   (st-font-size 25)
   (gdk-scale 2)
   (x-config
    #~(format #f "~a ~a; ~a ~a"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Click Method Enabled' 0 1"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Accel Speed' 1.0"))))

(define-public %rocinante
  (ship
   (inherit %yggdrasill)
   (name "rocinante")
   (x-config
    #~(format #f "~a ~a; ~a ~a"
              #$(file-append xinput "/bin/xinput")
              "set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1"
              #$(file-append xinput "/bin/xinput")
              "set-prop 14 'libinput Accel Speed' 0.7"))))

(define-public (host->nameship hn)
  (eval-string (string-append "%" hn)))
