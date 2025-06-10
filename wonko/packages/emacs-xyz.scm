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
         (commit (string-append "v" version))))
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

(define-public emacs-org-sql ;;
  (package
    (name "emacs-org-sql")
    (version "3.0.4")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/wonko7/org-sql")
         (commit "777fde3c3f96d626280c7202323f145467491c22")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1qzmcv3vxrdhxx6qzwmrh4xbjw5xgghz1ddv4jdawlnqkwsmn5dl"))))
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

(define-public emacs-browser-hist
  (package
    (name "emacs-browser-hist")
    (version "v0.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/agzam/browser-hist.el")
                (commit "0372c6d984ca194d9454b14eba6eadec480ec3ff")))
              (sha256
               (base32
                "0s19gglc9jwapy7a9mf4i97a7r5q9lpm2ivvn0zjhqxcmzj3295j"))))
    (inputs (list emacs-embark))
    (build-system emacs-build-system)
    (home-page "https://github.com/agzam/browser-hist.el")
    (synopsis "Search through the Browser history, in Emacs")
    (description "Browsers usually keep their history in a sqlite database, and it’s trivial to extract it. This package allows you to search through your browser history by URL and the Page Title.")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-consult-omni
  (package
    (name "emacs-consult-omni")
    (version "v0.2")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/armindarvish/consult-omni")
                (commit "d0a24058bf0dda823e5f1efcae5da7dc0efe6bda")))
              (sha256
               (base32
                "12jz9hwb1m3ix7zai5qkbyycbaff55yf67pc8q3ijcg5xlks8ckp"))))
    (inputs (list emacs-browser-hist
                  emacs-gptel
                  emacs-embark))
    (build-system emacs-build-system)
    (arguments
     (list
      #:include #~(cons "sources/.*\\.el$" %default-include)
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'move-sources
            (lambda _
              (for-each (lambda (f)
                          (let ((b (basename f)))
                            (if (or (string= b "consult-omni-browser-history.el")
                                    (string= b "consult-omni-buffer.el")
                                    (string= b "consult-omni-calc.el")
                                    (string= b "consult-omni-dict.el")
                                    (string= b "consult-omni-duckduckgo.el")
                                    (string= b "consult-omni-fd.el")
                                    (string= b "consult-omni-find.el")
                                    (string= b "consult-omni-gptel.el")
                                    (string= b "consult-omni-git-grep.el")
                                    (string= b "consult-omni-grep.el")
                                    (string= b "consult-omni-line-multi.el")
                                    (string= b "consult-omni-invidious.el")
                                    (string= b "consult-omni-man.el")
                                    (string= b "consult-omni-org-agenda.el")
                                    ;; projects
                                    ;; removed github because of go cli dependency
                                    (string= b "consult-omni-ripgrep-all.el")
                                    (string= b "consult-omni-ripgrep.el")
                                    (string= b "consult-omni-sources.el")
                                    (string= b "consult-omni-stackoverflow.el")
                                    (string= b "consult-omni-wikipedia.el")
                                    (string= b "consult-omni-youtube.el"))
                                (rename-file f b)
                                (delete-file f))))
                        (find-files "./sources" ".*\\.el$")))))))
    (home-page "https://github.com/armindarvish/consult-omni")
    (synopsis "consult-omni - a powerful versatile omni search inside Emacs")
    (description "consult-omni is a package for getting search results from one or several custom sources (web search engines, AI assistants, elfeed database, org notes, local files, desktop applications, mail servers, …) directly in Emacs minibuffer. It is a successor of consult-web, with expanded features and functionalities.

consult-omni provides wrappers and macros around consult, to make it easier for users to get results from different sources and combine local and web sources in an omni-style search. In other words, consult-omni enables getting consult-style multi-source or dynamically completed results in minibuffer for a wide range of sources including Emacs functions/packages (e.g. Emacs buffers, org files, elfeed,…), command-line programs (grep, find, gh, …), or web search engines (Google, Brave, Bing, …).

consult-omni can be an open-source free alternative to other omni-search tools such as Alfred or MacOS spotlight. It provides a range of default sources as examples, but the main idea here is to remain agnostic of the source and provide the toolset for the users to define their own sources/workflows (a.k.a plugins).")
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

;; libxaw was needed to get alpha-background working
(define-public emacs-exwm-custom-emacs
  (package
    (inherit emacs-exwm)
    (name "emacs-exwm-custom-emacs")
    (arguments
     (substitute-keyword-arguments (package-arguments emacs)
       ((#:emacs _ #f) (package
                         (inherit emacs)
                         (inputs (modify-inputs (package-inputs emacs)
                                   (prepend libxaw)))))))))

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
