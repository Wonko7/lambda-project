(use-modules
 (guix gexp)
 (guix modules)
 (gnu home)
 (gnu home services)
 (gnu home services shells)
 (gnu system shadow)
 (gnu services)
 (guix profiles)
 (srfi srfi-1)
 (srfi srfi-11)

 ;; fonts
 (w7 packages fonts)
 (gnu packages fonts)
 (gnu packages fontutils)
 (gnu packages unicode)

 ;; emacs
 (gnu packages emacs)
 (gnu packages emacs-xyz)
 (gnu packages aspell)
 (gnu packages hunspell)
 (gnu packages libreoffice)

 ;; desktop stuff
 (gnu packages glib)
 (gnu packages pulseaudio)
 (gnu packages synergy)
 (gnu packages xorg)
 (gnu packages toys)
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
 (gnu packages tor)

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
 (gnu packages wm)
 (gnu packages compton)
 (w7 packages emacs-xyz)

 ;; doc
 (gnu packages man)

 ;; my stuff
 (defs)
 (fleet)
 (spock)
 (dotfiles)
 (pkgs)
 (stateful-prelude))

(display
 (spock-say (string-append "wonko's HOME for " (ship-name %ship)))
 (current-error-port))
(newline (current-error-port))

(define %term-cmd "urxvt")

