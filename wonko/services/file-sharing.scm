(define-module (wonko services file-sharing)
  #:use-module (gnu services)
  #:use-module (gnu services file-sharing)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-26)
  #:export (noautostart-transmission-daemon-service-type))


(define (noautostart-transmission-daemon-shepherd-service config)
  (list (shepherd-service
         (inherit (car ((@@ (gnu services file-sharing)
                            transmission-daemon-shepherd-service)
                        config)))
         (auto-start? #f))))

(define noautostart-transmission-daemon-service-type
  (service-type
   (inherit transmission-daemon-service-type)
   (extensions
    (list (service-extension shepherd-root-service-type
                             noautostart-transmission-daemon-shepherd-service)
          (service-extension account-service-type
                             (const (@@ (gnu services file-sharing)
                                        %transmission-daemon-accounts)))
          (service-extension activation-service-type
                             (@@ (gnu services file-sharing)
                                 transmission-daemon-activation))))))
