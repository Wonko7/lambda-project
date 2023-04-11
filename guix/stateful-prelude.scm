(define-module (stateful-prelude)
  #:use-module (fleet))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stateful stuff:

(define-public conf-root-dir
  (dirname
   (dirname (current-filename)))) ;; FIXME: threading macro plz?

(chdir (dirname (current-filename))) ;; "/code/wonko-mono-conf/guix"

(define-public %ship (hostname->ship (getenv "SHIP")))
(unless %ship
  (display "something is fucky with SHIP env var." (current-error-port))
  (exit #f))
(define-public %home (getenv "HOME"))