(define %emacs-values
  #~(progn
     (setq my/font #$%font
           my/lambda-project   #$%lambda-project
           my/font-size        #$(ship-emacs-font-size %ship)
           my/modeline-height  #$(ship-emacs-modeline-height %ship)
           my/tag-height       #$(ship-emacs-tag-height %ship)
           my/tag-font-size    #$(ship-emacs-tag-font-size %ship)
           my/tag-radius       #$(ship-emacs-tag-radius %ship)
           my/tag-padding      #$(ship-emacs-tag-padding %ship)
           my/org-agenda-tags-column #$(ship-emacs-org-agenda-tags-column %ship)
           my/org-habit-preceding-days #$(ship-emacs-org-habit-preceding-days %ship)
           my/term-cmd #$%term-cmd
           my/lock-cmd #$(apply
                          string-append
                          (concatenate
                           ((@ (srfi srfi-1) zip)
                            %lock-cmd
                            (circular-list " "))))
           my/window-divider-default-right-width #$(ship-emacs-divider-width %ship))
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
  `(("communication" . ,%communication-world) ;; 18786ae50272627a665a160bc5becc587957d8a3
    ("desktop" . ,%desktop-world)
    ("utils" . ,%utils-world)
    ("web" . ,%web-world)
    ("zonked" . ,(list onionshare-cli)))) ;; --commit=0f0c1c66f4d0bb32f2f5c74cc15b472fbd30e6c1

(define-public (profiles->names ps)
  (map car ps))

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

 (services
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
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #f)
             (aliases %aliases)
             (environment-variables
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
                 ,(string-append "$GUILE_LOAD_PATH:" %lambda-project "/guix"))
                ("GUIX_LOCPATH" . "$HOME/.guix-home/profile/lib/locale")
                ("LANG" . "en_GB.utf8")
                ("PASSWORD_STORE_DIR" . "/data/pass")
                ("PASSWORD_STORE_GENERATED_LENGTH" . "33")
                ;; ("PS1" . "is in bashrc because I want it after source /etc/bashrc")
                ("RIPGREP_CONFIG_PATH" . "$HOME/.config/ripgrep/ripgreprc")
                ("GDK_SCALE" . ,(number->string
                                 (ship-gdk-scale %ship)))
                ("GDK_DPI_SCALE" . ,(number->string
                                     (ship-gdk-dpi-scale %ship)))
                ("QT_QPA_PLATFORM_PLUGIN_PATH" . "$HOME/.guix-home/profile/lib/qt5/plugins")
                ("QT_STYLE_OVERRIDE" . "kvantum")
                ("XDG_CURRENT_DESKTOP" . "qt5ct")
                ("FLEET" .
                 ,(string-concatenate
                   (concatenate ((@ (srfi srfi-1) zip)
                                 (map ship-name %fleet)
                                 (circular-list " ")))))))
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
      (".x-config"
       ,(program-file "x-config"
                      (ship-x-config %ship)))
      (".xsession"
       ,(program-file
         "xsession"
         (cmd+arg->script
          `(("source" . "~/.bash_profile")
            (xhost . "+SI:localuser:$USER")
            (xset . "b 0 0 0")
            (xset . "r rate 400 30")
            ,(if (ship-media-station? %ship)
                 `(xset . "s off -dpms")
                 `(xset . "dpms 600 1200 0"))
            (xsetroot . "-cursor_name left_ptr")
            (setxkbmap . "dvorak")
            (xmodmap . "~/.config/x-config/common.xmodmap")
            (xmodmap . ,(string-append ".config/x-config/"
                                       (ship-name %ship)
                                       ".xmodmap"))
            (feh . ,(string-append "--bg-scale '"
                                   (ship-wallpaper %ship)
                                   "'"))
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
      (,(string-append ".config/x-config/"
                       (ship-name %ship)
                       ".xmodmap")
       ,(local-file
         (string-append %lambda-project "/misc/"
                        (ship-name %ship)
                        ".xmodmap")))
      (".config/x-config/common.xmodmap"
       ,(local-file
         (string-append %lambda-project "/misc/common.xmodmap")))
      (".config/picom/picom.conf"
       ,(plain-file "picom.conf"
                    (picom-configuration
                     (ship-picom-radius %ship))))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc"
                    (dunst-configuration
                     (ship-font %ship)
                     (ship-dunst-font-size %ship)
                     (ship-dunst-width %ship))))
      (".config/pantalaimon/pantalaimon.conf"
       ,(local-file
         (string-append %lambda-project "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file
         (string-append %lambda-project "/misc/Synergy.conf")))
      (".config/feh/themes"
       ,(let ((fsz (number->string (ship-feh-font-size %ship))))
          (mixed-text-file
           "feh_symlink_name_is_theme_name"
           "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
           " --fontpath " %home "/.guix-home/profile/share/fonts/truetype/"
           " --menu-font JetBrainsMono-Regular/" fsz
           " --font JetBrainsMono-Regular/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources"
                    (xresources-configuration
                     (ship-font %ship)
                     (ship-rxvt-font-size %ship))))))

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
             '((spock)
               (srfi srfi-1)
               (guix build utils))
           #~(begin
               (use-modules (spock)
                            (srfi srfi-1)
                            (guix build utils))
               (let ((guix #$(string-append %home "/.config/guix/current/bin/guix"))
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
               (let ((guix #$(string-append %home "/.config/guix/current/bin/guix")))
                 (with-environment-variables
                     '(("GUILE_LOAD_PATH"
                        #$(string-append "$GUILE_LOAD_PATH:" %lambda-project "/guix"))
                       ("SHIP" #$(ship-name %ship)))
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
             '((spock)
               (srfi srfi-1))
           #~(begin
               (use-modules
                (srfi srfi-1)
                (spock))
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
         (with-imported-modules
             '((srfi srfi-1)
               (srfi srfi-37))
           #~(begin
               (use-modules
                (srfi srfi-1)
                (srfi srfi-37))
               (let* ((args (args-fold (cdr (program-arguments))
                                       (let ((display-and-exit-proc
                                              (lambda (msg)
                                                (lambda (opt name arg loads)
                                                  (display msg)
                                                  (quit)))))
                                         (list (option '(#\p "push_remote") #t #f
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
                                                         (alist-cons 'repo arg acc)))))
                                       (lambda (opt name arg loads)
                                         (error "Unrecognized option `~A'" name))
                                       (lambda (op loads) (cons op loads))
                                       '()))
                      (repo (or (assoc-ref args 'repo)
                                (getcwd)))
                      (git #$(file-append git "/bin/git"))
                      (fleet-remotes (list #$@(map (lambda (s) (ship-name s)) %fleet))))

                 (display (assoc-ref args 'push-remote))
                 (newline)
                 (display (assoc-ref args 'fleet))
                 (newline)
                 (display repo)
                 (newline)
                 (display (basename repo))
                 (newline)
                 (display fleet-remotes)
                 (newline)
                 )))))
      ))

   (simple-service
    'secrets-scripts
    home-files-service-type
    `(("local/bin/secrets-backup"
       ,(program-file
         "_"
         (with-imported-modules
             '((spock)
               (guix build utils))
           #~(begin
               (use-modules (spock)
                            (guix build utils))
               (display (spock-say
                         (string-append "backup SECRETS for " #$(ship-name %ship)))
                        (current-error-port))
               (newline (current-error-port))
               (let ((pass   #$(file-append password-store "/bin/pass"))
                     (cat    #$(file-append coreutils "/bin/cat"))
                     (cp     #$(file-append coreutils "/bin/cp"))
                     (base64 #$(file-append coreutils "/bin/base64"))
                     (tar    #$(file-append tar "/bin/tar")))
                 (system
                  (string-append "cd " #$%home " && " tar " czf - .ssh/id_ed25519* | "
                                 base64 " | "
                                 pass " insert -m fleet/" #$(ship-name %ship) "/backup-ssh"))
                 (system
                  (string-append cp " " #$%home "/.ssh/id_ed25519.pub "
                                 ;; #$%project-lambda "/guix/data/ssh/" #$(ship-name %ship)
                                 ".pub")))))))
      ("local/bin/secrets-deploy"
       ,(program-file
         "_"
         (with-imported-modules
             '((spock)
               (guix build utils))
           #~(begin
               (use-modules (spock)
                            (guix build utils))
               (display (spock-say
                         (string-append "deploy SECRETS for " #$(ship-name %ship)))
                        (current-error-port))
               (newline (current-error-port))
               (let ((pass   #$(file-append password-store "/bin/pass"))
                     (base64 #$(file-append coreutils "/bin/base64"))
                     (tar    #$(file-append tar "/bin/tar")))
                 (system
                  (string-append pass " show fleet/" #$(ship-name %ship) "/ssh | "
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
                  (list #$(string-append %home %guix-extra-profiles-dir
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
                   (string-append #$%home "/.config/guix/current/bin/guix")
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
        (start (if (ship-media-station? %ship)
                   #~(make-forkexec-constructor
                      (list #$(file-append synergy "/bin/synergyc")
                            "-f" "yggdrasill.local")
                      #:log-file "herd-logs/synergy.log")
                   #~(make-forkexec-constructor
                      (list #$(file-append synergy "/bin/synergy"))
                      #:log-file "herd-logs/synergy.log")))
        (stop #~(make-kill-destructor))
        (documentation "can't be arsed to move IRL"))
       (shepherd-service
        (provision '(neko))
        (auto-start? (not (ship-media-station? %ship)))
        (start #~(make-forkexec-constructor
                  (list #$(file-append oneko "/bin/oneko") "-dog")
                  #:log-file "herd-logs/oneko.log"))
        (stop #~(make-kill-destructor))
        (documentation "neko")))))))))
