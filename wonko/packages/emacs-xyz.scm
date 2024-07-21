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
  #:use-module (wonko packages office)
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

(define-public emacs-zathura-sync-theme
  (package
    (name "emacs-zathura-sync-theme")
    (version "0.0.1")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/amolv06/zathura-sync-theme")
         (commit "master")))
       (sha256
        (base32 "1l6aaqm5617yq3wyri6f7a2jqh6pzkjpv221k97n3yyavxzq85wk"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/amolv06/zathura-sync-theme")
    (synopsis "synchronize Zathura’s theme with Emacs")
    (description "synchronize Zathura’s theme with Emacs")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-org-ml
  (package
    (name "emacs-org-ml")
    (version "5.8.8")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/ndwarshuis/org-ml")
         (commit (string-append "v" version))
         ;; (commit version)
         ))
       (file-name (git-file-name name version))
       (sha256
        (base32 "16j03fdikha5hwg8ifj0shsn4prbgf7dsggy3ksidpl63w3g05h4"))))
    (inputs
     (list emacs-s
           emacs-dash))
    (build-system emacs-build-system)
    (home-page "https://github.com/ndwarshuis/org-ml")
    (synopsis "A functional API for org-mode")
    (description "A functional API for org-mode")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-org-sql ;; replace with my fork?
  (package
    (name "emacs-org-sql")
    (version "3.0.4")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/ndwarshuis/org-sql")
         (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0v2bbwxblzpkf57p6d5i0isia90jxw17p9aaslizpcybqsp3c3ha"))))
    (inputs
     (list emacs-f
           emacs-s
           emacs-dash
           emacs-org-ml))
    (build-system emacs-build-system)
    (home-page "https://github.com/ndwarshuis/org-sql")
    (synopsis "converts org-mode files to Structured Query Language")
    (description "converts org-mode files to Structured Query Language")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-verbiste
  (package
    (name "emacs-verbiste")
    (version "0.1")
    (source (origin
              (method url-fetch)
              (uri "https://salsa.debian.org/debian/verbiste/-/raw/master/debian/verbiste.el")
              (sha256
               (base32
                "0vrbhmv2pp9k3d3rh3kkag96jb2ncnp1hn580ipyphrx46jq9nby"))))
    (inputs (list verbiste))
    (build-system emacs-build-system)
    (home-page "https://salsa.debian.org/debian/verbiste/")
    (synopsis "verbiste for emacs")
    (description "verbiste for emacs")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-exwm-firefox-evil
  (package
    (name "emacs-exwm-firefox-evil")
    (version "v0.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/walseb/exwm-firefox-evil")
                (commit "master")))
              (sha256
               (base32
                "1fbxll1ylkrkk6jm4mwcdvpix23dxvfsgl2zs10lr823ndydk1b6"))))
    (inputs (list emacs-evil
                  emacs-exwm-firefox-core
                  emacs-exwm))
    (build-system emacs-build-system)
    (home-page "https://github.com/walseb/exwm-firefox-evil")
    (synopsis "")
    (description "")
    (license (@ (guix licenses) gpl3+))))
