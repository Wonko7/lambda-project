(add-to-load-path (dirname (current-filename)))
;; (add-to-load-path "/code/wonko-mono-conf/guix")

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

 ;; desktop stuff
 (gnu packages glib)
 (gnu packages pulseaudio)
 (gnu packages synergy)
 (gnu packages xorg)
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
 (gnu packages dunst)
 (w7 packages jonaburg-picom)
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
 (spock-say (string-append "building HOME for " (ship-name %ship)))
 (current-error-port))
(display "\n"
         (current-error-port))

(define %emacs-values
  #~(progn
     (setq my/font #$%font
           my/font-size #$(ship-emacs-font-size %ship)
           my/modeline-height #$(ship-emacs-modeline-height %ship))
     (provide 'conf/generated-values)))

(define %aliases
  `(("g" . "git")
    ("psrg" . "ps aux | rg")
    ("df" . "df -h")
    ("st" . ,(format #f "st -f '~a:size=~a'" %font
                     (ship-st-font-size %ship)))
    ("dmesg" . "dmesg -He")
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

(home-environment
 (packages
  (append

   %emacs-world
   %crypto-world
   %xorg-world
   %fonts-world
   %ocaml5-world

   (list
    ;; services
    ibhagwan-picom
    synergy
    dunst
    ;; yes also man pages plz
    man-db)))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (aliases %aliases)
             (environment-variables
              `(("HISTFILESIZE" . "100000")
                ("HISTSIZE" . "100000")
                ("HISTFILE" . "$XDG_CACHE_HOME/.bash_history")
                ("PAGER" . "")
                ;; ("PATH" . "./_opam/bin:$PATH")
                ("BLOCK_SIZE" . "human-readable")
                ("LIBRARY_PATH" . "$LIBRARY_PATH:~/.guix-profile/lib")
                ("C_INCLUDE_PATH" . "$C_INCLUDE_PATH:~/.guix-profile/include")
                ("LD_LIBRARY_PATH" . "$LD_LIBRARY_PATH:~/.guix-profile/lib")
                ("PATH" . "~/local/bin:$PATH")
                ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
                ("PASSWORD_STORE_DIR" . "/data/pass")
                ("RIPGREP_CONFIG_PATH" . "$HOME/.config/ripgrep/ripgreprc")
                ("GDK_SCALE" . ,(number->string
                                 (ship-gdk-scale %ship)))
                ("GDK_DPI_SCALE" . ,(number->string
                                     (ship-gdk-dpi-scale %ship)))
                ("QT_QPA_PLATFORM_PLUGIN_PATH" . "$HOME/.guix-home/profile/lib/qt5/plugins")
                ("QT_STYLE_OVERRIDE" . "kvantum")
                ("XDG_CURRENT_DESKTOP" . "qt5ct")))
             (bash-profile
              (list
               (plain-file "bash-profile"
                           ;; FIXME: list of manifets. script init manifests + init gits
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
                    (lambda (file)
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

   (simple-service 'emacsd-snippets-config-files
                   home-files-service-type
                   (map
                    (lambda (file)
                      `(,(string-append ".emacs.d/snippets/" file)
                        ,(local-file
                          (string-append conf-root-dir "/emacs.d/snippets/" file))))
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
         (string-append conf-root-dir  "/emacs.d/exwm.el")))
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
            (xset . "dpms 180 1200 0")
            (xsetroot . "-cursor_name left_ptr")
            (setxkbmap . "dvorak")
            (xmodmap . "~/.config/x-config/common.xmodmap")
            (xmodmap . ,(string-append ".config/x-config/"
                                       (ship-name %ship)
                                       ".xmodmap"))
            (feh . ,(string-append "--bg-scale '"
                                   (ship-wallpaper %ship)
                                   "'"))
            ("~/.x-config"  . "")
            (,#~(string-append  "exec " #$dbus "/bin/dbus-launch --exit-with-session")
                . #$(file-append emacs-exwm "/bin/exwm"))))))
      ("spock"
       ,(program-file
         "spock"
         (with-imported-modules
          '((spock))
          #~(begin
              (use-modules
               (spock))
              (display
               (spock-say "live long & prosper!"))
              (newline)))))
      ;; utils:
      (".config/git/config"
       ,(local-file
         (string-append conf-root-dir "/misc/gitconfig")))
      (".config/git/attributes"
       ,(local-file
         (string-append conf-root-dir "/misc/gitattributes")))
      (".config/ripgrep/ripgreprc"
       ,(local-file
         (string-append conf-root-dir "/misc/ripgreprc")))
      ;; GTK & QT configs:
      (".gtkrc-2.0"
       ,(local-file
         (string-append conf-root-dir "/misc/gtkrc-2.0")))
      (".config/gtk-3.0/settings.ini"
       ,(local-file
         (string-append conf-root-dir "/misc/gtkrc-3.0")))
      (".config/Kvantum/kvantum.kvconfig"
       ,(local-file
         (string-append conf-root-dir "/misc/kvantum.kvconfig")))
      (".config/Kvantum/KvGnomish#/KvGnomish#.kvconfig"
       ,(local-file
         (string-append conf-root-dir "/misc/kv_yggdrasill.kvconfig")))
      (".config/qt5ct/qt5ct.conf"
       ,(local-file
         (string-append conf-root-dir "/misc/qt5ct.conf")))
      ;; my X stuff:
      (".XCompose"
       ,(local-file
         (string-append conf-root-dir "/misc/XCompose")))
      (,(string-append ".config/x-config/"
                       (ship-name %ship)
                       ".xmodmap")
       ,(local-file
         (string-append conf-root-dir "/misc/"
                        (ship-name %ship)
                        ".xmodmap")))
      (".config/x-config/common.xmodmap"
       ,(local-file
         (string-append conf-root-dir "/misc/common.xmodmap")))
      (".config/picom.conf"
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
         (string-append conf-root-dir "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file
         (string-append conf-root-dir "/misc/Synergy.conf")))
      ;; deploy secrets
      ("local/bin/secrets"
       ,(program-file
         "secrets"
         (with-imported-modules
          '((spock)
            (guix build utils))
          #~(begin
              (use-modules (spock)
                           (guix build utils))
              (display (spock-say
                        (string-append "deploying SECRETS for " #$(ship-name %ship)))
                       (current-error-port))
              (newline (current-error-port))
              (let ((pass   #$(file-append password-store "/bin/pass"))
                    (base64 #$(file-append coreutils "/bin/base64"))
                    (tar    #$(file-append tar "/bin/tar")))
                (system
                 (string-append pass " show fleet/" #$(ship-name %ship) "/ssh | "
                                base64 " -d | " tar " xz ")))))))))

   (simple-service 'guix-config-files
                   home-files-service-type
                   (map
                    (lambda (file)
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
                (provision '(dunst))
                (start #~(make-forkexec-constructor
                          (list #$(file-append dunst "/bin/dunst"))
                          #:log-file "log/dunst.log"))
                (stop #~(make-kill-destructor))
                (documentation "riced notifications"))
               (shepherd-service
                (provision '(guix-repl))
                (start #~(make-forkexec-constructor
                          (list
                           (string-append #$%home "/.config/guix/current/bin/guix")
                           "repl" "--listen=tcp:37146")
                          #:environment-variables '("INSIDE_EMACS=1")
                          #:log-file "log/guix-repl.log"))
                (stop #~(make-kill-destructor))
                (documentation "REPL to me, like lovers do"))
               (shepherd-service
                (provision '(xss-lock))
                (start #~(make-forkexec-constructor
                          (list #$(file-append xss-lock "/bin/xss-lock")
                                "--"
                                "/run/setuid-programs/xlock" "-mode" "daisy" "-lockdelay" "10")
                          #:log-file "log/xss-lock.log"))
                (stop #~(make-kill-destructor))
                (documentation "don't touch my stuff"))
               (shepherd-service
                (provision '(synergy))
                (start #~(make-forkexec-constructor
                          (list #$(file-append synergy "/bin/synergy"))
                          #:log-file "log/synergy.log"))
                (stop #~(make-kill-destructor))
                (documentation "can't be arsed to move IRL")))))))))
