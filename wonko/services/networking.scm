(define-module (wonko services networking)
  #:use-module (gnu)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11))

(use-package-modules admin linux vpn)
(use-service-modules shepherd)

(define-public azirevpn-fr-service
  (list
   (shepherd-service
     (requirement '(networking user-processes udev)) ;;  wait-for-wan
     (provision '(azirevpn))
     (start #~(lambda _
                (invoke (string-append #$wireguard-tools "/bin/wg-quick")
                        "up" "azirevpn-fr-par")))
     (stop #~(lambda _
               (invoke (string-append #$wireguard-tools "/bin/wg-quick")
                       "down" "azirevpn-fr-par")))
     (respawn-delay 5) ;; retry every 5s
     (documentation "azirevpn wg"))))

(define-public wait-for-wan-service
  (list
   (shepherd-service
     (requirement '(networking user-processes))
     (provision '(wait-for-wan))
     (start #~(lambda _
                (lambda ()
                  (invoke "/run/privileged/bin/ping" "-c3" "8.8.8.8"))))
     (one-shot? #f)
     (respawn? #t) ;; FIXME is not respawned :(
     (respawn-delay 5) ;; retry every 5s
     ;; The limit is expressed as a pair of integers: the first integer, n, specifies a number of consecutive respawns and the second integer, t, specifies a number of seconds
     (respawn-limit #~'(6000 . 1000)) ;; oo
     (documentation "wait for wan"))))
