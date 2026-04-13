;; https://github.com/kmonad/kmonad/issues/483
(define-module (wonko services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 match)
  #:use-module (pipe)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; layer constructors

;; to make these easily threadable, first arg is a layer-def
;; which is just a (list aliases layer).
;; TODO might make this a record?

(define (init-layer layer name)
  (list '() ;; empty aliases
        (cons*
         'deflayer
         name
         (drop layer 2))))

(define (kmonad/merge-layers l1-layer-def l2)
  "Replace l1 keys with non XX keys from l2"
  (match-let (((previous-aliases l1) l1-layer-def))
    (list
     previous-aliases
     (map (lambda (k1 k2)
            (if (equal? k2 'XX) k1 k2))
          l1
          l2))))

(define layer-counter 0)
(define (kmonad/merge-with-tap-fn layer-def modifiers tap-fn)
  "To facilitate home row on multiple layers:
replace keys in layer with modifiers as held vs original key if tapped.
To have the same number of elements in layer & modifiers, modifiers has XX XX
as preamble instead of `deflayer dvorak-etc'. Returns a list with two elements,
the aliases definitions & the new layer."
  (set! layer-counter (1+ layer-counter)) ;; to avoid collisions
  (let* ((alias-prefix (number->string
                        layer-counter))
         (alias-name (lambda (a b)
                       (string-append "layer_" alias-prefix "_"
                                      (symbol->string a)
                                      "-"
                                      (symbol->string b)))))
    (match-let* (((previous-aliases layer) layer-def)
                 ((aliases new-layer) (fold
                                       (match-lambda*
                                         ((k1 k2 (aliases layer))
                                          (if (equal? k2 'XX)
                                              (list aliases
                                                    (cons k1 layer))
                                              (let ((alias (alias-name k1 k2)))
                                                (list (cons `(defalias ,(string->symbol alias)
                                                               ,(tap-fn k1 k2))
                                                            aliases)
                                                      (cons (string->symbol
                                                             (string-append "@" alias))
                                                            layer))))))
                                       `(,previous-aliases ())
                                       layer
                                       modifiers)))
      (list aliases
            (reverse new-layer)))))

(define (kmonad/tap-fn k1 k2)
  "to be used as arg to kmonad/merge-with-tap-fn"
  `(tap-hold-next-release
    700 ,k1
    ;; This could be constructed on modifier initials. I only have two cases for now:
    ,(cond ((equal? k2 'ALcs) '(around lctl lsft))
           ((equal? k2 'ARcs) '(around rctl rsft))
           (#t k2))))

(define (kmonad/layer-tap-fn k1 k2)
  "to be used as arg to kmonad/merge-with-tap-fn"
  `(tap-hold-next-release
    700 ,k1
    ,(cond ((equal? k2 'ws) '(layer-toggle whitespace))
           ((equal? k2 'sym) '(layer-toggle symbols))
           ((equal? k2 'xsym) '(layer-toggle xim-symbols))
           (#t k2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; serialise

(define* (sexps-to-string #:rest sexps)
  (apply string-append
         (apply append
                (zip (circular-list "\n")
                     (map object->string (apply append sexps))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xorg integration:

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; kmonad base config elements:

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
  `((defalias SYS (layer-next system))
    (defalias Tsy (layer-toggle symbols))
    (defalias Tsx (layer-toggle xim-symbols))
    (defalias SRQ (layer-switch sysrq))
    (defalias XDD #((cmd-button ,(setxkb "us")) (layer-switch dance-commander)))
    (defalias XXD #((cmd-button ,(setxkb "us")) (layer-switch xim-dance-commander)))
    (defalias XFR #((cmd-button ,(setxkb "fr")) (layer-switch fr)))
    (defalias XUS #((cmd-button ,(setxkb "us")) (layer-switch fr)))
    (defalias LLL (layer-next meta))))

(define kmonad-whitespace-aliases
  '((defalias Cn  C-n)
    (defalias Cp  C-p)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dance-commander dvorak

;; food for thought: not doing anything of ctrls or under @CP, or left of @CP
;; doc: x modifiers: lalt -> meta (emacs), lmet -> hyper (WM).
(define dvorak
  '(deflayer XX
     esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12 ;; FIXME f12?
     grv  1    2    3    4    5    6    7    8    9    0    @CP  @LLL bspc  ins  home pgup
     tab  @qte @com @dot p    y    f    g    c    r    l    /    @C:  \     del  end  pgdn
     esc  a    o    e    u    i    d    h    t    n    s    -    ret
     lsft @smc q    j    k    x    b    m    w    v    z    rsft                 up
     lalt @Tsy lmet           spc            rmet ralt @Tsy @Tsy            left down rght))

(define kmonad-home-row-modifiers
  '( XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   lsft XX   XX   XX   XX   XX   XX   XX   XX   rsft XX   XX   XX   XX   XX   XX
     lctl lctl XX   lmet XX   XX   XX   XX   rmet XX   rctl XX   rctl
     XX   ALcs XX   XX   XX   XX   XX   XX   XX   XX   ARcs XX                  XX
     XX   XX   XX             XX             XX   XX   XX   XX             XX   XX   XX))

(define kmonad-home-layers
  '( XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   sym  XX   ws   XX   XX   ws   XX   sym  XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                  XX
     XX   XX   XX             XX             XX   XX   XX   XX             XX   XX   XX))

(define kmonad-dance-commander-layer
  (-> dvorak
      (init-layer 'dance-commander)
      (kmonad/merge-with-tap-fn kmonad-home-row-modifiers
                                kmonad/tap-fn)
      (kmonad/merge-with-tap-fn kmonad-home-layers
                                kmonad/layer-tap-fn)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xim-dance-commander dvorak with xim symbols

(define (s/sym/xim-sym/ layer)
  (map (lambda (k)
         (cond ((equal? k 'sym) 'xsym)
               ((equal? k '@Tsy) '@Tsx)
               (#t k)))
       layer))

(define kmonad-xim-dance-commander-layer
  (-> (s/sym/xim-sym/ dvorak)
      (init-layer 'xim-dance-commander)
      (kmonad/merge-with-tap-fn kmonad-home-row-modifiers
                                kmonad/tap-fn)
      (kmonad/merge-with-tap-fn (s/sym/xim-sym/ kmonad-home-layers)
                                kmonad/layer-tap-fn)))

(define kmonad-whitespace-layer
  (->
   '(deflayer whitespace
      esc  mute vold volu XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   home XX   XX   end  del  del  XX   XX   XX   XX   XX   @CP  bspc  ret  brup pgup
      tab  home XX   tab  XX   bspc bspc pgup up   pgdn XX   /    XX   \     del  brdn pgdn
      caps XX   XX   esc  esc  ret  ret  left down rght XX   -    ret
      lsft XX   XX   esc  esc  tab  tab  esc  esc  XX   XX   rsft                 brup
      lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            vold brdn volu)
   (init-layer 'whitespace)
   (kmonad/merge-with-tap-fn kmonad-home-row-modifiers
                             kmonad/tap-fn)))
(define symbols
  '(deflayer symbols
     @SYS ä    ö    ë    ü    ï    ÿ    f7   f8   f9   f10  f11  @SYS
     grv  â    œ    ê    ù    î    XX   XX   XX   XX   XX   @osb @csb bspc  ins  home pgup
     tab  ^    -    è    =    @ocb /    XX   ç    /    @λ   /    =    \     del  end  pgdn
     esc  à    ô    é    &    @p   \    @op  @cp  \    XX   -    ret
     lsft +    \_   XX   û    @ccb grv  @osb @csb @qu  @qu  rsft                 up
     lalt @Tsy lmet           spc            rmet @Tsy @Tsy @Tsy            left down rght))

(define kmonad-symbols-layer
  (-> symbols
      (init-layer 'symbols)
      (kmonad/merge-with-tap-fn kmonad-home-row-modifiers
                                kmonad/tap-fn)))

(define kmonad-xim-symbols-layer
  (-> symbols
      (init-layer 'xim-symbols)
      (kmonad/merge-layers
       '(deflayer xim-symbols
          XX   @ä   @ö   @ë   @ü   @ï   @ÿ   XX   XX   XX   XX   XX   XX
          XX   @â   @œ   @ê   @ù   @î   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   @è   XX   XX   XX   XX   @ç   XX   @λ   XX   XX   XX   XX   XX   XX
          XX   @à   @ô   @é   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   @œ   @û   @ccb XX   @osb @csb XX   XX   rsft                XX
          lalt @Tsx  lmet          spc            rmet @Tsx @Tsx @Tsx           XX   XX   XX))
      (kmonad/merge-with-tap-fn kmonad-home-row-modifiers
                                kmonad/tap-fn)))

(define kmonad-system-layer
  '(deflayer system
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt7 @vt8 @vt9 @v10 @v11 @v12
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt7 @vt8 @vt9 @v10 @v11 @v12 bspc  ins  home pgup
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   /    =    \     del  @SRQ pgdn
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   -    XX
     lsft XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   rsft                 up
     lalt @Tsy lmet           spc            rmet ralt cmp  @Tsy            left down rght))

(define kmonad-sysrq-layer
  '(deflayer sysrq
     @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD
     @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD @XDD  @XDD @XDD @XDD
     @XDD @qte @com @dot @RQp @RQy @RQf @RQg @RQc @RQr @RQl @XDD @XDD @XDD  @XDD @RIP @XDD
     @XDD @RQa @RQo @RQe @RQu @RQi @RQd @RQh @RQt @RQn @RQs @XDD @XDD
     @XDD @smc @RQq @RQj @RQk @RQx @RQb @RQm @RQw @RQv @RQz @XDD                 @XDD
     @XDD @XDD @XDD           @XDD           @XDD @XDD @XDD @XDD            @XDD @XDD @XDD))

(define kmonad-meta-layer
  '(deflayer meta
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt7 @vt8 @vt9 @v10 @v11 @XFR
     XX   @vt1 @vt2 @vt3 @vt4 @vt5 @vt6 @vt7 @vt8 @vt9 @v10 @v11 XX   bspc  ins  home pgup
     XX   @XFR XX   XX   XX   XX   @XFR XX   XX   XX   XX   /    =    \     del  @SRQ pgdn
     XX   @XFR XX   XX   @XUS XX   @XDD XX   XX   XX   XX   -    XX
     lsft XX   @XUS XX   XX   @XXD @XXD XX   XX   XX   XX   rsft                 up
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

(define f12->FR
  '( XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   @XFR
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
     XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX                  XX
     XX   XX   XX             XX             XX   XX   XX   XX             XX   XX   XX))

(define (kmonad-make-config-file input output default-layer)
  (let* ((xkb (if (equal? default-layer 'fr)
                  "fr"
                  "us"))
         (flatten-layer-def (match-lambda ((aliases layer)
                                           (append aliases (list layer)))))
         (flatten+EZFR-layer-def (lambda (layer)
                                   (-> layer
                                       (kmonad/merge-layers f12->FR)
                                       (flatten-layer-def)))))
    (mixed-text-file
     "kmonad-config"
     ;; base config:
     kmonad-defsrc-us
     (sexps-to-string
      (list
       (kmonad-defcfg input output xkb)))
     kmonad-base-aliases
     ;; general aliases:
     (sexps-to-string
      kmonad-common-modifier-aliases
      kmonad-system-actions-aliases
      kmonad-whitespace-aliases
      kmonad-xim-aliases)
     ;; typing layouts. order is important, first is default:
     (if (equal? default-layer 'fr)
         (sexps-to-string
          (list kmonad-fr-layer)
          (flatten+EZFR-layer-def kmonad-dance-commander-layer)
          (flatten+EZFR-layer-def kmonad-xim-dance-commander-layer))
         (sexps-to-string
          (flatten-layer-def kmonad-dance-commander-layer)
          (flatten-layer-def kmonad-xim-dance-commander-layer)
          (list kmonad-fr-layer)))
     ;; misc layouts:
     (sexps-to-string
      (flatten-layer-def kmonad-symbols-layer)
      (flatten-layer-def kmonad-xim-symbols-layer)
      (flatten-layer-def kmonad-whitespace-layer)
      (list
       kmonad-system-layer
       kmonad-sysrq-layer
       kmonad-meta-layer)))))

(define (kmonad-config id input default-layer)
  `(,id
    ,(kmonad-make-config-file
      input
      (string-append "kbd-you-touch-my-tralala-" id)
      default-layer)))

(define kmonad-laptop-config
  (kmonad-config "laptop"
                 "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
                 'dance-commander))

(define kmonad-fr-laptop-config
  (kmonad-config "laptop"
                 "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
                 'fr))

(define kmonad-ergodox-config
  (kmonad-config "ergodox"
                 "/dev/input/by-id/usb-ZSA_Technology_Labs_Ergodox_EZ_9p4oo_6aXwEB-event-kbd"
                 'dance-commander))

(define kmonad-bullshit-config
  (kmonad-config "cheap-bullshit"
                 "/dev/input/by-id/usb-MOSART_Semi._2.4G_INPUT_DEVICE-event-kbd"
                 'dance-commander))
