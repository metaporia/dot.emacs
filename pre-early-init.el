;;; pre-early-init.el --- desc -*- no-byte-compile: t; lexical-binding: t; -*-

;; Reducing clutter in ~/.emacs.d by redirecting files to ~/emacs.d/var/
(setq minimal-emacs-var-dir (expand-file-name "var/" minimal-emacs-user-directory))
(setq package-user-dir (expand-file-name "elpa" minimal-emacs-var-dir))
(setq user-emacs-directory minimal-emacs-var-dir)

;; disable built-in package manager, package.el
(setq minimal-emacs-package-initialize-and-refresh nil)
