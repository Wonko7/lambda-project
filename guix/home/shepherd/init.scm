(use-modules (shepherd service)
             ((ice-9 ftw) #:select (scandir)))

;; Load all the files in the directory 'init.d' with a suffix '.scm'.
(format #t "lol: ~a\n" (string-append (getenv "HOME") "/.config/shepherd/init.d"))
(for-each
  (lambda (file)
    (load (string-append "init.d/" file)))
  (scandir (string-append (getenv "HOME") "/.config/shepherd/init.d")
           (lambda (file)
             (format #t "looking at: ~s\n\n" file)
             (string-suffix? ".scm" file))))

;; Send shepherd into the background
