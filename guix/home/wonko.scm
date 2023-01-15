(use-modules
 (guix gexp)
 (gnu home)
 (gnu home services)
 (gnu home services shells)
 (gnu services)

 ;; fonts
 (w7 packages fonts)
 ;; FIXME:
 (gnu packages fonts)
 ;; there -can- should only be one
 (gnu packages fontutils)
 (gnu packages unicode)

 ;; emacs
 (gnu packages emacs)
 (gnu packages emacs-xyz)
 (gnu packages aspell)
 (gnu packages hunspell)
 (gnu packages libreoffice)
 (gnu packages ocaml)

 ;; desktop stuff
 (gnu packages pulseaudio)
 (gnu packages synergy)
 (gnu packages xorg) ;; xinit
 (gnu packages linux)
 (gnu packages xdisorg)
 (gnu packages suckless)
 (gnu packages music)
 (gnu packages lxde)
 (gnu packages gnome)
 (gnu packages kde-plasma)
 (gnu packages kde-frameworks)

 ;; tools
 (gnu packages admin)
 (gnu packages databases) ;; recutils
 (gnu packages version-control)
 (gnu packages tmux)
 (gnu packages ssh)
 (gnu packages bittorrent)
 (gnu packages rust-apps) ;; fd rg
 (gnu packages gnupg)
 (gnu packages password-utils)
 (gnu packages bash)

 ;; dev
 (gnu packages haskell-apps)
 (gnu packages compression)
 (gnu packages commencement) ;; gcc
 (gnu packages pkg-config)
 (gnu packages base)
 (gnu packages gdb)
 (gnu packages m4)
 (gnu packages maths)

 ;; services
 (gnu home services shepherd)
 (gnu packages image-viewers)
 (gnu packages matrix)
 (w7 packages jonaburg-picom)
 (w7 packages emacs-xyz)
 ;; doc
 (gnu packages man))

(define conf-root-dir
  (dirname
   (dirname
    (dirname
     (current-filename))))) ;; threading macro plz?

