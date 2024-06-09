(define-module (wonko homes)
 #:use-module (guix gexp)
 #:use-module (guix modules)
 #:use-module (gnu home)
 #:use-module (gnu home services)
 #:use-module (gnu home services shells)
 #:use-module (gnu system shadow)
 #:use-module (gnu services)
 #:use-module (guix profiles)
 #:use-module (srfi srfi-1)
 #:use-module (srfi srfi-11)

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

 ;; desktop stuff
 #:use-module (gnu packages glib)
 #:use-module (gnu packages pulseaudio)
 #:use-module (gnu packages synergy)
 #:use-module (gnu packages xorg)
 #:use-module (gnu packages toys)
 #:use-module (gnu packages linux)
 #:use-module (gnu packages xdisorg)
 #:use-module (gnu packages suckless)
 #:use-module (gnu packages music)
 #:use-module (gnu packages xfce)
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
 #:use-module (gnu packages tor)

 ;; dev
 #:use-module (gnu packages haskell-apps)
 #:use-module (gnu packages compression)
 #:use-module (gnu packages commencement) ;; gcc
 #:use-module (gnu packages pkg-config)
 #:use-module (gnu packages base)
 #:use-module (gnu packages gdb)
 #:use-module (gnu packages m4)
 #:use-module (gnu packages maths)

 ;; services
 #:use-module (gnu home services shepherd)
 #:use-module (gnu packages image-viewers)
 #:use-module (gnu packages matrix)
 #:use-module (gnu packages wm)
 #:use-module (gnu packages compton)
 #:use-module (w7 packages emacs-xyz)

 ;; doc
 #:use-module (gnu packages man)

 ;; my stuff
 #:use-module (wonko defs)
 #:use-module (wonko fleet)
 #:use-module (wonko dotfiles)
 #:use-module (wonko pkgs))

(define %term-cmd "urxvt")

(define %emacs-values
  #~(progn
     (setq my/font #$%font
           my/lambda-project   #$%lambda-project
           my/font-size        120
           my/modeline-height  40
           my/tag-height       0.95
           my/tag-font-size    11
           my/tag-radius       300
           my/tag-padding      15
           my/org-agenda-tags-column 78
           my/org-habit-preceding-days 43
           my/window-divider-default-right-width 2
           my/term-cmd #$%term-cmd
           my/lock-cmd #$(apply
                          string-append
                          (concatenate
                           ((@ (srfi srfi-1) zip)
                            %lock-cmd
                            (circular-list " ")))))
     (provide 'conf/generated-values)))

(define %aliases
  `(("g" . "git")
    ("psrg" . "ps aux | rg")
    ("df" . "df -h")
    ("dmesg" . "dmesg -He")
    ("free" . "free -h")
    ("grep" . "grep --color=auto")
    ("ls" . "ls --color=yes")
    ("ll" . "ls -l --color=auto")
    ("la" . "ls -A --color=auto")
    ("lla" . "ls -lA --color=auto")
    ("lsd" . "ls -lAc --color=auto")
    ("t" . "tree -C")
    ("tarc" . "tar -cavf")
    ("tarx" . "tar -xavf")
    ("tart" . "tar -tavf")
    ("rsy" . "rsync -hrlpD --progress")
    ("prsy" . "rsync -hrlpD --progress --owner --group")
    ("nmcli" . "nmcli -c yes")
    ("ip" . "ip -c -h")))

(define-public %profiles
  `(("communication" . ,%communication-world)
    ("desktop" . ,%desktop-world)
    ("utils" . ,%utils-world)
    ("web" . ,%web-world)))

(define-public (profiles->names ps)
  (map car ps))

;;;;;;;;;;;;;

(define-public %wonko-env
  `(("HISTFILESIZE" . "100000")
    ("HISTSIZE" . "100000")
    ("HISTFILE" . "$XDG_CACHE_HOME/.bash_history")
    ("HISTCONTROL" . "ignorespace")
    ("PAGER" . "")
    ("DICTIONARY" . "en_GB-ise") ;; hunspell
    ("DISPLAY" . ":9")
    ("BLOCK_SIZE" . "human-readable")
    ("LIBRARY_PATH" . "$LIBRARY_PATH:~/.guix-home/profile/lib")
    ("C_INCLUDE_PATH" . "$C_INCLUDE_PATH:~/.guix-home/profile/include")
    ("LD_LIBRARY_PATH" . "$LD_LIBRARY_PATH:~/.guix-home/profile/lib")
    ("PATH" . "$HOME/local/bin:$PATH")
    ("PATH" . "./_opam/bin:$PATH")
    ("GUIX_EXTRA_PROFILES" .
     ,(string-append "$HOME" %guix-extra-profiles-dir))
    ("GUILE_LOAD_PATH" .
     ,(string-append "$GUILE_LOAD_PATH:" %lambda-project))
    ("GUIX_LOCPATH" . "$HOME/.guix-home/profile/lib/locale")
    ("LANG" . "en_GB.utf8")
    ("PASSWORD_STORE_DIR" . "/data/pass")
    ("PASSWORD_STORE_GENERATED_LENGTH" . "33")
    ;; ("PS1" . "is in bashrc because I want it after source /etc/bashrc")
    ("RIPGREP_CONFIG_PATH" . "$HOME/.config/ripgrep/ripgreprc")
    ("QT_QPA_PLATFORM_PLUGIN_PATH" . "$HOME/.guix-home/profile/lib/qt5/plugins")
    ("QT_STYLE_OVERRIDE" . "kvantum")
    ("XDG_CURRENT_DESKTOP" . "qt5ct")
    ;; ("FLEET" .
    ;;  ,(string-concatenate
    ;;    (concatenate ((@ (srfi srfi-1) zip)
    ;;                  (map ship-name %fleet)
    ;;                  (circular-list " ")))))
    ))

(define-public %wonko-bash-config
  (home-bash-configuration
   (guix-defaults? #f)
   (aliases %aliases)
   (environment-variables %wonko-env)
   (bashrc
    (list
     (mixed-text-file
      "bash-options"
      "# Source the system-wide file.\n"
      "[ -f /etc/bashrc ] && source /etc/bashrc\n")
     (mixed-text-file
      "interactive-shell-bash-options"
      "[[ $- != *i* ]] && return ## ssh/non-interactive shells exit here\n"
      "shopt -s autocd\n"
      "shopt -s extglob\n"
      "shopt -s globstar\n"
      "shopt -s nocaseglob\n"
      ;; this affects emacs' completion:
      "bind 'set completion-ignore-case on' 2> /dev/null\n"
      "[ x$TERM = xtramp ] && return\n"
      "PS1='$(if [ x$? = x0 ]; then echo 🍏; else echo 🍎 [$?]; fi)"
      " \\A \\u@\\h "
      "$([ ! -z \"$SSH_CLIENT\" ] && echo \"📡 \")"
      "\\w${GUIX_ENVIRONMENT:+ [env]}\nλ '\n"
      "set -o vi\n"
      "bind '\"jj\":vi-movement-mode'\n")))))

;; (define-public (per-hostname-files hostname)
;;   )

(define-public %wonko-services
  (list
   (simple-service 'sourcing-extra-profiles home-shell-profile-service-type
                   (list
                    ;; (mixed-text-file
                    ;;  "force-tramp-shopt"
                    ;;  "shopt -s autocd\n"
                    ;;  "shopt -s extglob\n"
                    ;;  "shopt -s globstar\n"
                    ;;  "shopt -s nocaseglob\n")
                    (bash-profile-source-profiles (profiles->names %profiles))))


   (simple-service 'emacsd-config-files
                   home-files-service-type
                   (map
                    (lambda (file)
                      `(,(string-append ".emacs.d/" file)
                        ,(local-file
                          (string-append %lambda-project "/emacs.d/" file))))
                    '("completion.el"
                      "communication.el"
                      "dev.el"
                      "opam-user-setup.el"
                      "doom.el"
                      "elfeed.el"
                      "evil.el"
                      "fancy.el"
                      "early-init.el"
                      "init.el"
                      "lisp-config.el"
                      "keys.el"
                      "misc.el"
                      "org-conf.el")))

   (simple-service 'emacsd-snippets-config-files
                   home-files-service-type
                   (map
                    (lambda (file)
                      `(,(string-append ".emacs.d/snippets/" file)
                        ,(local-file
                          (string-append %lambda-project "/emacs.d/snippets/" file))))
                    '("fundamental-mode/danger_triangle"
                      "org-mode/begin_src"
                      "org-mode/begin_quote")))

   (simple-service 'emacsd-generated-config-files
                   home-files-service-type
                   (list
                    `(".emacs.d/generated-values.el"
                      ,(scheme-file "_" %emacs-values))))

   (simple-service
    'config-files
    home-files-service-type
    ;; exwm config is outside of .emacs.d:
    `((".exwm"
       ,(local-file
         (string-append %lambda-project "/emacs.d/exwm.el")))
      (".emacs.d/aliases"
       ,(plain-file "aliases"
                    (emacs-eshell-aliases-configuration %aliases)))
      ;; (".x-config"
      ;;  ,(program-file "x-config"
      ;;                 (ship-x-config %ship)))
      (".xsession"
       ,(program-file
         "xsession"
         (cmd+arg->script
          `(("source" . "~/.bash_profile")
            (xhost . "+SI:localuser:$USER")
            (xset . "b 0 0 0")
            (xset . "r rate 400 30")
            (xset . "dpms 600 1200 0")
            ;; FIXME
            ;; ,(if (ship-media-station? %ship)
            ;;      `(xset . "s off -dpms")
            ;;      `(xset . "dpms 600 1200 0"))
            (xsetroot . "-cursor_name left_ptr")
            (setxkbmap . "dvorak")
            (xmodmap . "~/.config/x-config/common.xmodmap")
            (xmodmap . "~/.config/x-config/ship.xmodmap") ;; TODO carefull
            (feh . ,(string-append "--bg-scale '" %wallpaper "'"))
            (xrdb  . "-load ~/.Xresources")
            ("~/.x-config" . "")
            (,#~(string-append  "exec " #$dbus "/bin/dbus-launch --exit-with-session")
             . #$(file-append emacs-exwm "/bin/exwm"))))))

      ;; utils:
      (".config/git/config"
       ,(local-file
         (string-append %lambda-project "/misc/gitconfig")))
      (".config/git/attributes"
       ,(local-file
         (string-append %lambda-project "/misc/gitattributes")))
      (".config/ripgrep/ripgreprc"
       ,(local-file
         (string-append %lambda-project "/misc/ripgreprc")))
      ;; GTK & QT configs:
      (".gtkrc-2.0"
       ,(local-file
         (string-append %lambda-project "/misc/gtkrc-2.0")))
      (".config/gtk-3.0/settings.ini"
       ,(local-file
         (string-append %lambda-project "/misc/gtkrc-3.0")))
      (".config/Kvantum/kvantum.kvconfig"
       ,(local-file
         (string-append %lambda-project "/misc/kvantum.kvconfig")))
      ;; (".config/Kvantum/KvGnomish#/KvGnomish#.kvconfig"
      ;;  ,(local-file
      ;;    (string-append %lambda-project "/misc/kv_yggdrasill.kvconfig")))
      (".config/qt5ct/qt5ct.conf"
       ,(local-file
         (string-append %lambda-project "/misc/qt5ct.conf")))
      ;; my X stuff:
      (".XCompose"
       ,(local-file
         (string-append %lambda-project "/misc/XCompose")))
      (".config/x-config/common.xmodmap"
       ,(local-file
         (string-append %lambda-project "/misc/common.xmodmap")))
      (".config/pantalaimon/pantalaimon.conf"
       ,(local-file
         (string-append %lambda-project "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file
         (string-append %lambda-project "/misc/Synergy.conf")))
      ;; (".config/feh/themes"
      ;;  ,(let ((fsz (number->string (ship-feh-font-size %ship))))
      ;;     (mixed-text-file
      ;;      "feh_symlink_name_is_theme_name"
      ;;      "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
      ;;      " --fontpath " %home "/.guix-home/profile/share/fonts/truetype/"
      ;;      " --menu-font JetBrainsMono-Regular/" fsz
      ;;      " --font JetBrainsMono-Regular/" fsz "\n")))
      ))

   (simple-service 'guix-config-files
                   home-files-service-type
                   (map
                    (lambda (file)
                      `(,(string-append ".config/guix/" file)
                        ,(local-file
                          (string-append %lambda-project "/guix/config/" file))))
                    '("shell-authorized-directories"
                      "channels.scm")))

   (simple-service 'guix-manifests
                   home-files-service-type
                   (map
                    (lambda (np)
                      (let-values (((n p) (car+cdr np)))
                        (pkgs->manifest n p)))
                    %profiles))

   (simple-service
    'guix-profiles-scripts
    home-files-service-type
    `(("local/bin/guix-extra-profiles-build"
       ,(program-file
         "_"
         (with-imported-modules
             '((wonko spock)
               (srfi srfi-1)
               (guix build utils))
           #~(begin
               (use-modules (wonko spock)
                            (srfi srfi-1)
                            (guix build utils))
               (let ((guix "~/.config/guix/current/bin/guix")
                     (ps   (let ((args (drop (program-arguments) 1)))
                             (if (null? args)
                                 '#$(profiles->names %profiles)
                                 args))))
                 (map (lambda (p)
                        (display (spock-say
                                  (string-append "build PROFILE " p))
                                 (current-error-port))
                        (newline (current-error-port))
                        (system
                         (string-append guix " package -m ~/local/manifests/" p
                                        " -p $GUIX_EXTRA_PROFILES/" p)))
                      ps))))))

      ("local/bin/guix-os-reconfigure"
       ,(program-file
         "reconfigure"
         (with-imported-modules
             '((guix config)
               (guix memoization)
               (guix profiling)
               (guix build syscalls)
               (guix combinators)
               (guix diagnostics)
               (guix colors)
               (guix i18n)
               (guix utils))
           #~(begin
               (use-modules (guix utils))
               (let ((guix "~/.config/guix/current/bin/guix"))
                 (with-environment-variables
                     '(("GUILE_LOAD_PATH"
                        #$(string-append "$GUILE_LOAD_PATH:" %lambda-project "/guix"))
                       ;; FIXME ("SHIP" #$(ship-name %ship))
                       )
                   (system
                    (string-append guix " system reconfigure "
                                   #$%lambda-project "/guix/os.scm"))))))))))

   (simple-service
    'home-scripts
    home-files-service-type
    `(("local/bin/spock"
       ,(program-file
         "spock"
         (with-imported-modules
             '((wonko spock)
               (srfi srfi-1))
           #~(begin
               (use-modules
                (srfi srfi-1)
                (wonko spock))
               (let* ((args (drop (program-arguments) 1))
                      (greeting (if (equal? args '())
                                    "live long & prosper!"
                                    (string-concatenate
                                     (concatenate
                                      (zip args
                                           (circular-list " ")))))))
                 (display (spock-say greeting))
                 (newline))))))
      ("local/bin/git-add-remotes"
       ,(program-file
         "git-add-remotes"
         #~(begin
             (use-modules
              (srfi srfi-1)
              (srfi srfi-37)
              (ice-9 popen)
              (ice-9 textual-ports))
             (let* ((args (args-fold (cdr (program-arguments))
                                     (list (option '(#\p "push-remote") #t #f
                                                   (lambda (opt name arg acc)
                                                     (alist-cons 'push-remote arg acc)))
                                           (option '(#\f "fleet") #f #f
                                                   (lambda (opt name arg acc)
                                                     (alist-cons 'fleet #t acc)))
                                           (option '(#\l "lab") #f #f
                                                   (lambda (opt name arg acc)
                                                     (alist-cons 'lab #t acc)))
                                           (option '(#\h "hub") #f #f
                                                   (lambda (opt name arg acc)
                                                     (alist-cons 'hub #t acc)))
                                           (option '(#\r "repo") #t #f
                                                   (lambda (opt name arg acc)
                                                     (alist-cons 'repo arg acc))))
                                     (lambda (opt name arg loads)
                                       (error "Unrecognized option `~A'" name))
                                     (lambda (op loads)
                                       (cons op loads))
                                     '()))
                    (repo (or (assoc-ref args 'repo)
                              (getcwd)))
                    (name (basename repo))
                    (git #$(file-append git "/bin/git"))
                    (fleet-remotes (list #$@(map (lambda (s)
                                                   ;; (ship-name s)
                                                   s
                                                   ) %fleet-names))))
               (chdir repo)
               (when (assoc-ref args 'fleet)
                 (map (lambda (rm)
                        (system
                         (string-append git " remote add " rm " " rm ".local:" repo))
                        (newline))
                      fleet-remotes)
                 (string-set! repo 0 #\@) ;; WARNING: don't use repo after this!
                 (system
                  (string-append git " remote add discovery-usb /mnt/discovery/_live/" repo)))
               (when (assoc-ref args 'lab)
                 (system
                  (string-append git " remote add lab git@gitlab.com:wonko7/" name)))
               (when (assoc-ref args 'hub)
                 (system
                  (string-append git " remote add hub git@github.com:wonko7/" name)))
               (when (assoc-ref args 'push-remote)
                 (let* ((pipe (open-input-pipe
                               (string-append git " branch --show-current")))
                        (branch (string-drop-right (get-string-all pipe) 1))
                        (remote (assoc-ref args 'push-remote)))
                   (system
                    (string-append git " push -u " remote " " branch ":inbox-"
                                   "$HOSTNAME" ;; test this.
                                   "-" branch))))))))))

   (simple-service
    'secrets-scripts
    home-files-service-type
    `(("local/bin/secrets-backup"
       ,(program-file
         "_"
         (with-imported-modules
             '((wonko spock)
               (guix build utils))
           #~(begin
               (use-modules (wonko spock)
                            (guix build utils))
               (display (spock-say
                         (string-append "backup SECRETS for ";; FIXME #$(ship-name %ship)
                                        ))
                        (current-error-port))
               (newline (current-error-port))
               (let ((pass   #$(file-append password-store "/bin/pass"))
                     (cat    #$(file-append coreutils "/bin/cat"))
                     (cp     #$(file-append coreutils "/bin/cp"))
                     (base64 #$(file-append coreutils "/bin/base64"))
                     (tar    #$(file-append tar "/bin/tar")))
                 (system
                  (string-append "cd && " tar " czf - .ssh/id_ed25519* | "
                                 base64 " | "
                                 pass " insert -m fleet/" ;; #$(ship-name %ship) FIXME
                                 "/backup-ssh"))
                 (system
                  (string-append cp " ~/.ssh/id_ed25519.pub "
                                 ;; #$%project-lambda "/guix/data/ssh/" #$(ship-name %ship)
                                 ".pub")))))))
      ("local/bin/secrets-deploy"
       ,(program-file
         "_"
         (with-imported-modules
             '((wonko spock)
               (guix build utils))
           #~(begin
               (use-modules (wonko spock)
                            (guix build utils))
               (display (spock-say
                         (string-append "deploy SECRETS for "
                                        ;; #$(ship-name %ship)
                                        ))
                        (current-error-port))
               (newline (current-error-port))
               (let ((pass   #$(file-append password-store "/bin/pass"))
                     (base64 #$(file-append coreutils "/bin/base64"))
                     (tar    #$(file-append tar "/bin/tar")))
                 (system
                  (string-append pass " show fleet/" ;; #$(ship-name %ship) "/ssh | " FIXME
                                 base64 " -d | " tar " xz ")))))))))

   (service
    home-shepherd-service-type
    (home-shepherd-configuration
     (services
      (list
       (shepherd-service
        (provision '(picom))
        (start #~(make-forkexec-constructor
                  (list #$(file-append picom "/bin/picom"))
                  #:log-file "herd-logs/picom.log"))
        (stop #~(make-kill-destructor))
        (documentation "bling"))
       (shepherd-service
        (provision '(pantalaimon))
        (start #~(make-forkexec-constructor
                  (list #$(string-append "~" %guix-extra-profiles-dir
                                         "/communication/bin/pantalaimon"))
                  #:log-file "herd-logs/matrix.log"))
        (stop #~(make-kill-destructor))
        (documentation "Crypto back-end server for ement.el"))
       (shepherd-service
        (provision '(dunst))
        (start #~(make-forkexec-constructor
                  (list #$(file-append dunst "/bin/dunst"))
                  #:log-file "herd-logs/dunst.log"))
        (stop #~(make-kill-destructor))
        (documentation "riced notifications"))
       (shepherd-service
        (provision '(guix-repl))
        (start #~(make-forkexec-constructor
                  (list
                   "~/.config/guix/current/bin/guix"
                   "repl" "--listen=tcp:37146")
                  #:environment-variables '("INSIDE_EMACS=1")
                  #:log-file "herd-logs/guix-repl.log"))
        (stop #~(make-kill-destructor))
        (documentation "REPL to me, like lovers do"))
       (shepherd-service
        (provision '(xss-lock))
        (start #~(make-forkexec-constructor
                  (cons* #$(file-append xss-lock "/bin/xss-lock")
                         "--"
                         '#$%lock-cmd)
                  #:log-file "herd-logs/xss-lock.log"))
        (stop #~(make-kill-destructor))
        (documentation "don't touch my stuff"))
       (shepherd-service
        (provision '(synergy))
        ;; (auto-start? #f)
        (start #~(make-forkexec-constructor
                  (list #$(file-append synergy "/bin/synergy"))
                  #:log-file "herd-logs/synergy.log"))
        (stop #~(make-kill-destructor))
        (documentation "can't be arsed to move IRL"))
       (shepherd-service
        (provision '(neko))
        (auto-start? #t)
        (start #~(make-forkexec-constructor
                  (list #$(file-append oneko "/bin/oneko") "-dog")
                  #:log-file "herd-logs/oneko.log"))
        (stop #~(make-kill-destructor))
        (documentation "neko"))))))) )

(define-public %wonko-home
  (home-environment
   (packages
    (append
     %emacs-world
     %ocaml-with-opam-world
     %ocaml-mode-deps
     %crypto-world
     %xorg-world
     %fonts-world
     %vcs-world
     (list
      ;; services
      picom
      synergy
      dunst
      ;; yes also man pages plz
      man-db)))

   (services %wonko-services)))

(define-public %tina-home
  (home-environment
   (services
    (list
     (simple-service 'guix-config-files
                     home-files-service-type
                     (map
                      (lambda (file)
                        `(,(string-append ".config/guix/" file)
                          ,(local-file
                            (string-append %lambda-project "/guix/config/" file))))
                      '("channels.scm")))
     (simple-service 'x-config-files
                     home-files-service-type
                     `((".xsession"
                        ,(program-file
                          "xsession"
                          #~(system #$(file-append xfce "/bin/startxfce4"))))))))
   (packages
    (append
     %fonts-world
     %xfce-world
     %web-world
     (list
      pavucontrol
      man-db)))))
