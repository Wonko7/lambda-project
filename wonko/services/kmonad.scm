;; https://github.com/kmonad/kmonad/issues/483
(define-module (wonko services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix gexp)
  #:export (kmonad-service-type
            %kmonad-config))

(define (kmonad-shepherd-service config-path)
  ;; Tells shepherd how we want it to create a (single) <shepherd-service>
  ;; for kmonad from a string
  (list (shepherd-service
         (documentation "Run the kmonad daemon (kmonad-daemon).")
         ;; (description "Run the kmonad daemon (kmonad-daemon).")
         (provision '(kmonad-daemon))
         (requirement '(udev user-processes))
         (start #~(make-forkexec-constructor
                   (list #$(file-append kmonad "/bin/kmonad")
                         #$config-path)))
         (stop #~(make-kill-destructor)))))

(define kmonad-service-type
  ;; Extend the shepherd root into a new type of service that takes a single string
  (service-type
    (name 'kmonad)
    (description "Run the kmonad daemon (kmonad-daemon).")
    (extensions
      (list (service-extension shepherd-root-service-type
                               kmonad-shepherd-service)))))

(define %kmonad-config
  (mixed-text-file
   "kmonad-config"
   (object->string
    `(defcfg
       input (device-file "/dev/input/by-path/platform-i8042-serio-0-event-kbd")
       output (uinput-sink "keyboard-you-touch-my-tralala"
                           "echo this keyboard fucks &&
                           /run/current-system/profile/bin/sleep 1 &&
                           DISPLAY=:9 /home/wonko/.guix-home/profile/bin/setxkbmap -option compose:ralt us") ;; which display though?
       cmp-seq ralt    ;; Set the compose key to `RightAlt'
       cmp-seq-delay 5 ;; 5ms delay between each compose-key sequence press

       ;; Comment this if you want unhandled events not to be emitted
       fallthrough true
       ;; Set this to false to disable any command-execution in KMonad
       allow-cmd true))

   ;; kmonad may have nilly willy symbols but guile does not:
   "(defalias smc ;)"
   "(defalias dot .)"
   "(defalias com ,)"
   "(defalias p   |)"
   "(defalias csb ])"
   "(defalias osb [)"
   "(defalias ccb })"
   "(defalias ocb {)"
   "(defalias cp  \\))"
   "(defalias op  \\()"
   "(defalias qte ')"
   "(defalias rqt `)"

   (object->string '(defalias ä #(\ \ t a)))
   (object->string '(defalias â #(\ \ c a)))
   (object->string '(defalias à #(\ \ b a)))

   (object->string '(defalias é #(\ \ q e)))
   (object->string '(defalias è #(\ \ b e)))
   (object->string '(defalias ê #(\ \ c e)))
   (object->string '(defalias ë #(\ \ t e)))

   (object->string '(defalias ï #(\ \ t i)))
   (object->string '(defalias î #(\ \ c i)))

   (object->string '(defalias ö #(\ \ t o)))
   (object->string '(defalias ô #(\ \ c o)))
   (object->string '(defalias œ #(\ \ o e)))

   (object->string '(defalias ü #(\ \ t u)))
   (object->string '(defalias û #(\ \ c u)))
   (object->string '(defalias ù #(\ \ b u)))

   (object->string '(defalias ÿ #(\ \ t y)))

   (object->string '(defalias ç #(\ \ c c)))

   (object->string '(defalias λ #(\ \ l a m b d a)))

   ;; <3
   (object->string '(defalias EC (tap-hold-next-release 200 esc lctl)))
   (object->string '(defalias RC (tap-hold-next-release 200 ret rctl)))
   ;; next doesn't work in this one:
   ;; (object->string '(defalias SA (tap-hold-next-release 200
   ;;                                                      (layer-next symbols)
   ;;                                                      (layer-toggle symbols))))
   (object->string '(defalias SA  (layer-toggle symbols)))
   (object->string '(defalias SYS (layer-next system)))

   (object->string '(defalias vt2 (cmd-button "/run/current-system/profile/bin/chvt 2")))
   (object->string '(defalias vt3 (cmd-button "/run/current-system/profile/bin/chvt 3")))
   (object->string '(defalias vt9 (cmd-button "/run/current-system/profile/bin/chvt 9")))
   (object->string '(defalias v11 (cmd-button "/run/current-system/profile/bin/chvt 11")))

   (object->string
    '(defalias Tsy (layer-toggle symbols)))

   ;; using keymap/template/us_ansi_tkl.kbd:
   "(defsrc
      esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \\    del  end  pgdn
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up
      lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght)"

   "\n"

   (object->string '(defalias ac (tap-hold-next-release 200 a lctl)))
   (object->string '(defalias uW (tap-hold-next-release 200 u (layer-toggle whitespace))))
   (object->string '(defalias hW (tap-hold-next-release 200 h (layer-toggle whitespace))))
   (object->string '(defalias sc (tap-hold-next-release 200 s lctl)))
   (object->string '(defalias Qs (tap-hold-next-release 200 @qte lsft)))
   (object->string '(defalias ls (tap-hold-next-release 200 l rsft)))
   (object->string '(defalias qs (tap-hold-next-release 200 q lsft)))
   (object->string '(defalias vs (tap-hold-next-release 200 v rsft)))
   (object->string '(defalias oS (tap-hold-next-release 200 o (layer-toggle symbols))))
   (object->string '(defalias nS (tap-hold-next-release 200 n (layer-toggle symbols))))
   (object->string '(defalias em (tap-hold-next-release 200 e lmet)))
   (object->string '(defalias tm (tap-hold-next-release 200 t lmet)))
   (object->string '(defalias SDV (layer-switch dvorak-num-mod)))
   (object->string '(defalias SDC (layer-switch dance-commander)))
   (object->string '(defalias SDN (layer-switch dvorak-no-bullshit)))
   (object->string '(defalias LLL (layer-next meta-layer)))
"\n"

   (object->string '(defalias Smc (tap-hold-next-release 200 @smc lsft)))
   (object->string '(defalias Sz (tap-hold-next-release 200 z lsft)))
   (object->string '(defalias yW (tap-hold-next-release 200 y (layer-toggle whitespace))))
   (object->string '(defalias fW (tap-hold-next-release 200 f (layer-toggle whitespace))))
   (object->string '(defalias qS (tap-hold-next-release 200 q (layer-toggle symbols))))
   (object->string '(defalias vS (tap-hold-next-release 200 v (layer-toggle symbols))))
"\n"
   (object->string '(defalias Cn C-n))
   (object->string '(defalias Cp C-p))
   (object->string '(defalias Csp C-spc))
   (object->string '(defalias Css #(C-spc C-spc)))
   (object->string '(defalias CP  #(C-spc P)))
   (object->string '(defalias jm (tap-hold-next-release 200 j lmet)))
   (object->string '(defalias wm (tap-hold-next-release 200 w lmet)))

"\n"
   (object->string '(defalias shV (tap-hold-next-release 200 @SDV lsft)))
   (object->string '(defalias shC (tap-hold-next-release 200 @SDC lsft)))

   (object->string
    '(deflayer dance-commander
       esc  @SDC @SDV @SDN f4   f5   f6   f7   f8   f9   f10  f11  @LLL
       grv  1    2    3    4    5    6    7    8    9    0    @SDV @CP  bspc  ins  home pgup
       tab  @qte @com @dot p    @yW  @fW  g    c    r    l    /    @SDV \     del  end  pgdn
       @EC  @ac  @oS  @em  u    i    d    h    @tm  @nS  @sc  -    @RC
       @shV @Smc @qS  @jm  k    x    b    m    @wm  @vS  @Sz  @shV                 up
       @SA  @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

   "\n"
   ;; micm isn't recognized
   (object->string
    '(deflayer whitespace
       XX   mute vold volu XX   XX   XX   XX   XX   XX   XX   XX   XX
       XX   XX   XX   XX   @SDV del  del  @SDV XX   XX   XX   @SDC @CP  bspc  ins  brup pgup
       XX   XX   XX   pgup pgdn bspc bspc pgup up   pgdn XX   /    @SDC \     del  brdn pgdn
       caps XX   XX   down up   ret  ret  left down rght XX   -    @RC
       lsft XX   XX   @Cn  @Cp  @Csp @Csp XX   XX   XX   XX   rsft                 brup
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left brdn rght))

"\n"
   (object->string
    '(deflayer dvorak-no-bullshit
       @SDC @SDC @SDV @SDN f4   f5   f6   f7   f8   f9   f10  f11  f12
       grv  1    2    3    4    5    6    7    8    9    0    @SDC @csb bspc  ins  home pgup
       tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
       @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
       lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
       @SA  @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))
"\n"

   (object->string '(defalias c1 (tap-hold-next-release 200 1 lctl)))
   (object->string '(defalias c0 (tap-hold-next-release 200 0 lctl)))
   (object->string '(defalias W4 (tap-hold-next-release 200 4 (layer-toggle whitespace))))
   (object->string '(defalias W7 (tap-hold-next-release 200 7 (layer-toggle whitespace))))
   (object->string '(defalias S2 (tap-hold-next-release 200 2 (layer-toggle symbols))))
   (object->string '(defalias S9 (tap-hold-next-release 200 9 (layer-toggle symbols))))
   (object->string '(defalias m3 (tap-hold-next-release 200 3 lmet)))
   (object->string '(defalias m8 (tap-hold-next-release 200 8 lmet)))

"\n"

   (object->string
    '(deflayer dvorak-num-mod
       @SDC @SDC @SDV @SDN f4   f5   f6   f7   f8   f9   f10  f11  f12
       grv  @c1  @S2  @m3  @W4  5    6    @W7  @m8  @S9  0    @SDC @csb bspc  ins  home pgup
       tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
       @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
       @shC @smc q    j    k    x    b    m    w    v    z    @shC                 up
       @SA  @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))
   "\n"

   (object->string
    '(deflayer symbols
       @SYS ä    ö    ë    ü    ï    ÿ    f7   f8   f9   f10  f11  @SYS
       grv  â    ô    ê    ù    î    XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
       tab  ^    -    è    =    @ocb /    XX   ç    /    @λ   /    =    \     del  end  pgdn
       @EC  à    œ    é    &    @p   \    @op  @cp  \    XX   -    @RC
       lsft +    \_   XX   û    @ccb XX   @osb @csb XX   XX   rsft                 up
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left down rght))

   (object->string
    '(deflayer xim-symbols
       @SYS @ä   @ö   @ë   @ü   @ï   @ÿ   f7   f8   f9   f10  f11  @SYS
       grv  @â   @ô   @ê   @ù   @î   XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
       tab  ^    -    @è   =    @ocb /    XX   @ç   /    @λ   /    =    \     del  end  pgdn
       @EC  @à   @œ   @é   &    @p   \    @op  @cp  \    XX   -    @RC
       lsft +    \_   XX   @û   @ccb XX   @osb @csb XX   XX   rsft                 up
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left down rght))

   "\n"
   (object->string
    '(deflayer system
       XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 XX   @v11 XX
       XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 XX   @osb @csb bspc  ins  home pgup
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  end  pgdn
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    @RC
       lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left down rght))

"\n"
   (object->string
    '(deflayer meta-layer
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
       XX   @SDC @SDV @SDN XX   XX   XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  end  pgdn
       XX   XX   XX   XX   XX   XX   @SDC XX   XX   @SDN XX   -    @RC
       lsft XX   XX   XX   XX   XX   XX   XX   XX   @SDV XX   rsft                 up
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left down rght
       ))

"\n"
   (object->string
    '(deflayer empty
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  end  pgdn
       XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    @RC
       lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
       lalt @SA  lmet           spc            rmet ralt cmp  @SA             left down rght
       ))

   (object->string
    '(deflayer dance-commander-old-middle-row
       esc  @SDC @SDV @SDN f4   f5   f6   f7   f8   f9   f10  f11  @LLL
       grv  1    2    3    4    5    6    7    8    9    0    @SDV @CP  bspc  ins  home pgup
       tab  @Qs  @com @dot p    y    f    g    c    r    @ls  /    @SDV \     del  end  pgdn
       @EC  @ac  @oS  @em  @uW  i    d    @hW  @tm  @nS  @sc  -    @RC
       lsft @smc @qs  j    k    x    b    m    w    @vs  z    rsft                 up
       @SA  @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))
   ))
