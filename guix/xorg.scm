(define-module (xorg)
  #:autoload   (gnu services sddm) (sddm-service-type)
  #:use-module (gnu artwork)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)
  #:use-module (gnu system pam)
  #:use-module (gnu system setuid)
  #:use-module (gnu system keyboard)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu packages base)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnustep)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages bash)
  #:use-module (gnu system shadow)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix store)
  #:use-module (guix packages)
  #:use-module (guix derivations)
  #:use-module (guix records)
  #:use-module (guix deprecation)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:export (noautostart-slim-service-type
            noautostart-slim-configuration
            noautostart-slim-configuration-allow-empty-passwords
            noautostart-slim-configuration-auto-login
            noautostart-slim-configuration-auto-login-session
            noautostart-slim-configuration-default-user
            noautostart-slim-configuration-display
            noautostart-slim-configuration-gnupg
            noautostart-slim-configuration-noautostart-slim
            noautostart-slim-configuration-sessreg
            noautostart-slim-configuration-shepherd
            noautostart-slim-configuration-theme
            noautostart-slim-configuration-theme-name
            noautostart-slim-configuration-vt
            noautostart-slim-configuration-xauth
            noautostart-slim-configuration-xorg
            noautostart-slim-theme
            noautostart-slim-theme-name
            noautostart-slim-configuration-gnupg?
            noautostart-slim-configuration-auto-login?))

(define-record-type* <noautostart-slim-configuration>
  noautostart-slim-configuration make-noautostart-slim-configuration
  noautostart-slim-configuration?
  (noautostart-slim noautostart-slim-configuration-noautostart-slim
        (default slim))
  (allow-empty-passwords? noautostart-slim-configuration-allow-empty-passwords?
                          (default #t))
  (gnupg? noautostart-slim-configuration-gnupg?
          (default #f))
  (auto-login? noautostart-slim-configuration-auto-login?
               (default #f))
  (default-user noautostart-slim-configuration-default-user
                (default ""))
  (theme noautostart-slim-configuration-theme
         (default %default-slim-theme))
  (theme-name noautostart-slim-configuration-theme-name
              (default %default-slim-theme-name))
  (xauth noautostart-slim-configuration-xauth
         (default xauth))
  (shepherd noautostart-slim-configuration-shepherd
            (default shepherd))
  (auto-login-session noautostart-slim-configuration-auto-login-session
                      (default #f))
  (xorg-configuration noautostart-slim-configuration-xorg
                      (default (xorg-configuration)))
  (display noautostart-slim-configuration-display
           (default ":0"))
  (vt noautostart-slim-configuration-vt
      (default "vt7"))
  (sessreg noautostart-slim-configuration-sessreg
           (default sessreg)))

(define (slim-pam-service config)
  "Return a PAM service for @command{slim}."
  (list (unix-pam-service
         "slim"
         #:login-uid? #t
         #:allow-empty-passwords?
         (noautostart-slim-configuration-allow-empty-passwords? config)
         #:gnupg?
         (noautostart-slim-configuration-gnupg? config))))

(define (noautostart-slim-shepherd-service config)
  (let* ((xinitrc (xinitrc #:fallback-session
                           (noautostart-slim-configuration-auto-login-session config)))
         (xauth   (noautostart-slim-configuration-xauth config))
         (startx  (xorg-start-command (noautostart-slim-configuration-xorg config)))
         (display (noautostart-slim-configuration-display config))
         (vt (noautostart-slim-configuration-vt config))
         (shepherd   (noautostart-slim-configuration-shepherd config))
         (theme-name (noautostart-slim-configuration-theme-name config))
         (sessreg (noautostart-slim-configuration-sessreg config))
         (lockfile (string-append "/var/run/slim-" vt ".lock")))
    (define slim.cfg
      (mixed-text-file "slim.cfg"  "
default_path /run/current-system/profile/bin
default_xserver " startx "
display_name " display "
xserver_arguments " vt "
xauth_path " xauth "/bin/xauth
authfile /var/run/slim-" vt ".auth
lockfile " lockfile "
logfile /var/log/slim-" vt ".log

# The login command.  '%session' is replaced by the chosen session name, one
# of the names specified in the 'sessions' setting: 'wmaker', 'xfce', etc.
login_cmd  exec " xinitrc " %session
sessiondir /run/current-system/profile/share/xsessions
session_msg session (F1 to change):
sessionstart_cmd " sessreg "/bin/sessreg -a -l $DISPLAY %user
sessionstop_cmd " sessreg "/bin/sessreg -d -l $DISPLAY %user

halt_cmd " shepherd "/sbin/halt
reboot_cmd " shepherd "/sbin/reboot\n"
(if (noautostart-slim-configuration-auto-login? config)
    (string-append "auto_login yes\ndefault_user "
                   (noautostart-slim-configuration-default-user config) "\n")
    "")
(if theme-name
    (string-append "current_theme " theme-name "\n")
    "")))

    (define theme
      (noautostart-slim-configuration-theme config))

    (list (shepherd-service
           (documentation "Xorg display server")
           (provision (append
                       ;; For compatibility, also provide 'xorg-server'.
                       (if (string=? vt "vt7")
                           '(xorg-server)
                           '())

                       (list (symbol-append 'xorg-server-
                                            (string->symbol vt)))))
           (requirement '(pam user-processes host-name udev))
           (start
            #~(lambda ()
                ;; A stale lock file can prevent SLiM from starting, so remove it to
                ;; be on the safe side.
                (false-if-exception (delete-file lockfile))

                (fork+exec-command
                 (list (string-append #$(noautostart-slim-configuration-noautostart-slim config)
                                      "/bin/slim")
                       "-nodaemon")
                 #:environment-variables
                 (list (string-append "SLIM_CFGFILE=" #$slim.cfg)
                       #$@(if theme
                              (list #~(string-append "SLIM_THEMESDIR=" #$theme))
                              #~())))))
           (stop #~(make-kill-destructor))
           ;; this is all copy pasted from gnu/guix/services/xorg.scm
           ;; this is the only real change is the following two lines:
           (auto-start? #f)
           (respawn? #f)))))

(define noautostart-slim-service-type
  (handle-xorg-configuration noautostart-slim-configuration
    (service-type (name 'slim)
                  (extensions
                   (list (service-extension shepherd-root-service-type
                                            noautostart-slim-shepherd-service)
                         (service-extension pam-root-service-type
                                            slim-pam-service)))
                  (default-value (slim-configuration))
                  (description
                   "Run the SLiM graphical login manager for X11."))))
