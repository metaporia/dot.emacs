;;; org.el --- org stuff, duh! -*- no-byte-compile: t; lexical-binding: t; -*-

;;;; Org

;; NB: evil-org enabled along with evil 

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
  (add-hook 'org-capture-mode-hook #'org-align-all-tags)
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
                        ("bruce" . ?b)
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
  (setq ;org-log-done t
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

  ;; todo keyword colors
  (setq org-todo-keyword-faces
        '(("TODO(t!)"      :inherit (org-todo region) :foreground  "#4C566A" :weight bold)
          ))


  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)

  ; don't log time stamps when cycling org todo state
  ;; (setq org-log-done 'time)
  ;; (setq org-log-into-drawer t)

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t))
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  ;; enter insert mode in org-captures
  (add-hook 'org-capture-mode-hook 'evil-insert-state)
  ;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
  (setq org-capture-templates
        (quote (("t" "todo" entry (file "~/org/refile.org")
                 "* TODO %?\n%U\n%a\n" )
                ("r" "respond" entry (file "~/org/refile.org")
                 "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :immediate-finish t)
                ("n" "note" entry (file "~/org/refile.org")
                 "* %? :NOTE:\n%U\n%a\n" )
                ;;("b" "bruce" entry (file+olp+datetree "~/org/mental.org" "Appointment Logs" "Bruce") "* Session Notes" :jump-to-captured 1)
                ;;("p" "athey" entry (file+olp+datetree "~/org/mental.org" "Appointment Logs" "Athey") "* Session Notes" :jump-to-captured 1)
                ;; FIXME
                ("b" "bruce" entry (file+datetree "~/org/log.org")
                 "* Bruce Therapy :bruce:\n** Talking Points\n%?\n** Session Notes"
                 :jump-to-captured 1
                 :empty-lines 1
                 )
                ("m" "medication" entry (file+olp "~/org/mental.org" "Medication Logs" "Lamictal")
                 "* %t\n %?"
                 :jump-to-captured 1
                 :empty-lines 1
                 )
                ("w" "weight" entry (file+olp "~/org/physical.org" "Weight")
                 "* Measurement
  :PROPERTIES:
  :DATE: %U
  :END:
  weight: %?
                  "
                 :jump-to-captured 1
                 :empty-lines 1
                 )
                ("a" "athey" entry (file+datetree "~/org/log.org")
                 "* Athey :athey:\n** Talking Points\n %?\n** Session Notes\n"
                 ;;"* Athey :athey:\n ** Session Notes\n%?"
                 :jump-to-captured 1
                 :empty-lines 1
                 )
                ("l" "log" entry (file+datetree "~/org/log.org")
                 "* %? %^g "
                 :jump-to-captured 1
                 :empty-lines 1
                 )
                ;; ("j" "journal" entry (file+datetree "~/org/diary.org")
                ;;  "* %?\n%U\n" )
                ("j" "journal" entry (file+headline "~/org/diary.org" "Journal")
                 "* %U %?\n"
                 :jump-to-captured 1
                 :empty-lines 1
                 )

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

  ;; custom agenda views (for monthly todos, &c.)
  ;; nice to have an example to build off of as we refine our agenda workflow
  (setq org-agenda-custom-commands '(("n" "Agenda and all TODOs"
                                      ((agenda "")
                                        (alltodo "")))
                                     ("f" occur-tree "\\<FIXME\\>")
                                     ))

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


