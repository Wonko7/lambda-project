(define-module (wonko pkgs)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (guix gexp)
  ;; bork [2026-06-21 Sun 12:38]
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  ;; emacs
  #:use-module (nongnu packages clojure)
  #:use-module (wonko packages emacs-xyz)
  #:use-module (maxipassat packages emacs-xyz)
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
 emacs emacs-build emacs-xyz aspell hunspell ocaml guile guile-xyz java clojure uml haskell-xyz
 ;; desktop stuff
 pulseaudio synergy xorg toys linux xdisorg suckless music lxde xfce gnome kde-plasma kde-frameworks kde-graphics lxqt qt terminals ebook video imagemagick photo gimp pdf graphviz image-viewers libreoffice
 ;; web
 chromium tor matrix irc bittorrent
 gnuzilla
 ;; tools
 admin databases version-control file lsof tmux ssh vim bittorrent rust-apps gnupg password-utils moreutils bash disk cpio rsync cryptsetup curl web networking vpn dns hardware certs ntp tls screen
 ;; dev
 android flashing-tools haskell-apps compression commencement pkg-config base gdb m4 maths ocaml libevent tls code node multiprecision sqlite image-viewers matrix wm man)

;; FIXME: [2026-06-21 Sun 12:44] tmp borked hash/vbump in guix upstream <--
(define-public emacs-evil-numbers
  ;; XXX: Upstream did not tag latest release.  Use commit matching exact
  ;; version bump.
  (let ((commit "61dde4e3715fd1255df8f87a37d9c8022e909bf4"))
    (package
      (name "emacs-evil-numbers")
      (version "0.7")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/juliapath/evil-numbers")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "006s8azhypp5n7jnvqkb4rmzqmnsdwj87c3r97zhjzgi2jq953gx"))))
      (build-system emacs-build-system)
      (arguments
       (list
        #:test-command #~(list "emacs" "--batch"
                               "-l" "evil-numbers.el"
                               "-l" "tests/evil-numbers-tests.el"
                               "-f" "ert-run-tests-batch-and-exit")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'skip-failing-tests
              (lambda _
                (substitute* "tests/evil-numbers-tests.el"
                  (("\\(ert-deftest simple-negative .*" all)
                   (string-append all " (skip-unless nil)"))))))))
      (native-inputs (list emacs-ert-runner))
      (propagated-inputs (list emacs-evil))
      (home-page "https://github.com/juliapath/evil-numbers")
      (synopsis "Increment and decrement numeric literals")
      (description
       "This package provides functionality to search for a number up to the
end of a line and increment or decrement it.")
      (license license:gpl3+))))

