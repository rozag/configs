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
 '(hl-todo-keyword-faces
   '(("TODO" . "#dc752f")
     ("HACK" . "#b1951d")
     ("TEMP" . "#b1951d")
     ("FIXME" . "#dc752f")
     ("???" . "#dc752f")))
 '(package-selected-packages
   '(org-bullets kotlin-mode groovy-mode gradle-mode yaml-mode which-key spacemacs-theme neotree projectile use-package evil-visual-mark-mode))
 '(pdf-view-midnight-colors '("#b2b2b2" . "#292b2e"))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-date ((t (:foreground "#7590db" :underline nil)))))


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
(use-package evil
  :ensure t
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-respect-visual-line-mode t)
  (evil-mode t))

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

(use-package counsel-projectile
  :ensure t
  :after projectile
  :init (counsel-projectile-mode t))

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
      ("s-p" . projectile-command-map))
    ("C-c p" . projectile-command-map))

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

(use-package spacemacs-common
  :ensure spacemacs-theme
  :config (load-theme 'spacemacs-dark t))

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
    (setq org-bullets-bullet-list '("◉" "◉" "○" "►" "•" "•" "•" "•" "•" "•" "•")))


;; ==============================
;; Use particular frame width, full height, align to the right
;; ==============================
(setq default-frame-alist '((left . (- 0)) (width . 152) (fullscreen . fullheight)))


;; ==============================
;; Set up font
;; ==============================
(when (window-system)
  (set-frame-font "JetBrains Mono 13" nil t))
(setq-default line-spacing 0.2)


;; ==============================
;; Emoji: 🌚, 󠁿🚀, 🌝
;; ==============================
(set-fontset-font t 'symbol "Apple Color Emoji")
(set-fontset-font t 'symbol "Noto Color Emoji" nil 'append)
(set-fontset-font t 'symbol "Segoe UI Emoji" nil 'append)
(set-fontset-font t 'symbol "Symbola" nil 'append)


;; ==============================
;; Enable ligatures
;; ==============================
(let ((ligatures `((?-  ,(regexp-opt '("-|" "-~" "---" "-<<" "-<" "--" "->" "->>" "-->")))
                     (?/  ,(regexp-opt '("/**" "/*" "///" "/=" "/==" "/>" "//")))
                     (?*  ,(regexp-opt '("*>" "***" "*/")))
                     (?<  ,(regexp-opt '("<-" "<<-" "<=>" "<=" "<|" "<||" "<|||" "<|>" "<:" "<>" "<-<"
                                           "<<<" "<==" "<<=" "<=<" "<==>" "<-|" "<<" "<~>" "<=|" "<~~" "<~"
                                           "<$>" "<$" "<+>" "<+" "</>" "</" "<*" "<*>" "<->" "<!--")))
                     (?:  ,(regexp-opt '(":>" ":<" ":::" "::" ":?" ":?>" ":=" "::=")))
                     (?=  ,(regexp-opt '("=>>" "==>" "=/=" "=!=" "=>" "===" "=:=" "==")))
                     (?!  ,(regexp-opt '("!==" "!!" "!=")))
                     (?>  ,(regexp-opt '(">]" ">:" ">>-" ">>=" ">=>" ">>>" ">-" ">=")))
                     (?&  ,(regexp-opt '("&&&" "&&")))
                     (?|  ,(regexp-opt '("|||>" "||>" "|>" "|]" "|}" "|=>" "|->" "|=" "||-" "|-" "||=" "||")))
                     (?.  ,(regexp-opt '(".." ".?" ".=" ".-" "..<" "...")))
                     (?+  ,(regexp-opt '("+++" "+>" "++")))
                     (?\[ ,(regexp-opt '("[||]" "[<" "[|")))
                     (?\{ ,(regexp-opt '("{|")))
                     (?\? ,(regexp-opt '("??" "?." "?=" "?:")))
                     (?#  ,(regexp-opt '("####" "###" "#[" "#{" "#=" "#!" "#:" "#_(" "#_" "#?" "#(" "##")))
                     (?\; ,(regexp-opt '(";;")))
                     (?_  ,(regexp-opt '("_|_" "__")))
                     (?\\ ,(regexp-opt '("\\" "\\/")))
                     (?~  ,(regexp-opt '("~~" "~~>" "~>" "~=" "~-" "~@")))
                     (?$  ,(regexp-opt '("$>")))
                     (?^  ,(regexp-opt '("^=")))
                     (?\] ,(regexp-opt '("]#"))))))
    (dolist (char-regexp ligatures)
      (apply (lambda (char regexp) (set-char-table-range
                                    composition-function-table
                                    char `([,regexp 0 font-shape-gstring])))
             char-regexp)))


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
;; Hide file icon from title bar
;; ==============================
(setq ns-use-proxy-icon nil)


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
;; Open some files on startup
;; ==============================
(find-file "~/.emacs")
(find-file "~/org-files/planner.org")

