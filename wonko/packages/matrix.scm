(define-module (wonko packages matrix)
  #:use-module (guix packages)
  #:use-module (gnu packages matrix)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (wonko defs))

(define-public img-pantalaimon
  (let ((commit "9fe0e801284b8afe11071443b3143b419fc95d27")
        (revision "0"))
    (package
      (inherit pantalaimon)
      (name "img-pantalaimon")
      (version (git-version "0.10.6" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/matrix-org/pantalaimon") ;; archived??
                (commit commit)))
         (file-name (git-file-name name version))
         (patches (list
                   (local-file
                    (string-append %lambda-project
                                   "/wonko/packages/patches/pantalaimon-img.patch"))))
         (sha256
          (base32 "07cf5k0b1i5pfplmx2p5l3ba76jjfzzcky9ylj7593k7nrm5drl3"))))
      (arguments
       (substitute-keyword-arguments (package-arguments pantalaimon)
         ((#:phases phases) #~(modify-phases #$phases
                                (delete 'check))))))))

img-pantalaimon
