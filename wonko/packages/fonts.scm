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

(define-public font-nerd-jetbrains
  (package
    (name "font-nerd-jetbrains")
    (version "3.3.0")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://github.com/ryanoasis/nerd-fonts/releases/download/v" version "/JetBrainsMono.zip"))
       (sha256
        (base32
         "1r6v5naj0g6wkhpr53zc7rygg9s199h81s7wf3x4nq0b6lm7i0rd"))))
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
         "0rixy2sgmv492ja6g9c27ypdav63wpyp5qzr5wkac8nhfkmc4ndw"))))
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
         "0yz2srglpvgqdw4nlv50lvl08wi1dd0dxk902v2j8d9g7p5kb9kj"))))
    (build-system font-build-system)

    (home-page "https://fonts.google.com/noto/specimen/Noto+Emoji")
    (synopsis "Iconic font aggregator, collection, and patcher")
    (description
     "Nerd Fonts patches developer targeted fonts with a high number
of glyphs (icons). Specifically to add a high number of extra glyphs
from popular ‘iconic fonts’ such as Font Awesome, Devicons, Octicons,
and others.")
    (license (@ (guix licenses) expat))))

(define-public font-google-roboto-mono
  (package
    (name "font-google-roboto-mono")
    (version "2.136")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/googlefonts/RobotoMono")
                    (commit "8f651634e746da6df6c2c0be73255721d24f2372")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "00ddmr7yvb9isakfvgv6g74m80fmg81dmh1hrrdyswapaa7858a5"))))
    (build-system font-build-system)
    (home-page "https://github.com/googlefonts/RobotoMono")
    (synopsis "Monospaced Roboto font")
    (description
     "Roboto Mono is a monospaced addition to the Roboto type family.
Like the other members of the Roboto family, the fonts are optimized for readability
on screens across a wide variety of devices and reading environments. While the
monospaced version is related to its variable width cousin, it doesn’t hesitate to
change forms to better fit the constraints of a monospaced environment. For example,
narrow glyphs like ‘I’, ‘l’ and ‘i’ have added serifs for more even texture while
wider glyphs are adjusted for weight. Curved caps like ‘C’ and ‘O’ take on the
straighter sides from Roboto Condensed. Special consideration is given to glyphs
important for reading and writing software source code. Letters with similar shapes
are easy to tell apart. Digit ‘1’, lowercase ‘l’ and capital ‘I’ are easily
differentiated as are zero and the letter ‘O’. Punctuation important for code has
also been considered. For example, the curly braces ‘{ }’ have exaggerated points
to clearly differentiate them from parenthesis ‘( )’ and braces ‘[ ]’. Periods and
commas are also exaggerated to identify them more quickly. The scale and weight of
symbols commonly used as operators have also been optimized.")
    (license (@ (guix licenses) asl2.0))))
