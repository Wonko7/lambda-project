;;; early-init.el  -*- lexical-binding: t; -*-

(require 'conf/generated-values "~/.emacs.d/generated-values.el")

(setq default-frame-alist `((background-color . ,my/background-colour)
                            (ns-appearance . dark)
                            (fullscreen . maximized)
                            (alpha . (100 . 70))
                            (alpha-background . 0.9)))

(setq initial-frame-alist (quote ((fullscreen . maximized))))

(menu-bar-mode -1)
