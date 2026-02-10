(define-module (wonko packages toys)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages toys))

(define-public oneko-warn
  (package
    (inherit oneko)
    (arguments (substitute-keyword-arguments (package-arguments oneko)
                 ((#:phases phases)
                  #~(modify-phases #$phases
                      (add-after 'configure 'warn
                        (lambda _
                          ;; ignore warning
                          (substitute* "Makefile"
                            (("(CDEBUGFLAGS = ).*" _ front)
                             (string-append front "-O2 -fpermissive\n")))))))))))
