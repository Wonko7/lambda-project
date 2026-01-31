(define-module (wonko packages mail)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public exim-content-scan
  (package
    (inherit exim)
    (name "exim-content-scan")
    (arguments
     (substitute-keyword-arguments (package-arguments exim)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'configure 'enable-content-scan
              (lambda _
                (substitute* "Local/Makefile"
                  (("# (WITH_CONTENT_SCAN=yes)" all var) var))))))))))
