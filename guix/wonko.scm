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
 (gnu packages dunst)
 (w7 packages jonaburg-picom)
 (w7 packages emacs-xyz)
 ;; doc
 (gnu packages man)

 ;; my stuff
 (fleet)
 (spock)
 (dotfiles)
 (pkgs))

(define conf-root-dir
  (dirname
   (dirname (current-filename))
   )) ;; threading macro plz?

(chdir (dirname (current-filename))) ;; "/code/wonko-mono-conf/guix"
;; (chdir "/code/wonko-mono-conf/guix")


(define-public hostname (getenv "HOSTNAME"))
(define %host (hostname->ship "yggdrasill"))
(define %host (hostname->ship hostname))
;; (display (ship-emacs-font-size %host))
;; (display (identity %yggdrasill))

(display (spock-say (string-append "building HOME for " (ship-name %host))))
(display (dunst-configuration %host))
(exit 0)

(define %emacs-values
  #~(progn (setq my/font #$%font
                 my/font-size #$(ship-emacs-font-size %host)
                 my/modeline-height #$(ship-emacs-modeline-height %host))
           (provide 'conf/generated-values)))

(home-environment
 (packages
  (append
   %emacs-world

   (list
    ;; other utils
    recutils
    tree
    git
    tmux
    acpi

    ;; services
    ibhagwan-picom
    synergy
    dunst

    ;; basic system stuff
    man-db)))

 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #t)
             (aliases
              `(("g" . "git")
                ("psrg" . "ps aux | rg")
                ("df" . "df -h")
                ("st" . ,(format #f "-f '~a:~a'" %font (ship-st-font-size %host)))
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
              `(("HISTFILE" . "$XDG_CACHE_HOME/.bash_history")
                ("PAGER" . "")
                ("PATH" . "./_opam/bin:$PATH")
                ("LIBRARY_PATH" . "$LIBRARY_PATH:~/.guix-profile/lib")
                ("C_INCLUDE_PATH" . "$C_INCLUDE_PATH:~/.guix-profile/include")
                ("LD_LIBRARY_PATH" . "$LD_LIBRARY_PATH:~/.guix-profile/lib")
                ("PATH" . "~/local/bin:$PATH")
                ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
                ("PASSWORD_STORE_DIR" . "/data/pass")
                ("RIPGREP_CONFIG_PATH" . "$HOME/.config/ripgrep/ripgreprc")
                ("GDK_SCALE" . ,(number->string (ship-gdk-scale %host)))
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

   (simple-service 'emacsd-snippets-config-files
                   home-files-service-type
                   (map
                    (lambda
                        (file)
                      `(,(string-append ".emacs.d/snippets/" file)
                        ,(local-file
                          (string-append conf-root-dir "/emacs.d/snippets/" file))))
                    '("fundamental-mode/danger_triangle"
                      "org-mode/begin_src"
                      "org-mode/begin_quote")))

   (simple-service 'emacsd-generated-config-files
                   home-files-service-type
                   (list `(".emacs.d/generated-values.el"
                           ,(scheme-file "_" %emacs-values))))

   (simple-service
    'config-files
    home-files-service-type
    ;; exwm config is outside of .emacs.d:
    `((".exwm"
       ,(local-file (string-append conf-root-dir  "/emacs.d/exwm.el")))
      (".xsession"
       ,(program-file
         "xsession"
         #~(system
            (format #f "source ~~/.bash_profile; ~a +SI:localuser:$USER; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; ~a ~a; exec dbus-launch --exit-with-session ~a"
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
                    #$(file-append xinput "/bin/xinput")  ;; FIXME -> make this part of xorg system config.
                    "set-prop 14 'libinput Click Method Enabled' 0 1"
                    #$(file-append xinput "/bin/xinput")
                    "set-prop 14 'libinput Accel Speed' 1.0"
                    (string-append ".local/fixme/" (ship-name %host) ".xmodmap")
                    #$(file-append feh "/bin/feh")
                    "--bg-scale '/data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png'"
                    #$(file-append emacs-exwm "/bin/exwm")))))
      (".config/git/config"
       ,(local-file (string-append conf-root-dir "/misc/gitconfig")))
      (".config/git/attributes"
       ,(local-file (string-append conf-root-dir "/misc/gitattributes")))
      (,(string-append ".local/fixme/" (ship-name %host) ".xmodmap")
       ,(local-file (string-append conf-root-dir "/misc/" (ship-name %host) ".xmodmap")))
      (".local/fixme/common.xmodmap"
       ,(local-file (string-append conf-root-dir "/misc/common.xmodmap")))
      (".config/picom.conf"
       ,(local-file (string-append conf-root-dir "/misc/picom.conf")))
      (".config/dunst/dunstrc"
       ,(plain-file "dunstrc" (dunst-configuration %host)))
      (".config/pantalaimon/pantalaimon.conf"
       ,(local-file (string-append conf-root-dir "/misc/pantalaimon.conf")))
      (".config/Synergy/Synergy.conf"
       ,(local-file (string-append conf-root-dir "/misc/Synergy.conf")))
      (".config/nyxt/init.lisp"
       ,(local-file (string-append conf-root-dir "/misc/nyxt.lisp")))
      (".config/ripgrep/ripgreprc"
       ,(local-file (string-append conf-root-dir "/misc/ripgreprc")))))

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
