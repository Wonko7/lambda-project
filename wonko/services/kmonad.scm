;; https://github.com/kmonad/kmonad/issues/483
(define-module (wonko services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 match)
  ;; my stuff
  #:use-module (wonko misc)
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
                 (string-append
                  " -option compose:menu,compose:ralt,shift:breaks_caps,shift:both_capslock"
                  " -variant altgr-intl us")
                 " -option lv3:ralt_switch fr latin9"))
        (setxkb " /run/current-system/profile/bin/setxkbmap ")
        (sudo "/run/privileged/bin/sudo -u ")
        (display  " DISPLAY="))
    (apply string-append
           (map (match-lambda
                  ((user . disp)
                   (string-append
                    sudo user display disp setxkb " us -option" ";\n" ;; reset options
                    sudo user display disp setxkb xkb ";\n")))
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
    (defalias λ #(\ \ l a m b d a))

    (defalias qu  #( ? ))
    (defalias til #( ~ ))))

(define kmonad-common-modifier-aliases
  `(;; <3
    (defalias EC (tap-next-release esc lctl))
    (defalias RC (tap-next-release ret rctl))
    ;; next doesn't work in this one:
    ;; (defalias SA (tap-next-release
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
    (defalias SRQ (layer-switch sysrq))
    (defalias XDB #((cmd-button ,(setxkb "us")) (layer-switch dvorak-some-bullshit)))
    (defalias XDD #((cmd-button ,(setxkb "us")) (layer-switch dance-commander)))
    (defalias XDN #((cmd-button ,(setxkb "us")) (layer-switch dvorak-no-bullshit)))
    (defalias XXB #((cmd-button ,(setxkb "us")) (layer-switch xim-dvorak-some-bullshit)))
    (defalias XXD #((cmd-button ,(setxkb "us")) (layer-switch xim-dance-commander)))
    (defalias XFR #((cmd-button ,(setxkb "fr")) (layer-switch fr)))
    (defalias XUS #((cmd-button ,(setxkb "us")) (layer-switch fr)))
    (defalias LLL (layer-next meta))
    ;; (defalias shV (tap-next-release @SDV lsft))
    ;; (defalias shC (tap-next-release @SDC lsft))
    (defalias mDB (tap-next-release @SDB lmet))
    (defalias mDD (tap-next-release @SDD lmet))
    (defalias mXB (tap-next-release @SXB lmet))
    (defalias mXD (tap-next-release @SXD lmet))
    ))

(define kmonad-numrow-modifier-aliases
  '((defalias c1 (tap-next-release 1 lctl))
    (defalias c0 (tap-next-release 0 lctl))
    (defalias W4 (tap-next-release 4 (layer-toggle whitespace)))
    (defalias W5 (tap-next-release 5 (layer-toggle whitespace)))
    (defalias W6 (tap-next-release 6 (layer-toggle whitespace)))
    (defalias W7 (tap-next-release 7 (layer-toggle whitespace)))
    ;; (defalias S2 (tap-next-release 2 (layer-toggle symbols)))
    ;; (defalias xS2 (tap-next-release 2 (layer-toggle xim-symbols)))
    ;; (defalias S9 (tap-next-release 9 (layer-toggle symbols)))
    ;; (defalias xS9 (tap-next-release 9 (layer-toggle xim-symbols)))
    ;; (defalias m3 (tap-next-release 3 lmet))
    ;; (defalias m8 (tap-next-release 8 lmet))
    ))

(define kmonad-dance-commander-modifier-aliases
  '((defalias ac (tap-next-release a lctl))
    (defalias sc (tap-next-release s lctl))
    (defalias Qs (tap-next-release @qte lsft))
    (defalias ls (tap-next-release l rsft))
    (defalias qs (tap-next-release q lsft))
    (defalias vs (tap-next-release v rsft))
    (defalias oS (tap-next-release o (layer-toggle symbols)))
    (defalias xoS (tap-next-release o (layer-toggle xim-symbols)))
    (defalias nS (tap-next-release n (layer-toggle symbols)))
    (defalias xnS (tap-next-release n (layer-toggle xim-symbols)))
    (defalias em (tap-next-release e lmet))
    (defalias tm (tap-next-release t lmet))
    (defalias uW (tap-next-release u (layer-toggle whitespace)))
    (defalias hW (tap-next-release h (layer-toggle whitespace)))
    (defalias Smc (tap-next-release @smc (around lctl lsft)))
    (defalias Sz (tap-next-release z (around lctl lsft)))
    (defalias yW (tap-next-release y (layer-toggle whitespace)))
    (defalias fW (tap-next-release f (layer-toggle whitespace)))
    ;; (defalias qS (tap-next-release q (layer-toggle symbols)))
    ;; (defalias xqS (tap-next-release q (layer-toggle xim-symbols)))
    ;; (defalias vS (tap-next-release v (layer-toggle symbols)))
    ;; (defalias xvS (tap-next-release v (layer-toggle xim-symbols)))
    ))

(define kmonad-whitespce-aliases
  '((defalias Cn C-n)
    (defalias Cp C-p)
    (defalias Csp C-spc)
    (defalias C:  #(C-spc :))
    (defalias CP  #(C-spc P))))

(define (char-index->sysrq-alias i)
  (let* ((c (char-set->string
             (char-set
              (integer->char
               (+ (char->integer #\a) i)))))
         (var (string->symbol
               (string-append "RQ" c)))
         (key (string->symbol c)))
    `(defalias ,var #((around A-ssrq ,key)))))

(define kmonad-system-actions-aliases
  (append
   ;; sysrq:
   '((defalias RIP #((around A-ssrq s)    ;; sync
                     (pause 1000)
                     (around A-ssrq u)    ;; remount ro
                     (pause 1000)
                     (around A-ssrq b)))) ;; reboot
   (map char-index->sysrq-alias (range 0 25))
   ;; chvt:
   (map
    (lambda (i)
      (let ((n (number->string i)))
        `(defalias
           ,(string->symbol (string-append (if (> i 9) "v" "vt") n))
           (cmd-button ,(string-append "/run/current-system/profile/bin/chvt " n)))))
    (range 1 12))))

;; food for thought: not doing anything of ctrls or under @CP, or left of @CP
;; doc: x modifiers: lalt -> meta (emacs), lmet -> hyper (WM).
(define kmonad-dance-commander-layer
  '(deflayer dance-commander
     esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  @LLL
     grv  1    2    3    4    5    6    7    8    9    0    @Csp @CP  bspc  ins  home pgup
     tab  @Qs  @com @dot p    @yW  @fW  g    c    r    @ls  /    @C:  \     del  end  pgdn
     @EC  @ac  @oS  @em  @uW  i    d    @hW  @tm  @nS  @sc  -    @RC
     lsft @Smc q    j    k    x    b    m    w    v    @Sz  rsft                 up
     lalt @Tsy @mDB           spc            @mDB ralt @Tsy @Tsy            left down rght))

(define kmonad-xim-dance-commander-layer
  (kmonad/merge-layers
   kmonad-dance-commander-layer
   '(deflayer xim-dance-commander
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   @xoS XX   XX   XX   XX   XX   XX   @xnS XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                  XX
      lalt @Tsx @mXB           XX             @mXB XX   @Tsx @Tsx           XX   XX   XX)))

(define kmonad-dvorak-no-bullshit-layer
  '(deflayer dvorak-no-bullshit
     @SDD f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
     grv  1    2    3    4    5    6    7    8    9    0    @osb @csb bspc  ins  home pgup
     tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
     @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
     lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
     lalt @Tsy lmet           spc            rmet ralt @Tsy @Tsy            left down rght))

(define kmonad-dvorak-some-bullshit-layer
  '(deflayer dvorak-some-bullshit
     @SDD f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  @LLL
     grv  1    2    3    @W4  @W5  @W6  @W7  8    9    0    @Csp @CP  bspc  ins  home pgup
     tab  @qte @com @dot p    y    f    g    c    r    l    /    =    \     del  end  pgdn
     @EC  a    o    e    u    i    d    h    t    n    s    -    @RC
     lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
     lalt @Tsy @mDD           spc            @mDD ralt @Tsy @Tsy            left down rght))

(define kmonad-xim-dvorak-some-bullshit-layer
  (kmonad/merge-layers
   kmonad-dvorak-some-bullshit-layer
   '(deflayer xim-dvorak-some-bullshit
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                   XX
      lalt @Tsx @mXD           XX             @mXD XX   @Tsx @Tsx            XX   XX   XX)))

(define kmonad-whitespace-layer
  '(deflayer whitespace
     esc  mute vold volu XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   home XX   XX   end  del  del  XX   XX   XX   XX   XX   @CP  bspc  ret  brup pgup
     tab  tab  XX   tab  XX   bspc bspc pgup up   pgdn XX   /    XX   \     del  brdn pgdn
     caps XX   XX   esc  esc  ret  ret  left down rght XX   -    @RC
     lsft XX   XX   esc  esc  tab  tab  esc  esc  XX   XX   rsft                 brup
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left brdn rght))

(define kmonad-symbols-layer
  '(deflayer symbols
     @SYS ä    ö    ë    ü    ï    ÿ    f7   f8   f9   f10  f11  @SYS
     grv  â    œ    ê    ù    î    XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
     tab  ^    -    è    =    @ocb /    XX   ç    /    @λ   /    =    \     del  end  pgdn
     @EC  à    ô    é    &    @p   \    @op  @cp  \    XX   -    @RC
     lsft +    \_   XX   û    @ccb @til @osb @csb @qu  @qu  rsft                 up
     lalt @Tsy lmet           spc            rmet @Tsy @Tsy @Tsy            left down rght))

(define kmonad-xim-symbols-layer
  (kmonad/merge-layers
   kmonad-symbols-layer
   '(deflayer xim-symbols
      XX   @ä   @ö   @ë   @ü   @ï   @ÿ   XX   XX   XX   XX   XX   XX
      XX   @â   @œ   @ê   @ù   @î   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   @è   XX   XX   XX   XX   @ç   XX   @λ   XX   XX   XX   XX   XX   XX
      XX   @à   @ô   @é   XX   XX   XX   XX   XX   XX   XX   XX   @RC
      XX   XX   XX   @œ   @û   @ccb XX   @osb @csb XX   XX   rsft                XX
      lalt @Tsx  lmet          spc            rmet @Tsx @Tsx @Tsx           XX   XX   XX)))

(define kmonad-system-layer
  '(deflayer system
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt6 @vt8 @vt9 @v10 @v11 @v12
     XX   XX   @vt2 @vt3 XX   XX   XX   XX   XX   @vt9 @v10 @v11 @v12 bspc  ins  home pgup
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  @SRQ pgdn
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    @RC
     lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

(define kmonad-sysrq-layer
  '(deflayer sysrq
     @SDD f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
     grv  1    2    3    4    5    6    7    8    9    0    @osb @csb bspc  ins  home pgup
     tab  @qte @com @dot @RQp @RQy @RQf @RQg @RQc @RQr @RQl /    =    \     del  @RIP pgdn
     @EC  @RQa @RQo @RQe @RQu @RQi @RQd @RQh @RQt @RQn @RQs -    @RC
     lsft @smc @RQq @RQj @RQk @RQx @RQb @RQm @RQw @RQv @RQz rsft                 up
     lalt @Tsy lmet           spc            rmet ralt @Tsy @Tsy            left down rght))

(define kmonad-meta-layer
  '(deflayer meta
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt6 @vt8 @vt9 @v10 @v11 @XFR
     XX   @XDD @XDB @XDN XX   XX   XX   XX   XX   @vt9 @v10 @v11 @csb bspc  ins  home pgup
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
             kmonad-sysrq-layer
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
