(define-module (lambda fleet)
  #:use-modules (guix build utils)
  #:use-modules (guix gexp)
  #:export (%fleet-hosts
            %fleet-names))

(define-public %fleet-hosts
  (list
   (host "192.168.1.1" "daban-urnud.local")
   (host "192.168.1.3" "yggdrasill.local")
   (host "192.168.1.4" "rocinante.local")
   (host "192.168.1.6" "enterprise.local")
   (host "192.168.1.9" "nispe.local")))

(define %fleet-names (list "enterprise"
                           "rocinante"
                           "yggdrasill"
                           "daban-urnud"))
