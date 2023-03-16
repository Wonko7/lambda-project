(define-module (dotfiles)
  #:use-module (guix gexp)
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

(define (make-tuple-config fa fb)
  (lambda (lines)
    (fold (lambda (lines acc)
            (let-values (((a b) (car+cdr lines)))
              (string-append acc (fa a) (fb b))))
          ""
          lines)))

(define-public xsettingd-configuration
  (make-tuple-config
   symbol->string
   (lambda (b)
     (string-append " "
                    (cond ((number? b) (format #f "~a" b))
                          ((string? b) (format #f "\"~a\"" b))
                          ((symbol? b) (format #f "\"~a\"" (symbol->string b))))

                    ";\n"))))

(define-public cmd+arg->script
  (make-tuple-config
     (lambda (a)
       (if (symbol? a)
           #~(string-append #$(file-append a (string-append "/bin/" (symbol->string a))))
           a))
     (lambda (b)
       (string-append " " b "; "))))
