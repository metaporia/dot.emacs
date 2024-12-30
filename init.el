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

(setq straight-use-package-by-default t)

;; enable lazy loading
;; FIXME: verify that we want this
(setq use-package-always-defer t)


;;; Package Specs

;;;; General.el
(use-package general :demand)


;;;; Emacs

;; Relative Line Numbers
;; TODO: disable for non-programming modes
(defun relative-linum-hook ()
  (setq-local display-line-numbers 'relative)
  (display-line-numbers-mode 1)
  )


(use-package emacs
  ;;:custom
  ;;(display-line-numbers 'relative)
  :init
  (add-hook 'prog-mode-hook 'relative-linum-hook)

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
  
  
  ;; Font
  (set-frame-font "SauceCodePro Nerd Font Medium 14" nil t)
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

;;;; Xclip mode, necessary for wl-copy since hyprland is dumb
(use-package xclip
  :demand
  :init
  ;;(setq save-interprogram-paste-before-kill nil) 
  (setq select-enable-clipboard nil)
  ;;:custom
  ;;(xclip-method "wl-copy")
  :config 
  (xclip-mode 1)
  )

;; ;;; FUUUCK this doesn't work either
;; (use-package simpleclip
;;   :demand
;;   :bind ( :map evil-insert-state-map
;;          ("C-<S-C>" . simpleclip-copy)
;;          ("C-<S-V>" . simpleclip-paste))
;;   :config
;;   (simpleclip-mode))


;;

(use-package evil-collection
  :after evil
  :demand
  :custom
  (evil-collection-calendar-want-org-bindings t)
  (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init)
  )

; (evil-set-register ?+ "gg")

(use-package evil
  :demand ; No lazy-loading
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

  ;; Global leader
  (defvar leader-map (make-sparse-keymap)
    "Keymap for <leader> binds")

  ;; free ',' for leader-map
  (define-key evil-motion-state-map (kbd "\\") 'evil-repeat-find-char-reverse)

  ;; enter 'leader-map'
  (define-key evil-normal-state-map "," leader-map)

  ;; (defun evil-paste-from-clip-reg ()
  ;;   (interactive)
  ;;   (evil-paste-from-register ?+)
  ;;   )

  (evil-define-key nil leader-map
    "e" 'eval-last-sexp
    "w" 'save-buffer
    "b" 'list-buffers
    "d" 'define-word
    "," 'other-window
    )


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
  (evil-define-key '(normal visual) 'global (kbd ", y") 'evil-wl-copy)
  ;;(evil-define-key 'insert 'global (kbd "C-S-V") 'evil-


  ;;(evil-define-key nil evil-normal-state-map (kbd "C-y") "\"ap" )

  ;; copy to clip reg needs a macro or custom operator

  ;; (evil-define-operator evil-yank-to-clip-reg (beg end type yank-handler)
  ;;   :move-point nil
  ;;   :repeat nil
  ;;   (interactive "<R><x><y>")
  ;;   (evil-yan beg end type ?+ yank-handler)
  ;;   )
  (evil-define-key nil leader-map "c" 'evil-yank-to-clip-reg)


  ;; Local Leader
  (defvar local-leader-map (make-sparse-keymap)
    "Keymap for <local-leader> binds")

  ;; enter 'local-leader-map'
  (define-key evil-normal-state-map (kbd "SPC") local-leader-map)
  )

(use-package evil-escape
  :demand
  :config
  (evil-escape-mode)
  (setq-default evil-escape-key-sequence "jk"))

(use-package evil-surround
  :demand
  :config
  (global-evil-surround-mode))

(use-package evil-commentary
  :bind (:map evil-normal-state-map ("g c" . evil-commentary)))

;;;; Theme

(use-package color-theme-sanityinc-tomorrow
  ;:demand
  :config
  (load-theme 'sanityinc-tomorrow-night t))


(use-package doom-themes
  :demand
  :config
  (load-theme 'doom-nord)
  )

;;;; Modeline

(use-package doom-modeline
  :demand
  :init
  (doom-modeline-mode t))

;; for fresh install run M-x nerd-icons-install-fonts
(use-package nerd-icons
  :demand
  :custom
  (nerd-icons-font-family "Sauce Code Pro Nerd Font")
  )


;;;; Helpful (better help w/ e.g., C-h k)

(use-package helpful
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

;;;; Completion

(use-package emacs
  :custom
  (tab-always-indent 'complete)
  (read-extended-command-predicate #'command-completion-default-include-p)
  )


(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles basic partial-completion))))
  )

;; TODO: bind to transfer completion to minibuffer
(use-package corfu
  :after evil evil-collection
  :demand
  :custom
  ;; Enable cycling for `corfu-next/previous'
  (corfu-cycle t)
  (corfu-count 14)
  (corfu-scroll-margin 6)
  (corfu-preselect-first t)
  (global-corfu-minibuffer nil)
  
                                        ; (corfu-preview-current t)
  :init
  (corfu-popupinfo-mode) ;; show doc previews
  (global-corfu-mode)

  ;; unbind org tab
  :config
  (evil-define-key 'insert 'global 
    (kbd "C-n")  'completion-at-point)
  (evil-define-key 'insert 'corfu-map
    (kbd "C-e")  'corfu-complete
                                        ;(kbd "TAB") 'corfu-next
    (kbd "C-y")  'corfu-quit)


  ;; TODO: map tab to corfu-next in commandline

  ;; FIXME
  ;; (evil-define-key 'insert 'evil-ex-completion-map (kbd "TAB")
  ;;             (lambda (&optional _)
  ;;                (interactive) (message "hello")))
  ;; `(menu-item "" nil :filter
  ;;             ,(lambda (&optional _)
  ;;               (interactive) (message "hello") )))
                                        ; #'corfu-next)))

  ;;(define-key evil-command-line-map (kbd "C-n")  'corfu-next)
  ;;(define-key evil-command-line-map (kbd "C-p")  'corfu-previous)
  ;;(define-key evil-command-line-map (kbd "C-y")  'corfu-quit)

  ;; these may be necessary for org-mode
  ;;(evil-define-key 'insert 'org-mode-map (kbd "TAB") nil)
  ;;(evil-define-key nil 'evil-insert-state-map (kbd "TAB") nil)
  ;;(evil-define-key 'insert 'evil-org-mode (kbd "TAB") #'completion-at-point)
  ;;(define-key evil-insert-state-map (kbd "C-n")  #'completion-at-point)
  ;;(define-key evil-insert-state-map (kbd "C-e")  #'corfu-complete)


  )

;; Add extensions
(use-package cape
  :demand
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative keys: M-p, M-+, ...
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  ;; ...
  )

;; TODO: set completion-styles-alist (try 'flex')
(use-package kind-icon
  :demand
  :after corfu
  :custom
  (kind-icon-blend-background t)
  (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))


;;;; Which-key

(use-package which-key
  :demand
  :config
  (which-key-mode))



;;;; Org
(defun my/prettify-symbols-setup ()
  ;; Checkboxes
  (push '("[ ]" . "") prettify-symbols-alist)
  (push '("[X]" . "") prettify-symbols-alist)
  (push '("[-]" . "" ) prettify-symbols-alist)

  ;; org-abel
  (push '("#+BEGIN_SRC" . ?≫) prettify-symbols-alist)
  (push '("#+END_SRC" . ?≫) prettify-symbols-alist)
  (push '("#+begin_src" . ?≫) prettify-symbols-alist)
  (push '("#+end_src" . ?≫) prettify-symbols-alist)

  (push '("#+BEGIN_QUOTE" . ?❝) prettify-symbols-alist)
  (push '("#+END_QUOTE" . ?❞) prettify-symbols-alist)

  ;; Drawers
  (push '(":PROPERTIES:" . "") prettify-symbols-alist)
  (push '(":LOGBOOK:"."󱚉")prettify-symbols-alist)

  ;; Tags
  ;; TODO add symbols for missing tags
  (push '(":projects:" . "") prettify-symbols-alist)
  (push '(":work:"     . "") prettify-symbols-alist)
  (push '(":inbox:"    . "") prettify-symbols-alist)
  (push '(":task:"     . "") prettify-symbols-alist)
  (push '(":thesis:"   . "") prettify-symbols-alist)
  (push '(":uio:"      . "") prettify-symbols-alist)
  (push '(":emacs:"    . "") prettify-symbols-alist)
  (push '(":learn:"    . "") prettify-symbols-alist)
  (push '(":code:"     . "") prettify-symbols-alist)

  (prettify-symbols-mode))

(add-hook 'org-mode-hook        #'my/prettify-symbols-setup)
(add-hook 'org-agenda-mode-hook #'my/prettify-symbols-setup)


(use-package org
  :straight (:type built-in)
  :custom
  (org-startup-folded t)
  (org-hide-emphasis-markers t)
  :init
  (setq org-agenda-files "~/org/agenda")
  (setq org-directory "~/org")
  (setq org-agenda-dim-blocked-tasks nil)
                                        ; enable org-indent-mode by default
  (setq org-startup-indented t)
  ;;(setq org-startup-folded 'fold)
  (setq org-cycle-separator-lines 0)
  (setq org-deadline-warning-days 20)
  (setq org-alphabetical-lists t)

  (setq org-list-allow-alphabetical t)
  (setq org-fast-tag-selection-single-key t)

  ;; display remote inline images
  (setq org-display-remote-inline-images 'download)

  (setq org-tag-alist '(("code" . ?c)
                        ("meta" . ?m)
                        ("note" . ?n)
                        ("personal" . ?p)
                        ("school" . ?s)
                        ("music" . ?u)
                        ("projects" . ?j)
                        ("work" . ?w)
                        ("emacs" . ?e)
                        ("task" . ?t)
                        ("mental" . ?t)
                        ))

  ;; MISC PRETTIFICATION

  ;; hide shit, enable pretty-entities
  (setq org-adapt-indentation t
        org-hide-leading-stars t
        org-pretty-entities t
        org-ellipsis "  .")

  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0) ; don't indent code blocks (finally!)

  ;;

  ;; TODOs


  ;; pretttify todos
  (setq org-log-done t
        org-auto-align-tags t
        org-tags-column -80
        org-fold-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        )

  ;; todo priority
  (setq org-lowest-priority ?F)  ;; Gives us priorities A through F
  (setq org-default-priority ?E) ;; If an item has no priority, it is considered [#E].

  ;; TODO figure out how to inherit colors from active theme
  (setq org-priority-faces
        '((65 . "#BF616A")
          (66 . "#EBCB8B")
          (67 . "#B48EAD")
          (68 . "#81A1C1")
          (69 . "#5E81AC")
          (70 . "#4C566A")))


  ;; todo keywords
  (setq org-todo-keywords
        ;; The "|" classifies workflow states. To its left lie unfinished states, and to
        ;; its right, finished states.
        ;;
        ;; "/" enables dependency enforcement.
        ;;
        (quote ((sequence "TODO(t!)" "NEXT(n!)" "|" "DONE(d!)")
                (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@!)"))))

  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t))
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  ;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
  (setq org-capture-templates
        (quote (("t" "todo" entry (file "~/org/refile.org")
                 "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
                ("r" "respond" entry (file "~/org/refile.org")
                 "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
                ("n" "note" entry (file "~/org/refile.org")
                 "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
                ("b" "bruce" entry (file+olp+datetree "~/org/mental.org" "Mental Health" "Bruce")
                 "* Session Notes" :jump-to-captured 1)
                ("j" "journal" entry (file+datetree "~/org/diary.org")
                 "* %?\n%U\n" :clock-in t :clock-resume t)
                ("w" "org-protocol" entry (file "~/org/refile.org")
                 "* TODO Review %c\n%U\n" :immediate-finish t)
                ;;("m" "Meeting" entry (file "~/org/refile.org")
                ;; "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
                ("h" "habit" entry (file "~/org/refile.org")
                 "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

  ;; refile setup



  ;; targets include agenda files up to depth=9
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))

  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)

  ;; allow parent creation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

  ;; ido
  ;;(setq org-completion-use-ido t)

                                        ; Exclude DONE state tasks from refile targets
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  (setq org-refile-target-verify-function 'bh/verify-refile-target)


  (setq doc-view-resolution 300)

  :config
  ;; agenda bindings
  (global-set-key "\C-cl" 'org-store-link)
  (global-set-key "\C-ca" 'org-agenda)
  (global-set-key "\C-cc" 'org-capture)
  (global-set-key "\C-cb" 'org-switchb)
  (global-set-key (kbd "C-'") 'org-cycle-agenda-files)

  ;; latex image stuff
  (setq org-format-options (plist-put org-format-latex-options :scale 2.0))
  (setq org-latex-create-formula-image-program 'dvisvgm)

  ;; babel languages
  (org-babel-do-load-languages 'org-babel-load-languages '( (shell . t)))

  (defun my/org-hide-done-entries-in-region (start end)
    (interactive "r")
    (org-map-entries #'org-fold-hide-subtree
                     "/+DONE" 'region 'archive 'comment))

  (defun my/org-hide-done-entries-in-buffer ()
    (interactive)
    (org-map-entries #'org-fold-hide-subtree
                     "/+DONE" 'file 'archive 'comment))
(defun my/org-toggle-archive-done-entries-in-buffer ()
    (interactive)
    (org-map-entries '(org-toggle-tag "ARCHIVE" 'on)
                     "/+DONE" 'file 'archive 'comment))

  )

(use-package evil-org
  :demand
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  ;; (add-hook 'evil-org-mode-hook
  ;;           (lambda ()
  ;;             (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))



(use-package org-download
  :demand
  :after evil
  :init
  (evil-define-key nil leader-map "ld" 'org-download-yank)
  )

;; (use-package org-bullets
;;   :hook
;;   (('org-mode . org-bullets-mode)))

;; ;; change org bullets from '-' to '•'
;; (font-lock-add-keywords
;;  'org-mode
;;  '(("^ *\\([-]\\) "
;;     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

;; ;; set different font sizes for org headings
;; ;; FIXME fonts are too big (we just want headings to be a hair larger
;; (let* ((variable-tuple
;;         (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
;;               ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
;;               ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
;;               ((x-list-fonts "Verdana")         '(:font "Verdana"))
;;               ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
;;               (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
;;        (base-font-color     (face-foreground 'default nil 'default))
;;        (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

;;    (custom-theme-set-faces
;;     'user
;;     `(org-level-8 ((t (,@headline ,@variable-tuple))))
;;     `(org-level-7 ((t (,@headline ,@variable-tuple))))
;;     `(org-level-6 ((t (,@headline ,@variable-tuple))))
;;     `(org-level-5 ((t (,@headline ,@variable-tuple))))
;;     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
;;     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.2))))
;;     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.3))))
;;     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.4))))
;;     `(org-document-title ((t (,@headline ,@variable-tuple :height 1.7 :underline nil))))))

;; TODO make this work with evil
;; https://github.com/awth13/org-appear
(use-package org-appear
  :custom
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-auto-submarkers t)
  (org-appear-autoentities t)
  (org-appear-autokeywords t)
  :init
  ;; enable
  (add-hook 'org-mode-hook 'org-appear-mode)
  ;; evil
  (setq org-appear-trigger 'manual)
  (add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'evil-insert-state-entry-hook
                        #'org-appear-manual-start
                        nil
                        t)
              (add-hook 'evil-insert-state-exit-hook
                        #'org-appear-manual-stop
                        nil
                        t)))
  )

(use-package org-superstar
  :config
  ;;(setq org-superstar-leading-bullet " ")
  (setq org-superstar-headline-bullets-list '("◉" "○" "⚬" "◈" "◇"))
  (setq org-superstar-special-todo-items t) ;; Makes TODO header bullets into boxes
  (setq org-superstar-todo-bullet-alist '(("TODO"  . 9744)
                                          ("WAIT"  . 9744)
                                          ("READ"  . 9744)
                                          ("NEXT"  . 9744)
                                          ("PROG"  . 9744)
                                          ("DONE"  . 9745)))
  :hook (org-mode . org-superstar-mode))

;; org prettification
(use-package olivetti
  :custom
  (olivetti-body-width 85)
  :hook (org-mode . olivetti-mode))


(use-package svg-tag-mode
  :hook (org-mode . svg-tag-mode)
  :config
  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
  (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
  (defconst day-re "[A-Za-z]\\{3\\}")
  (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

  (defun svg-progress-percent (value)
	(svg-image (svg-lib-concat
				(svg-lib-progress-bar (/ (string-to-number value) 100.0)
			      nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
				(svg-lib-tag (concat value "%")
				  nil :stroke 0 :margin 0)) :ascent 'center))

  (defun svg-progress-count (value)
	(let* ((seq (mapcar #'string-to-number (split-string value "/")))
           (count (float (car seq)))
           (total (float (cadr seq))))
	  (svg-image (svg-lib-concat
				  (svg-lib-progress-bar (/ count total) nil
					:margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
				  (svg-lib-tag value nil
					:stroke 0 :margin 0)) :ascent 'center)))
  (setq svg-tag-tags
      `(
        ;; Task priority
        ("\\[#[A-Z]\\]" . ( (lambda (tag)
                              (svg-tag-make tag :face 'org-priority
                                            :beg 2 :end -1 :margin 0))))

        ;; Progress
        ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
          (svg-progress-percent (substring tag 1 -2)))))
        ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
          (svg-progress-count (substring tag 1 -1)))))

        ;; Citation of the form [cite:@Knuth:1984]
        ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                          (svg-tag-make tag
                                                        :inverse t
                                                        :beg 7 :end -1
                                                        :crop-right t))))
        ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                (svg-tag-make tag
                                                              :end -1
                                                              :crop-left t))))


        ;; Active date (with or without day name, with or without time)
        (,(format "\\(<%s>\\)" date-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :end -1 :margin 0))))
        (,(format "\\(<%s \\)%s>" date-re day-time-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
        (,(format "<%s \\(%s>\\)" date-re day-time-re) .
         ((lambda (tag)
            (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

        ;; Inactive date  (with or without day name, with or without time)
         (,(format "\\(\\[%s\\]\\)" date-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
         (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :inverse nil
						       :crop-right t :margin 0 :face 'org-date))))
         (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
          ((lambda (tag)
             (svg-tag-make tag :end -1 :inverse t
						       :crop-left t :margin 0 :face 'org-date)))))))


;;;; Xenops (latex mode)
(use-package xenops
  :demand
  :init 
  (setq xenops-math-image-scale-factor 1.8)
  :hook
  ((latex-mode . xenops-mode)
   (LaTeX-mode . xenops-mode))
  )


;;;; Snippets
(use-package yasnippet
  :demand
  ;; :hook (
  ;;        ( text-mode
  ;;          progmode
  ;;          conf-mode
  ;;          snippet-mode) . yas-minor-mode-on
  ;;        )
  :init 
  (setq yas-snippet-dir (expand-file-name "snippets" user-emacs-directory))
  (setq yas-prompt-functions '(yas-ido-prompt))
  :config
  (yas-reload-all)
  (yas-global-mode 1))

;; (yas-reload-all)
;; (add-hook 'after-init-hook #'yas-minor-mode)
(use-package  yasnippet-snippets :demand)

;;;; Telescope and minibuffer replacement 
;; can't seem to get corfu working in minibuffer (idk)
(use-package ivy
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d)")
  (ivy-re-builders-alist '((t . ivy--regex-fuzzy)))
  :config
  (ivy-mode 0)
  )

;; (use-package helm
;;   :after evil
;;   ;:demand
;;   :bind (
;;          :map evil-normal-state-map
;;          ("M-x" . helm-M-x)
;;          )
;;   :config
;;   (evil-define-key nil leader-map "lf"  'helm-find-files)
;;   )

;; Enable vertico

(use-package vertico
  ;; ::general
  ;; (general-define-key
  ;;  :states '(insert normal)
  ;;  :keymaps '(vertico-map)
  ;;  "C-g" 'vertico-exit
  ;;  )

  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  ;; :bind (:map vertico-map
  ;;             ("c-g" . vertico-exit))
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; completion style
  ;(setq completion-styles '(flex basic))
  ;;(setq completion-category-defaults
  ;;(setq completion-category-overrides '(buffer . '(
  )

