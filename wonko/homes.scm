(define-module (wonko homes)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu system shadow)
  #:use-module (gnu services)
  #:use-module (guix profiles)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  ;; fonts
  #:use-module (wonko packages fonts)
  ;; services
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services xdg)
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
 gnupg
 aspell hunspell libreoffice
 glib pulseaudio synergy xorg toys linux xdisorg suckless music image-viewers
 xfce lxde gnome kde-plasma kde-frameworks
 admin databases version-control tmux ssh rust-apps gnupg password-utils bash
 bittorrent tor
 haskell-apps compression commencement pkg-config base gdb m4 maths man
 ;; services
 freedesktop matrix wm compton)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; home components

(define %term-cmd "urxvt")

(define* (make-emacs-values-service #:key
                                    (font-size                          120)
                                    (modeline-height                    40)
                                    (theme                              "doom-laserwave")
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
            my/theme                                #$theme
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

(define-public %media-emacs-values-service
  (make-emacs-values-service #:font-size 240
                             #:theme "doom-outrun-electric"))

(define %aliases
  `(("g"     . "git")
    ("psrg"  . "ps aux | rg -M0")
    ("df"    . "df -h")
    ("dmesg" . "dmesg -He")
    ("free"  . "free -h")
    ("grep"  . "grep --color=auto")
    ("ls"    . "ls --color=auto")
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
    ("ip"    . "ip -c -h")
    ("v"     . "vim")
    ("kys"   . "exit")))

(define-public %profiles
  ;; utils: add everything that's in system packages if this
  ;; needs to be deployed on non guix OS
  `(("borked-comms" . ,%borked-comms-world)
    ("borked-calibre" . ,%borked-calibre-world)))

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
    ("LIBRARY_PATH"        . "$LIBRARY_PATH:~/.guix-home/profile/lib")
    ("C_INCLUDE_PATH"      . "$C_INCLUDE_PATH:~/.guix-home/profile/include")
    ("LD_LIBRARY_PATH"     . "$LD_LIBRARY_PATH:~/.guix-home/profile/lib")
    ("PATH"                . "$HOME/local/bin:$PATH")
    ;; ("PATH"                . "./_opam/bin:$PATH")
    ("GUIX_EXTRA_PROFILES" . ,%guix-extra-profiles-dir)
    ;; ("GUILE_LOAD_COMPILED_PATH" .
    ;;  ,(string-append %lambda-project ":/code/w7-guix-channel:/code/nonguix"))
    ("GUILE_LOAD_PATH" .
     ,(string-append %lambda-project
                     ":$HOME/.config/guix/current/share/guile/site/3.0/"
                     ":$GUILE_LOAD_PATH"))
    ("GUILE_LOAD_COMPILED_PATH" .
     ,(string-append "$HOME/.config/guix/current/lib/guile/3.0/site-ccache/"
                     ":$HOME/.config/guix/current/share/guile/site/3.0/"
                     ":$GUILE_LOAD_COMPILED_PATH"))
    ("GUIX_LOCPATH"                    . "$HOME/.guix-home/profile/lib/locale")
    ("LANG"                            . "en_GB.utf8")
    ("PASSWORD_STORE_DIR"              . "/data/pass")
    ("PASSWORD_STORE_GENERATED_LENGTH" . "33")
    ;; ("PS1"                          . "is in bashrc because I want it after source /etc/bashrc")
    ("RIPGREP_CONFIG_PATH"             . "$HOME/.config/ripgrep/ripgreprc")
    ;; GREP: this concerns multi/compose key/accents/exwm-xim/input methods
    ;; ("XMODIFIER"           . "@im=exwm-xim")
    ;; ("GTK_IM_MODULE"       . "xim")
    ;; ("QT_IM_MODULE"        . "xim")
    ;; ("CLUTTER_IM_MODULE"   . "xim")
    ;; xorg appearance:
    ("CALIBRE_USE_DARK_PALETTE"        . "1")
    ("GTK_THEME"                       . "Breeze-Dark")
    ;; QT: in conjunction with .config/kdeglobals further down:
    ("QT_PLUGIN_PATH"                  . "$HOME/.guix-home/profile/lib/qt6/plugins")
    ("QT_STYLE_OVERRIDE"               . "Breeze")
    ("XCURSOR_THEME"                   . "breeze_cursors")
    ("XCURSOR_SIZE"                    . "32")))

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
      " \\A 🦄 \\u@\\h "
      "$(if [ -z \"$SSH_CLIENT\" ]; then echo 🌈; else echo 📡; fi)"
      " \\w${GUIX_ENVIRONMENT:+ [env]}\nλ '\n"
      "set -o vi\n"
      "bind '\"jj\":vi-movement-mode'\n")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; skeleton config: needs emacs-values & x-config before being used

(define-public %common-shepherd-wonko-services
  (list
   (shepherd-service
    (provision '(picom))
    (start #~(make-forkexec-constructor
              (list #$(file-append picom "/bin/picom")
                    "--backend=glx"
                    "--corner-radius=20" ;; --rounded-corners-exclude
                    "--opacity-rule=10:name *= 'oneko'")
              #:log-file #$(home-log-path "picom")))
    (stop #~(make-kill-destructor))
    (documentation "bling"))
   (shepherd-service
    (provision '(pantalaimon))
    (start #~(make-forkexec-constructor
              (list #$(string-append %guix-extra-profiles-dir
                                     "/communication/bin/pantalaimon")) ;; FIXME borked-comms
              #:environment-variables (cons "DISPLAY=:9"
                                            (default-environment-variables))
              #:log-file #$(home-log-path "matrix")))
    (stop #~(make-kill-destructor))
    (documentation "Crypto back-end server for ement.el"))
   (shepherd-service
    (provision '(dunst))
    (start #~(make-forkexec-constructor
              (list #$(file-append dunst "/bin/dunst"))
              #:log-file #$(home-log-path "dunst")))
    (stop #~(make-kill-destructor))
    (documentation "riced notifications"))
   (shepherd-service
    (provision '(guix-repl))
    (start #~(make-forkexec-constructor
              (list ;; a case could be made for /run/current-system/profile/bin/guix
               "/home/wonko/.config/guix/current/bin/guix" "repl" "--listen=tcp:37146")
              #:environment-variables (cons "INSIDE_EMACS=1"
                                            (default-environment-variables))
              #:log-file #$(home-log-path "guix-repl")))
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
                   #:log-file #$(home-log-path "xss-lock")))
         (stop #~(make-kill-destructor))
         (documentation "don't touch my stuff"))
       (shepherd-service
         (provision '(oneko))
         (start #~(make-forkexec-constructor
                   (list #$(file-append oneko "/bin/oneko") "-dog")
                   #:log-file #$(home-log-path "oneko")))
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
                 #:log-file #$(home-log-path "xss-lock")))
       (stop #~(make-kill-destructor))
       (documentation "don't touch my stuff"))
      (shepherd-service
       (provision '(synergy))
       (start #~(make-forkexec-constructor
                 (list #$(file-append synergy "/bin/synergyc")
                       "-n" "media-station"
                       "-f" "yggdrasill.local")
                 #:log-file #$(home-log-path "synergy")))
       (stop #~(make-kill-destructor))
       (documentation "can't be arsed to move IRL"))
      %common-shepherd-wonko-services)))))

(define* (make-xsession #:key
                        (media-station? #f))
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
              #$(if media-station?
                    #~(string-append #$xset "/bin/xset s off -dpms;")
                    #~(string-append #$xset "/bin/xset dpms 600 1200 0;"))
              "exec " #$emacs-exwm-custom-emacs-next "/bin/exwm"))))))))

(define-public %bare-skeleton-wonko-services ;; shell, emacs, dotfiles
  (cons*
   (service home-bash-service-type %wonko-bash-config)
   (simple-service 'dircolors home-shell-profile-service-type
                   (list
                    (mixed-text-file
                     "dircolors"
                     "eval $(dircolors -b ~/.config/dircolors/dircolors)\n")))
   (simple-service 'sourcing-extra-profiles home-shell-profile-service-type
                   (list
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
                      "fancy-but-later.el"
                      "early-init.el"
                      "init.el"
                      "lisp-dev.el"
                      "keys.el"
                      "misc.el"
                      "org-conf.el"
                      "workspaces.el")))

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

   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
              (default-cache-ttl (* 60 30))
              (max-cache-ttl (* 60 60 2))
              (pinentry-program
               (file-append pinentry-emacs "/bin/pinentry-emacs"))
              (ssh-support? #t)))

   (simple-service
    'xdg-user-directories-config-service
    home-xdg-user-directories-service-type
    (home-xdg-user-directories-configuration
      (desktop     "$HOME/desktop")
      (documents   "$HOME/documents")
      (download    "$HOME/downloads")
      (music       "$HOME/music")
      (pictures    "$HOME/pictures")
      (publicshare "$HOME/public")
      (templates   "$HOME/templates")
      (videos      "$HOME/videos")))

   (service
    (service-type
      (name 'home-xdg-desktop-portal)
      (extensions
       (list
        (service-extension
         home-profile-service-type
         (const (list xdg-desktop-portal
                      xdg-desktop-portal-gtk)))
        (service-extension
         home-xdg-configuration-files-service-type
         (const `(("xdg-desktop-portal/portals.conf"
                   ,(mixed-text-file "xdg-portals"
                                     "[preferred]\n"
                                     "default=gtk")))))))
      (default-value #f)
      (description "xdg portal")))

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
      (".config/dircolors/dircolors"
       ,(local-file
         (string-append %lambda-project "/misc/dircolors")))
      (".config/vim/vimrc"
       ,(local-file
         (string-append %lambda-project "/misc/vimrc")))
      ;; my X stuff:
      (".config/kdeglobals"
       ,(file-append breeze "/share/color-schemes/BreezeDark.colors"))
      (".XCompose"
       ,(local-file
         (string-append %lambda-project "/misc/XCompose")))
      (".config/pantalaimon/pantalaimon.conf"
       ,(local-file
         (string-append %lambda-project "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file
         (string-append %lambda-project "/misc/Synergy.conf")))
      (".config/vlc/vlcrc"
       ,(local-file
         (string-append %lambda-project "/misc/vlcrc")))
      (".config/mpv/mpv.conf"
       ,(local-file
         (string-append %lambda-project "/misc/mpv.conf")))
      (".config/mpv/input.conf"
       ,(local-file
         (string-append %lambda-project "/misc/mpv-input.conf")))))

   (simple-service 'guix-config-files
                   home-files-service-type
                   (map ;; there used to be more
                    (lambda (file)
                      `(,(string-append ".config/guix/" file)
                        ,(local-file
                          (string-append %lambda-project "/misc/guix-config/" file))))
                    '("shell-authorized-directories" "channels.scm")))

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
               (guix build utils)
               (ice-9 match)
               (ice-9 regex))
           #~(begin
               (use-modules (wonko spock)
                            (srfi srfi-1)
                            (guix build utils)
                            (ice-9 match)
                            (ice-9 regex))
               (let ((guix "~/.config/guix/current/bin/guix")
                     (ps   (let ((args (drop (program-arguments) 1)))
                             (if (null? args)
                                 '#$(profiles->names %profiles)
                                 (map (lambda (path)
                                        (list
                                         (regexp-substitute/global #f "([^/_]+)_[^_]+.scm"
                                                                   path 1)
                                         path))
                                      args)))))
                 (map (match-lambda*
                        (((profile channels))
                         (display (spock-say
                                   (string-append "build PROFILE " profile))
                                  (current-error-port))
                         (display (string-append "... with pinned channels " channels "\n\n")
                                  (current-error-port))
                         (system
                          (string-append guix " time-machine -C " channels
                                         " -- package -m ~/local/manifests/" profile
                                         " -p " #$%guix-extra-profiles-dir  "/" profile)))
                        ((profile)
                         (display (spock-say
                                   (string-append "build PROFILE " profile))
                                  (current-error-port))
                         (system
                          (string-append guix " package -m ~/local/manifests/" profile
                                         " -p " #$%guix-extra-profiles-dir  "/" profile))))
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
    'home-run-folder home-run-on-first-login-service-type
    #~(let ((mkdir #$(file-append coreutils "/bin/mkdir")))
        (system (string-append mkdir " -p ~/.run/emacs/ ~/.run/log/"))))

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
                         (string-append "backup SECRETS for " ;; FIXME #$(ship-name %ship)
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

   %base-home-services))


;; (map (match-lambda*
;;        (((profile channels))
;;         (string-append " time-machine -C " channels
;;                        " package -m ~/local/manifests/" profile
;;                        " -p " %guix-extra-profiles-dir  "/" profile "\n"))
;;        ((profile)
;;         (string-append " package -m ~/local/manifests/" profile
;;                        " -p " %guix-extra-profiles-dir  "/" profile "\n")))

;;      (map (lambda (path)
;;             (list
;;              (regexp-substitute/global #f "([^/_]+)_[^_]+.scm"
;;                                        path 1)
;;              path))
;;           (list "pinned/borked-comms_10-02-2025.scm"))
;;      )

(define-public %skeleton-wonko-services
  (cons*
   (make-xsession)
   %bare-skeleton-wonko-services))

(define-public %skeleton-wonko-home
  (home-environment
    (packages
     (append
      %emacs-world
      %ocaml-minimal
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
           " --menu-font " %font-feh "/" fsz
           " --font " %font-feh "/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources" (xresources-configuration %font 10)))
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
   %vanilla-shepherd-wonko-service
   (simple-service 'highdpi-bash home-bash-service-type
                   (home-bash-extension
                    (environment-variables
                     '(("GDK_SCALE" . "2")
                       ("QT_USE_PHYSICAL_DPI" . "1")
                       ("QT_SCALE_FACTOR" . "1")
                       ("GDK_DPI_SCALE" . "1.5")
                       ("XCURSOR_SIZE" . "64")))))
   (simple-service
    'config-files
    home-files-service-type
    `((".config/feh/themes"
       ,(let ((fsz "20"))
          (mixed-text-file
           "feh_symlink_name_is_theme_name"
           "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
           " --fontpath " "/home/wonko/.guix-home/profile/share/fonts/truetype/"
           " --menu-font " %font-feh "/" fsz
           " --font " %font-feh "/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources" (xresources-configuration %font 10)))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc"
                    (dunst-configuration %font 8 175)))))
   %skeleton-wonko-services))

(define-public %highdpi-wonko-home
  (home-environment
    (inherit %skeleton-wonko-home)
    (services %highdpi-wonko-services)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; media-station

(define-public %media-station-wonko-services
  (cons*
   (make-xsession #:media-station? #t)
   %media-emacs-values-service
   %media-station-shepherd-wonko-service
   (simple-service 'media-bash home-bash-service-type
                   (home-bash-extension
                    (bashrc (list (mixed-text-file
                                   "media-umask"
                                   "umask 0002\n")))
                    (environment-variables
                     '(("DISPLAY" . ":11")
                       ("GDK_SCALE" . "3")
                       ("QT_SCALE_FACTOR" . "3")
                       ("XCURSOR_SIZE" . "64")))))
   (simple-service
    'config-files
    home-files-service-type
    `((".config/feh/themes"
       ,(let ((fsz "30"))
          (mixed-text-file
           "feh_symlink_name_is_theme_name"
           "feh --borderless" ;; FIXME gexp %font ttf filename and use that:
           " --fontpath " "/home/wonko/.guix-home/profile/share/fonts/truetype/"
           " --menu-font " %font-feh "/" fsz
           " --font " %font-feh "/" fsz "\n")))
      (".Xresources"
       ,(plain-file "Xresources" (xresources-configuration %font 20)))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc"
                    (dunst-configuration %font 20 500)))))
   %bare-skeleton-wonko-services))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; minimal emacs debug

(define rewrite-emacs-input
  (package-input-rewriting `((,emacs-minimal . ,emacs))))

(define-public %emacs-debug-home
  (home-environment
    (packages (map rewrite-emacs-input
                   (append
                    %emacs-debug-world
                    %xorg-world
                    %fonts-world)))
    (services (cons*
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
                           #$xset "/bin/xset dpms 600 1200 0;"
                           "exec " #$(rewrite-emacs-input emacs-exwm-custom-emacs) "/bin/exwm")))))))
               %bare-skeleton-wonko-services))))
