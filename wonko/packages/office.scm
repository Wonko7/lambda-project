(define-module (wonko packages office)
  #:use-module (guix packages)
  #:use-module (guix cvs-download)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix i18n)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages perl)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))


(define-public verbiste
  (package
    (name "verbiste")
    (version "0.1.48")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://perso.b2b2c.ca/~sarrazip/dev/verbiste-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "04wwqs5bhssj3rc0avv4jbrs3qh9ps70rnisizb8j37qj4b0x7da"))))
    (native-inputs (list pkg-config))
    (inputs (list libxml2 perl perl-xml-parser))
    (build-system gnu-build-system)
    (arguments
     (list
      #:configure-flags #~(list "--without-gnome-app"
                                "--without-mate-applet"
                                "--without-gtk-app")))
    (synopsis "Verbiste est un système de conjugaison française")
    (description "Verbiste est un système de conjugaison française")
    (home-page "http://sarrazip.com/dev/verbiste.html")
    (license (@ (guix licenses) gpl3+))))
