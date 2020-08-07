;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here

;;; General settings and appearance
;; (menu-bar-mode 1)

(after! solaire-mode
  (add-hook 'doom-init-ui-hook #'solaire-mode-swap-bg t))
(load-theme 'doom-material t)

(set-frame-font "Monaco 11" nil t)
(setq ns-use-proxy-icon nil)
(setq frame-title-format "%b")
(setq icon-title-format nil)

(doom-load-envvars-file "~/.doom.d/myenv")

(map! (:leader
        (:prefix "w"
          :desc "Close window and kill buffer" :n "C" (λ! (kill-this-buffer) (+workspace/close-window-or-workspace))
          :n "U" #'winner-redo))
      :i "C-h" #'evil-delete-backward-char-and-join
      :i "S-C-h" #'backward-kill-word
      :i "C-l" #'evil-delete-char
      ;; I like to be able to do micro-movements
      ;; within insert state
      :i "C-f" #'forward-char
      :i "C-b" #'backward-char
      ;; Redefine help in insert state
      :i "C-?" #'help-command
      :niv "C-S-SPC" (λ! (push-mark))
      :niv "M-h" #'backward-sexp
      :niv "M-l" #'forward-sexp
      :niv "M-j" #'down-list
      :niv "M-k" #'backward-up-list
      :nv "DEL" (λ! (evil-previous-line) (evil-end-of-line))
      :nv "U" #'undo-tree-redo
      :nv "C-i" #'better-jumper-jump-forward
      :nv "C-o" #'better-jumper-jump-backward
      :nv "C-/" #'avy-goto-char-timer
      :nv "C-'" #'ivy-resume
      :nv "C-;" #'avy-resume)

(map!   :g "s-x"   #'counsel-M-x
        :g "s-z"   #'eval-expression
        :g "s-`"   #'other-frame
        :g "M-;"   #'+emacs-lisp/open-repl
        :gniv "s-/"   #'swiper-isearch
        :g "s-f"   #'counsel-grep-or-swiper
        :g "s-o"   #'+ivy/jump-list
        :g "s-p"   #'counsel-yank-pop
        :g "s-h"   #'evil-window-decrease-width
        :g "s-l"   #'evil-window-increase-width
        :g "s-;"   #'ace-window
        :n "C-S-b" #'scroll-other-window
        :n "C-S-f" #'scroll-other-window-down
        :g "s-j"   #'evil-window-next
        :g "s-k"   #'evil-window-prev
        (:when (featurep! :ui workspaces)
          :g "s-1"   (λ! (+workspace/switch-to 0))
          :g "s-2"   (λ! (+workspace/switch-to 1))
          :g "s-3"   (λ! (+workspace/switch-to 2))
          :g "s-4"   (λ! (+workspace/switch-to 3))
          :g "s-5"   (λ! (+workspace/switch-to 4))
          :g "s-6"   (λ! (+workspace/switch-to 5))
          :g "s-7"   (λ! (+workspace/switch-to 6))
          :g "s-8"   (λ! (+workspace/switch-to 7))
          :g "s-9"   (λ! (+workspace/switch-to 8))
          :g "s-0"   #'+workspace/switch-to-last
          :g "s-t"   #'+workspace/new
          :g "s-T"   #'+workspace/display))

(map! :map +popup-mode-map
      "C-`" #'+popup/toggle)

;; Snipe/Avy

(after! evil-snipe
  (setq evil-snipe-scope 'visible))
;;   (define-key evil-snipe-parent-transient-map (kbd "C-;")
;;     (evilem-create 'evil-snipe-repeat
;;                    :bind ((evil-snipe-scope 'whole-buffer)
;;                           (evil-snipe-enable-highlight)
;;                           (evil-snipe-enable-incremental-highlight)))))

;; Evil
(after! evil
  (evil-ex-define-cmd "t" "copy"))

(defmacro define-and-bind-text-object (key start-regex end-regex)
  (let ((inner-name (make-symbol "inner-name"))
        (outer-name (make-symbol "outer-name")))
    `(progn
       (evil-define-text-object ,inner-name (count &optional beg end type)
         (evil-select-paren ,start-regex ,end-regex beg end type count nil))
       (evil-define-text-object ,outer-name (count &optional beg end type)
         (evil-select-paren ,start-regex ,end-regex beg end type count t))
       (define-key evil-inner-text-objects-map ,key (quote ,inner-name))
       (define-key evil-outer-text-objects-map ,key (quote ,outer-name)))))

(define-and-bind-text-object "$" "\\$" "\\$")

;; Ispell
(setq ispell-dictionary "en_US")

;; writing
(use-package! academic-phrases
  :config
  (map! :after evil-org
        :map evil-org-mode-map
        :i "C-c [" #'academic-phrases-by-section))

(use-package! powerthesaurus
  :config
  (map! :after evil-org
        :map evil-org-mode-map
        :i "C-c '" #'powerthesaurus-lookup-word-dwim))

(after! persistent-overlays
  (setq persistent-overlays-directory "~/.doomemacs.d/.local/etc/overlays/"))
;; (define-globalized-minor-mode global-persistent-overlays-mode persistent-overlays-minor-mode #'persistent-overlays-minor-mode)
  ;; #'global-persistent-overlays-minor-mode)

;; Company
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 5)
  (map! :map company-active-map
        "C-h" #'backward-delete-char
        "C-?" #'company-show-doc-buffer
        "C-l" #'company-complete-selection
        "C-SPC" #'company-complete-selection
        "C-'" #'counsel-company))

(after! company-box
  (setq company-box-doc-enable nil))

(defun markdown-convert-buffer-to-org ()
  "Convert the current buffer's content from markdown to orgmode format and save it with the current buffer's file name but with .org extension."
  (interactive)
  (shell-command-on-region point-min (point-max)
                           (format "pandoc -f markdown -t org -o %s"
                                   (concat (file-name-sans-extension (buffer-file-name)) ".org"))))
;; jupyter
(use-package! jupyter
  :config
  (setq jupyter-repl-echo-eval-p t)
  (set-popup-rule! "^\\*jupyter-repl" :quit nil :side 'right :width 90 :slot 1)
  (map! :map jupyter-repl-mode-map
        "C-r" #'isearch-backward))

;; ESS
(after! ess-r-mode
  (add-hook! 'inferior-ess-mode-hook #'smartparens-mode)
  (add-hook! 'ess-mode-hook '(rainbow-delimiters-mode))
  (set-popup-rule! "^\\*R" :quit nil :side 'right :width 82 :slot 1)
  (setq ess-use-ido nil)
  (set-evil-initial-state! 'ess-help-mode 'motion)
  ;; (set-company-backend! 'ess-r-mode (car ess-r-company-backends))
  ;; (set-company-backend! 'inferior-ess-r-mode (car ess-r-company-backends))
  ;; ESS buffers should not be cleaned up automatically
  ;; (add-hook 'inferior-ess-mode-hook #'doom|mark-buffer-as-real)
  ;; Smartparens broke this a few months ago

  (custom-set-variables '(ess-R-font-lock-keywords
                          (quote ((ess-R-fl-keyword:keywords . t)
                            (ess-R-fl-keyword:constants . t)
                            (ess-R-fl-keyword:modifiers . t)
                            (ess-R-fl-keyword:fun-defs . t)
                            (ess-R-fl-keyword:assign-ops . t)
                            (ess-R-fl-keyword:%op% . t)
                            (ess-fl-keyword:fun-calls . t)
                            (ess-fl-keyword:numbers . t)
                            (ess-fl-keyword:operators . t)
                            (ess-fl-keyword:delimiters)
                            (ess-fl-keyword:= . t)
                            (ess-R-fl-keyword:F&T . t)))))

  (custom-set-variables '(inferior-ess-R-font-lock-keywords
                         (quote (ess-S-fl-keyword:prompt . t)
                           (ess-R-fl-keyword:messages . t)
                           (ess-R-fl-keyword:modifiers . t)
                           (ess-R-fl-keyword:fun-defs . t)
                           (ess-R-fl-keyword:keywords . t)
                           (ess-R-fl-keyword:assign-ops . t)
                           (ess-R-fl-keyword:constants . t)
                           (ess-R-fl-keyword:matrix-labels . t)
                           (ess-fl-keyword:fun-calls . t)
                           (ess-fl-keyword:numbers . t)
                           (ess-fl-keyword:operators . t)
                           (ess-fl-keyword:delimiters . nil)
                           (ess-fl-keyword:= . t)
                           (ess-R-fl-keyword:F&T . t))))

  ;; Functions related to the pipe. Credit to J. A. Branham
  ;; https://github.com/jabranham/emacs/blob/master/init.el

  (defun ess-beginning-of-pipe-or-end-of-line ()
    "Find point position of end of line or beginning of pipe %>%."
    (if (search-forward "%>%" (line-end-position) t)
        (let ((pos (progn
                     (beginning-of-line)
                     (search-forward "%>%" (line-end-position))
                     (backward-char 3)
                     (point))))
          (goto-char pos))
      (end-of-line)))

  (defun ess-next-pipe-or-end-of-line ()
    "Find point position of next pipe %>%."
    (if (search-forward "%>%" nil t)
        (let ((pos (progn
                     (beginning-of-line)
                     (search-forward "%>%")
                     (backward-char 4)
                     (point))))
          (goto-char pos))
      (end-of-line)))

    (defun ess-r-add-pipe ()
        "Add a pipe operator %>% at the end of the current line.
        Don't add one if the end of line already has one.  Ensure one
        space to the left and start a newline with indentation."
        (interactive)
        (end-of-line)
        (unless (looking-back "%>%" nil)
        (just-one-space 1)
        (insert "%>%"))
        (newline-and-indent)
        (evil-append nil))

    (defun ess-eval-pipe-through-line (vis)
      "Like `ess-eval-paragraph' but only evaluates up to the pipe on this line.
If no pipe, evaluate paragraph through the end of current line.
Prefix arg VIS toggles visibility of ess-code as for `ess-eval-region'."
      (interactive "P")
      (save-excursion
        (let ((end (progn
                     (ess-beginning-of-pipe-or-end-of-line)
                     (point)))
              (beg (progn (backward-paragraph)
                          (ess-skip-blanks-forward 'multiline)
                          (point))))
          (ess-eval-region beg end vis))))

    (defun inferior-ess-add-pipe ()
      "Like above but for inferior buffer."
      (interactive)
        (unless (looking-back "%>%" nil)
        (just-one-space 1)
        (insert "%>%")
        (just-one-space 1))
        (evil-append nil))

    (map! (:map ess-mode-map
        :i "C-<" #'ess-cycle-assign
        :i "C-." (λ! (insert "$") (+company/complete)))
        :niv "C-§" #'ess-switch-to-inferior-or-script-buffer
        :niv "C->" #'ess-r-add-pipe
        :map inferior-ess-mode-map
        :niv "C->" #'inferior-ess-add-pipe
        :niv "C-§" #'evil-window-next
        :nv "0" #'comint-bol
        :niv "C-r" #'counsel-shell-history
        :i "C-." (λ! (insert "$") (+company/complete))
        :localleader
        :map ess-mode-map
        "." #'ess-eval-pipe-through-line))

;;; LSP mode
(setq lsp-signature-auto-activate nil)

;; LSP and org
(defun org-babel-edit-prep:python (babel-info)
  "Prepare the local buffer environment for Org source block."
  (let ((lsp-file (or (->> babel-info caddr (alist-get :file))
                      buffer-file-name)))
    (setq-local buffer-file-name lsp-file)
    (setq-local lsp-buffer-uri (lsp--path-to-uri buffer-file-name))
    (lsp-python-enable)))

;; LSP dap
(use-package! dap-python)

;;; Org-mode setup

;; Poly Org
(use-package! poly-org)
(use-package! poly-markdown)

(defun +org-element-in-src-block-p (&optional inside)
  "A version of `org-in-src-block-p' that uses `org-element' for checking
if in src block to make it work with polymode (where char porpeties seem to
go lost)."
  (let ((case-fold-search t))
    (and (eq (org-element-type (org-element-context)) 'src-block)
         (if inside
             (save-match-data
               (save-excursion
                 (beginning-of-line)
                 (not (looking-at ".*#\\+\\(header\\|name\\|\\(begin\\|end\\)_src\\)"))))
           t))))

(defun polymode-mark-inner-chunk ()
  (let ((span (pm-innermost-span)))
    (set-mark (1+ (nth 1 span)))
    (goto-char (1- (nth 2 span)))))

(defun polymode-mark-chunk ()
  (let ((span (pm-innermost-span)))
    (goto-char (1- (nth 1 span)))
    (set-mark (line-beginning-position))
    (goto-char (nth 2 span))
    (goto-char (line-end-position))))

(evil-define-text-object evil-inner-polymode-chunk (count &optional beg end type)
  "Select inner polymode chunk."
  :type line
  (polymode-mark-inner-chunk)
  (evil-range (region-beginning)
              (region-end)
              'line))

(evil-define-text-object evil-a-polymode-chunk (count &optional beg end type)
  "Select a polymode chunk."
  :type line
  (polymode-mark-chunk)
  (evil-range (region-beginning)
              (region-end)
              'line))

(map! :map evil-inner-text-objects-map "c" 'evil-inner-polymode-chunk)
(map! :map evil-inner-text-objects-map "C" 'evilnc-inner-comment)
(map! :map evil-outer-text-objects-map "c" 'evil-a-polymode-chunk)
(map! :map evil-outer-text-objects-map "C" 'evilnc-outer-commenter)

(defun org-src-block-heading-or-org-previous-visible-heading ()
  (interactive)
  (if (+org-element-in-src-block-p t) (org-babel-goto-src-block-head)
    (org-babel-previous-src-block)))

;; (after! ivy
 ;; (add-to-list 'ivy-ignore-buffers "\\[.+\\]"))

;; (evil-define-minor-mode-key
;;   'normal 'poly-org-mode
;;   "C-c C-c" #'org-ctrl-c-ctrl-c)

(map! :map (poly-org-mode-map evil-org-mode-map)
      :niv "C-c C-c" #'org-ctrl-c-ctrl-c
      :nv "[i" #'polymode-previous-chunk
      :nv "]i" #'polymode-next-chunk
      :nv "C-i" #'better-jumper-jump-forward)

(map! :map (poly-org-mode-map evil-org-mode-map)
      :localleader
      "m" #'org-preview-latex-fragment)
;; :niv "C-c '" #'org-edit-special
(map! :after evil-org
      :map evil-org-mode-map
      :niv "C-i" #'better-jumper-jump-forward
      :i "C-l" (general-predicate-dispatch 'evil-delete-char
                 (org-at-table-p) 'org-table-next-field)
      :i "C-h" (general-predicate-dispatch 'delete-backward-char
                 (org-at-table-p) 'org-table-previous-field)
      :i "C-k" (general-predicate-dispatch 'evil-insert-digraph
                 (org-at-table-p) '+org/table-previous-row)
      :i "C-j" (general-predicate-dispatch 'electric-newline-and-maybe-indent
                 (org-at-table-p) 'org-table-next-row)
      :niv "C-c TAB" #'org-ctrl-c-tab
      :niv "C-c <C-tab>" (general-predicate-dispatch 'org-toggle-inline-images
                 (org-at-table-p) 'org-table-shrink)
      :nv "C-k" #'evil-insert-digraph
      :nv "C-j" #'electric-newline-and-maybe-indent)

(add-hook! 'polymode-init-inner-hook
  #'evil-normalize-keymaps)
     ;; lambda () (font-lock-add-keywords nil tex-font-lock-keywords-1))
     ;; lambda () (font-lock-add-keywords nil tex-font-lock-keywords-1))

;; General org-mode setup
;; Key bindings
(map! :after evil-org
      :map (evil-org-mode-map poly-org-mode-map)
      ;; Jumping with counsel
      :desc "Jump: Heading" :nv "C-/ h" (λ! (counsel-org-goto))
      :desc "Jump: SRC block" :nv "C-/ s" #'org-babel-goto-named-src-block
      :desc "Jump: Imenu" :nv "C-/ i" #'counsel-imenu
      ;; Folding and zzzparse trees
      :desc "Sparse tree: SRC blocks" :nv "z s" (λ! (org-occur "^#\\+BEGIN_SRC"))
      :desc "Close all blocks" :nv "z B" #'org-hide-block-all
      :desc "Show all blocks" :nv "z b" #'org-show-block-all
      :nv "[c" #'org-src-block-heading-or-org-previous-visible-heading
      :niv "C-§" #'ess-switch-to-inferior-or-script-buffer
      ;; Set TAGS with counsel
      :niv "C-c C-q" #'counsel-org-tag
      :niv "C-c C-*" #'org-ctrl-c-star)

;; (add-hook! 'org-mode-hook
;;   #'(doom|enable-line-numbers))

;; Let overlays persist revert buffer
(defun org-persistent-overlays ()
  "Congiguration of `persistent-overlays-minor-mode' in ord buffers.
Featuers:
- Preserve overlays after `revert-buffer',
- Preserve overlays when activating `org-mode'."
  (setq-local persistent-overlays-auto-merge nil)
  (setq-local persistent-overlays-auto-load t)
  (persistent-overlays-minor-mode 1))
  ;; (add-hook! 'before-revert-hook #'persistent-overlays-save-overlays nil t)
  ;; (add-hook! 'after-revert-hook #'persistent-overlays-load-overlays nil t))

;; (add-hook! 'org-mode-hook #'org-persistent-overlays)

(after! org
  (use-package! ox-extra
    :config
    (ox-extras-activate '(ignore-headlines)))

  (org-link-set-parameters "marginnote3app"
                           :follow (lambda (path)
                                     (shell-command (concat "open marginnote3app:" path))))
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9))
        org-outline-path-complete-in-steps nil ; Refile in a single go
        org-refile-use-outline-path t)
  (setq org-latex-create-formula-image-program 'dvisvgm
        org-ellipsis " ... " ; ▼
        org-latex-caption-above '(table))
  (setq-default org-format-latex-options (plist-put org-format-latex-options :scale 0.8))
  (setq org-babel-inline-result-wrap "%s")
  (setq org-latex-prefer-user-labels t)
  (set-popup-rule! "^\\*Org Src" :size 0.9 :quit nil :select t :autosave t :modeline t :ttl nil)
  (setq org-startup-indented nil)

  ;; Tufte
  (add-to-list 'org-latex-classes
               '("tufte-book"
                 "\\documentclass[round]{tufte-book}\n\\usepackage{color}\n\\usepackage{gensymb}\n\\usepackage{nicefrac}\n\\usepackage{units}"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


  ;; (add-hook 'org-mode-hook #'org-indent-mode)

  (defun org-babel-execute-named-src-block ()
    (interactive)
    (save-excursion
      (goto-char
       (org-babel-find-named-block
        (completing-read "Code Block: " (org-babel-src-block-names))))
      (org-babel-execute-src-block-maybe)))

  (defun +org/hide-block-subtree ()
  "Hide blocks only below current heading."
  (interactive)
  (save-restriction
    (widen)
    (org-narrow-to-subtree)
    (org-hide-block-all))))

(defun add-pcomplete-to-capf ()
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))

(add-hook 'org-mode-hook #'add-pcomplete-to-capf
          (set-company-backend! 'org-mode 'org-keyword-backend))



(defun org-keyword-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'org-keyword-backend))
    (prefix (and (eq major-mode 'org-mode)
                 (cons (company-grab-line "^#\\+\\(\\w*\\)" 1)
                       t)))
    (candidates (mapcar #'upcase
                        (cl-remove-if-not
                         (lambda (c) (string-prefix-p arg c))
                         (pcomplete-completions))))
    (ignore-case t)
    (duplicates t)))

(defun counsel-switch-to-fzf ()
  "Switch to counsel-file-jump, preserving current input."
  (interactive)
  (let ((input (ivy--input))
        (dir ivy--directory))
    (ivy-quit-and-run (counsel-fzf input dir))))

(map! :after ivy
      (:map ivy-minibuffer-map
        "C-l" #'ivy-partial-or-done
        "C-SPC" #'ivy-partial-or-done
        "C-h" #'ivy-backward-delete-char
        "C-o" #'ivy-dispatching-done
        "M-o" #'hydra-ivy/body
        [C-return] #'ivy-mark
        [C-S-return] #'ivy-unmark)
      :map ivy-switch-buffer-map
      "C-k" #'ivy-switch-buffer-kill
      :map counsel-find-file-map
      "C-t" #'counsel-switch-to-fzf)

(define-key! :keymaps +default-minibuffer-maps
  [escape] #'abort-recursive-edit
  "C-v"    #'yank
  "C-z"    (λ! (ignore-errors (call-interactively #'undo)))
  "C-a"    #'move-beginning-of-line
  "C-b"    #'backward-word
  "C-r"    #'counsel-minibuffer-history
  "C-j"    nil
  "C-k"    #'kill-line
  ;; Scrolling lines
  "C-S-n"  #'scroll-up-command
  "C-S-p"  #'scroll-down-command)

(setq org-latex-pdf-process
      '("latexmk -shell-escape -bibtex -pdf %f"))
(setq org-ref-default-bibliography '("~/Documents/Thesis/references_bibtex.bib")
      org-ref-bibliography-notes "~/Documents/Thesis/ref.org"
      org-ref-pdf-directory "~/Documents/Thesis/literature/"
      bibtex-completion-library-path "~/Documents/Thesis/literature/" ;the directory to store pdfs
      bibtex-completion-notes-path "~/Dropbox/org/ref.org" ;the note file for reference notes
      ;; org-directory "~/Dropbox/org"
      org-ref-bibliography-notes "~/Dropbox/org/ref.org"
      org-ref-default-citation-link "citet")

(map! :after org-ref
 (:map org-mode-map
      (:desc "References" :prefix "C-]"
      :i "C-c" #'org-ref-ivy-insert-cite-link
      :i "C-r" #'org-ref-ivy-insert-ref-link
      :i "C-l" #'org-ref-ivy-insert-label-link)))

;; AuCTeX setup
(setq-default TeX-master "preamble.tex")

(defun title-case-region-or-line (@begin @end)
  "Title case text between nearest brackets, or current line, or text selection.
Capitalize first letter of each word, except words like {to, of, the, a, in, or, and, …}. If a word already contains cap letters such as HTTP, URL, they are left as is.

When called in a elisp program, *begin *end are region boundaries.
URL `http://ergoemacs.org/emacs/elisp_title_case_text.html'
Version 2017-01-11"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (let (
           $p1
           $p2
           ($skipChars "^\"<>(){}[]“”‘’‹›«»「」『』【】〖〗《》〈〉〔〕"))
       (progn
         (skip-chars-backward $skipChars (line-beginning-position))
         (setq $p1 (point))
         (skip-chars-forward $skipChars (line-end-position))
         (setq $p2 (point)))
       (list $p1 $p2))))
  (let* (
         ($strPairs [
                     [" A " " a "]
                     [" And " " and "]
                     [" At " " at "]
                     [" As " " as "]
                     [" By " " by "]
                     [" Be " " be "]
                     [" Into " " into "]
                     [" In " " in "]
                     [" Is " " is "]
                     [" It " " it "]
                     [" For " " for "]
                     [" Of " " of "]
                     [" Or " " or "]
                     [" On " " on "]
                     [" Via " " via "]
                     [" The " " the "]
                     [" That " " that "]
                     [" To " " to "]
                     [" Vs " " vs "]
                     [" With " " with "]
                     [" From " " from "]
                     ["'S " "'s "]
                     ["'T " "'t "]
                     ]))
    (save-excursion
      (save-restriction
        (narrow-to-region @begin @end)
        (upcase-initials-region (point-min) (point-max))
        (let ((case-fold-search nil))
          (mapc
           (lambda ($x)
             (goto-char (point-min))
             (while
                 (search-forward (aref $x 0) nil t)
               (replace-match (aref $x 1) "FIXEDCASE" "LITERAL")))
           $strPairs))))))

(defun org-ref-list-of-figures (&optional arg)
  "Generate buffer with list of figures in them.
ARG does nothing.
Ignore figures in COMMENTED sections."
  (interactive)
  (save-excursion
    (widen)
    (let* ((c-b (buffer-name))
	   (counter 0)
	   (list-of-figures
	    (org-element-map (org-ref-parse-buffer) 'link
	      (lambda (link)
		"create a link for to the figure"
		(when
		    (and (string= (org-element-property :type link) "file")
			 (string-match-p
			  "[^.]*\\.\\(png\\|jpg\\|eps\\|pdf\\|svg\\)$"
			  (org-element-property :path link))
			 ;; ignore commented sections
			 (save-excursion
			   (goto-char (org-element-property :begin link))
			   (not (or (org-in-commented-heading-p)
				    (org-at-comment-p)
				    (-intersection (org-get-tags) org-export-exclude-tags)))))
		  (cl-incf counter)

		  (let* ((start (org-element-property :begin link))
			 (linenum (progn (goto-char start) (line-number-at-pos)))
			 (fname (org-element-property :path link))
			 (parent (car (cdr
				       (org-element-property :parent link))))
			 (caption (cl-caaar (plist-get parent :caption)))
			 (name (plist-get parent :name)))

		    (if caption
			(format "[[file:%s::%s][Figure %s:]] %s\n" c-b linenum counter caption)
		      ;; if it has no caption, try the name
		      ;; if it has no name, use the file name
		      (cond (name
			     (format "[[file:%s::%s][Figure %s:]] %s\n" c-b linenum counter name))
			    (fname
			     (format "[[file:%s::%s][Figure %s:]] %s\n"
				     c-b linenum counter fname))))))))))
      (switch-to-buffer "*List of Figures*")
      (setq buffer-read-only nil)
      (org-mode)
      (erase-buffer)
      (insert (mapconcat 'identity list-of-figures ""))
      (goto-char (point-min))
      ;; open links in the same window
      (setq-local org-link-frame-setup
		  '((file . find-file)))
      (setq buffer-read-only t)
      (use-local-map (copy-keymap org-mode-map))
      (local-set-key "q" #'(lambda () (interactive) (kill-buffer))))))
