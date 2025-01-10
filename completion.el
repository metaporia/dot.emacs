;; Completion
;; corfu & vertico for everything
;; pillaged from doomemacs vertico and corfu modules


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

