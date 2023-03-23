(define-module (dotfiles)
  #:use-module (guix gexp)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:export (cmd+arg->script))

(define (field-replace key value file)
  (regexp-substitute/global #f key file
                            'pre
                            (if (number? value)
                                (number->string value)
                                value)
                            'post))

(define-public (dunst-configuration ship-font ship-dunst-font-size ship-dunst-width)
  (let ((file (call-with-input-file "../misc/dunstrc" get-string-all)))
    (fold (lambda (l file)
            (let-values (((k v) (car+cdr l)))
             (field-replace k v file)))
          file
          `(("=FONT=" . ,ship-font)
            ("=FONT_SIZE=" . ,ship-dunst-font-size)
            ("=WIDTH=" . ,ship-dunst-width)))))

(define-public (picom-configuration ship-picom-radius)
  (let ((file (call-with-input-file "../misc/picom.conf" get-string-all)))
    (fold (lambda (l file)
            (let-values (((k v) (car+cdr l)))
             (field-replace k v file)))
          file
          `(("=RADIUS=" . ,ship-picom-radius)))))

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
                    "\n"))))

(define-macro (cmd+arg->script cmds)
  (let ((cmds (eval cmds (current-module))))
    `(gexp
      (system
       (string-append
        ,@(map (lambda (command)
                 (let-values (((cmd args) (car+cdr command)))
                   (cond ((gexp? cmd)   `(string-append (ungexp ,cmd) " " ,args "; "))
                         ((string? cmd) `(string-append ,cmd  " " ,args "; "))
                         (#t            `(string-append (ungexp ,cmd) "/bin/"
                                                        ,(symbol->string cmd) " "
                                                        ,args "; ")))))
               cmds))))))
