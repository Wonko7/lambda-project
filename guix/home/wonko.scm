(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu services)
             (gnu packages admin)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (guix gexp))

;; TODO: native compilation

(home-environment
 (packages (list
            emacs
            ;; emacs-next
            ;; basic (bitches):
            emacs-general
            emacs-use-package
            emacs-emacsql-sqlite3

            ;; org
            emacs-org
            emacs-org-roam
            emacs-org-super-agenda
            ;; emacs-org-download (images)
            ;;"emacs-org-ref"
            ;;"emacs-org-static-blog"
            ;;"emacs-org2web"
            ;;"emacs-org-web-tools" (sucking stuff out of www)
            ;;"emacs-org-beautify-theme"
            ;;"org-superstar-mode"
            emacs-org-modern
            emacs-org-ql
            ;; emacs-org-auto-expand
            ;; emacs-org-appear
            ;; emacs-orgit (link to magit)

            emacs-evil
            emacs-evil-surround
            emacs-evil-org
            emacs-evil-matchit
            emacs-evil-leader
            emacs-evil-goggles
            emacs-evil-exchange
            emacs-evil-escape
            emacs-evil-collection
            emacs-evil-cleverparens
            ;; emacs-evil-args
            ;; emacs-evil-lion (align)
            ;;emacs-evil-multiedit
            ;;emacs-evil-mc
            ;; emacs-evil-visualstar
            ;; emacs-evil-textobj-syntax
            ;;emacs-evil-commentary
            ;;emacs-evil-smartparens
            ;;emacs-evil-paredit
            ;;emacs-vdiff-magit

            ;; apps
            emacs-elfeed
            emacs-elfeed-org
            emacs-circe
            emacs-pass

            ;; guile/scheme <3
            emacs-geiser
            emacs-geiser-guile

            ;; spell
            emacs-flyspell-correct
            emacs-auto-dictionary-mode

            ;; transverse:
            emacs-ibuffer-projectile
            emacs-projectile
            emacs-magit
            emacs-magit-annex
            emacs-emojify
            ;; also tramp
            ;; oh dog:
            ;; "emacs-company"
            ;; avy, ivy, embark..
            ;;
            ;; code but transverse:
            emacs-rainbow-delimiters
            emacs-rainbow-identifiers
            emacs-lsp-mode

            ;; completion framework
            emacs-orderless
            ;;"emacs-consult-org-roam"
            ;;"emacs-consult-lsp"
            ;;"emacs-consult-yasnippet"
            ;;"emacs-consult-dir" ;; meh
            emacs-consult
            emacs-embark
            emacs-vertico
            emacs-which-key

            ;; simple gui
            emacs-doom-modeline
            emacs-doom-themes
            emacs-all-the-icons
            emacs-all-the-icons-completion
            emacs-all-the-icons-dired
            emacs-exwm
            emacs-lemon

            ;; new compared to emacs.scm:
            ))

 (services
  (list
   ;; (simple-service 'config-files
   ;;                 home-files-service-type
   ;;                 `(("run" ,(local-file "run"))
   ;;                   ("README.txt" ,(local-file "README.txt"))
   ;;                                       ;; (".config/guix/channels.scm" ,(local-file "config/guix/channels.scm")
   ;;                   (".emacs.d/init.el" ,(local-file "../../emacs.d/init.el"))
   ;;                   (".emacs.d/evil.el" ,(local-file "../../emacs.d/evil.el"))
   ;;                   ;; (".gitconfig" ,(local-file "gitconfig"))
   ;;                   ))
   (simple-service 'config-files
                   home-files-service-type
                   (map (lambda (file)
                          `(,(string-append ".emacs.d/" file)
                            ,(local-file (string-append "emacs.d/" file))))
                        '("completion.el"
                          "evil.el"
                          "exwm.el"
                          "fancy.el"
                          "init.el"
                          "lisp-config.el"
                          "maps.el"
                          "org-conf.el")))
   )))
