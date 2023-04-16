(define-module (stateful-prelude)
  #:use-module (defs)
  #:use-module (fleet))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stateful stuff:

(define-public %ship (hostname->ship (getenv "SHIP")))

(unless %ship
  (display "something is fucky with SHIP env var." (current-error-port))
  (throw 'no-ship))

(define-public %home (getenv "HOME"))
