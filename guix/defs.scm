(define-module (defs)
  #:use-module (gnu system keyboard))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general defs:

(define-public %font "JetBrains Mono")
(define-public %wallpaper "/data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png")
(define-public %lock-cmd
  '("/run/setuid-programs/xlock" "-mode" "daisy" "-lockdelay" "10"))


(define-public %dvorak-kb
  (keyboard-layout "us" "dvorak" #:options '("ctrl:nocaps")))
(define-public %fr-kb
  (keyboard-layout "fr" "azerty" #:options '("ctrl:nocaps")))
(define-public %us-kb
  (keyboard-layout "us" "qwerty" #:options '("ctrl:nocaps")))

(define-public (check predicate)
  (lambda (v)
    (if (predicate v)
        v
        (display (string-append "bad record value : " v)))))
