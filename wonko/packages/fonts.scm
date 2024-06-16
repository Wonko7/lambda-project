(define-module (wonko packages fonts)
  #:use-module (ice-9 regex)
  #:use-module (guix utils)
  ;; #:use-module ((guix licenses) #:prefix license:) ;; for some reasons this breaks guix for me
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system font)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages c)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gd)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages xorg))

(define-public font-nerd-symbols
  (package
    (name "font-nerd-symbols")
    (version "3.2.1")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://github.com/ryanoasis/nerd-fonts/releases/download/v" version "/NerdFontsSymbolsOnly.zip"))
       (sha256
        (base32
         "1nb9bhl16lwvr58phcj0hyrzdxqv45gycj6a1nl95pcqy76a06zz"))))
    (build-system font-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'install 'make-files-writable
           (lambda _
             (for-each
              make-file-writable
              (find-files "." ".*\\.(otf|otc|ttf|ttc)$"))
             #t)))))
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Iconic font aggregator, collection, and patcher")
    (description
     "Nerd Fonts patches developer targeted fonts with a high number
of glyphs (icons). Specifically to add a high number of extra glyphs
from popular ‘iconic fonts’ such as Font Awesome, Devicons, Octicons,
and others.")
    (license (@ (guix licenses) expat))))

(define-public font-goog-noto-emoji
  (package
    (name "font-goog-noto-emoji")
    (version "0.1")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf"))
       ;; (file-name "noto-emoji.zip")
       (sha256
        (base32
         "0z1sa9bxw11yj79kvjcb29pg92krbznp9szq179cc0w8l1awisif"))))
    (build-system font-build-system)

    (home-page "https://fonts.google.com/noto/specimen/Noto+Emoji")
    (synopsis "Iconic font aggregator, collection, and patcher")
    (description
     "Nerd Fonts patches developer targeted fonts with a high number
of glyphs (icons). Specifically to add a high number of extra glyphs
from popular ‘iconic fonts’ such as Font Awesome, Devicons, Octicons,
and others.")
    (license (@ (guix licenses) expat))))
