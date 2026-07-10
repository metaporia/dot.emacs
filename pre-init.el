;;; pre-init.el --- bootstrap straight.el -*- no-byte-compile: t; lexical-binding: t; -*-

(setq use-package-always-ensure nil)

;; Store lockfile in repo root rather than var/ (which is gitignored)
(setq straight-profiles '((nil . "~/emacs/straight-versions.el")))

;; Straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
