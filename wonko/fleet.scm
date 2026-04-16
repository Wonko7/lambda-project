(define-module (wonko fleet)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu services base)
  #:use-module (gnu)
  #:use-module (wonko defs)
  #:export (%fleet-hosts
            %fleet-names
            net-peer-local-address
            net-peer-wg-address))

(use-service-modules base vpn)

(define-record-type* <net-peer>
  net-peer make-net-peer
  net-peer?
  this-net-peer
  (name net-peer-name (sanitize (check string?)))
  (wg-address net-peer-wg-address (sanitize (check string?)))
  (local-address net-peer-local-address (sanitize (check string?)))
  (public-key net-peer-public-key (sanitize (check string?))))

(define-public %of-course-i-still-love-you-net-peer
  (net-peer
   (name "of-course-i-still-love-you")
   (public-key "U7UZuuT33d22P8lRCcvF8RbS1/PKhBQUeYhyOhmVoGY=")
   (local-address "192.168.1.7") ;; remember to update router's MAC -> ip attribution
   (wg-address "10.42.0.7")))

(define-public (net-to-wg-peer peer)
  (wireguard-peer
    (name (net-peer-name peer))
    (public-key (net-peer-public-key peer))
    (allowed-ips (list (string-append (net-peer-wg-address peer) "/32")))))

(define-public (net-peer-addr-to/24 peer)
  (list (string-append (net-peer-wg-address peer) "/24")))

(define-public %star-fleet-client-config
  (wireguard-configuration
    (interface "star-fleet")
    (peers
     (list
      (wireguard-peer
        (inherit (net-to-wg-peer %of-course-i-still-love-you-net-peer))
        (public-key "U7UZuuT33d22P8lRCcvF8RbS1/PKhBQUeYhyOhmVoGY=")
        (endpoint "[2a01:e0a:b5a:de71::1]:51820")
        (allowed-ips '("10.42.0.0/24"))
        (keep-alive 60))))))

(define-public %enterprise-net-peer
  (net-peer
   (name "enterprise")
   (public-key "mvSVvhTp95KdeSGqnvQlO6GAYJoB0f9uqhbv7UrZTFQ=")
   (local-address "192.168.1.6")
   (wg-address "10.42.0.6")))

(define-public %yggdrasill-net-peer
  (net-peer
   (name "yggdrasill")
   (public-key "bhy+DDTGIcndgFWk1TLTttZAi0COnugg+YpTBB96Wm0=")
   (local-address "192.168.1.3")
   (wg-address "10.42.0.3")))

(define-public %rocinante-net-peer
  (net-peer
   (name "rocinante")
   (public-key "Hpugstb4CA8kryRhzE37vl76mrfYPqWHBkFXjiydfl0=")
   (local-address "192.168.1.4")
   (wg-address "10.42.0.4")))

(define-public %discovery-net-peer
  (net-peer
   (name "discovery")
   (public-key "nIAdvx5JR1uwLyyzKgOU/x3DHi6KKKKcL9nexPAP50Q=")
   (local-address "")
   (wg-address "10.42.0.5")))

(define-public %nispe-net-peer
  (net-peer
   (name "nispe")
   (public-key "Tg9H0FfzLndUEcRYQ6EsqQzPIsozrCtUASQ4WVItWgQ=")
   (local-address "192.168.1.9")
   (wg-address "10.42.0.9")))


(define-public %star-fleet-hosts
  (list %yggdrasill-net-peer
        %enterprise-net-peer
        %rocinante-net-peer
        %discovery-net-peer
        %nispe-net-peer
        %of-course-i-still-love-you-net-peer))

(define-public %fleet-hosts
  (append
   (filter identity
           (map (lambda (h)
                  (if (not (string= "" (net-peer-local-address h)))
                      (host (net-peer-local-address h)
                            (string-append (net-peer-name h) ".local"))
                      #f))
                %star-fleet-hosts))
   (map (lambda (h)
          (host (net-peer-wg-address h)
                (string-append (net-peer-name h) ".star-fleet.local")))
        %star-fleet-hosts)
   ;; (list
   ;;  ;; (host "192.168.1.1" "daban-urnud.local") ;; RIP you now rest in silicon heaven
   ;;  (host "192.168.1.9" "nispe.local"))
   ))

(define-public (fleet-names-from-hosts hosts)
  (map (lambda (h)
         (string-drop-right (host-canonical-name h) 6))
       hosts))

(define-public (fleet-canonical-names-from-hosts hosts)
  (map (lambda (h)
         (host-canonical-name h))
       hosts))

(define-public %fleet-names (list ;; machines that have ssh & substitute keys:
                             ;; "daban-urnud"             ;; 1
                             ;; "discovery"               ;; 5 (not on local net)
                             ;; "nispe"                   ;; 9
                             "enterprise"                 ;; 6
                             "of-course-i-still-love-you" ;; 7
                             "rocinante"                  ;; 4
                             "yggdrasill"))               ;; 3
