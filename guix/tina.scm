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
 (spock-say (string-append "Tina's HOME for " (ship-name %ship)))
 (current-error-port))
(newline (current-error-port))

(home-environment
 (packages
  (append
   %fonts-world
   %xfce-world
   %web-world
   (list
    ;; yes also man pages plz
    man-db))))
