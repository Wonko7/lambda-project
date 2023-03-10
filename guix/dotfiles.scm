(define-module (dotfiles)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (fleet))

(define (field-replace key value file)
  (regexp-substitute/global #f key file
                            'pre
                            (if (number? value)
                                (number->string value)
                                value)
                            'post))

(define-public (dunst-configuration ship)
  (let ((file (call-with-input-file "../misc/dunstrc" get-string-all)))
    (fold (lambda (l file)
            (let-values (((k v) (car+cdr l)))
             (field-replace k v file)))
          file
          `(("=FONT=" . ,(ship-font ship))
            ("=FONT_SIZE=" . ,(ship-dunst-font-size ship))))))
