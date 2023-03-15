(define-module (pkgs)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  ;; fonts
  #:use-module (w7 packages fonts)
  ;; FIXME:
  #:use-module (gnu packages fonts)
  ;; there -can- should only be one
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages unicode)
  ;; emacs
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages hunspell)
  #:use-module (gnu packages libreoffice)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages ocaml)
  ;; desktop stuff
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages synergy)
  #:use-module (gnu packages xorg) ;; xinit
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages music)
  #:use-module (gnu packages lxde)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages kde-frameworks)
  ;; tools
  #:use-module (gnu packages admin)
  #:use-module (gnu packages databases) ;; recutils
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages bittorrent)
  #:use-module (gnu packages rust-apps) ;; fd rg
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages bash)
  ;; dev
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages commencement) ;; gcc
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages ocaml)
  ;; services
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages image-viewers)
  #:use-module (gnu packages matrix)
  #:use-module (gnu packages dunst)
  #:use-module (w7 packages jonaburg-picom)
  #:use-module (w7 packages emacs-xyz)
  ;; doc
  #:use-module (gnu packages man))

(define-public %emacs-world
  (list emacs ;; TODO: native compilation
        ;; emacs-next
        ;; basic (bitches) stuff:
        emacs-general
        emacs-emacsql-sqlite3
        emacs-undo-fu
        emacs-vundo

        ;; org
        emacs-org
        emacs-org-roam
        emacs-org-super-agenda
        emacs-org-web-tools
        emacs-org-ql
        emacs-enlive
        emacs-seq
        emacs-calfw
        ;; emacs-org-download (images)
        ;;"emacs-org-ref"
        ;;"emacs-org-static-blog"
        ;;"emacs-org2web"
        ;;"emacs-org-beautify-theme"
        ;;"org-superstar-mode"
        ;; emacs-org-auto-expand
        ;; emacs-org-appear
        ;; emacs-orgit (link to magit)
        ;; emacs-org-modern

        ;; evil
        emacs-evil
        emacs-evil-org
        emacs-evil-leader
        emacs-evil-escape
        emacs-evil-matchit
        emacs-evil-surround
        emacs-evil-exchange
        emacs-evil-goggles
        emacs-evil-cleverparens
        emacs-evil-visualstar
        emacs-evil-snipe
        emacs-evil-collection
        emacs-evil-owl ;; (show registers)
        emacs-evil-args
        emacs-evil-lion ;; (align)
        emacs-evil-multiedit
        emacs-evil-mc
        emacs-evil-textobj-syntax
        emacs-evil-commentary
        emacs-evil-smartparens
        emacs-evil-paredit
        ;; emacs-hercules
        ;; emacs-vdiff-magit

        ;; apps
        emacs-elfeed
        emacs-elfeed-org
        emacs-elfeed-goodies
        emacs-circe
        emacs-pass
        emacs-magit
        emacs-magit-annex
        emacs-magit-todos
        emacs-diff-hl
        emacs-dirvish
        emacs-eshell-up
        emacs-dired-du
        emacs-diredfl
        emacs-dired-rsync
        emacs-dired-hacks
        emacs-all-the-icons-dired
        emacs-dired-toggle-sudo
        ;; 🗺
        emacs-osm
        ;; desktop stuff?
        emacs-nov-el

        ;; spell
        emacs-flycheck-guile
        emacs-flyspell-correct
        emacs-auto-dictionary-mode
        hunspell
        hunspell-dict-fr-toutes-variantes
        hunspell-dict-en-us
        hunspell-dict-en-gb
        hunspell-dict-en-gb-ize

        ;; transverse:
        emacs-ibuffer-projectile
        emacs-projectile
        emacs-perspective
        emacs-emojify

        ;; code: ()
        emacs-rainbow-mode
        emacs-rainbow-blocks
        emacs-rainbow-delimiters
        emacs-rainbow-identifiers
        emacs-lsp-mode ;; FIXME
        emacs-lsp-ui
        ;;emacs-company-lsp
        ;;emacs-company
        emacs-corfu
        emacs-corfu-doc
        emacs-eglot
        emacs-consult-eglot
        emacs-consult-org-roam
        emacs-eval-sexp-fu-el
        emacs-eval-in-repl-geiser
        emacs-gnuplot
        ;; ocaml
        emacs-eval-in-repl-ocaml
        emacs-tuareg
        ;; guile/scheme <3
        emacs-geiser
        emacs-geiser-guile
        emacs-guix

        ;; completion framework
        emacs-orderless
        emacs-consult
        emacs-consult-dir
        emacs-consult-lsp
        emacs-consult-yasnippet
        emacs-embark
        emacs-vertico
        emacs-which-key
        emacs-yasnippet
        emacs-doom-snippets
        emacs-bash-completion
        bash-completion

        ;; search
        fd
        ripgrep
        emacs-rg
        emacs-wgrep

        ;; simple gui
        emacs-beacon
        emacs-doom-modeline
        emacs-diminish
        emacs-doom-themes
        emacs-all-the-icons
        emacs-all-the-icons-completion
        ;; exwm
        emacs-exwm
        emacs-exwm-edit
        emacs-perspective
        emacs-persp-mode
        emacs-lemon
        emacs-ace-window    ;; FIXME
        emacs-ace-link      ;; FIXME
        emacs-ace-jump-mode ;; FIXME
        emacs-buffer-expose
        emacs-switch-window

        ;; x stuff
        emacs-desktop-environment

        ;; communication
        emacs-ement
        emacs-mastodon
        pantalaimon

        ;; ☠
        rtorrent
        emacs-mentor))

(define-public %crypto-world
  (list gnupg
        password-store
        emacs-pass
        emacs-auth-source-pass
        emacs-pinentry
        pinentry-emacs
        openssh))

(define-public %xorg-world
  (list xinit
        xset
        xhost
        xorg-server
        xf86-input-libinput
        xf86-video-fbdev
        xf86-video-nouveau

        xsettingsd
        ;; xautolock
        xss-lock

        pamixer
        brightnessctl
        scrot
        upower
        playerctl
        ;; tlp and have emacs set rfkill for me? fuck that noise.

        ;; bling
        breeze breeze-gtk breeze-icons))

(define-public %fonts-world
  (list font-jetbrains-mono
        ;; font-nerd-jetbrains
        font-nerd-noto
        font-nerd-symbols
        font-goog-noto-emoji))

(define-public %ocaml-with-opam-world
  (list opam
        mercurial
        darcs
        unzip
        gcc-toolchain
        gdb
        gnuplot
        m4
        gnu-make
        pkg-config))

(define-public %ocaml5-world
  (list ocaml5.0-eio-main
        ocaml-batteries
        ocamlformat))

(define-public %vcs-world
  (list mercurial
        darcs
        git))

(define-public %utils-world
  (list recutils
        tree
        tmux
        acpi))
