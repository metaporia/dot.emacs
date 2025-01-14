;;; post-init.el --- primary user config -*- no-byte-compile: t; lexical-binding: t; -*-

(use-package compile-angel
  :config
  (compile-angel-on-load-mode)
  (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode))

;;;; General
(use-package general)

;;;; Misc Helpers

;; - https://systemcrafters.net/emacs-from-erflow.com/questions/12558019/shortcut-to-open-a-specific-file-in-emacs
(set-register ?e (cons 'file (expand-file-name "post-init.el" minimal-emacs-user-directory)))

;;; Misc helpers
(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file minimal-emacs-user-directory)))

(general-define-key "C-c r" (lambda () (interactive) (load-user-file "post-init.el")))

;; list packages registered in current emacs session
(general-define-key "C-c C-l p"
                    (lambda () (interactive)
                      (require 'subr-x)
                      (dolist (package (sort (hash-table-keys straight--recipe-cache)
                                             #'string-lessp))
                        (scratch-buffer)
                        (insert (format
                                 "%25s | %s\n"
                                 package (plist-get (gethash package straight--recipe-cache)
                                                    :local-repo))))

                                ))

;; highlight parens

(use-package smartparens
  :hook (prog-mode markdown-mode)
  :custom
  (sp-show-pair-delay 0.08)
  :config
  (require 'smartparens-config))

;; color parens
(use-package rainbow-delimiters
  :hook (prog-mode markdown-mode))

;;;; Emacs

;; Relative Line Numbers
;; TODO: disable for non-programming modes
(defun relative-linum-hook ()
  (setq-local display-line-numbers 'relative)
  (display-line-numbers-mode 1)
  )

(add-hook 'prog-mode-hook 'relative-linum-hook)

;; Hide warnings and display only errors
(setq warning-minimum-level :error)

;; type y|n in confirmation dialogs
(defalias 'yes-or-no-p 'y-or-n-p)

;; tabstop = 2
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; Font
(set-frame-font "SauceCodePro Nerd Font Medium 14" nil t)
(set-face-attribute 'default nil :height 140)


;; disable pop-up confirmation box
(setq use-dialog-box nil)


;;;; Helpful (better help w/ e.g., C-h k)

(use-package helpful
  :defer t
  :bind (
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h f" . helpful-callable)
         )
  )


;;;; Dico
(defun define-word-wrapped (word)
  "Read a word and pass it to dico(1)."
  (with-output-to-temp-buffer "*dico-define*"
    (shell-command (concat "d " word) "*dico-define*" "*Messages*")
    (pop-to-buffer "*dico-define*")))

(defun define-word ()
  (interactive)
  (define-word-wrapped (thing-at-point 'word () )))


;;;; Evil

;; must be set before evil and evil collection
(setq evil-want-keybinding nil)

(use-package evil
  :general
  (:states '(normal visual) :prefix "," :keymaps 'override
           "p"  (general-simulate-key "\"+p" :state 'normal
                  :keymap nil :lookup nil :name me:paste-clipboard-reg )
           ;; FIXME
           ;; we may need to define evil-operator to enable select-enable-clipboard,
           ;; copy, and then disable it so it doesn't get clobbered
           ;;"c"  (general-simulate-key "\"+y" :state 'normal
           ;;       :keymap nil :lookup nil :name me:copy-to-clipboard-reg )
           )
  :custom
  (evil-visual-update-x-selection-p nil)
  (evil-kill-on-visual-paste nil)
  :init
  ;;(fset 'evil-visual-update-x-selection 'ignore)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-u-delete t)
  (setq evil-respect-visual-line-mode t) ; j/k -> gj/gk

  (setq evil-shift-width 2)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; some QOL nvim maps

  ;; buffer nav
  (evil-define-key 'normal 'global
    (kbd "C-n") 'evil-next-buffer
    (kbd "C-p") 'evil-prev-buffer
    (kbd "C-k") 'evil-delete-buffer)

  ;; map c-g to escape or keyboard-quit (default)
  ;;
  ;; https://emacs.stackexchange.com/questions/13763/how-can-i-make-c-g-run-both-evil-force-normal-state-and-keyboard-quit
  (defun evil-keyboard-quit ()
    "Keyboard quit and force normal state."
    (interactive)
    (and evil-mode (evil-force-normal-state))
    (keyboard-quit))

  ;; (define-key evil-normal-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  ;; (define-key evil-motion-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  ;; (define-key evil-insert-state-map   (kbd "C-g") #'evil-keyboard-quit) 
  ;; (define-key evil-window-map         (kbd "C-g") #'evil-keyboard-quit) 
  ;; (define-key evil-operator-state-map (kbd "C-g") #'evil-keyboard-quit) 
  ;(define-key minibuffer-local-map (kbd "c-g") 'abort-recursive-edit)

  ;; Leader maps
  ;; migrating to general

  ;; Global leader
  (general-create-definer leader :prefix ",")
  (general-create-definer local-leader :prefix "SPC")

  ;(defvar leader-map (make-sparse-keymap) "Keymap for <leader> binds")

  ;; free ',' for leader-map
  (define-key evil-motion-state-map (kbd "\\") 'evil-repeat-find-char-reverse)

  ;; enter 'leader-map'
  ;(define-key evil-normal-state-map "," leader-map)

  ;; (defun evil-paste-from-clip-reg ()
  ;;   (interactive)
  ;;   (evil-paste-from-register ?+)
  ;;   )


  (leader :states 'normal ;:keymaps 'override
    "e" 'eval-last-sexp
    "w" 'save-buffer
    "b" 'switch-to-buffer
    "d" 'define-word
    "," 'other-window
    )

  ;; Local Leader
  ;(defvar local-leader-map (make-sparse-keymap) "Keymap for <local-leader> binds")

  ;; enter 'local-leader-map'
  ;(define-key evil-normal-state-map (kbd "SPC") local-leader-map)

  ;; this works at least. doesn't work with visual selection or motions
  ;; probably have to make evil-operator for this
  ;; paste is easy (and already works)
  ;; TLDR; ensure emacs can't clobber global clipboard, except through wl-copy
  (defun wl-copy ()
    (interactive)
    (shell-command (concat "wl-copy " (thing-at-point 'word ()))))


  (evil-define-operator evil-wl-copy (beg end)
    "Evil operator for to copy directly to system clipboard
    (by-passing \"+ since it seems broken in this config"
    :move-point nil
    :repeat nil
    (interactive "<r>")
    (call-process "wl-copy"
                  nil ; infile
                  0 ; dest=0 -> don't wait, discard output
                  nil ; display: if non-nil redisplay buffer after insertion
                  (format "%s" (buffer-substring beg end)))
    )

  (evil-define-operator evil-wl-paste (beg end)
    "Evil operator for to copy directly to system clipboard
    (by-passing \"+ since it seems broken in this config"
    :move-point nil
    :repeat nil
    (interactive "<r>")
    (call-process "wl-paste"
                  nil ; infile
                  t ; insert in current buffer at point
                  nil ; display: if non-nil redisplay buffer after insertion
                  (format "%s" (buffer-substring beg end)))
    )



  ;;(evil-define-key '(normal visual) 'global (kbd ", y") 'evil-wl-copy)
  (evil-define-key '(normal visual) 'global (kbd ", c") 'evil-wl-copy)
  ;;(evil-define-key 'insert 'global (kbd "C-S-V") 'evil-


  ;;(evil-define-key nil evil-normal-state-map (kbd "C-y") "\"ap" )

  ;; copy to clip reg needs a macro or custom operator

  ;; (evil-define-operator evil-yank-to-clip-reg (beg end type yank-handler)
  ;;   :move-point nil
  ;;   :repeat nil
  ;;   (interactive "<R><x><y>")
  ;;   (evil-yan beg end type ?+ yank-handler)
  ;;   )
  ;;(evil-define-key nil leader-map "c" 'evil-yank-to-clip-reg)


  )


(use-package evil-collection
  :after evil
  :ensure t
  :custom
  (evil-collection-calendar-want-org-bindings t)
  (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init)
  )


(use-package evil-escape
  :config
  (evil-escape-mode)
  (setq-default evil-escape-key-sequence "jk"))

(use-package evil-surround
  :config
  (global-evil-surround-mode))

(use-package evil-commentary
  :bind (:map evil-normal-state-map ("g c" . evil-commentary)))

;; search with '*' and '#' from visual selection
(use-package evil-visualstar
  :after evil
  :ensure t
  :defer t
  :commands global-evil-visualstar-mode
  :hook (after-init . global-evil-visualstar-mode))

(use-package evil-org
  :defer t
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  ;; (add-hook 'evil-org-mode-hook
  ;;           (lambda ()
  ;;             (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;;; Themes

(use-package color-theme-sanityinc-tomorrow
  :defer t
  :config
  (load-theme 'sanityinc-tomorrow-night t))


(use-package doom-themes
  :config
  (load-theme 'doom-nord t)
  )

;; treat all themes as safe (we have no custom.el this time 'round)
(setq custom-safe-themes t)


(use-package doom-modeline
 :init
 (doom-modeline-mode t))

;; for fresh install run M-x nerd-icons-install-fonts
(use-package nerd-icons
  :custom
  (nerd-icons-font-family "Sauce Code Pro Nerd Font")
  )

;;;; activate recentf, savehist, saveplace, and auto-revert


;; Save minibuffer history
(setq history-length 25)
;;(savehist-mode t)

;; Remember cursor position in files
(save-place-mode t)

;; Revert buffers when the underlying file has changed
;;
;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(add-hook 'after-init-hook #'global-auto-revert-mode)

;; recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(add-hook 'after-init-hook #'recentf-mode)

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(add-hook 'after-init-hook #'savehist-mode)

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(add-hook 'after-init-hook #'save-place-mode)


;;;; Magit

(use-package magit
  :defer t
  :commands magit-status
  :general
  (leader :states 'normal ;:keymaps 'override
    "g g" 'magit-status)
  )

;;;; Which-key

(use-package which-key
  :config
  (which-key-mode))

;;;; Org
(minimal-emacs-load-user-init "org.el")

;;;; Completion (corfu & vertico)

(minimal-emacs-load-user-init "completion.el")



