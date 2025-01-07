(define-module (wonko services xorg)
  #:use-module (gnu services)
  #:use-module (gnu services xorg)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system pam)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-26)
  #:export (noautostart-slim-service-type))

(define (noautostart-slim-shepherd-service config)
  (list (shepherd-service
         (inherit (car ((@@ (gnu services xorg) slim-shepherd-service) config)))
         (auto-start? #f)
         (respawn? #f))))

(define noautostart-slim-service-type
  (service-type (inherit slim-service-type)
                (extensions
                 (list (service-extension shepherd-root-service-type
                                          noautostart-slim-shepherd-service)
                       (service-extension pam-root-service-type
                                          (@@ (gnu services xorg) slim-pam-service))))))
