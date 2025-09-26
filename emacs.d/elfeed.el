;;; elfeed.el  -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elfeed

(require 'elfeed)
(setq elfeed-search-filter "+unread +tf")

(require 'elfeed-org)
(setq rmh-elfeed-org-files (list (concat org-directory "notes/rss/root.org")))
(elfeed-org)

(require 'elfeed-goodies)
(setq powerline-height 25)
(setq elfeed-goodies/entry-pane-position 'bottom)
(elfeed-goodies/setup)

(provide 'conf/elfeed)
