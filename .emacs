;; packages for emacs to download stuff from
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                        ("marmalade" . "http://marmalade-repo.org/packages/")
                        ("melpa" . "http://melpa.milkbox.net/packages/")))

(require 'package)
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(eshell-scroll-to-bottom-on-output (quote all))
 '(package-selected-packages (quote (magit smex darcula-theme use-package multi-run))))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'multi-run)
;; this is for multi-run
(setq fractus-all (list "128.84.139.10" "128.84.139.11" "128.84.139.12" "128.84.139.24" "128.84.139.25" "128.84.139.27" "128.84.139.28" "128.84.139.20"))
;;(setq fractus-all (list "128.84.139.24" "128.84.139.25" "128.84.139.27" "128.84.139.28" "128.84.139.20"))
(setq multi-run-ssh-username "david")
(setq multi-run-hostnames-list fractus-all)
(defalias 'run 'multi-run)
(defalias 'configure-terminals 'multi-run-configure-terminals)
(defalias 'run-ssh 'multi-run-ssh)
(defalias 'kill-timers 'multi-run-kill-all-timers)
(defalias 'kill-terminals 'multi-run-kill-terminals)
(defalias 'run-loop 'multi-run-loop)
(defalias 'run-with-delay 'multi-run-with-delay)
(defalias 'run-with-delay2 'multi-run-with-delay2)
(defalias 'multi-find 'multi-run-find-remote-files)
(defalias 'multi-find-sudo 'multi-run-find-remote-files-sudo)
(defalias 'multi-copy 'multi-run-copy)
(defalias 'multi-copy-sudo 'multi-run-copy-sudo)
(defalias 'gwd 'multi-run-get-working-directory)



(ido-mode 1)
(setq ido-enable-flex-matching 1)

(use-package darcula-theme
	     :ensure t
	     :config
	     )

(desktop-save-mode 1)

;; smex built on top of ido offers M-x completion
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; keybinding for magit-status, eshell buffer, faircompilation buffer
(global-set-key (kbd "C-x g") 'magit-status)
