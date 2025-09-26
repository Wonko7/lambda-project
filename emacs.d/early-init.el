;;; early-init.el  -*- lexical-binding: t; -*-

(setq default-frame-alist '((background-color . "#27212E")
                            (ns-appearance . dark)
                            (fullscreen . maximized)
                            (alpha . (100 . 70))
                            (alpha-background . 0.9)))

(setq initial-frame-alist (quote ((fullscreen . maximized))))

(menu-bar-mode -1)
