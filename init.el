
;;; Desiderata:
;; - org
;; - evil
;; - completion (corfu)
;; - telescope replacement (helm looks good)

;; Packages to consider
;; - desktop (sessions, I think)

;;;; TODO
;; - outline mode (for elisp)
;; - bookmarks/session/common files in registers
;; - evil-escape
;; - evil: leader keys (,w ,b &c)

;;;; Load =.custom.el=

;; So injected settings don't muck up our manually managed settings we
;; store them elsewhere

(setq-default custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;;; Meta: reload config
(defun reload-emacs-config ()
  "
  Reloads ~/.config/emacs/init.el

  NB: 
  - not idempotent
  - skips early-init.el
  "
  (interactive)
  (load-file user-init-file))
(global-set-key (kbd "C-c r") 'reload-emacs-config)



;; Add user-init-file to "e register
;; https://stackoverflow.com/questions/12558019/shortcut-to-open-a-specific-file-in-emacs
(set-register ?e (cons 'file "~/emacs/init.el"))
;; from https://arne.me/blog/emacs-from-scratch-part-one-foundations


;;; Remove UI elements

(tool-bar-mode -1)             ; Hide the outdated icons
(scroll-bar-mode -1)           ; Hide the always-visible scrollbar
(setq use-file-dialog nil)      ; Ask for textual confirmation instead of GUI
(setq ring-bell-function 'ignore) ; disable bell

(setq     inhibit-startup-screen t
          inhibit-startup-message t
          inhibit-startup-echo-area-message t
          inhibit-splash-screen t) ; Remove the "Welcome to GNU Emacs" splash screen

;;; Package Management

;; straight.el and built-in use-package
;; - straight.el: https://github.com/radian-software/straight.el

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

;; use use-package (lazy loading & tidy specs)
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; enable lazy loading
;; FIXME: verify that we want this
(setq use-package-always-defer t)


;;; Package Specs

;;;; Emacs
(use-package emacs
             :init
             ; type y|n in confirmation dialogs
             (defalias 'yes-or-no-p 'y-or-n-p)
             ; utf8
             (set-charset-priority 'unicode)
             (setq locale-coding-system 'utf-8
                   coding-system-for-read 'utf-8
                   coding-system-for-write 'utf-8)
             (set-terminal-coding-system 'utf-8)
             (set-keyboard-coding-system 'utf-8)
             (set-selection-coding-system 'utf-8)
             (prefer-coding-system 'utf-8)
             (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
             ; tabstop = 2
             (setq-default indent-tabs-mode nil)
             (setq-default tab-width 2)
             ; Don't use X clipboard for unnamed register "
             (setq select-enable-clipboard nil)

             ; Font
             (set-face-attribute 'default nil :height 140)

             ;;

             )


;;;; Evil

(use-package evil
             :demand ; No lazy-loading
             :config
             (evil-mode 1)

             )

(use-package evil-escape
  ; :after evil
  ; :ensure t
  :config
  (evil-escape-mode)
  (setq-default evil-escape-key-sequence "jk"))




;;; Themes

(use-package doom-themes
  :demand
  :config
  (load-theme 'doom-nord)
  )

;;; Relative Line Numbers

(use-package emacs
  :init
  (display-line-numbers-mode)
  (setq display-line-numbers 'relative)
  )


;;; Modeline

(use-package doom-modeline
  :demand
  :init
  (doom-modeline-mode t))

;; for fresh install run M-x nerd-icons-install-fonts
(use-package nerd-icons)


;;; Helpful (better help w/ e.g., C-h k)

(use-package helpful
  :bind (
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h f" . helpful-callable)
         )
  )
