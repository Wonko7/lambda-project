(define-module (fleet)
  #:use-module (spock)
  #:use-module (guix records)
  #:export (ship
            ship-name
            ship-font
            ship-st-font-size
            ship-dunst-font-size
            ship-emacs-font-size
            ship-emacs-modeline-height
            ship-gdk-scale))

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
   (gdk-scale 2)))

(define-public (hostname->ship hn)
  (eval-string (string-append "%" hn)))

(ship-emacs-font-size %yggdrasill)

(%yggdrasill emacs-font-size)
