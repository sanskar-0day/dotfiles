;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.






;; -------- 1. UI & Speed Settings (The "100x" feel) --------
;; Relative line numbers make it easy to jump: "d 5 j" deletes 5 lines down.
(setq display-line-numbers-type 'relative)

;; Don't ask "Are you sure?" when quitting. Just quit.
(setq confirm-kill-emacs nil)

;; Silence the annoying bell sound on errors.
(setq ring-bell-function #'ignore)

;; -------- 2. Typst Configuration (FIXED) --------
;; We use typst-ts-mode (Tree-Sitter) for speed, not the old mode.
(use-package! typst-ts-mode
  :mode "\\.typ\\'"
  :config
  ;; Indent with 2 spaces
  (setq typst-ts-mode-indent-offset 2)
  
  ;; Keybinding: SPC m c to compile & preview
  (map! :map typst-ts-mode-map
        :localleader
        "c" #'typst-ts-mode-compile-and-preview))

;; -------- 3. Org Mode (Second Brain) --------
(setq org-directory "~/org"
      org-agenda-files '("~/org")
      org-log-done 'time       ; Log the time you finish tasks
      org-hide-emphasis-markers t) ; Hide the *bold* asterisks

;; -------- 4. Navigation (Optional) --------
;; Only keep this block IF you added (package! consult-project-extra) to packages.el
(after! consult
  (setq consult-project-function #'consult-project-extra-find))


(setq +workspaces-on-switch-project-behavior t)
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)        ; For Nim via shell
     (zig . t)          ; ob-zig handles this
     (python . t)))     ; Optional, for testing

  (setq org-confirm-babel-evaluate nil))

;; Geiser (PRIMARY for SICP)
(after! geiser
  (setq geiser-default-implementation 'racket))

;; Common Lisp (uses Sly)
(after! sly
  (setq inferior-lisp-program "sbcl"))
