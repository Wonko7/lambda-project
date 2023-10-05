(define-module (pkgs)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  ;; fonts
  #:use-module (w7 packages fonts)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages unicode)
  ;; emacs
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages hunspell)
  #:use-module (gnu packages libreoffice)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages java)
  #:use-module (gnu packages clojure)
  #:use-module (nongnu packages clojure)
  #:use-module (gnu packages uml)
  ;; desktop stuff
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages synergy)
  #:use-module (gnu packages xorg) ;; xinit
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages music)
  #:use-module (gnu packages lxde)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages ebook)
  #:use-module (gnu packages video)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages gimp)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages kde)
  ;; web
  #:use-module (nongnu packages mozilla)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages tor)
  #:use-module (gnu packages matrix)
  #:use-module (gnu packages irc)
  ;; tools
  #:use-module (w7 packages w7-st)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages databases) ;; recutils
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages file)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages bittorrent)
  #:use-module (gnu packages rust-apps) ;; fd rg
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages moreutils)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages cryptsetup)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages web)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages vpn)
  #:use-module (gnu packages hardware) ;; ddcutil
  #:use-module (gnu packages certs)
  ;; dev
  #:use-module (gnu packages android)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages commencement) ;; gcc
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages tls)
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
        ;; rm emacs-emacsql-sqlite3
        emacs-undo-fu
        emacs-vundo

        ;; org
        emacs-org
        emacs-org-roam
        emacs-org-super-agenda
        emacs-org-web-tools
        emacs-org-ql
        emacs-org-board
        emacs-org-books
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
        emacs-forge
        emacs-diff-hl
        emacs-dirvish
        emacs-coterm
        ;; FIXME remove these?
        emacs-eshell-up
        emacs-eshell-syntax-highlighting
        emacs-esh-autosuggest
        emacs-eshell-prompt-extras
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
        emacs-pcmpl-args
        emacs-cape
        emacs-eglot
        emacs-consult-eglot
        emacs-consult-org-roam
        emacs-eval-sexp-fu-el
        emacs-eval-in-repl-geiser
        emacs-gnuplot
        emacs-eval-in-repl-ocaml
        emacs-tuareg
        ;; clojure
        emacs-cider
        emacs-clojure-mode
        ;; guile/scheme <3
        emacs-geiser
        emacs-geiser-guile
        emacs-guix
        ;; rest
        emacs-plz
        ;; guix / dev env:
        emacs-buffer-env
        emacs-inheritenv

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
        emacs-nyan-mode
        emacs-doom-modeline
        emacs-diminish
        emacs-doom-themes
        emacs-all-the-icons
        emacs-all-the-icons-completion
        emacs-kind-icon
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
        ;; locale
        glibc-locales

        ;; communication
        emacs-ement
        emacs-mastodon
        ;; pantalaimon

        ;; ☠
        rtorrent
        emacs-mentor))

(define-public %xfce-world
  (list xfce
        xfce4-session
        xfconf
        xfce4-battery-plugin))

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
        xev
        xfontsel
        xdpyinfo
        xrdb
        setxkbmap
        xmodmap
        xprop
        xclip
        xinput
        xrandr

        xsettingsd ;; meh.
        ;; xautolock
        xss-lock

        pamixer
        pavucontrol-qt
        brightnessctl
        scrot
        upower
        playerctl
        ;; tlp and have emacs set rfkill for me? fuck that noise.

        ;; terms
        w7-st
        alacritty ;; FIXME config this and make it useful?

        ;; x <3
        xeyes

        ;; bling
        feh
        qtsvg   ;; needed for rendering icons
        kvantum ;; for qt theme
        qt5ct   ;; for changing icon theme & font size.
        breeze breeze-gtk breeze-icons))

(define-public %desktop-world
  (list calibre
        ;; img
        scrot
        imagemagick
        ;; video
        mpv
        vlc
        ;; webcam
        guvcview
        ;; ebooks & pdf
        calibre
        ;;okular ;; 280Mb
        zathura ;; FIXME config this
        zathura-ps
        zathura-pdf-mupdf
        xournal ;; oldschool pdf editor
        ;; desktop stuff
        ddcutil ;; monitor settings
        ))

(define-public %web-world
  (list firefox
        ungoogled-chromium
        speedtest-cli
        netcat-openbsd
        nmap
        youtube-dl
        ;; onionshare
        ))

(define-public %hack-the-world
  (list wireshark))

(define-public %image-edition-world
  (list gimp
        ;; kdenlive
        krita))

(define-public %fonts-world
  (list font-jetbrains-mono
        font-nerd-noto
        font-nerd-symbols
        font-goog-noto-emoji))

(define-public %ocaml-with-opam-world
  (list opam
        mercurial
        darcs
        unzip
        ;; gcc
        gcc-toolchain
        gdb
        gnuplot
        m4
        gnu-make
        pkg-config
        libev
        openssl
        ))

(define-public %ocaml-mode-deps
  (list ocaml-utop
	dune
        ocamlformat))

(define-public %ocaml5-world
  (list ocaml
        ocaml5.0-eio-main
        ocaml-batteries
        ocamlformat))

;; this now lives in org's guix.scm
;; (define-public %babel-world
;;
;;   (list gnuplot
;;         plantuml
;;         clojure
;;         icedtea
;; 	leiningen
;;         ;; ocaml ;; FIXME.
;;         ocamlformat
;; 	ocaml-utop
;;         ocaml-batteries
;;         opam
;; 	dune))

(define-public %vcs-world
  (list mercurial
        darcs
        git))

(define-public %utils-world
  (list ripgrep
        fd
        ;; system
        acpi
        tmux
        net-tools
        ;; disk
        parted
        ;; files
        coreutils
        recutils
        moreutils
        file
        tree
        ;; compression
        p7zip
        unzip
        ;; android
        adb
        ;; web
        curl
        jq))

(define-public %os-net-world
  (list nss-certs
        wireguard-tools
        iproute
        iw))

(define-public %os-misc-world
  (list font-terminus
        emacs
        vim))

(define-public %os-disk-world
  (list git
        rsync
        parted
        cryptsetup
        btrfs-progs
        dosfstools
        util-linux+udev))

(define-public %communication-world
  (list pantalaimon
        weechat))
