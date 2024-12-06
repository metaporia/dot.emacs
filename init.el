;;; Sources:
;; basics came from:
;; - https://arne.me/blog/emacs-from-scratch-part-one-foundations
;;
;; some more evil stuff from
;; - https://systemcrafters.net/emacs-from-scratch/basics-of-emacs-configuration/

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
  ;; type y|n in confirmation dialogs
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; utf8
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))

  ;; tabstop = 2
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  
  ;; Don't use X clipboard for unnamed register "
  (setq select-enable-clipboard nil)
  
  ;; Font
  (set-face-attribute 'default nil :height 140)

  ;; Save minibuffer history
  (setq history-length 25)
  (savehist-mode t)

  ;; Remember cursor position in files
  (save-place-mode t)

  ;; disable pop-up confirmation box
  (setq use-dialog-box nil)

  
  ;; Revert buffers when the underlying file has changed
  (global-auto-revert-mode 1)

  )


;;;; Evil

(use-package evil-collection
  :after evil
  :demand
  :config
  (evil-collection-init)
  )

(use-package evil
  :demand ; No lazy-loading
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-shift-width 2)
  :config
  (evil-mode 1)

  ;; map c-g to escape or keyboard-quit (default)
  ;;
  ;; https://emacs.stackexchange.com/questions/13763/how-can-i-make-c-g-run-both-evil-force-normal-state-and-keyboard-quit
  (defun evil-keyboard-quit ()
    "Keyboard quit and force normal state."
    (interactive)
    (and evil-mode (evil-force-normal-state))
    (keyboard-quit))

  (define-key evil-normal-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  (define-key evil-motion-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  (define-key evil-insert-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  (define-key evil-window-map         (kbd "C-g") #'evil-keyboard-quit) 
  (define-key evil-operator-state-map (kbd "C-g") #'evil-keyboard-quit) 

  ;; Leader maps

  ;; Global leader
  (defvar leader-map (make-sparse-keymap)
    "Keymap for <leader> binds")

  ;; free ',' for leader-map
  (define-key evil-motion-state-map (kbd "\\") 'evil-repeat-find-char-reverse)

  ;; enter 'leader-map'
  (define-key evil-normal-state-map "," leader-map)

  (evil-define-key nil leader-map
    "e" 'eval-last-sexp
    "w" 'save-buffer
    "b" 'list-buffers
    )

  ;; Local Leader
  (defvar local-leader-map (make-sparse-keymap)
    "Keymap for <local-leader> binds")

  ;; enter 'local-leader-map'
  (define-key evil-normal-state-map (kbd "SPC") local-leader-map)

  ;; TODO:
  ;; - allow 'q' to quit eg help popups without having to leave normal mode
  ;;   (macros are unnecessary outside of proper file buffers)
  ;;   - evil-collection should do the trick
  ;; - evil: swap ',' and '\' to free up ',' for leader
  )

(use-package evil-escape
  :demand
  :config
  (evil-escape-mode)
  (setq-default evil-escape-key-sequence "jk"))

;;;; Theme

(use-package doom-themes
  :demand
  :config
  (load-theme 'doom-nord)
  )

;;;; Relative Line Numbers

(use-package emacs
  :init
  (display-line-numbers-mode)
  (setq display-line-numbers 'relative)
  )


;;;; Modeline

(use-package doom-modeline
  :demand
  :init
  (doom-modeline-mode t))

;; for fresh install run M-x nerd-icons-install-fonts
(use-package nerd-icons)


;;;; Helpful (better help w/ e.g., C-h k)

(use-package helpful
  :bind (
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h f" . helpful-callable)
         )
  )
