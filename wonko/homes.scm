(define-module (wonko homes)
 #:use-module (guix gexp)
 #:use-module (guix modules)
 #:use-module (gnu)
 #:use-module (gnu home)
 #:use-module (gnu system shadow)
 #:use-module (gnu services)
 #:use-module (guix profiles)
 #:use-module (srfi srfi-1)
 #:use-module (srfi srfi-11)
 #:use-module (ice-9 match)
 ;; fonts
 #:use-module (wonko packages fonts)
 ;; services
 #:use-module (gnu home services)
 #:use-module (gnu home services shepherd)
 #:use-module (gnu home services shells)
 #:use-module (gnu services shepherd)
 #:use-module (wonko packages emacs-xyz)
 ;; my stuff
 #:use-module (wonko defs)
 #:use-module (wonko fleet)
 #:use-module (wonko dotfiles)
 #:use-module (wonko pkgs))

(use-package-modules
 fonts fontutils unicode
 emacs emacs-xyz
 aspell hunspell libreoffice
 glib pulseaudio synergy xorg toys linux xdisorg suckless music image-viewers
 xfce lxde gnome kde-plasma kde-frameworks
 admin databases version-control tmux ssh rust-apps gnupg password-utils bash
 bittorrent tor
 haskell-apps compression commencement pkg-config base gdb m4 maths man
 ;; services
 matrix wm compton)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; home components

(define %term-cmd "urxvt")

(define* (make-emacs-values-service #:key
                                    (font-size                          120)
                                    (modeline-height                    40)
                                    (tag-height                         0.95)
                                    (tag-font-size                      11)
                                    (tag-radius                         10)
                                    (tag-padding                        15)
                                    (org-agenda-tags-column             78)
                                    (org-habit-preceding-days           43)
                                    (window-divider-default-right-width 2))
   (simple-service
    'emacsd-generated-config-files
    home-files-service-type
    (list
     `(".emacs.d/generated-values.el"
       ,(scheme-file
         "emacs_values_el"
         #~(progn
            (setq
             my/font-size                            #$font-size
             my/modeline-height                      #$modeline-height
             my/tag-height                           #$tag-height
             my/tag-font-size                        #$tag-font-size
             my/tag-radius                           #$tag-radius
             my/tag-padding                          #$tag-padding
             my/org-agenda-tags-column               #$org-agenda-tags-column
             my/org-habit-preceding-days             #$org-habit-preceding-days
             my/window-divider-default-right-width   #$window-divider-default-right-width
             my/font           #$%font
             my/lambda-project #$%lambda-project
             my/term-cmd       #$%term-cmd
             my/lock-cmd       #$(apply
                                  string-append
                                  (concatenate
                                   ((@ (srfi srfi-1) zip)
                                    %lock-cmd
                                    (circular-list " ")))))
            (provide 'conf/generated-values)))))))

(define-public %vanilla-emacs-values-service
  (make-emacs-values-service))

(define-public %highdpi-emacs-values-service
  (make-emacs-values-service
   #:font-size                          80
   #:modeline-height                    75
   #:tag-height                         0.47
   #:tag-font-size                      4.9
   #:tag-radius                         6
   #:tag-padding                        4.0
   #:org-agenda-tags-column             80
   #:org-habit-preceding-days           47
   #:window-divider-default-right-width 5))

(define %aliases
  `(("g"     . "git")
    ("psrg"  . "ps aux | rg -M0")
    ("df"    . "df -h")
    ("dmesg" . "dmesg -He")
    ("free"  . "free -h")
    ("grep"  . "grep --color=auto")
    ("ls"    . "ls --color=yes")
    ("ll"    . "ls -l --color=auto")
    ("la"    . "ls -A --color=auto")
    ("lla"   . "ls -lA --color=auto")
    ("lsd"   . "ls -lAc --color=auto")
    ("t"     . "tree -C")
    ("tarc"  . "tar -cavf")
    ("tarx"  . "tar -xavf")
    ("tart"  . "tar -tavf")
    ("rsy"   . "rsync -hrlpD --append-verify --progress")
    ("copy"  . "rsy")
    ("nmcli" . "nmcli -c yes")
    ("ip"    . "ip -c -h")))

(define-public %profiles
  ;; utils: add everything that's in system packages if this
  ;; needs to be deployed on non guix OS
  `(("communication" . ,%communication-world)
    ("desktop" . ,%desktop-world)
    ("utils" . ,(append
                 %dev-world
                 %git-world
                 %utils-world))
    ("web" . ,%web-world)
    ("borked" . ,%borked-world)
    ))

(define-public (profiles->names ps)
  (map car ps))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; bash

(define-public %wonko-env
  `(("HISTFILESIZE"        . "100000")
    ("HISTSIZE"            . "100000")
    ("HISTFILE"            . "$XDG_CACHE_HOME/.bash_history")
    ("HISTCONTROL"         . "ignorespace")
    ("PAGER"               . "")
    ("DICTIONARY"          . "en_GB-ise") ;; hunspell
    ("DISPLAY"             . ":9")
    ("BLOCK_SIZE"          . "human-readable")
    ;; GREP: this concerns multi/compose key/accents/exwm-xim/input methods
    ;; ("XMODIFIER"           . "@im=exwm-xim")
    ;; ("GTK_IM_MODULE"       . "xim")
    ;; ("QT_IM_MODULE"        . "xim")
    ;; ("CLUTTER_IM_MODULE"   . "xim")
    ("LIBRARY_PATH"        . "$LIBRARY_PATH:~/.guix-home/profile/lib")
    ("C_INCLUDE_PATH"      . "$C_INCLUDE_PATH:~/.guix-home/profile/include")
    ("LD_LIBRARY_PATH"     . "$LD_LIBRARY_PATH:~/.guix-home/profile/lib")
    ("PATH"                . "$HOME/local/bin:$PATH")
    ("PATH"                . "./_opam/bin:$PATH")
    ("GUIX_EXTRA_PROFILES" . ,%guix-extra-profiles-dir)
    ;; ("GUILE_LOAD_COMPILED_PATH" .
    ;;  ,(string-append %lambda-project ":/code/w7-guix-channel:/code/nonguix"))
    ("GUILE_LOAD_PATH" .
     ,(string-append "$GUILE_LOAD_PATH:" %lambda-project
                     ;; ":/code/w7-guix-channel"
                     ;; ":/code/nonguix"
                     ;; ":/code/guix"
                     ))
    ("GUIX_LOCPATH"                    . "$HOME/.guix-home/profile/lib/locale")
    ("LANG"                            . "en_GB.utf8")
    ("PASSWORD_STORE_DIR"              . "/data/pass")
    ("PASSWORD_STORE_GENERATED_LENGTH" . "33")
    ;; ("PS1"                          . "is in bashrc because I want it after source /etc/bashrc")
    ("RIPGREP_CONFIG_PATH"             . "$HOME/.config/ripgrep/ripgreprc")
    ("QT_QPA_PLATFORM_PLUGIN_PATH"     . "$HOME/.guix-home/profile/lib/qt5/plugins")
    ("QT_STYLE_OVERRIDE"               . "kvantum")
    ("XDG_CURRENT_DESKTOP"             . "qt5ct")))

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
      "path-setup"
      "# Source my paths:\n"
      "source ~/.profile\n")
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
      "bind '\"jj\":vi-movement-mode'\n"
      "[ -n \"$EAT_SHELL_INTEGRATION_DIR\" ] && source \"$EAT_SHELL_INTEGRATION_DIR/bash\"\n"
      )))))

