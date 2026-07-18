(define-module (wonko fleet)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu services base)
  #:use-module (gnu)
  #:use-module (wonko defs)
  #:use-module (ice-9 optargs)
  #:export (%fleet-hosts
            %fleet-names
            net-peer-ip6-local-address
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
  (ip6-local-address net-peer-ip6-local-address (sanitize (check string?)))
  (public-key net-peer-public-key (sanitize (check string?))))

(define*-public (net-peer-subnet-init #:key name public-key host-id)
  (net-peer
   (name name)
   (public-key public-key)
   (wg-address (format #f "10.42.0.~d" host-id))
   (local-address (format #f "192.168.1.~d" host-id))
   (ip6-local-address (format #f "fd00::42:~d/64" host-id))))

(define-public %of-course-i-still-love-you-net-peer
  (net-peer-subnet-init
   #:name "of-course-i-still-love-you"
   #:public-key "U7UZuuT33d22P8lRCcvF8RbS1/PKhBQUeYhyOhmVoGY="
   #:host-id 7))

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
  (net-peer-subnet-init
   #:name "enterprise"
   #:public-key "mvSVvhTp95KdeSGqnvQlO6GAYJoB0f9uqhbv7UrZTFQ="
   #:host-id 6))

(define-public %yggdrasill-net-peer
  (net-peer-subnet-init
   #:name "yggdrasill"
   #:public-key "bhy+DDTGIcndgFWk1TLTttZAi0COnugg+YpTBB96Wm0="
   #:host-id 3))

(define-public %rocinante-net-peer
  (net-peer-subnet-init
   #:name "rocinante"
   #:public-key "Hpugstb4CA8kryRhzE37vl76mrfYPqWHBkFXjiydfl0="
   #:host-id 4))

(define-public %discovery-net-peer
  (net-peer
   (name "discovery")
   (public-key "nIAdvx5JR1uwLyyzKgOU/x3DHi6KKKKcL9nexPAP50Q=")
   (local-address "") ;; handled by dhcp, needs to be empty for correct hosts generation
   (ip6-local-address "fd00::42:5/64")
   (wg-address "10.42.0.5")))

(define-public %nispe-net-peer
  (net-peer-subnet-init
   #:name "nispe"
   #:public-key "Tg9H0FfzLndUEcRYQ6EsqQzPIsozrCtUASQ4WVItWgQ="
   #:host-id 9))

(define-public %star-fleet-hosts
  (list
   ;; fleet:
   %enterprise-net-peer
   %of-course-i-still-love-you-net-peer
   %rocinante-net-peer
   %yggdrasill-net-peer
   ;; friends of the fleet:
   %discovery-net-peer
   %nispe-net-peer))

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
        %star-fleet-hosts)))

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
                             ;; "discovery"               ;; 5 (not on ip4 local net)
                             ;; "nispe"                   ;; 9
                             "enterprise"                 ;; 6
                             "of-course-i-still-love-you" ;; 7
                             "rocinante"                  ;; 4
                             "yggdrasill"))               ;; 3
