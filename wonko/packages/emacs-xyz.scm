(define-module (wonko packages emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix cvs-download)
  #:use-module (guix download)
  #:use-module (guix bzr-download)
  #:use-module (guix gexp)
  #:use-module (guix i18n)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system perl)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

(define-public emacs-evil-snipe
  (package
    (name "emacs-evil-snipe")
    (version "2.0.8")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/hlissner/evil-snipe")
         (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "18j33smlajj7ynigfgm64z3kfys5idbxin2gd93civ2564n85r33"))))
    (inputs
     (list emacs-evil))
    (build-system emacs-build-system)
    (home-page "https://github.com/hlissner/evil-snipe")
    (synopsis "snipe stuff")
    (description
     "It provides 2-character motions for quickly (and more accurately) jumping around text, compared to evil's built-in f/F/t/T motions, incrementally highlighting candidate targets as you type.")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-popwin ;; elfeed goodies dep
  (package
    (name "emacs-popwin")
    (version "1.0.2")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/emacsorphanage/popwin")
         (commit (string-append version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1x1iimzbwb5izbia6aj6xv49jybzln2qxm5ybcrcq7xync5swiv1"))))
    (inputs
     (list emacs-evil))
    (build-system emacs-build-system)
    (home-page "https://github.com/emacsorphanage/popwin")
    (synopsis "popwin: manage windows")
    (description "popwin: manage windows")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-elfeed-goodies
  (package
   (name "emacs-elfeed-goodies")
   (version "0.0.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/jeetelongname/elfeed-goodies")
           (commit "544ef42ead011d960a0ad1c1d34df5d222461a6b")))
     ;; (file-name (git-file-name name version))
     (sha256
      (base32 "147pwqx2maf430qhigzfd6lqk7a5sbrydf9a4c5bvsw8jv7wzb6l"))))
   (propagated-inputs
    (list emacs-elfeed emacs-powerline emacs-link-hint emacs-popwin))
   (build-system emacs-build-system)
   (home-page "https://github.com/jeetelongname/elfeed-goodies")
   (synopsis "elfeed goodies")
   (description "elfeed goodies")
   (license (@ (guix licenses) gpl3+))))

(define-public emacs-buffer-expose
  (package
    (name "emacs-buffer-expose")
    (version "0.0.1")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/clemera/buffer-expose")
         (commit "c4a1c745123b86c15ba7bb4858255b5252e8440a")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "09vj418hrg5759fild8y7f7n1ybgx20s1ip46pmh8fa1ss9yg7cr"))))
    (inputs
     (list emacs-evil))
    (build-system emacs-build-system)
    (home-page "https://github.com/clemera/buffer-expose")
    (synopsis "Expose: show buffers on a grid")
    (description
     "Visual buffer switching using a window grid")
    (license (@ (guix licenses) gpl3+))))
