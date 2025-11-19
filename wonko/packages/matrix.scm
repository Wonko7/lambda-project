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
  (let ((commit "e4a14b0a9b876abb1913b953457de15a9fc06d32")
        (revision "0"))
    (package
      (inherit pantalaimon)
      (name "pantalaimon")

      (version (git-version "0.10.5" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/matrix-org/pantalaimon")
               (commit commit)))
         (file-name (git-file-name name version))
         (patches (list
                   (local-file
                    (string-append %lambda-project
                                   "/wonko/packages/patches/pantalaimon-img.patch"))))
         (sha256
          (base32 "1qzlkl3z2y9crf12alaqp279flhd4g1hdpygp9bl81x4zxwjrmbp"))))
      (arguments
       (substitute-keyword-arguments (package-arguments pantalaimon)
         ((#:phases phases) #~(modify-phases #$phases
                                (delete 'check))))))))
