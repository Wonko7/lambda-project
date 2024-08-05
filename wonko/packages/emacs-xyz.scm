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

(define-public emacs-consult-gh
  (package
    (name "emacs-consult-gh")
    (version "1.0")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/armindarvish/consult-gh")
                (commit "306053a25fbcdb07cf902644668cc55510125e10" )))
              (sha256
               (base32
                "1c4nmzf0nbzc8g1rzs30af00nd4scl5rap330y26fllrw1mdwfbs"))))
    (inputs (list emacs-embark
                  emacs-transient))
    (build-system emacs-build-system)
    (home-page "https://github.com/armindarvish/consult-gh")
    (synopsis "Consult-GH - A GitHub CLI client inside GNU Emacs using Consult")
    (description "Consult-GH provides an interface to interact with GitHub repositories (search, view files and issues, clone, fork, …) from inside Emacs. It uses the awesome package consult by Daniel Mendler and GitHub CLI and optionally Embark by Omar Antolín Camarena, and provides an intuitive UI using minibuffer completion familiar to Emacs users.")
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

(define-public emacs-consult-notes
  (package
    (name "emacs-consult-notes")
    (version "v0.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/mclear-tools/consult-notes")
                (commit "9858bb13b54934ea0a95df45947ff40ffde4553b")))
              (sha256
               (base32
                "0kv5hdc3cl7vkr06llyd6dcbddd55rmhhsfr8hzjpmvgw0h317kg"))))
    (inputs (list emacs-s
                  emacs-dash
                  emacs-consult))
    (build-system emacs-build-system)
    (home-page "https://github.com/mclear-tools/consult-notes")
    (synopsis "for easily selecting notes via consult")
    (description "consult-notes can be used with any directory (or directories) of note files. It easily integrates with note systems like zk, denote, or org-roam. Additionally, it may also search org headings in a set of specified files.")
    (license (@ (guix licenses) gpl3+))))

(define-public emacs-consult-omni
  (package
    (name "emacs-consult-omni")
    (version "v0.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/armindarvish/consult-omni")
                (commit version)))
              (sha256
               (base32
                "09a7jvmg2zkzci1b6vzlsjmlfcramfkfa24mv5hjmc20zc6sdnnf"))))
    (inputs (list emacs-browser-hist
                  emacs-consult-gh
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
                            (if (not (or (string= b "consult-omni-mu4e.el")
                                         (string= b "consult-omni-notmuch.el")
                                         (string= b "consult-omni-brave.el")
                                         (string= b "consult-omni-brave-autosuggest.el")
                                         (string= b "consult-omni-gptel.el")
                                         (string= b "consult-omni-elfeed.el")))
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
