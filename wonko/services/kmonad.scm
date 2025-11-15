;; https://github.com/kmonad/kmonad/issues/483
(define-module (wonko services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 match)
  #:export (kmonad-dance-commander-layer
            kmonad-fr-layer
            kmonad-service-type
            kmonad-config
            kmonad-make-config
            kmonad-laptop-config
            kmonad-fr-laptop-config
            kmonad-ergodox-config
            kmonad-bullshit-config))

(define (kmonad-shepherd-service config)
  ;; Tells shepherd how we want it to create a (single) <shepherd-service>
  ;; for kmonad from a string
  (let ((id          (first config))
        (config-path (second config)))
    (list (shepherd-service
            (documentation "Run the kmonad daemon.")
            (provision (list (string->symbol (string-append "kmonad-" id))))
            (requirement '(udev user-processes))
            (start #~(make-forkexec-constructor
                      (list #$(file-append kmonad "/bin/kmonad")
                            #$config-path)))
            (stop #~(make-kill-destructor))))))

(define kmonad-service-type
  ;; Extend the shepherd root into a new type of service that takes a single string
  (service-type
    (name 'kmonad)
    (description "Run the kmonad daemon.")
    (extensions
     (list (service-extension shepherd-root-service-type
                              kmonad-shepherd-service)))))

(define (kmonad/merge-layers l1 l2)
  "replace l1 keys w/ non XX keys from l2"
  (map (lambda (k1 k2)
         (if (equal? k2 'XX) k1 k2))
       l1
       l2))

(define* (sexps-to-string #:rest sexps)
  (apply string-append
         (apply append
                (zip (circular-list "\n")
                     (map object->string (apply append sexps))))))

(define (setxkb xkb)
  ;; FIXME: see zzull's "setxkbmap -device $(xinput list --id-only keyboard:'%s') fr bepo"
  (let ((xkb (if (string= xkb "us")
                 " -option compose:ralt us"
                 " -option lv3:ralt_switch fr latin9"))
        (setxkb " /run/current-system/profile/bin/setxkbmap ")
        (sudo "/run/privileged/bin/sudo -u ")
        (display  " DISPLAY="))
    (apply string-append
           (map (match-lambda
                  ((user . disp)
                   (string-append sudo user display disp setxkb xkb ";\n")))
                '(("wonko" . ":9")
                  ("media" . ":11")
                  ("tina"  . ":10"))))))

(define (kmonad-defcfg input output xkb)
  ;; laptop: "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
  (let ((init-cmd (string-append
                   "echo this keyboard fucks &&
                   /run/current-system/profile/bin/sleep 1 ;"
                   (setxkb xkb))))
    `(defcfg
       input (device-file ,input)
       output (uinput-sink ,output
                           ,init-cmd)
       cmp-seq    ralt ;; Set the compose key to `RightAlt'
       cmp-seq-delay 5 ;; 5ms delay between each compose-key sequence press

       ;; Comment this if you want unhandled events not to be emitted
       fallthrough true
       ;; Set this to false to disable any command-execution in KMonad
       allow-cmd true)))

(define kmonad-defsrc-us
  "(defsrc
      esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \\    del  end  pgdn
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft                 up
      lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght)")

(define kmonad-base-aliases
  ;; kmonad may have nilly willy symbols but guile does not:
  "
  (defalias smc ;)
  (defalias dot .)
  (defalias com ,)
  (defalias p   |)
  (defalias csb ])
  (defalias osb [)
  (defalias ccb })
  (defalias ocb {)
  (defalias cp  \\))
  (defalias op  \\()
  (defalias qte ')
  (defalias rqt `)\n")

(define kmonad-xim-aliases
  '((defalias ä #(\ \ t a))
    (defalias â #(\ \ c a))
    (defalias à #(\ \ b a))

    (defalias é #(\ \ q e))
    (defalias è #(\ \ b e))
    (defalias ê #(\ \ c e))
    (defalias ë #(\ \ t e))

    (defalias ï #(\ \ t i))
    (defalias î #(\ \ c i))

    (defalias ö #(\ \ t o))
    (defalias ô #(\ \ c o))
    (defalias œ #(\ \ o e))

    (defalias ü #(\ \ t u))
    (defalias û #(\ \ c u))
    (defalias ù #(\ \ b u))

    (defalias ÿ #(\ \ t y))
    (defalias ç #(\ \ c c))
    (defalias λ #(\ \ l a m b d a))))

(define kmonad-common-modifier-aliases
  `(;; <3
    (defalias EC (tap-hold-next-release 200 esc lctl))
    (defalias RC (tap-hold-next-release 200 ret rctl))
    ;; next doesn't work in this one:
    ;; (defalias SA (tap-hold-next-release 200
    ;;                                     (layer-next symbols)
    ;;                                     (layer-toggle symbols)))
    ;;(defalias SA  (layer-toggle symbols))
    ;;(defalias xSA (layer-toggle xim-symbols))
    (defalias SYS (layer-next system))
    (defalias Tsy (layer-toggle symbols))
    (defalias Tsx (layer-toggle xim-symbols))
    (defalias SDB (layer-switch dvorak-some-bullshit))
    (defalias SDD (layer-switch dance-commander))
    (defalias SXB (layer-switch xim-dvorak-some-bullshit))
    (defalias SXD (layer-switch xim-dance-commander))
    (defalias SDN (layer-switch dvorak-no-bullshit))
    (defalias XDB #((cmd-button ,(setxkb "us")) (layer-switch dvorak-some-bullshit)))
    (defalias XDD #((cmd-button ,(setxkb "us")) (layer-switch dance-commander)))
    (defalias XDN #((cmd-button ,(setxkb "us")) (layer-switch dvorak-no-bullshit)))
    (defalias XXB #((cmd-button ,(setxkb "us")) (layer-switch xim-dvorak-some-bullshit)))
    (defalias XXD #((cmd-button ,(setxkb "us")) (layer-switch xim-dance-commander)))
    (defalias XFR #((cmd-button ,(setxkb "fr")) (layer-switch fr)))
    (defalias XUS #((cmd-button ,(setxkb "us")) (layer-switch fr)))
    (defalias LLL (layer-next meta))
    ;; (defalias shV (tap-hold-next-release 200 @SDV lsft))
    ;; (defalias shC (tap-hold-next-release 200 @SDC lsft))
    (defalias mDB (tap-hold-next-release 200 @SDB lmet))
    (defalias mDD (tap-hold-next-release 200 @SDD lmet))
    (defalias mXB (tap-hold-next-release 200 @SXB lmet))
    (defalias mXD (tap-hold-next-release 200 @SXD lmet))
    ))

(define kmonad-numrow-modifier-aliases
  '((defalias c1 (tap-hold-next-release 200 1 lctl))
    (defalias c0 (tap-hold-next-release 200 0 lctl))
    (defalias W4 (tap-hold-next-release 200 4 (layer-toggle whitespace)))
    (defalias W5 (tap-hold-next-release 200 5 (layer-toggle whitespace)))
    (defalias W6 (tap-hold-next-release 200 6 (layer-toggle whitespace)))
    (defalias W7 (tap-hold-next-release 200 7 (layer-toggle whitespace)))
    ;; (defalias S2 (tap-hold-next-release 200 2 (layer-toggle symbols)))
    ;; (defalias xS2 (tap-hold-next-release 200 2 (layer-toggle xim-symbols)))
    ;; (defalias S9 (tap-hold-next-release 200 9 (layer-toggle symbols)))
    ;; (defalias xS9 (tap-hold-next-release 200 9 (layer-toggle xim-symbols)))
    ;; (defalias m3 (tap-hold-next-release 200 3 lmet))
    ;; (defalias m8 (tap-hold-next-release 200 8 lmet))
    ))

(define kmonad-dance-commander-modifier-aliases
  '((defalias ac (tap-hold-next-release 200 a lctl))
    (defalias uW (tap-hold-next-release 200 u (layer-toggle whitespace)))
    (defalias hW (tap-hold-next-release 200 h (layer-toggle whitespace)))
    (defalias sc (tap-hold-next-release 200 s lctl))
    (defalias Qs (tap-hold-next-release 200 @qte lsft))
    (defalias ls (tap-hold-next-release 200 l rsft))
    (defalias qs (tap-hold-next-release 200 q lsft))
    (defalias vs (tap-hold-next-release 200 v rsft))
    (defalias oS (tap-hold-next-release 200 o (layer-toggle symbols)))
    (defalias xoS (tap-hold-next-release 200 o (layer-toggle xim-symbols)))
    (defalias nS (tap-hold-next-release 200 n (layer-toggle symbols)))
    (defalias xnS (tap-hold-next-release 200 n (layer-toggle xim-symbols)))
    (defalias em (tap-hold-next-release 200 e lmet))
    (defalias tm (tap-hold-next-release 200 t lmet))
    (defalias Smc (tap-hold-next-release 200 @smc lsft))
    (defalias Sz (tap-hold-next-release 200 z lsft))
    (defalias yW (tap-hold-next-release 200 y (layer-toggle whitespace)))
    (defalias fW (tap-hold-next-release 200 f (layer-toggle whitespace)))
    ;; (defalias qS (tap-hold-next-release 200 q (layer-toggle symbols)))
    ;; (defalias xqS (tap-hold-next-release 200 q (layer-toggle xim-symbols)))
    ;; (defalias vS (tap-hold-next-release 200 v (layer-toggle symbols)))
    ;; (defalias xvS (tap-hold-next-release 200 v (layer-toggle xim-symbols)))
    ))

(define kmonad-whitespce-aliases
  '((defalias Cn C-n)
    (defalias Cp C-p)
    (defalias Csp C-spc)
    (defalias CP  #(C-spc P))))

(define kmonad-system-actions-aliases
  '((defalias vt2 (cmd-button "/run/current-system/profile/bin/chvt 2"))
    (defalias vt3 (cmd-button "/run/current-system/profile/bin/chvt 3"))
    (defalias vt9 (cmd-button "/run/current-system/profile/bin/chvt 9"))
    (defalias v10 (cmd-button "/run/current-system/profile/bin/chvt 10"))
    (defalias v11 (cmd-button "/run/current-system/profile/bin/chvt 11"))))

;; food for thought: not doing anything of ctrls or under @CP, or left of @CP
(define kmonad-dance-commander-layer
  '(deflayer dance-commander
     esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  @LLL
     grv  1    2    3    4    5    6    7    8    9    0    @Csp @CP  bspc  ins  home pgup
     tab  @Qs  @com @dot p    @yW  @fW  g    c    r    @ls  /    =    \     del  end  pgdn
     @EC  @ac  @oS  @em  u    i    d    h    @tm  @nS  @sc  -    @RC
     lsft @Smc q    j    k    x    b    m    w    v    @Sz  rsft                 up
     @Tsy @Tsy @mDB           spc            @mDB ralt @Tsy  @Tsy            left down rght))

(define kmonad-xim-dance-commander-layer
  (kmonad/merge-layers
   kmonad-dance-commander-layer
   '(deflayer xim-dance-commander
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   @xoS XX   XX   XX   XX   XX   XX   @xnS XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                  XX
      @Tsx @Tsx @mXB           XX             @mXB XX   @Tsx @Tsx           XX   XX   XX)))

(define kmonad-dvorak-no-bullshit-layer
  '(deflayer dvorak-no-bullshit
     @SDD f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
     grv  1    2    3    4    5    6    7    8    9    0    @osb @csb bspc  ins  home pgup
     tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
     @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
     lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
     @Tsy @Tsy lmet           spc            rmet ralt @Tsy @Tsy            left down rght))

(define kmonad-dvorak-some-bullshit-layer
  '(deflayer dvorak-some-bullshit
     @SDD f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  @LLL
     grv  1    2    3    @W4  @W5  @W6  @W7  8    9    0    @Csp @CP  bspc  ins  home pgup
     tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
     @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
     lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
     @Tsy @Tsy @mDD           spc            @mDD ralt @Tsy @Tsy            left down rght))

(define kmonad-xim-dvorak-some-bullshit-layer
  (kmonad/merge-layers
   kmonad-dvorak-some-bullshit-layer
   '(deflayer xim-dvorak-some-bullshit
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                   XX
      @Tsx @Tsx @mXD           XX             @mXD XX   @Tsx @Tsx            XX   XX   XX)))

(define kmonad-whitespace-layer
  '(deflayer whitespace
     esc  mute vold volu XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   home XX   XX   end  del  del  XX   XX   XX   XX   XX   @CP  bspc  ret  brup pgup
     tab  tab  XX   tab  XX   bspc bspc pgup up   pgdn XX   /    XX   \     del  brdn pgdn
     caps XX   XX   down up   ret  ret  left down rght XX   -    @RC
     lsft XX   XX   pgdn pgup tab  tab  XX   XX   XX   XX   rsft                 brup
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left brdn rght))

(define kmonad-symbols-layer
  '(deflayer symbols
     @SYS ä    ö    ë    ü    ï    ÿ    f7   f8   f9   f10  f11  @SYS
     grv  â    œ    ê    ù    î    XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
     tab  ^    -    è    =    @ocb /    XX   ç    /    @λ   /    =    \     del  end  pgdn
     @EC  à    ô    é    &    @p   \    @op  @cp  \    XX   -    @RC
     lsft +    \_   XX   û    @ccb XX   @osb @csb XX   XX   rsft                 up
     @Tsy @Tsy lmet           spc            rmet @Tsy @Tsy @Tsy            left down rght))

(define kmonad-xim-symbols-layer
  (kmonad/merge-layers
   kmonad-symbols-layer
   '(deflayer xim-symbols
      XX   @ä   @ö   @ë   @ü   @ï   @ÿ   XX   XX   XX   XX   XX   XX
      XX   @â   @œ   @ê   @ù   @î   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   @è   XX   XX   XX   XX   @ç   XX   @λ   XX   XX   XX   XX   XX   XX
      XX   @à   @ô   @é   XX   XX   XX   XX   XX   XX   XX   XX   @RC
      XX   XX   XX   @œ   @û   @ccb XX   @osb @csb XX   XX   rsft                XX
      @Tsx @Tsx  lmet          spc            rmet @Tsx @Tsx @Tsx           XX   XX   XX)))

(define kmonad-system-layer
  '(deflayer system
     XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 @v10 @v11 XX
     XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 @v10 @osb @csb bspc  ins  home pgup
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  end  pgdn
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    @RC
     lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
     @Tsy @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

(define kmonad-meta-layer
  '(deflayer meta
     XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 @v10 @v11 @XFR
     XX   @XDD @XDB @XDN XX   XX   XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
     XX   @XFR XX   XX   XX   XX   @XFR XX   XX   XX   XX   /    =    \     del  end  pgdn
     XX   @XFR XX   XX   @XUS XX   @XDD XX   XX   @XDN XX   -    @RC
     lsft XX   @XUS XX   XX   @XXD @XXD XX   XX   @XDB XX   rsft                 up
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

(define kmonad-fr-layer
  ;; kmonad sets it as us, then we let xorg take care of it.
  '(deflayer fr
     esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  @LLL
     grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc  ins  home pgup
     tab  q    w    e    r    t    y    u    i    o    p    @osb @csb \     del  end  pgdn
     caps a    s    d    f    g    h    j    k    l    @smc @qte ret
     lsft z    x    c    v    b    n    m    @com @dot /    rsft                 up
     lctl lmet lalt           spc            ralt rmet cmp  rctl            left down rght))

(define kmonad-empty-layer
  '(deflayer empty
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  end  pgdn
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    @RC
     lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

(define (kmonad-make-config-file input output default-layer)
  (let ((xkb (if (equal? default-layer kmonad-fr-layer)
                 "fr"
                 "us")))
    (mixed-text-file
     "kmonad-config"
     kmonad-defsrc-us
     (sexps-to-string
      (list
       (kmonad-defcfg input output xkb)))
     kmonad-base-aliases
     (sexps-to-string
      kmonad-common-modifier-aliases
      kmonad-numrow-modifier-aliases
      kmonad-dance-commander-modifier-aliases
      kmonad-system-actions-aliases
      kmonad-whitespce-aliases
      kmonad-xim-aliases)
     (sexps-to-string
      (delete-duplicates
       (list default-layer
             kmonad-dance-commander-layer
             kmonad-xim-dance-commander-layer
             kmonad-dvorak-no-bullshit-layer
             kmonad-dvorak-some-bullshit-layer
             kmonad-xim-dvorak-some-bullshit-layer
             kmonad-whitespace-layer
             kmonad-symbols-layer
             kmonad-system-layer
             kmonad-xim-symbols-layer
             kmonad-meta-layer
             kmonad-fr-layer))))))

(define (kmonad-config id input default-layer)
  `(,id
    ,(kmonad-make-config-file
      input
      (string-append "kbd-you-touch-my-tralala-" id)
      default-layer)))

(define kmonad-laptop-config
  (kmonad-config "laptop"
                 "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
                 kmonad-dance-commander-layer))

(define kmonad-fr-laptop-config
  (kmonad-config "laptop"
                 "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
                 kmonad-fr-layer))

(define kmonad-ergodox-config
  (kmonad-config "ergodox"
                 "/dev/input/by-id/usb-ZSA_Technology_Labs_Ergodox_EZ_9p4oo_6aXwEB-event-kbd"
                 kmonad-dance-commander-layer))

(define kmonad-bullshit-config
  (kmonad-config "cheap-bullshit"
                 "/dev/input/by-id/usb-MOSART_Semi._2.4G_INPUT_DEVICE-event-kbd"
                 kmonad-fr-layer))
