(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu services)
             ;; fonts
	     (w7 packages fonts)
	     (gnu packages fonts)
             (gnu packages fontutils)
             (gnu packages unicode)
             ;; emacs
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages aspell)
             (gnu packages libreoffice)
	     (gnu packages ocaml)
	     ;; tools
             (gnu packages admin)
             (gnu packages xorg)	; xinit
             (gnu packages version-control)
             (gnu packages synergy)
             (gnu packages tmux)
             (gnu packages ssh)
	     (gnu packages databases) ; recutils
             ;; dev
             (gnu packages haskell-apps)
             (gnu packages compression)
             (gnu packages commencement) ; gcc
             (gnu packages pkg-config)
             (gnu packages base)
             (gnu packages gdb)
             (gnu packages m4)
             (gnu packages maths)
             ;; services
             (gnu packages image-viewers)
             (w7 packages jonaburg-picom)
             ;; doc
             (gnu packages man)
             ;; guix
             (guix gexp))

(define conf-root-dir (dirname (dirname (dirname (current-filename))))) ;; threading macro plz?

(home-environment
 (packages (list
            emacs ;; TODO: native compilation
            ;; emacs-next
            ;; basic (bitches) stuff:
            emacs-general
            emacs-emacsql-sqlite3

            ;; org
            emacs-org
            emacs-org-roam
            emacs-org-super-agenda
            ;; emacs-org-download (images)
            ;;"emacs-org-ref"
            ;;"emacs-org-static-blog"
            ;;"emacs-org2web"
            ;;"emacs-org-web-tools" (sucking stuff out of www)
            ;;"emacs-org-beautify-theme"
            ;;"org-superstar-mode"
            emacs-org-modern
            ;; FIXME emacs-org-ql
            ;; emacs-org-auto-expand
            ;; emacs-org-appear
            ;; emacs-orgit (link to magit)

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
            emacs-circe
            emacs-pass
            emacs-magit
            emacs-magit-annex
            emacs-dirvish
            emacs-eshell-up
            emacs-dired-du
            emacs-diredfl
            emacs-dired-rsync
            emacs-all-the-icons-dired
            emacs-dired-toggle-sudo

            ;; guile/scheme <3
            emacs-geiser
            emacs-geiser-guile
            emacs-guix

            ;; spell
            emacs-flyspell-correct
            emacs-auto-dictionary-mode

            ;; transverse:
            emacs-ibuffer-projectile
            emacs-projectile
            emacs-emojify

            ;; code: ()
            emacs-rainbow-delimiters
            emacs-rainbow-identifiers
            emacs-lsp-mode
            emacs-eval-sexp-fu-el
            ;; ocaml
            emacs-tuareg
            opam mercurial darcs unzip gcc-toolchain gdb gnuplot m4 gnu-make pkg-config

            ;; completion framework
            emacs-orderless
            emacs-consult
            emacs-consult-org-roam
            emacs-consult-dir
            emacs-consult-lsp
            ;;emacs-consult-yasnippet
            emacs-embark
            emacs-vertico
            emacs-vertico-posframe
            emacs-which-key

            ;; spelling
            hunspell
            hunspell-dict-fr-toutes-variantes
            hunspell-dict-en-us
            hunspell-dict-en-gb
            hunspell-dict-en-gb-ize

            ;; simple gui
            emacs-doom-modeline
            emacs-doom-themes
            emacs-all-the-icons
            emacs-all-the-icons-completion
            ;; exwm
            emacs-exwm
            emacs-lemon
            ;; x stuff
            emacs-desktop-environment
            xinit xset xhost xorg-server xf86-input-libinput xf86-video-fbdev xf86-video-nouveau

            ;; fonts
            ;; font-nerd-jetbrains
            font-jetbrains-mono
            font-nerd-noto
            font-nerd-symbols
            font-goog-noto-emoji

            ;; other lightweight stuff I'm gonna need:
            ;; gpg!
            recutils
            synergy
            openssh
            git
            tmux
            man-db ;; check this
            ;; services
            jonaburg-picom
            synergy
            ))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (bash-profile (list (plain-file "bash-profile"
                                             "export HISTFILE=$XDG_CACHE_HOME/.bash_history
export GUIX_PROFILE=~/.guix-extra-profiles/web
test -r $GUIX_PROFILE/etc/profile && . $GUIX_PROFILE/etc/profile
export GUIX_PROFILE=~/.guix-extra-profiles/desktop
test -r $GUIX_PROFILE/etc/profile && . $GUIX_PROFILE/etc/profile
export PAGER=\"\"
export PATH=\"./_opam/bin:$PATH\"
export LIBRARY_PATH=\"$LIBRARY_PATH:~/.guix-profile/lib\"
export C_INCLUDE_PATH=\"$C_INCLUDE_PATH:~/.guix-profile/include\"
export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:~/.guix-profile/lib\"
export PATH=\"~/local/bin:$PATH\"
test -r ~/.opam/opam-init/init.sh && . ~/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
export GDK_SCALE=2
export GDK_DPI_SCALE=1")))))
   (simple-service 'emacsd-config-files
                   home-files-service-type
                   (map (lambda (file)
                          `(,(string-append ".emacs.d/" file)
                            ,(local-file (string-append conf-root-dir "/emacs.d/" file))))
                        '("completion.el"
                          "dev.el"
                          "doom.el"
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
                   `((".exwm" ,(local-file (string-append conf-root-dir  "/emacs.d/exwm.el")))
                     (".xsession" ,(program-file ;; slim/gdm will exec this:
                                    "xsession"
                                    #~(system
                                       (format #f "source ~~/.bash_profile; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; exec ~a"
                                               #$(file-append xset "/bin/xset")             "b 0 0 0"
                                               #$(file-append xset "/bin/xset")             "r rate 400 30"
                                               #$(file-append xsetroot "/bin/xsetroot")     "-cursor_name left_ptr"
                                               #$(file-append setxkbmap "/bin/setxkbmap")   "dvorak"
                                               #$(file-append xmodmap "/bin/xmodmap")       "~/.local/fixme/common.xmodmap"
                                               #$(file-append xmodmap "/bin/xmodmap")       "~/.local/fixme/yggdrasill.xmodmap"
                                               #$(file-append xinput "/bin/xinput")         "set-prop 14 'libinput Click Method Enabled' 0 1"
                                               #$(file-append xinput "/bin/xinput")         "set-prop 14 'libinput Accel Speed' 1.0"
                                               #$(file-append feh "/bin/feh")               "--bg-scale /data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png"
                                               #$(file-append emacs-exwm "/bin/exwm")))))
                     ;; git, etc:
                     (".gitconfig" ,(local-file (string-append conf-root-dir  "/misc/gitconfig"))) ;; setxkbmap
                     ;; when do I exec setxkbmap then ?
                     (".local/fixme/yggdrasill.xmodmap" ,(local-file (string-append conf-root-dir  "/misc/yggdrasill.xmodmap")))
                     (".local/fixme/common.xmodmap" ,(local-file (string-append conf-root-dir  "/misc/common.xmodmap")))
                     ;; shepherd & services
                     (".config/shepherd/init.scm" ,(local-file (string-append conf-root-dir  "/guix/home/shepherd/init.scm")))
                     (".config/shepherd/init.d/picom.scm" ,(local-file (string-append conf-root-dir  "/guix/home/shepherd/init.d/picom.scm")))
                     (".config/shepherd/init.d/synergy.scm" ,(local-file (string-append conf-root-dir  "/guix/home/shepherd/init.d/synergy.scm")))
                     (".config/picom.conf" ,(local-file (string-append conf-root-dir  "/misc/picom.conf")))
                     (".config/Synergy/Synergy.conf" ,(local-file (string-append conf-root-dir  "/misc/Synergy.conf")))
                     (".config/nyxt/init.lisp" ,(local-file (string-append conf-root-dir  "/misc/nyxt.lisp")))))
   (simple-service 'guix-config-files
                   home-files-service-type
                   (map (lambda (file)
                          `(,(string-append ".config/guix/" file)
                            ,(local-file (string-append conf-root-dir "/guix/config/" file))))
                        '("shell-authorized-directories"
                          "channels.scm" ;; FIXME redundant
                          ))))))
