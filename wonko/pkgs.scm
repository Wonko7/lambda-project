(define-module (wonko pkgs)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (guix gexp)
  ;; fonts
  #:use-module (wonko packages fonts)
  ;; emacs
  #:use-module (nongnu packages clojure)
  #:use-module (wonko packages emacs-xyz)
  #:use-module (wonko packages office)
  ;; web
  #:use-module (nongnu packages mozilla)
  ;; dev
  #:use-module (nongnu packages compression)
  ;; services
  #:use-module (gnu home services shepherd))

(use-package-modules
 fonts fontutils unicode
 ;; emacs
 emacs emacs-xyz aspell hunspell libreoffice ocaml java clojure uml haskell-xyz
 ;; desktop stuff
 pulseaudio synergy xorg toys linux xdisorg suckless music lxde xfce gnome kde-plasma kde-frameworks lxqt qt terminals ebook video imagemagick gimp pdf kde
 ;; web
 chromium tor matrix irc bittorrent
 ;; tools
 admin databases version-control file lsof tmux ssh vim bittorrent rust-apps gnupg password-utils moreutils bash disk cpio rsync cryptsetup curl web networking vpn hardware certs
 ;; dev
 android haskell-apps compression commencement pkg-config base gdb m4 maths ocaml libevent tls code node multiprecision sqlite image-viewers matrix wm man)

(define-public %emacs-world
  (list emacs
        ;; basic (bitches) stuff:
        emacs-general
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
        emacs-org-noter
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

        ;; desktop stuff? FIXME: set these up:
        emacs-nov-el
        emacs-auctex
        pandoc
        emacs-verbiste
        verbiste

        ;; office stuff
        emacs-org-jira

        ;; I, for one, welcome our new ai overlords
        emacs-gptel

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
        ;; emacs-multiple-cursors
        emacs-evil-mc
        emacs-evil-textobj-syntax
        emacs-evil-commentary
        emacs-evil-smartparens
        emacs-evil-paredit
        ;; emacs-hercules
        ;; emacs-vdiff-magit

        ;; apps
        ;; emacs-elfeed
        ;; emacs-elfeed-org
        ;; emacs-elfeed-goodies
        emacs-powerline
        emacs-circe
        emacs-pass
        emacs-magit
        emacs-magit-annex
        emacs-magit-todos
        emacs-git-link
        emacs-forge
        emacs-diff-hl
        emacs-dirvish
        emacs-coterm
        emacs-detached
        emacs-dired-du
        emacs-diredfl
        emacs-dired-rsync
        emacs-dired-hacks
        emacs-dired-toggle-sudo
        ;; 🗺
        emacs-osm

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
        emacs-no-littering

        ;; code: ()
        emacs-origami-el
        emacs-rainbow-mode
        emacs-rainbow-blocks
        emacs-rainbow-delimiters
        emacs-rainbow-identifiers
        emacs-lsp-mode ;; FIXME
        emacs-lsp-ui
        emacs-eglot
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
        ;; maxi passat:
        emacs-org-sql

        ;; completion framework
        emacs-embark
        emacs-vertico
        emacs-marginalia
        emacs-orderless
        emacs-corfu
        emacs-corfu-doc
        emacs-pcmpl-args
        emacs-cape
        emacs-consult
        emacs-consult-dir
        emacs-consult-lsp
        emacs-consult-yasnippet
        emacs-consult-eglot
        emacs-consult-org-roam
        emacs-consult-omni
        emacs-consult-notes ;; omni
        emacs-consult-gh    ;; omni
        emacs-browser-hist  ;; omni
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
        emacs-alert
        emacs-beacon
        emacs-nyan-mode
        emacs-doom-modeline
        emacs-svg-tag-mode
        emacs-diminish
        emacs-doom-themes
        emacs-all-the-icons
        emacs-all-the-icons-completion
        emacs-all-the-icons-dired
        emacs-kind-icon
        emacs-default-text-scale
        ;; exwm
        emacs-exwm
        emacs-exwm-edit
        emacs-exwm-modeline
        emacs-exwm-firefox-core
        emacs-exwm-firefox-evil
        emacs-exwm-mff
        emacs-perspective
        emacs-persp-mode
        emacs-lemon
        emacs-ace-window
        emacs-ace-link      ;; FIXME
        emacs-ace-jump-mode ;; FIXME
        ;; emacs-buffer-expose
        emacs-switch-window

        ;; system
        emacs-bluetooth

        ;; x stuff
        emacs-desktop-environment
        emacs-zathura-sync-theme
        ;; locale
        glibc-locales

        ;; communication
        emacs-ement
        emacs-mastodon
        emacs-slack
        ;; pantalaimon

        ;; ☠
        emacs-transmission
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
        arandr
        xrandr
        autorandr
        xdotool
        wmctrl

        xsettingsd ;; meh.
        ;; xautolock
        xss-lock

        pamixer
        pavucontrol
        brightnessctl
        scrot
        upower
        playerctl
        rxvt-unicode
        ;; tlp and have emacs set rfkill for me? fuck that noise.

        ;; x <3
        oneko
        xeyes
        ;; bling
        feh
        qtsvg   ;; needed for rendering icons
        kvantum ;; for qt theme
        qt5ct   ;; for changing icon theme & font size.
        breeze breeze-gtk breeze-icons))

(define-public %desktop-world
  (list
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
        ;; ☠
        ;; onionshare
        ;; rtorrent
        `(,transmission "gui")))

(define-public %hack-the-world
  (list wireshark))

(define-public %image-edition-world
  (list gimp
        ;; kdenlive
        krita))

(define-public %fonts-world
  (list font-jetbrains-mono
        ;; font-nerd-noto
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
        ;; ocsigen dependencies:
        gmp
        postgresql
        sqlite
        node
        sassc
        unzip
        gdb
        gnuplot
        m4
        gnu-make
        pkg-config
        libev
        openssl
        zlib))

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
        git
        git-annex))

(define-public %git-world
  (list git
        git-annex))

(define-public %utils-world
  (list ripgrep
        fd
        ;; system
        acpi
        tmux
        net-tools
        ;; disk
        cpio
        parted
        smartmontools
        gptfdisk
        ;; files
        coreutils
        recutils
        moreutils
        file
        tree
        lsof
        ;; compression
        p7zip
        unzip
        unrar
        ;; dev
        sloccount
        ;; android
        adb
        ;; web
        curl
        jq))

(define-public %os-net-world
  (list wireguard-tools
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
