(define-module (wonko packages emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix cvs-download)
  #:use-module (guix download)
  #:use-module (guix bzr-download)
  #:use-module (guix gexp)
  #:use-module (guix i18n)
  #:use-module (guix utils)
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
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-build)
  #:use-module (gnu packages emacs-xyz)
  ;; (for emacs x-toolkits experiments
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages lesstif)
  ;; )
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
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (delete 'check))))
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
         (commit "92296ec6c8f63d8a13db15039a4694cd2318532e")))
       (sha256
        (base32 "1n1g7vaysb725abyvdimhs09zkhxm8zrpva8bds7w5afajlzszmb"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/amolv06/zathura-sync-theme")
    (synopsis "synchronize Zathura’s theme with Emacs")
    (description "synchronize Zathura’s theme with Emacs")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-nerd-icons-completion
  (let ((commit "8e5b995eb2439850ab21ba6062d9e6942c82ab9c")
        (revision "1"))
    (package
      (name "emacs-nerd-icons-completion")
      (version (git-version "0.1.0" revision commit))
      (home-page "https://github.com/rainstormstudio/nerd-icons-completion/")
      (propagated-inputs
       (list emacs-compat
             emacs-nerd-icons))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference (url home-page)
                             (commit commit)))
         (sha256
          (base32
           "0nbyrzz5sscycbr1h65ggzrm1m9agfwig2mjg7jljzw8dk1bmmd2"))))
      (build-system emacs-build-system)
      (synopsis "Use nerd-icons for completion")
      (description "Use nerd-icons for completion")
      (license (@ (guix licenses) gpl3+)))))

(define-public emacs-nerd-icons-dired
  (let ((commit "c0b0cda2b92f831d0f764a7e8c0c6728d6a27774")
        (revision "1"))
    (package
      (name "emacs-nerd-icons-dired")
      (version (git-version "0.1.0" revision commit))
      (home-page "https://github.com/rainstormstudio/nerd-icons-dired")
      (propagated-inputs
       (list emacs-nerd-icons))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference (url home-page)
                             (commit commit)))
         (sha256
          (base32
           "1iwqzh32j6fsx0nl4y337iqkx6prbdv6j83490riraklzywv126a"))))
      (build-system emacs-build-system)
      (synopsis "Use nerd-icons for completion")
      (description "Use nerd-icons for completion")
      (license (@ (guix licenses) gpl3+)))))

(define-public emacs-nerd-icons-ibuffer
  (let ((commit "46f57138e57329d841b1745e586b4f2c69f82b87")
        (revision "1"))
    (package
      (name "emacs-nerd-icons-ibuffer")
      (version (git-version "0.1.0" revision commit))
      (home-page "https://github.com/seagle0128/nerd-icons-ibuffer")
      (propagated-inputs
       (list emacs-nerd-icons))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference (url home-page)
                             (commit commit)))
         (sha256
          (base32
           "020nl0q6ab08frbikd78lnk821wsv6r3i7p5g1jmfw05zywj2jyr"))))
      (build-system emacs-build-system)
      (synopsis "Display nerd icons in ibuffer")
      (description "Display nerd icons in ibuffer")
      (license (@ (guix licenses) gpl3+)))))

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

(define-public emacs-nano-calendar
  (let ((commit "9baab985541f83e85e421b53b9d397f9c31e68d3"))
    (package
      (name "emacs-nano-calendar")
      (version "1.0.0")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/rougier/nano-calendar")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "136rpk0p9zsg897isbzfhs0951gcsa24wiyfv57p5qgz22hnjd1p"))))
      (build-system emacs-build-system)
      (home-page "https://github.com/rougier/nano-calendar")
      (synopsis "NANO calendar")
      (description "This library offers an alternative to calendar. It’s very similar and offer only a few options, like the possibility to color day according to the number of item in the org-agenda")
      (license (@ (guix licenses) gpl3+)))))

(define-public emacs-tramp-hlo
  (let ((commit "b726b4042e96ac5cead396c8d12c01e6bad2bd78"))
    (package
      (name "emacs-tramp-hlo")
      (version "0.0.1")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "https://github.com/jsadusk/tramp-hlo")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "154w75nh2i58fs7qw4b3rc4j224pnxfbh326h4fbl9kpf9rz9qk5"))))
      (build-system emacs-build-system)
      (home-page "https://github.com/jsadusk/tramp-hlo")
      (synopsis "Higher level emacs functions as optimized tramp operations")
      (description "Normally a tramp handler only contains implementations of the emacs primitive file operations. Implementing this set of operations allows emacs to do anything on a remote host, but many of the common functions in the emacs standard library will trigger multiple file operations for a single call. This can cause performance issues, because each file operation involves a roundtrip to the remote host.

This module implements some of those operations as single round trip tramp operations. The bulk of the operation is implemented as a server side bash script, rather than an elisp function. In practice this makes a lot of day to day editing on remote hosts much more responsive.")
      (license (@ (guix licenses) gpl3+)))))





(define-public emacs-exwm-firefox-evil
  (package
    (name "emacs-exwm-firefox-evil")
    (version "v0.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                 (url "https://github.com/walseb/exwm-firefox-evil")
                 (commit "ec9e14eca25aea9b7c7169be23843898f46696e7")))
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

;; https://issues.guix.gnu.org/issue/73416#4
;; check if this is still needed when revert patch hits master, in the meantime it means that
;; the emacs specified with an absolute path in xsession script is replaced by the one in
;; PATH, so I "fixed" it by removing vanilla emacs from PATH & replacing it by my custom thing
(define-public custom-emacs
  (package
    (inherit emacs)
    (inputs ;; libxaw is needed to get alpha-background working
     (modify-inputs (package-inputs emacs)
       (append libxaw)))
    (arguments ;; [2025-11-30 Sun 16:28], [2026-01-29 Thu 17:02] dired is failing again :(
     (substitute-keyword-arguments (package-arguments emacs)
       ((#:phases phases) #~(modify-phases #$phases
                              (delete 'check)))))))

(define-public emacs-exwm-custom-emacs
  (package
    (inherit emacs-exwm)
    (name "emacs-exwm-custom-emacs")
    (arguments
     (substitute-keyword-arguments (package-arguments emacs-exwm)
       ((#:emacs _ #f) custom-emacs)))))

(define-public emacs-exwm-custom-emacs-next
  (package
    (inherit emacs-exwm)
    (name "emacs-exwm-custom-emacs")
    (arguments
     (substitute-keyword-arguments (package-arguments emacs-exwm)
       ((#:emacs _ #f) (package
                         (inherit emacs-next)
                         (inputs (modify-inputs (package-inputs emacs-next)
                                   (prepend libxaw)))))))))
