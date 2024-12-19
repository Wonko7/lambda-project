(define-module (wonko systems daban-urnud)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sddm)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services guix)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services shells)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-88)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko dotfiles)
  #:use-module (wonko xorg)
  #:use-module (wonko homes)
  #:use-module (wonko systems)
  #:use-module (wonko services kmonad)
  #:export (%daban-urnud-os))

(use-package-modules xorg)

(define machine-home-services
  (list
   (simple-service
    'config-files
    home-files-service-type
    `((".config/x-config/ship.xmodmap"
       ,(local-file
         (string-append %lambda-project "/misc/enterprise.xmodmap")))
      (".x-config"
       ,(program-file
         "x-config"
         #~(system
            (string-append
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'Synaptics Two-Finger Scrolling' 1 1;"
             #$xinput "/bin/xinput"
             " set-prop 'ETPS/2 Elantech Touchpad' 'libinput Accel Speed' 0.7"))))))))

(define %wonko-home
  (home-environment
   (inherit %vanilla-wonko-home)
   (services
    ;; (append
    ;;  machine-home-services
    ;;  %vanilla-wonko-services)
    (append
     machine-home-services
     (@@ (wonko homes) %just-vanilla-wonko-services)
     (cons*
      ((@@ (wonko homes) make-xsession) #:xmodmap? #f #:dvorak? #f)
      %vanilla-shepherd-wonko-service
      %bare-skeleton-wonko-services)))))

(define %media-station-home
  (home-environment
   (inherit %media-station-wonko-home)
   (services
    (append
     machine-home-services
     %media-station-wonko-services))))

;; (object->string
;;     `(defsrc
;;        o
;;       esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
;;       grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup
;;       ;;tab  q    w    e    r    t    y    u    i    o    p    "["   "]"   \     del  end  pgdn
;;       ;;caps a    s    d    f    g    h    j    k    l    \;   '    ret
;;       ;;lsft z    x    c    v    b    n    m    \,   \.    /    rsft                 up
;;       lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght
;;       ))

(define %keyboard-config
  (mixed-text-file
   "kbd"
   (object->string
    `(defcfg
      input (device-file "/dev/input/by-path/platform-i8042-serio-0-event-kbd")
      output (uinput-sink "keyboard-you-touch-my-tralala"
                          "echo this keyboard fucks &&
                           /run/current-system/profile/bin/sleep 1 &&
                           /home/wonko/.guix-home/profile/bin/setxkbmap -option compose:ralt")
      cmp-seq ralt    ;; Set the compose key to `RightAlt'
      cmp-seq-delay 5 ;; 5ms delay between each compose-key sequence press

      ;; Comment this if you want unhandled events not to be emitted
      fallthrough true
      ;; Set this to false to disable any command-execution in KMonad
      allow-cmd true))
   ;; ; might be a symbol for kmonad but guile disagrees:
   "(defalias smc ;)\n"
   "(defalias dot .)\n"
   "(defalias com ,)\n"
   "(defalias csb ])\n"
   "(defalias osb [)\n"
   "(defalias qte ')\n"
   ;; <3
   "(defalias EC (tap-hold-next-release 100 esc lctl))\n"
   "(defalias RC (tap-hold-next-release 100 ret rctl))\n"
   ;; using keymap/template/us_ansi_tkl.kbd:
   ;; "(defalias "
   "(defsrc
      esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \\    del  end  pgdn
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up
      lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght
      )\n"
   "\n"
   (object->string
    '(deflayer dvorak
       esc  f1   f2   x    f4   f5   f6   f7   f8   f9   f10  f11  f12
       grv  1    2    3    4    5    6    7    8    9    0    @osb @csb bspc  ins  home pgup
       tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
       @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
       lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
       lctl lalt lmet           spc            rmet ralt cmp  rctl            left down rght
       ))))

(define %daban-urnud-os
  (operating-system
    (inherit %laptop-os)
    (host-name "daban-urnud")
    (keyboard-layout %us-kb)
    (services (cons* (service slim-service-type wonko-slim-config)
                     (service slim-service-type media-station-slim-config)
                     (service guix-home-service-type
                              `((,(crew-name %wonko) ,%wonko-home)
                                (,(crew-name %media) ,%media-station-home)))
                     (udev-rules-service 'sexy-computer (udev-rule "69-sexy-computer.rules"
                                                                   "# (.)(.)\n#  8==o~~"))
                     (kmonad-service "/home/wonko/k.kbd") ;; FIXME
                     (extra-special-file "/etc/kmonad/keyboard.kbd"
                                         %keyboard-config)
                     %laptop-services))
    (mapped-devices
     (list (mapped-device
            (source (uuid "0a59dd11-43cf-4043-bcb6-932ad861fb2b"))
            (target "vault")
            (type luks-device-mapping))))

    (file-systems (let ((btrfs-vault-subvol (lambda (args)
                                              (make-vault-subvolume args mapped-devices))))
                    (cons*
                     (file-system
                       (mount-point "/boot")
                       (device (uuid "D4BC-780D"
                                     'fat32))
                       (type "vfat"))
                     (file-system
                       (mount-point "/mnt/vault")
                       (device "/dev/mapper/vault")
                       (type "btrfs")
                       (dependencies mapped-devices))
                     (append
                      (make-vault-subvolumes mapped-devices)
                      %base-file-systems))))))

%wonko-home
%daban-urnud-os
