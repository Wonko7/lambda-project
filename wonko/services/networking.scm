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
  #:use-module (srfi srfi-11)
  #:use-module (wonko misc))

(use-package-modules admin linux vpn)
(use-service-modules shepherd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vpn

(define-public wan-vpn-service
  (list
   (shepherd-service
     (requirement '(networking user-processes udev)) ;;  wait-for-wan
     (provision '(wan-vpn))
     (start #~(lambda _
                (invoke (string-append #$wireguard-tools "/bin/wg-quick")
                        "up" "wg-wan-vpn")))
     (stop #~(lambda _
               (invoke (string-append #$wireguard-tools "/bin/wg-quick")
                       "down" "wg-wan-vpn")))
     (respawn-delay 5) ;; retry every 5s
     (respawn-limit #~'(69 . 1)) ;; oo
     (documentation "wan wg"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wait for internet

(define-public wait-for-wan-service
  (list
   (shepherd-service
     (requirement '(networking user-processes))
     (provision '(wait-for-wan))
     (start #~(lambda _
                (invoke "/run/privileged/bin/ping" "-c3" "8.8.8.8")))
     (one-shot? #t)
     (respawn? #t)
     (respawn-delay 5) ;; retry every 5s
     ;; The limit is expressed as a pair of integers: the first integer, n, specifies a number of consecutive respawns and the second integer, t, specifies a number of seconds
     (respawn-limit #~'(6000 . 1000)) ;; oo
     (documentation "wait for wan"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fleet keep-alive service

(define-public fleet-keep-alive-service-type
  (shepherd-service-type
   'fleet-keep-alive
   (lambda (host)
     (shepherd-service
       (documentation (string-append "periodically ping " host))
       (provision
        (list (string->symbol (string-append "fleet-keep-alive-" host))))
       (requirement '(networking user-processes guix-daemon))
       (modules '((shepherd service timer)))
       (start #~(make-timer-constructor
                 (calendar-event #:minutes '#$(range 0 59 #:step 3))
                 (command
                  (list "/run/privileged/bin/ping" "-c3" #$host))
                 #:log-file "/var/log/fleet-keepalive.log"
                 #:wait-for-termination? #t))
       (stop #~(make-timer-destructor))))
   #t
   (description "periodically ping local hosts")))
