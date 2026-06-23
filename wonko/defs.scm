(define-module (wonko defs)
  #:use-module (guix gexp)
  #:use-module (gnu system keyboard))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general defs:


(define-public %font "JetBrains Mono Medium")
(define-public %font-feh "JetBrainsMono-Regular")

(define-public %lock-cmd
  '("/run/setuid-programs/xlock" "-mode" "daisy" "-lockdelay" "10"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; kbd

(define-public %dvorak-kb
  (keyboard-layout "us" "dvorak" #:options '("ctrl:nocaps")))
(define-public %fr-kb
  (keyboard-layout "fr" "azerty" #:options '("ctrl:nocaps")))
(define-public %us-kb
  (keyboard-layout "us" "qwerty" #:options '("ctrl:nocaps")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; record

(define-public (check predicate)
  (lambda (v)
    (if (predicate v)
        v
        (display (string-append "bad record value : " v)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sys paths

(define-public %lambda-project "/code/lambda-project")
(define-public %sys-profile-path "/run/current-system/profile/bin/")

(define-public %wake-up-notification-file "/run/systemd/wakeup")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dome paths

(define-public %home-log-root ".run/log/")
(define-public (home-log-path fn)
  #~(string-append (getenv "HOME") "/" #$%home-log-root #$fn ".log"))

(define-public %wallpaper "/data/docs/pics/wallpapers/nasa-poster-vision-future/1 - 8XMgqaI.png")
(define-public %guix-extra-profiles-dir "$HOME/.guix-extra-profiles")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; colours

(define-public %background-colour "#27212E")
(define-public %foreground-hl-colour "#EB64B9")
