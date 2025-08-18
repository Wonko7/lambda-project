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
  #:use-module (gnu home services shepherd)
  ;; non free firmware
  #:use-module (nongnu packages firmware))

(use-package-modules
 fonts fontutils unicode
 ;; emacs
 emacs emacs-build emacs-xyz aspell hunspell libreoffice ocaml java clojure uml haskell-xyz
 ;; desktop stuff
 pulseaudio synergy xorg toys linux xdisorg suckless music lxde xfce gnome kde-plasma kde-frameworks lxqt qt terminals ebook video imagemagick photo gimp pdf kde graphviz image-viewers
 ;; web
 chromium tor matrix irc bittorrent
 gnuzilla
 ;; tools
 admin databases version-control file lsof tmux ssh vim bittorrent rust-apps gnupg password-utils moreutils bash disk cpio rsync cryptsetup curl web networking vpn hardware certs ntp tls screen
 ;; dev
 android flashing-tools haskell-apps compression commencement pkg-config base gdb m4 maths ocaml libevent tls code node multiprecision sqlite image-viewers matrix wm man)

(define-public %emacs-world
  (list custom-emacs ;; see emacs-xyz.scm's custom-emacs for why FIXME
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
        emacs-org-appear
        emacs-org-board
        emacs-org-books
        emacs-org-noter
        emacs-enlive
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
        emacs-exiftool

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

        ;; apps:
        ;; emacs-elfeed
        ;; emacs-elfeed-org
        ;; emacs-elfeed-goodies
        ;; emacs-powerline
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
        emacs-eat
        emacs-detached
        emacs-dired-du
        emacs-diredfl
        emacs-dired-rsync
        emacs-dired-hacks
        emacs-dired-toggle-sudo
        emacs-dired-preview
        emacs-world-time-mode
        ;; 🗺
        emacs-osm
        ;; casual:
        emacs-casual-info
        emacs-casual-dired
        emacs-casual-calc

        ;; spell
        emacs-flycheck-guile
        emacs-flyspell-correct
        emacs-auto-dictionary-mode
        hunspell
        hunspell-dict-fr-toutes-variantes
        hunspell-dict-en-us
        hunspell-dict-en-gb
        emacs-jinx

        ;; transverse:
        emacs-ibuffer-projectile
        emacs-projectile
        emacs-perspective
        emacs-no-littering

        ;; code: ()
        emacs-origami
        emacs-rainbow-mode
        emacs-rainbow-blocks
        emacs-rainbow-delimiters
        emacs-rainbow-identifiers
        emacs-lsp-mode ;; FIXME
        emacs-lsp-ui
        emacs-eglot
        emacs-gnuplot
        emacs-eval-in-repl-ocaml
        emacs-tuareg
        ;; lisps
        emacs-eval-sexp-fu
        emacs-eval-in-repl-geiser
        emacs-aggressive-indent
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
        emacs-browser-hist ;; omni
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

        ;; word smith
        emacs-olivetti

        ;; simple gui
        emacs-alert
        emacs-beacon
        emacs-nyan-mode
        emacs-doom-modeline
        emacs-svg-tag-mode
        emacs-diminish
        emacs-doom-themes
        emacs-nerd-icons
        emacs-nerd-icons-completion
        emacs-nerd-icons-dired
        emacs-nerd-icons-ibuffer
        ;; emacs-all-the-icons
        ;; emacs-all-the-icons-completion
        ;; emacs-all-the-icons-dired
        ;; emacs-kind-icon
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
        emacs-window-layout
        emacs-ace-window
        emacs-ace-link      ;; FIXME
        emacs-ace-jump-mode ;; FIXME
        ;; emacs-buffer-expose
        emacs-switch-window

        ;; system
        emacs-bluetooth
        emacs-pulseaudio-control

        ;; x stuff
        emacs-desktop-environment
        emacs-zathura-sync-theme

        ;; communication
        emacs-ement
        emacs-mastodon
        emacs-slack
        ;; pantalaimon

        ;; ☠
        emacs-transmission))

(define-public %xfce-world
  (list xfce
        xfce4-session
        xfconf
        xfce4-battery-plugin))

(define-public %crypto-world ;; complements %utils-world
  (list gnupg
        password-store
        emacs-pass
        emacs-auth-source-pass
        emacs-pinentry))

(define-public %xorg-world
  (list xinit
        xset
        xsetroot
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
        xwininfo

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
        ;; oneko ;; borked FIXME
        xeyes
        ;; bling
        feh
        ;; gtk & qt theme:
        breeze breeze-gtk breeze-icons))

(define-public %desktop-world
  (list
   ;; img
   scrot
   imagemagick
   graphviz
   perl-image-exiftool
   ;; video
   mpv
   vlc
   ;; webcam
   guvcview
   ;; ebooks & pdf
   calibre
   mcomix
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
        ;; icecat
        ;; ungoogled-chromium ;; borked FIXME
        speedtest-cli
        netcat-openbsd
        nmap
        youtube-dl
        ;; ☠
        ;; onionshare
        `(,transmission "gui")))

(define-public %hack-the-world
  (list wireshark))

(define-public %image-edition-world
  (list
   gimp
   ;; kdenlive
   krita))

(define-public %fonts-world
  (list font-nerd-jetbrains
        font-google-roboto-mono
        font-nerd-symbols
        font-goog-noto-emoji))

(define-public %ocaml-with-opam-world
  (list opam
        ;; mercurial
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

(define-public %ocaml-minimal
  (list
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
  (list ;; mercurial
        darcs
        git
        git-annex))

(define-public %git-world
  (list git
        git-annex))

(define-public %dev-world
  (list sloccount
        adb
        teensy-loader-cli))

(define-public %utils-world
  (list
   ;; files
   ripgrep
   fd
   coreutils
   recutils
   moreutils
   file
   tree
   lsof
   inotify-tools
   ;; keyboard
   kmonad
   ;; system
   btop
   acpi
   tmux
   dtach
   net-tools ;; netstat
   strace
   ;; compression
   p7zip
   unzip
   unrar
   ;; android
   adb
   ;; web
   gnutls
   openssl
   curl
   jq))

(define-public %os-net-world ;; complements %utils-world
  (list
   openntpd
   wireguard-tools
   iproute
   iw))

(define-public %os-disk-world
  (list
   cpio
   parted
   smartmontools
   gptfdisk
   rsync
   parted
   cryptsetup
   btrfs-progs
   dosfstools
   util-linux+udev))

(define-public %os-misc-world
  (list font-terminus
        custom-emacs ;; see emacs-xyz.scm's custom-emacs for why FIXME
        vim))

(define-public %os-nonfree
  (list fwupd-nonfree))

(define-public %borked-comms-world
  (list pantalaimon))

(define-public %borked-calibre-world
  (list calibre))

(define-public %borked-2025-08
  (list ungoogled-chromium
        oneko))

(define-public %emacs-debug-world
  (list emacs-org
        emacs-org-roam
        emacs-evil
        emacs-exwm
        emacs-exwm-edit
        emacs-exwm-modeline
        emacs-exwm-firefox-core
        emacs-exwm-firefox-evil
        emacs-exwm-mff
        emacs-perspective
        emacs-persp-mode
        emacs-lemon
        emacs-window-layout
        emacs-doom-themes
        emacs-dash
        ))