(home-environment
 (packages
  (list
   emacs ;; TODO: native compilation
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
   ;; FIXME emacs-org-ql
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
   emacs-evil-surround
   emacs-evil-org
   emacs-evil-matchit
   emacs-evil-leader
   emacs-evil-goggles
   emacs-evil-exchange
   emacs-evil-escape
   emacs-evil-collection
   emacs-evil-cleverparens
   emacs-evil-snipe
   ;; emacs-evil-args
   ;; emacs-evil-lion (align)
   ;;emacs-evil-multiedit
   ;;emacs-evil-mc
   ;; emacs-evil-visualstar
   ;; emacs-evil-textobj-syntax
   ;;emacs-evil-commentary
   ;;emacs-evil-smartparens
   ;;emacs-evil-paredit
   ;;emacs-vdiff-magit

   ;; apps
   emacs-elfeed
   emacs-elfeed-org
   emacs-elfeed-goodies
   emacs-circe
   emacs-pass
   emacs-magit
   emacs-magit-annex
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
   ;; ocaml
   emacs-eval-in-repl-ocaml
   emacs-tuareg
   opam mercurial darcs unzip gcc-toolchain gdb gnuplot m4 gnu-make pkg-config
   ;; guile/scheme <3
   emacs-geiser
   emacs-geiser-guile
   emacs-guix

   ;; completion framework
   emacs-orderless
   emacs-consult
   emacs-consult-org-roam
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
   emacs-ace-window  ;; FIXME
   emacs-ace-link ;; FIXME
   emacs-ace-jump-mode ;; FIXME
   emacs-buffer-expose
   ;; x stuff
   emacs-desktop-environment
   xinit xset xhost xorg-server xf86-input-libinput xf86-video-fbdev xf86-video-nouveau
   pamixer brightnessctl scrot upower playerctl ;; tlp and have emacs set rfkill for me? fuck that noise.

   ;; fonts
   ;; font-nerd-jetbrains
   font-jetbrains-mono
   font-nerd-noto
   font-nerd-symbols
   font-goog-noto-emoji

   ;; bling
   breeze breeze-gtk breeze-icons

   ;; gpg/pass/ssh
   password-store gnupg
   emacs-pass
   emacs-auth-source-pass
   emacs-pinentry
   pinentry-emacs
   openssh

   ;; other utilts
   recutils
   tree
   git
   tmux
   acpi

   ;; services
   ibhagwan-picom
   synergy

   ;; communication
   emacs-ement
   pantalaimon

   ;; ☠
   rtorrent
   emacs-mentor

   ;; basic system stuff
   man-db))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (aliases
              '(("g" . "git")
                ("psrg" . "ps aux | rg")
                ("df" . "df -h")
                ("dmesg" . "dmesg -He")
                ("ls" . "ls --color=yes")
                ("ll" . "ls -l --color=auto")
                ("la" . "ls -A --color=auto")
                ("lla" . "ls -lA --color=auto")
                ("lsd" . "ls -lAc --color=auto")
                ("t" . "tree -AC")
                ("tarc" . "tar -cavf")
                ("tarx" . "tar -xavf")
                ("tart" . "tar -tavf")
                ("rsy" . "rsync -hrlpD --progress")
                ("prsy" . "rsync -hrlpD --progress --owner --group")
                ("nmcli" . "nmcli -c yes")
                ("ip" . "ip -c -h")))
             (environment-variables
              '(("HISTFILE" . "$XDG_CACHE_HOME/.bash_history")
                ("PAGER" . "")
                ("PATH" . "./_opam/bin:$PATH")
                ("LIBRARY_PATH" . "$LIBRARY_PATH:~/.guix-profile/lib")
                ("C_INCLUDE_PATH" . "$C_INCLUDE_PATH:~/.guix-profile/include")
                ("LD_LIBRARY_PATH" . "$LD_LIBRARY_PATH:~/.guix-profile/lib")
                ("PATH" . "~/local/bin:$PATH")
                ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
                ("PASSWORD_STORE_DIR" . "/data/pass")
                ("RIPGREP_CONFIG_PATH" . "~/.config/ripgrep/ripgreprc")
                ("GDK_SCALE" . "2")
                ("GDK_DPI_SCALE" . "1")))
             (bash-profile
              (list
               (plain-file "bash-profile"
                           "# hey boy. hey girl. superstar DJ. here we go!
for p in dev net desktop web utils; do
    profile=$GUIX_EXTRA_PROFILES/$p
    if [ -f $profile/etc/profile ]; then
        GUIX_PROFILE=$profile
        . $GUIX_PROFILE/etc/profile
    fi
    unset profile
done
test -r ~/.opam/opam-init/init.sh && . ~/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true")))))

   (simple-service 'emacsd-config-files
                   home-files-service-type
                   (map
                    (lambda
                        (file)
                      `(,(string-append ".emacs.d/" file)
                        ,(local-file
                          (string-append conf-root-dir "/emacs.d/" file))))
                    '("completion.el"
                      "communication.el"
                      "dev.el"
                      "opam-user-setup.el"
                      "doom.el"
                      "elfeed.el"
                      "evil.el"
                      "fancy.el"
                      "init.el"
                      "lisp-config.el"
                      "maps.el"
                      "misc.el"
                      "org-conf.el")))

   (simple-service 'config-files
                   home-files-service-type
                   ;; exwm config is outside of .emacs.d:
                   `((".exwm" ,(local-file
                                (string-append conf-root-dir  "/emacs.d/exwm.el")))
                     (".xsession" ,(program-file ;; slim/gdm will exec this:
                                    "xsession"
                                    #~(system
                                       (format #f "source ~~/.bash_profile; ~a +SI:localuser:$USER; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; exec ~a"
                                               #$(file-append xhost "/bin/xhost")
                                               #$(file-append xset "/bin/xset")
                                               "b 0 0 0"
                                               #$(file-append xset "/bin/xset")
                                               "r rate 400 30"
                                               #$(file-append xsetroot "/bin/xsetroot")
                                               "-cursor_name left_ptr"
                                               #$(file-append setxkbmap "/bin/setxkbmap")
                                               "dvorak"
                                               #$(file-append xmodmap "/bin/xmodmap")
                                               "~/.local/fixme/common.xmodmap"
                                               #$(file-append xmodmap "/bin/xmodmap")
                                               "~/.local/fixme/yggdrasill.xmodmap"
                                               #$(file-append xinput "/bin/xinput")
                                               "set-prop 14 'libinput Click Method Enabled' 0 1"
                                               #$(file-append xinput "/bin/xinput")
                                               "set-prop 14 'libinput Accel Speed' 1.0"
                                               #$(file-append feh "/bin/feh")
                                               "--bg-scale '/data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png'"
                                               #$(file-append emacs-exwm "/bin/exwm")))))
                     (".gitconfig" ,(local-file
                                     (string-append conf-root-dir  "/misc/gitconfig")))
                     (".local/fixme/yggdrasill.xmodmap" ,(local-file
                                                          (string-append conf-root-dir  "/misc/yggdrasill.xmodmap")))
                     (".local/fixme/common.xmodmap" ,(local-file
                                                      (string-append conf-root-dir  "/misc/common.xmodmap")))
                     (".config/picom.conf" ,(local-file
                                             (string-append conf-root-dir  "/misc/picom.conf")))
                     (".config/pantalaimon/pantalaimon.conf" ,(local-file
                                                               (string-append conf-root-dir  "/misc/pantalaimon.conf")))
                     (".config/Synergy/Synergy.conf" ,(local-file
                                                       (string-append conf-root-dir  "/misc/Synergy.conf")))
                     (".config/nyxt/init.lisp" ,(local-file
                                                 (string-append conf-root-dir  "/misc/nyxt.lisp")))
                     (".config/ripgrep/ripgreprc" ,(local-file
                                                 (string-append conf-root-dir  "/misc/ripgreprc")))))

   (simple-service 'guix-config-files
                   home-files-service-type
                   (map
                    (lambda
                        (file)
                      `(,(string-append ".config/guix/" file)
                        ,(local-file
                          (string-append conf-root-dir "/guix/config/" file))))
                    '("shell-authorized-directories"
                      "channels.scm")))

   (service home-shepherd-service-type
            (home-shepherd-configuration
             (services
              (list
               (shepherd-service
                (provision '(picom))
                (start #~(make-forkexec-constructor
                          (list #$(file-append ibhagwan-picom "/bin/picom"))
                          #:log-file "log/picom.log"))
                (stop #~(make-kill-destructor))
                (documentation "bling"))
               (shepherd-service
                (provision '(pantalaimon))
                (start #~(make-forkexec-constructor
                          (list #$(file-append pantalaimon "/bin/pantalaimon"))
                          #:log-file "log/matrix.log"))
                (stop #~(make-kill-destructor))
                (documentation "Crypto back-end server for ement.el"))
               (shepherd-service
                (provision '(synergy))
                (start #~(make-forkexec-constructor
                          (list #$(file-append synergy "/bin/synergy"))
                          #:log-file "log/synergy.log"))
                (stop #~(make-kill-destructor))
                (documentation "can't be arsed to move IRL"))
               (shepherd-service
                (provision '(guix-repl))
                (start #~(make-forkexec-constructor
                          (list (string-append (getenv "HOME") "/.config/guix/current/bin/guix") "repl" "--listen=tcp:37146")
                          #:environment-variables '("INSIDE_EMACS=1")
                          #:log-file "log/guix-repl.log"))
                (stop #~(make-kill-destructor))
                (documentation "REPL to me, like lovers do")))))))))
