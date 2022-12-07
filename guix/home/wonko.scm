(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu services)
             ;; fonts
	     (w7 packages fonts)
             (gnu packages fontutils)
             (gnu packages unicode)
             ;; emacs
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages aspell)
             (gnu packages libreoffice)
             ;; tools
             (gnu packages admin)
             (gnu packages xorg)	; xinit
             (gnu packages version-control)
             (gnu packages synergy)
             (gnu packages tmux)
             ;; guix
             (guix gexp))

(define conf-root-dir (dirname (dirname (dirname (current-filename))))) ;; threading macro plz?

(home-environment
 (packages (list
            emacs ;; TODO: native compilation
            ;; emacs-next
            ;; basic (bitches):
            emacs-general
            emacs-use-package
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

            ;; guile/scheme <3
            emacs-geiser
            emacs-geiser-guile

            ;; spell
            emacs-flyspell-correct
            emacs-auto-dictionary-mode

            ;; transverse:
            emacs-ibuffer-projectile
            emacs-projectile
            emacs-magit
            emacs-magit-annex
            emacs-emojify

            ;; code:
            emacs-rainbow-delimiters
            emacs-rainbow-identifiers
            emacs-lsp-mode

            ;; completion framework
            emacs-orderless
            ;;"emacs-consult-org-roam"
            ;;"emacs-consult-lsp"
            ;;"emacs-consult-dir" ;; meh
            ;;"emacs-consult-yasnippet"
            emacs-consult
            emacs-embark
            emacs-vertico
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
            emacs-all-the-icons-dired
            ;; exwm
            emacs-exwm
            emacs-lemon
            ;; x stuff
            emacs-desktop-environment
            xinit xset xhost xorg-server xf86-input-libinput xf86-video-fbdev xf86-video-nouveau

            ;; fonts
            font-nerd-jetbrains
            font-nerd-noto
            font-nerd-symbols
            font-goog-noto-emoji

            ;; other lightweight stuff I'm gonna need:
            synergy
            git
            tmux))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (bash-profile (list (plain-file "bash-profile"
                                             "export HISTFILE=$XDG_CACHE_HOME/.bash_history")))))
   (simple-service 'emacsd-config-files
                   home-files-service-type
                   (map (lambda (file)
                          `(,(string-append ".emacs.d/" file)
                            ,(local-file (string-append conf-root-dir "/emacs.d/" file))))
                        '("completion.el"
                          "evil.el"
                          "fancy.el"
                          "init.el"
                          "lisp-config.el"
                          "maps.el"
                          "org-conf.el")))
   (simple-service 'config-files
                   home-files-service-type
                   ;; exwm config is outside of .emacs.d:
                   `((".exwm" ,(local-file (string-append conf-root-dir  "/emacs.d/exwm.el")))
                     (".xinitrc" ,(local-file (string-append conf-root-dir  "/emacs.d/exwm.el")))
                     (".xsession" ,(program-file ;; slim/gdm will exec this:
                                    "xsession"
                                    #~(system
                                       (format #f "~a +SI:localuser:$USER\n\
                                                    ~a b 0 0 0\n\
                                                    ~a r rate 400 30\n\
                                                    ~a -cursor_name left_ptr\n\
                                                    ~a -fv\n\
                                                    exec ~a\n"
                                               #$(file-append xhost "/bin/xhost")
                                               #$(file-append xset "/bin/xset")
                                               #$(file-append xset "/bin/xset")
                                               #$(file-append xsetroot "/bin/xsetroot")
                                               #$(file-append fontconfig "/bin/fc-cache")
                                               #$(file-append emacs-exwm "/bin/exwm"))))))
                   ;; git, etc:
                   )
   (simple-service 'guix-config-files
                   home-files-service-type
                   (map (lambda (file)
                          `(,(string-append ".config/guix/" file)
                            ,(local-file (string-append conf-root-dir "/guix/config/" file))))
                        '("shell-authorized-directories"
                          "channels.scm" ;; FIXME redundant
                          ))))))
