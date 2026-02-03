(define-module (wonko packages bash)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26))

(define-public bash-complete-alias
  (package
    (name "bash-complete-alias")
    (version "1.18.x")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/cykerway/complete-alias")
              (commit "7f2555c2fe7a1f248ed2d4301e46c8eebcbbc4e2")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1a3rilzrdkk5s6qlq5kkcj0bnzq455giiy454aj32vnlcxz6z26a"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; There is no test suite.
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda _
             (substitute* "complete_alias"
               (("#(complete -F _complete_alias \"\\$\\{!BASH_ALIASES\\[@\\]\\}\")" all var) var))))
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((share (string-append (assoc-ref outputs "out") "/share/bash")))
               (install-file "complete_alias" share)))))))
    (home-page "https://github.com/cykerway/complete-alias")
    (synopsis "automagical shell alias completion")
    (description "automagical shell alias completion")
    (license license:gpl3+)))