(define-public emacs-evil-mc
  (let ((commit "7e363dd6b0a39751e13eb76f2e9b7b13c7054a43")
        (revision "0"))
    (package
      (name "emacs-evil-mc")
      (version (git-version "0.0.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/gabesoft/evil-mc")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0gzy2mqcdxhkg0hmxqzbjy5ihfal1s21wxd04mrikqri54sck4z5"))))
      (build-system emacs-build-system)
      (arguments
       (list #:test-command
             #~(list "emacs" "--no-init-file" "--batch"
                     "--eval=(require 'ecukes)" "--eval=(ecukes)")))
      (propagated-inputs
       (list emacs-evil))
      (native-inputs
       (list emacs-ecukes
             emacs-espuds
             emacs-evil-numbers
             emacs-evil-surround))
      (home-page "https://github.com/gabesoft/evil-mc")
      (synopsis "Interactive search compatible with @code{multiple-cursors}")
      (description "This package can be used with @code{multiple-cursors} to
provide an incremental search that moves all fake cursors in sync.")
      (license license:expat))))
;; FIXME: [2026-06-21 Sun 12:44] tmp borked hash/vbump in guix upstream -->

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
        emacs-nano-calendar
        emacs-hyperbole
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
        emacs-nov
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
        emacs-expand-region

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
        emacs-git-timemachine
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
        emacs-time-zones
        emacs-casual
        emacs-elpher
        emacs-calibre
        emacs-calibredb
        ;; 🗺
        emacs-osm
        ;; multimedia apps
        emacs-emms

        ;; spell
        hunspell
        hunspell-dict-fr-toutes-variantes
        hunspell-dict-en-us
        hunspell-dict-en-gb
        emacs-jinx

        ;; transverse:
        emacs-ibuffer-projectile
        emacs-projectile

        ;; code: ()
        emacs-origami
        emacs-outline-indent
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
        guile-3.0-latest
        guile-readline
        guile-colorized
        guile-pipe
        ;; rest
        emacs-plz
        ;; guix / dev env:
        emacs-buffer-env
        emacs-inheritenv
        ;; maxi passat:
        emacs-org-sql
        emacs-org-ml

        ;; completion framework
        emacs-embark
        emacs-vertico
        emacs-marginalia
        emacs-orderless
        emacs-corfu
        emacs-nerd-icons-corfu
        emacs-pcmpl-args
        emacs-cape
        emacs-consult
        emacs-consult-dir
        emacs-consult-lsp
        emacs-consult-yasnippet
        emacs-consult-eglot
        emacs-consult-org-roam
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
        emacs-consult-ripfd

        ;; word smith
        emacs-olivetti

        ;; simple gui
        emacs-alert
        emacs-beacon
        emacs-nyan-mode
        emacs-doom-modeline
        emacs-svg-tag-mode
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
        ;; emacs-exwm-modeline
        emacs-exwm-firefox-core
        emacs-exwm-firefox-evil
        emacs-exwm-mff
        emacs-perspective
        emacs-persp-mode
        emacs-lemon
        emacs-dimmer
        emacs-window-layout
        emacs-ace-window
        emacs-ace-link      ;; FIXME
        emacs-ace-jump-mode ;; FIXME
        ;; emacs-buffer-expose
        emacs-switch-window

        ;; system
        emacs-bluetooth
        emacs-pulseaudio-control
        ;; emacs-tramp ;; tramp hlo needs recent tramp.
        ;; emacs-tramp-hlo

        ;; x stuff
        emacs-desktop-environment
        emacs-zathura-sync-theme
        ;; https://codeberg.org/tusharhero/emacs-reader pdf reader

        ;; comms
        emacs-ement
        emacs-mastodon
        emacs-slack
        ;; emacs-erc-hl-nicks
        emacs-erc-image
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
        kitty
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
        ungoogled-chromium
        speedtest-cli
        netcat-openbsd
        nmap
        yt-dlp
        ;; ☠
        onionshare
        `(,transmission "gui")))

(define-public %hack-the-world
  (list wireshark))

(define-public %image-edition-world
  (list
   gimp
   ;; kdenlive
   ;; frei0r
   krita))

(define-public %fonts-world
  (list font-jetbrains-mono
        font-google-roboto-mono
        font-nerd-symbols
        font-google-noto-emoji
        font-misc-misc))

(define-public %ocaml-with-opam-world
  (list opam
        ;; mercurial
        ;; darcs ; borked [2026-06-21 Sun 11:11]
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

(define-public %guile-world
  (list guile-readline
        guile-colorized
        guile-pipe))

(define-public %vcs-world
  (list ;; mercurial
   ;; darcs ; borked [2026-06-21 Sun 11:11]
   git
   git-annex))

(define-public %git-world
  (list git
        git-annex))

(define-public %dev-world
  (list sloccount
        cloc
        adb
        fastboot
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
   strace
   fastfetch-minimal
   ;; compression
   p7zip
   unzip
   unrar
   ;; android
   adb
   fastboot
   ;; web
   curl
   jq))

(define-public %os-net-world ;; complements %utils-world
  (list
   `(,isc-bind "utils") ;; dns: dig nslookup
   iproute
   iw
   ndisc6
   net-tools ;; netstat
   openntpd
   tcpdump
   ;; ssl
   gnutls
   openssl
   ;; wg
   wireguard-tools))

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

(define-public %comms-world
  (list pantalaimon))

(define-public %borked-2026-02
  (list ungoogled-chromium))

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
