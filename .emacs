(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#0a0814" "#f2241f" "#67b11d" "#b1951d" "#4f97d7" "#a31db1" "#28def0" "#b2b2b2"])
 '(custom-enabled-themes '(spacemacs-dark))
 '(custom-safe-themes
   '("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" default))
 '(org-export-backends '(ascii html icalendar latex md odt))
 '(package-selected-packages
   '(dockerfile-mode rust-mode solidity-mode go-mode format-all dracula-theme hl-todo centaur-tabs flycheck elpy exec-path-from-shell py-autopep8 python-mode org-bullets kotlin-mode groovy-mode gradle-mode yaml-mode which-key spacemacs-theme neotree projectile use-package evil-visual-mark-mode))
 '(pdf-view-midnight-colors '("#b2b2b2" . "#292b2e"))
 '(python-shell-interpreter "python3")
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-date ((t (:foreground "#FF79C6" :underline nil)))))


;; ==============================
;; Initial package stuff
;; ==============================
(require 'package)

(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))

(setq package-enable-at-startup nil)
(package-initialize)


;; ==============================
;; use-package
;; ==============================
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))


;; ==============================
;; Packages themselves
;; ==============================
(use-package use-package-ensure-system-package
  :ensure t)

(use-package evil
  :ensure t
  :init
  (setq
   evil-want-C-u-scroll t
   evil-respect-visual-line-mode t
   evil-symbol-word-search t
   evil-want-C-i-jump nil)
  (evil-mode t)
  :config
  (evil-set-undo-system 'undo-tree))

(use-package undo-tree
  :ensure t
  :init
  (setq undo-tree-auto-save-history nil)
  (global-undo-tree-mode))

(use-package evil-surround
  :ensure t
  :init (global-evil-surround-mode t))

(use-package ivy
  :ensure t
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x C-b" . ivy-switch-buffer-other-window))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :init (ivy-mode t))

(use-package counsel
  :ensure t
  :init (counsel-mode t))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode t))

(use-package ivy-rich
  :ensure t
  :init (ivy-rich-mode t))

(use-package projectile
  :ensure t
  :init
    (projectile-mode t)
  :config
    (setq projectile-project-search-path '("~/workspace"))
    (setq projectile-switch-project-action 'neotree-projectile-action)
  :bind
    (:map projectile-mode-map
      ("s-p" . projectile-command-map)
      ;; This invokes real projectile-grep...
      ("C-S-f" . (lambda () (interactive) (counsel-M-x-action (projectile-grep))))
      ;; ...and this invokes counsel-projectile-grep
      ("C-M-f" . projectile-grep))
    ("C-c p" . projectile-command-map))

(use-package counsel-projectile
  :ensure t
  :after projectile
  :bind
    (:map projectile-mode-map
      ("s-j" . counsel-projectile))
  :init
    (counsel-projectile-mode t)
    (if
      (eq system-type 'darwin)
      (setq counsel-projectile-grep-base-command "ggrep -rnEI %s")))

(use-package neotree
  :ensure t
  :config
    (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
    (setq-default neo-show-hidden-files t)
    (setq neo-smart-open t)
    (setq neo-window-width 40)
    (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-cmap (kbd "p") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)
  :bind
    ("M-1" . neotree-toggle))

(use-package dracula-theme
  :ensure t
  :init (load-theme 'dracula t))

(use-package which-key
  :ensure t
  :config
    (setq which-key-show-early-on-C-h t)
    (setq which-key-idle-delay 0.05)
    (which-key-mode)
    (which-key-setup-side-window-bottom))

(use-package yaml-mode
  :ensure t
  :config
    (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
    (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

(use-package kotlin-mode
  :ensure t
  :config
    (add-to-list 'auto-mode-alist '("\\.kt\\'" . kotlin-mode))
    (add-to-list 'auto-mode-alist '("\\.kts\\'" . kotlin-mode)))

(use-package org
  :ensure t
  :config
    (setq org-todo-keywords '((sequence "TODO" "WIP" "DONE")))
    (setq org-fontify-done-headline t)
    (setq org-hide-leading-stars t)
    (setq org-odd-levels-only t)
    (setq org-ellipsis " ⤵ ")
    (setq org-startup-folded t)
    (set-face-attribute 'org-done nil :strike-through t)
    (set-face-attribute 'org-headline-done nil :strike-through t)
  :bind
    ("s-." . org-narrow-to-subtree)
    ("s-," . widen)
    ("s-r" . org-ctrl-c-star))

(use-package org-bullets
  :ensure t
  :hook
    (org-mode . org-bullets-mode)
  :init
    (setq org-bullets-bullet-list '("◉" "◉" "○" "►" "•" "•" "•" "•" "•" "•" "•" "•" "•" "•" "•" "•")))

(use-package exec-path-from-shell
  :ensure t
  :if
    (memq window-system '(mac ns x))
  :config
    (exec-path-from-shell-initialize))

(use-package elpy
  :ensure t
  :init
    (elpy-enable)
  :hook
    (elpy-mode . display-fill-column-indicator-mode)  
    (elpy-mode . (lambda () (setq display-fill-column-indicator-column 80)))
    (elpy-mode . (lambda () (highlight-indentation-mode -1)))
  :config
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (setq elpy-shell-echo-output nil)
    (setq elpy-rpc-python-command "python3")
    (setq elpy-rpc-timeout 2))

(use-package py-autopep8
  :ensure t
  :hook
    (elpy-mode . py-autopep8-enable-on-save))

(use-package flycheck
  :ensure t
  :hook
    (elpy-mode . flycheck-mode))

(use-package hl-todo
  :ensure t
  :hook
  (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
	hl-todo-keyword-faces
	'(("TODO" . "#FF4443")
	  ("HACK" . "#FF4443")
	  ("TEMP" . "#FF4443")
	  ("FIXME" . "#FF4443")
	  ("DEPRECATED" . "#FF4443")
	  ("???" . "#FF4443"))))

(use-package centaur-tabs
  :ensure t
  :demand
  :init
  :config
    (centaur-tabs-mode t)
    (setq
     centaur-tabs-height 32
     centaur-tabs-set-icons t
     centaur-tabs-set-modified-marker t
     centaur-tabs-modified-marker "●"
     centaur-tabs-gray-out-icons 'buffer
     centaur-tabs-show-count t
     centaur-tabs-show-new-tab-button nil)
    (defun centaur-tabs-buffer-groups ()
     (list "GROUP"))
    (defun centaur-tabs-hide-tab (x)
      "Disable tabs for certain buffer types"
      (let ((name (format "%s" x)))
        (or
         (window-dedicated-p (selected-window))
         (string-prefix-p "*Messag" name)
	 (string-prefix-p "*Calcul" name)
	 (string-prefix-p "*format-all-" name))))
  :bind
  ("C-x <left>" . centaur-tabs-backward)
  ("C-x <right>" . centaur-tabs-forward)
  ("<C-S-tab>" . centaur-tabs-backward)
  ("<C-tab>" . centaur-tabs-forward)
  ("<s-S-left>" . centaur-tabs-move-current-tab-to-left)
  ("<s-S-right>" . centaur-tabs-move-current-tab-to-right)
  (:map evil-normal-state-map
    ("g t" . centaur-tabs-forward)
    ("g T" . centaur-tabs-backward)))

(use-package format-all
  :ensure t
  :hook
    (c-mode . format-all-mode)
    (c++-mode . format-all-mode)
    (format-all-mode . format-all-ensure-formatter)
    (format-all-mode . display-fill-column-indicator-mode)  
    (format-all-mode . (lambda () (setq display-fill-column-indicator-column 80)))
  :config
    (setq-default format-all-formatters
	'(("C" clang-format)
	  ("C++" clang-format))))

(use-package go-mode
  :ensure t
  :ensure-system-package
    ((goimports . "go install golang.org/x/tools/cmd/goimports@latest")
     (godef . "go install github.com/rogpeppe/godef@latest"))
  :init
    (setq gofmt-command "goimports")
  :hook
    ((go-mode . (lambda ()
      (setq-local indent-tabs-mode t)
      (setq-local tab-width 2)))
     (before-save . gofmt-before-save))
  :config
    (add-to-list 'auto-mode-alist '("\\.go?\\'" . go-mode))
  :bind
    (:map evil-normal-state-map
      ("K" . godef-describe)
      ("C-K" . godoc-at-point)
      ("g d" . godef-jump-other-window)))

(use-package solidity-mode
  :ensure t
  :config
    (add-to-list 'auto-mode-alist '("\\.sol\\'" . solidity-mode)))

(use-package rust-mode
  :ensure t
  :config
    (setq rust-format-on-save t)
    (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode)))

(use-package dockerfile-mode
  :ensure t)


;; ==============================
;; Use particular frame width, full height, align to the right
;; ==============================
;; (setq default-frame-alist '((left . (- 0)) (width . 152) (fullscreen . fullheight)))


;; ==============================
;; Maximize frame
;; ==============================
(toggle-frame-maximized)


;; ==============================
;; Set up font
;; ==============================
(when (window-system)
  (set-frame-font "JetBrains Mono 11" nil t))
(setq-default line-spacing 0.2)


;; ==============================
;; Emoji: 🌚, 󠁿🚀, 🌝
;; ==============================
(set-fontset-font t 'symbol "Apple Color Emoji")
(set-fontset-font t 'symbol "Noto Color Emoji" nil 'append)
(set-fontset-font t 'symbol "Segoe UI Emoji" nil 'append)
(set-fontset-font t 'symbol "Symbola" nil 'append)


;; ==============================
;; Use modeline visual bell
;; ==============================
(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line "#962d00")
          (run-with-idle-timer 0.1 nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg))))


;; ==============================
;; Show line numbers
;; ==============================
(global-display-line-numbers-mode)


;; ==============================
;; Fix line number column width
;; ==============================
(setq display-line-numbers-width-start t)


;; ==============================
;; Highlight matching parentheses
;; ==============================
(show-paren-mode t)


;; ==============================
;; Always follow the symlink
;; ==============================
(setq vc-follow-symlinks t)


;; ==============================
;; Fix titlebar text appearance
;; ==============================
;; https://github.com/d12frosted/homebrew-emacs-plus/blob/master/Formula/emacs-plus.rb#L98
;; https://github.com/d12frosted/homebrew-emacs-plus/issues/55
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Properties-in-Mode.html#Properties-in-Mode
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))


;; ==============================
;; Restore latest session
;; ==============================
;; (desktop-save-mode t) ;; Disabled for now


;; ==============================
;; Disable welcome screen
;; ==============================
(setq inhibit-startup-screen t)


;; ==============================
;; Wrap long lines
;; ==============================
(global-visual-line-mode t)


;; ==============================
;; Highlight current line
;; ==============================
(global-hl-line-mode t)


;; ==============================
;; Display column number in powerline
;; ==============================
(column-number-mode t)


;; ==============================
;; Hide file icon from title bar
;; ==============================
(setq ns-use-proxy-icon nil)


;; ==============================
;; Scroll settings
;; ==============================
(setq
 mouse-wheel-scroll-amount '(1 ((shift) . 1)) ;; mouse scroll one line at a time
 mouse-wheel-progressive-speed nil            ;; don't accelerate scrolling
 scroll-step 5)                               ;; keyboard scroll one line at a time


;; ==============================
;; Set-up Emacs backup files
;; ==============================
(setq
 backup-directory-alist `(("." . "~/.emacs-backup-files"))
 backup-by-copying t
 delete-old-versions t
 kept-new-versions 10
 kept-old-versions 10
 version-control t)


;; ==============================
;; Kill current buffer faster
;; ==============================
(global-set-key (kbd "C-x k") 'kill-this-buffer)


;; ==============================
;; Comment / uncomment lines easier
;; ==============================
(global-set-key (kbd "s-/") 'comment-line)


;; ==============================
;; Keep buffers in sync with fs
;; ==============================
(global-auto-revert-mode t)


;; ==============================
;; Disable menu bar
;; ==============================
(menu-bar-mode -1)


;; ==============================
;; Open some files on startup
;; ==============================
(find-file "~/.emacs")
(find-file "~/org-files/planner.org")


;; ==============================
;; Run terminal (disabled for now)
;; ==============================
;; (term "/bin/zsh")


;; ==============================
;; Launch aita-android-review-reminder from Emacs
;; ==============================
(defun aita-android-review-reminder ()
  (interactive)
  (insert
   (shell-command-to-string
    (concat
     "("
     "cd ~/workspace/aita-android-review-reminder "
     "&& source .env "
     "&& make run-org ONLY_USER=rozag "
     "&& export GH_TOKEN='' "
     "&& cd - "
     ") "
     "| tail -n +2"))))


;; ==============================
;; Simplify closing "pop-ups"
;; ==============================
(defun close-and-kill-this-pane ()
  "If there are multiple windows, then close this pane and kill the buffer in it also."
  (interactive)
  (kill-this-buffer)
  (if (not (one-window-p))
    (delete-window)))
(defun close-and-kill-next-pane ()
  "If there are multiple windows, then close the other pane and kill the buffer in it also."
  (interactive)
  (other-window 1)
  (kill-this-buffer)
  (if (not (one-window-p))
    (delete-window)))
(global-set-key (kbd "C-x 4 0") 'close-and-kill-this-pane)
(global-set-key (kbd "C-x 4 1") 'close-and-kill-next-pane)


;; ==============================
;; Kill unneeded buffers
;; ==============================
(kill-buffer "*scratch*")

