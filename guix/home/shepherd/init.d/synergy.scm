(define synergy
  (make <service>
    #:provides '(synergy)
    #:docstring "Run `synergy'"
    #:start (make-forkexec-constructor
              '("synergy")
              #:log-file (string-append (getenv "HOME")
                                        "/log/synergy.log"))
    #:stop (make-kill-destructor)
    #:respawn? #t))
(register-services synergy)

(start synergy)
