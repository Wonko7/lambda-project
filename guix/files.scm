(define-module (files)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)

  ;; system
  #:use-module (guix build utils)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-26)
  #:use-module (srfi srfi-34)
  #:use-module (srfi srfi-35)
  #:use-module (srfi srfi-60)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 format)
  #:use-module (ice-9 threads)
  #:use-module (rnrs bytevectors)
  #:use-module (rnrs io ports))

(define-public (invoke/loud program . args)
  "Invoke PROGRAM with ARGS and capture PROGRAM's standard output and standard
error.  If PROGRAM succeeds, print nothing and return the unspecified value;
otherwise, raise a '&message' error condition that includes the status code
and the output of PROGRAM."
  (let-values (((pipe pid) (apply (@@ (guix build utils) open-pipe-with-stderr) program args)))
    (let loop ((lines '()))
      (match (read-line pipe)
        ((? eof-object?)
         (close-port pipe)
         (match (waitpid pid)
           ((_ . status)
            (if (zero? status)
                (apply string-append (reverse lines))
                (begin
                  (display "warning: faking secret data"
                           (current-error-port))
                  "lolfake")
                ))))
        (line
         (loop (cons line lines)))))))

(define-public (write-string-to-file f s)
  (let ((output-port (open-file f "a")))
    (display s output-port)
    (close output-port)))