(define-public %media-bash-config
  (home-bash-configuration
   (inherit %wonko-bash-config)
   (environment-variables
    (map (match-lambda
           (("DISPLAY" . l)
            '("DISPLAY" . ":11"))
           (x x))
         %wonko-env))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; skeleton config: needs emacs-values & x-config before being used

(define-public %common-shepherd-wonko-services
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
              (list #$(string-append %guix-extra-profiles-dir
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
              (list ;; a case could be made for /run/current-system/profile/bin/guix
               "/home/wonko/.config/guix/current/bin/guix" "repl" "--listen=tcp:37146")
              #:environment-variables '("INSIDE_EMACS=1")
              #:log-file "herd-logs/guix-repl.log"))
    (stop #~(make-kill-destructor))
    (documentation "REPL to me, like lovers do"))))

(define-public %vanilla-shepherd-wonko-service
  (service
   home-shepherd-service-type
   (home-shepherd-configuration
    (services
     (cons*
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
       (start #~(make-forkexec-constructor
                 (list #$(file-append synergy "/bin/synergy"))
                 #:log-file "herd-logs/synergy.log"))
       (stop #~(make-kill-destructor))
       (documentation "can't be arsed to move IRL"))
      (shepherd-service
       (provision '(neko))
       (start #~(make-forkexec-constructor
                 (list #$(file-append oneko "/bin/oneko") "-dog")
                 #:log-file "herd-logs/oneko.log"))
       (stop #~(make-kill-destructor))
       (documentation "neko"))
      %common-shepherd-wonko-services)))))

(define-public %media-station-shepherd-wonko-service
  (service
   home-shepherd-service-type
   (home-shepherd-configuration
    (services
     (cons*
      (shepherd-service
       (provision '(xss-lock))
       (auto-start? #f)
       (start #~(make-forkexec-constructor
                 (cons* #$(file-append xss-lock "/bin/xss-lock")
                        "--"
                        '#$%lock-cmd)
                 #:log-file "herd-logs/xss-lock.log"))
       (stop #~(make-kill-destructor))
       (documentation "don't touch my stuff"))
      (shepherd-service
       (provision '(synergy))
       (start #~(make-forkexec-constructor
                 (list #$(file-append synergy "/bin/synergyc")
                       "-n" "media-station"
                       "-f" "yggdrasill.local")
                 #:log-file "herd-logs/synergy.log"))
       (stop #~(make-kill-destructor))
       (documentation "can't be arsed to move IRL"))
      %common-shepherd-wonko-services)))))

(define* (make-xsession #:key
                        (xmodmap? #f) ;; deprecated
                        (media-station? #f)
                        (dvorak? #f))
  (simple-service
   'xsession
   home-files-service-type
   `((".xsession"
      ,(program-file
        "xsession"
        #~(begin
            (system
             (string-append
              "source ~/.bash_profile;"
              #$xhost "/bin/xhost +SI:localuser:$USER;"
              #$xset "/bin/xset r rate 400 30;"
              #$xsetroot "/bin/xsetroot -cursor_name left_ptr;"
              #$feh "/bin/feh --bg-scale '" #$%wallpaper "';"
              #$xrdb "/bin/xrdb -load ~/.Xresources;"
              "~/.x-config;"
              #$(if dvorak?
                    #~(string-append #$setxkbmap "/bin/setxkbmap dvorak;")
                    "")
              #$(if media-station?
                    #~(string-append #$xset "/bin/xset s off -dpms;")
                    #~(string-append #$xset "/bin/xset dpms 600 1200 0;"))
              #$(if xmodmap?
                    #~(string-append
                       #$xmodmap "/bin/xmodmap ~/.config/x-config/common.xmodmap;"
                       #$xmodmap "/bin/xmodmap ~/.config/x-config/ship.xmodmap;")
                    "")
              "exec " #$dbus "/bin/dbus-launch --exit-with-session "
              #$emacs-exwm "/bin/exwm"))))))))

(define-public %bare-skeleton-wonko-services ;; shell, emacs, dotfiles
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
                      "lisp-dev.el"
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
      ;; ssh:
      (".ssh/config"
       ,(local-file
         (string-append %lambda-project "/misc/ssh.config")))
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
      ;; (".config/x-config/common.xmodmap"
      ;;  ,(local-file
      ;;    (string-append %lambda-project "/misc/common.xmodmap")))
      (".config/pantalaimon/pantalaimon.conf"
       ,(local-file
         (string-append %lambda-project "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file
         (string-append %lambda-project "/misc/Synergy.conf")))))

   (simple-service 'guix-config-files
                   home-files-service-type
                   (map ;; there used to be more
                    (lambda (file)
                      `(,(string-append ".config/guix/" file)
                        ,(local-file
                          (string-append %lambda-project "/guix/config/" file))))
                    '("shell-authorized-directories")))

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
                      ps))))))))

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
                                 base64 " -d | " tar " xz ")))))))))))

(define-public %skeleton-wonko-services
  (cons*
   (make-xsession)
   %bare-skeleton-wonko-services))

(define-public %skeleton-wonko-home
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
      %dev-world
      (list
       ;; services
       picom
       synergy
       dunst
       ;; yes also man pages plz
       man-db)))
    (services %skeleton-wonko-services)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vanilla config: just needs x-config

(define %just-vanilla-wonko-services
  (list
   %vanilla-emacs-values-service
   (service home-bash-service-type %wonko-bash-config)
   (simple-service
    'config-files
    home-files-service-type
    `(;; package this better;
      (".config/feh/themes"
       ,(let ((fsz "15"))
          (mixed-text-file
           "feh_symlink_name_is_theme_name"
           "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
           " --fontpath " "/home/wonko/.guix-home/profile/share/fonts/truetype/"
           " --menu-font JetBrainsMono-Regular/" fsz
           " --font JetBrainsMono-Regular/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources" (xresources-configuration %font 10)))
      (".config/picom/picom.conf"
       ,(plain-file "picom.conf" (picom-configuration 10)))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc"
                    (dunst-configuration %font 12 300)))))))

(define-public %vanilla-wonko-services
  (cons*
   %vanilla-shepherd-wonko-service
   (append
    %just-vanilla-wonko-services
    %skeleton-wonko-services)))

(define-public %vanilla-wonko-home
  (home-environment
   (inherit %skeleton-wonko-home)
   (services %vanilla-wonko-services)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; highdpi config: just needs x-config

(define-public %highdpi-wonko-services
  (cons*
   %highdpi-emacs-values-service
   (service
    home-bash-service-type
    (home-bash-configuration
     (inherit %wonko-bash-config)
     (environment-variables
      (cons*
       '("GDK_SCALE" . "2")
       '("GDK_DPI_SCALE" . "1.5")
       %wonko-env))))
   (simple-service
    'config-files
    home-files-service-type
    `((".config/feh/themes"
       ,(let ((fsz "20"))
          (mixed-text-file
           "feh_symlink_name_is_theme_name"
           "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
           " --fontpath " "/home/wonko/.guix-home/profile/share/fonts/truetype/"
           " --menu-font JetBrainsMono-Regular/" fsz
           " --font JetBrainsMono-Regular/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources" (xresources-configuration %font 10)))
      (".config/picom/picom.conf"
       ,(plain-file "picom.conf" (picom-configuration 25)))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc"
                    (dunst-configuration %font 8 175)))))
   %vanilla-shepherd-wonko-service
   %skeleton-wonko-services))

(define-public %highdpi-wonko-home
  (home-environment
   (inherit %skeleton-wonko-home)
   (services %highdpi-wonko-services)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; media-station

(define-public %media-station-wonko-services
  (cons*
   (make-xsession #:media-station? #t #:dvorak? #f)
   (append
    %bare-skeleton-wonko-services ;; skeleton svc = this + make xsession
    (modify-services %just-vanilla-wonko-services
                     (home-bash-service-type config => %media-bash-config)))))

(define-public %media-station-wonko-home
  (home-environment
   (inherit %skeleton-wonko-home)
   (services %media-station-wonko-services)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tina

(define-public %tina-home
  (home-environment
   (services
    (list
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
