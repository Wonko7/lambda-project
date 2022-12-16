(define picom
  (make <service>
    #:provides '(picom)
    #:docstring "Run `picom'"
    #:start (make-forkexec-constructor
              '("picom")
              #:log-file (string-append (getenv "HOME")
                                        "/log/picom.log"))
    #:stop (make-kill-destructor)
    #:respawn? #t))
(register-services picom)

(start picom)
