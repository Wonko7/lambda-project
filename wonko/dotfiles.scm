(define-module (wonko dotfiles)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix profiles)
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
  (let ((file (call-with-input-file "misc/dunstrc" get-string-all)))
    (fold (lambda (l file)
            (let-values (((k v) (car+cdr l)))
              (field-replace k v file)))
          file
          `(("=FONT=" . ,ship-font)
            ("=FONT_SIZE=" . ,ship-dunst-font-size)
            ("=WIDTH=" . ,ship-dunst-width)))))

(define-public (picom-configuration ship-picom-radius)
  (let ((file (call-with-input-file "misc/picom.conf" get-string-all)))
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

(define-public emacs-eshell-aliases-configuration
  (make-tuple-config
   (lambda (a)
     (string-append "alias " a))
   (lambda (b)
     (string-append " " b " $*\n"))))

(define-public (bash-profile-source-profiles profiles)
  (let* ((profiles (apply string-append
                          (concatenate
                           (zip
                            (circular-list " $GUIX_EXTRA_PROFILES/")
                            profiles)))))
    (mixed-text-file
     "bash-profile"
     "# hey boy. hey girl. superstar DJ. here we go!\n"
     "# priortiy to system profiles, then user stuff\n"
     "for profile in /run/current-system/*-profile " profiles "; do\n"
     "    if [ -f $profile/etc/profile ]; then\n"
     "        GUIX_PROFILE=$profile\n"
     "        . $GUIX_PROFILE/etc/profile\n"
     "    fi\n"
     "    unset profile\n"
     "done\n"
     ;; "test -r ~/.opam/opam-init/init.sh && . ~/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true\n"
     )))

(define-public (xresources-configuration font rxvt-font-size)
  (let ((file (call-with-input-file "misc/Xresources" get-string-all)))
    (fold (lambda (l file)
            (let-values (((k v) (car+cdr l)))
              (field-replace k v file)))
          file
          `(("=FONT=" . ,font)
            ("=SIZE=" . ,rxvt-font-size)))))

(define-public (pkgs->manifest name ps)
  `(,(string-append "local/manifests/" name)
    ,(scheme-file
      name
      #~(begin
          #$(manifest->code
             (packages->manifest ps))))))

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
