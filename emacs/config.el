;; -*- lexical-binding: t; -*-

(defun my/display-startup-time ()
  "Display Emacs startup time and number of garbage collections."
  (interactive)
  (message "Emacs loaded in %.2f seconds with %d garbage collections."
           (float-time
            (time-subtract after-init-time before-init-time))
           gcs-done))

(add-hook 'emacs-startup-hook #'my/display-startup-time)

(require 'package)

;; 1. Define ALL valid repositories first so Emacs knows where to look
(setq package-archives
      '(("melpa"  . "https://melpa.org/packages/")
        ("elpa"   . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; 2. Initialize the package system
(package-initialize)

;; 3. Refresh the local cache ONLY if Emacs doesn't have one cached yet
(unless package-archive-contents
  (package-refresh-contents))

;; This code eliminates the need to type :ensure t for each package download.
(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Improves startup times by allowing Emacs to precompute and generate a single, large autoload file.
;; Instead of re-computing them on every startup.
;; The larger your configuration, the more it will be felt at startup.
;; However, if you enable this, you'll need to manually run the package-quickstart-refresh
;; command whenever your package activations change, such as when you modify the package-load-list
(setq package-quickstart t)

;; Async keeps package/file operations from unnecessarily blocking Emacs.
;; Only works with package.el
(use-package async
  :defer t
  :custom
  (dired-async-mode t)
  (async-bytecomp-package-mode t)
  (async-bytecomp-allowed-packages '(all))
  (async-package-do-action t))

(use-package emacs
  :custom
  ;; Keep the interface minimal; these are still relevant in terminals.
  (menu-bar-mode nil)
  (scroll-bar-mode nil)
  (tool-bar-mode nil)

  (inhibit-startup-screen t)

  ;; Editing behavior.
  (delete-selection-mode t)
  (electric-indent-mode nil)
  (electric-pair-mode t)
  (blink-cursor-mode nil)
  (global-auto-revert-mode t)

  (use-short-answers t)   ; Since Emacs 29, `yes-or-no-p' will use `y-or-n-p'

  (dired-kill-when-opening-new-dired-buffer t) ; Dired doesn't create new buffer
  (dired-mouse-drag-files t) ; Enable Drag and Drop support in dired (Only works in X11)

  (recentf-mode t) ; Enable recent file mode
  (context-menu-mode t) ; Right-click menu
  (savehist-mode t) ; Enables save history mode

  ;; Scrolling: preserve context without aggressive recentering.
  (mouse-wheel-progressive-speed nil)
  (scroll-conservatively 10)            ; smooth scrolling
  (scroll-margin 8)

  ;; Smooth pixel scrolling without momentum.
  (pixel-scroll-precision-mode t) ; Precise pixel scrolling. i.e. smooth scrolling (GUI only)
  (pixel-scroll-precision-use-momentum nil)

  ;; Four-space indentation is the general configuration convention.
  (indent-tabs-mode nil)
  (tab-width 4)
  (sgml-basic-offset 4)
  (c-ts-mode-indent-offset 4)
  (go-ts-mode-indent-offset 4)

  ;; Avoid backup and auto-save files beside project files.
  (make-backup-files nil)
  (auto-save-default nil)
  (delete-by-moving-to-trash t)

  ;; Persistent visual aids.
  (global-display-line-numbers-mode t)
  (global-hl-line-mode t)

  ;; Show tabs, tab marks, and trailing whitespace.
  (whitespace-style '(face tabs tab-mark trailing))

  :hook
  (prog-mode . hs-minor-mode)
  (prog-mode . display-fill-column-indicator-mode)
  (prog-mode . whitespace-mode)

  :config
  ;; Keep Customize-generated settings separate from this file.
  (setq custom-file
        (locate-user-emacs-file "custom.el"))

  (load custom-file 'noerror 'nomessage)

  :bind
  ([escape] . keyboard-escape-quit)

  ;; Zoom text with the keyboard or Ctrl + mouse wheel.
  ("C-+" . text-scale-increase)
  ("C--" . text-scale-decrease)
  ("<C-wheel-up>"   . text-scale-increase)
  ("<C-wheel-down>" . text-scale-decrease))

;; Keep these defaults explicit for modes that do not inherit the settings
;; above directly.
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4
 toggle-truncate-lines t
 truncate-lines t
 line-spacing 0.12
 require-final-newline t
 mode-require-final-newline t)

(delete-selection-mode 1)

;; These guards also make the configuration safe in terminal/minimal builds.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Save visited files after one second of Emacs inactivity.
(auto-save-visited-mode 1)

(setq auto-save-visited-interval 1)

;; Save modified buffers when Emacs loses focus.
(add-hook 'focus-out-hook
          (lambda ()
            (save-some-buffers t)))

;; Delete all trailing whitespace before saving a file.
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Ensure there is exactly one newline at the end of the file.
(setq require-final-newline t
      mode-require-final-newline t)

;; Reload changed files and Dired buffers automatically.
(global-auto-revert-mode 1)

(setq global-auto-revert-non-file-buffers t)

;; Prefer filesystem notifications over periodic polling.
(setq auto-revert-use-notify t)

;; Show spaces, tabs, tab markers, and trailing whitespace.
(setq whitespace-style
      '(face spaces space-mark tabs tab-mark trailing))

(global-whitespace-mode 1)

;; Code lines remain horizontally visible.
(setq-default truncate-lines t)

;; Prose gets visual wrapping without modifying the underlying text.
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'visual-line-mode)

;; Line numbers add little value in terminals, shells, vterm, and Magit.
(dolist (mode '(term-mode
                shell-mode
                eshell-mode
                vterm-mode
                magit-status-mode))
  (add-hook (intern (concat (symbol-name mode) "-hook"))
            (lambda ()
              (display-line-numbers-mode 0))))

(defvar my/font-family "FiraCode Nerd Font"
  "Primary Emacs font.")

(defvar my/font-height 100
  "Current logical font height.")

(defun my/set-font-size-by-dpi (&optional frame)
  "Dynamically set fine-grained font height normalized across macOS, Linux, and external displays."
  (let* ((target-frame (or frame (selected-frame))))
    (when (display-graphic-p target-frame)
      (let* ((attrs  (frame-monitor-attributes target-frame))
             (geom   (cdr (assq 'geometry attrs)))
             (mm     (cdr (assq 'mm-size attrs)))
             (px-w   (nth 2 geom))
             (mm-w   (car mm))
             ;; Frame scaling factor (2.0 on Mac Retina, 1.0 on Linux 1080p)
             (scale  (if (fboundp 'frame-scale-factor)
                         (frame-scale-factor target-frame)
                       1.0))
             ;; Raw DPI based on reported display geometry
             (raw-dpi (and px-w mm-w (> mm-w 0) (* (/ (float px-w) mm-w) 25.4)))

             ;; Normalized logical DPI

             ;; Fine-grained multi-tier mapping:
             ;; - Retina / HiDPI (scale >= 2.0):
             ;;     > 85 eff-DPI (e.g. Mac Studio Display / 4K scaled) -> 140
             ;;     <= 85 eff-DPI (e.g. MacBook Built-in Retina ~74.8) -> 130
             ;;
             ;; - Standard DPI (scale < 2.0):
             ;;     > 150 raw-dpi (e.g. High-density 13"/14" 1080p/2K Linux) -> 110
             ;;     > 120 raw-dpi (e.g. Linux Laptop 15.6" 1080p ~141.8 DPI) -> 100 (ANCHOR)
             ;;     > 90 raw-dpi  (e.g. Standard External 24" 1080p / 27" 1440p) -> 95
             ;;     <= 90 raw-dpi (e.g. Low-density large external display)     -> 90
             (height (if (>= scale 2.0)
                         (let ((eff-dpi (and raw-dpi (/ raw-dpi scale))))
                           (cond
                            ((and eff-dpi (> eff-dpi 85)) 140)
                            (t 130)))
                       (cond
                        ((and raw-dpi (> raw-dpi 150)) 110)
                        ((and raw-dpi (> raw-dpi 120)) 100) ;; Linux laptop baseline (141.8 DPI -> 100)
                        ((and raw-dpi (> raw-dpi 90))   95) ;; Standard external monitor baseline
                        (t 90)))))                           ;; Low-density fallback

        (setq my/font-height height)

        ;; Apply settings to default face
        (set-face-attribute 'default target-frame
                            :font my/font-family
                            :height height
                            :weight 'normal) ;; 'normal prevents over-bold text on macOS CoreText

        ;; Keep all configurable UI text at the same size as the buffer.
        (my/apply-unified-font-height target-frame)

        (message "[font] Frame %s | Scale: %.1f | Raw DPI: %s | Applied Height: %d"
                 target-frame
                 scale
                 (if raw-dpi (format "%.1f" raw-dpi) "N/A")
                 height)))))

;; Hooks for initial startup, client frame spawns, and cross-monitor frame dragging

;; Initialize on startup
(add-hook 'window-setup-hook #'my/set-font-size-by-dpi)

;; Handle newly spawned client frames (daemon mode or multi-window)
(add-hook 'after-make-frame-functions #'my/set-font-size-by-dpi)

;; Dynamically adjust when dragging frames across external monitors
(add-hook 'move-frame-functions #'my/set-font-size-by-dpi)

(setq-default line-spacing 0.12)

(defun my/apply-unified-font-height (&optional frame)
  "Make UI and popup faces use the same height as the default face."
  (let ((height (face-attribute 'default :height frame)))

    ;; Core UI faces.
    (dolist (face
             '(mode-line
               mode-line-inactive
               mode-line-buffer-id
               header-line
               minibuffer-prompt
               fixed-pitch
               variable-pitch
               fixed-pitch-serif
               tooltip
               fringe
               vertical-border
               shadow
               link
               completion-list-mode))
      (when (facep face)
        (set-face-attribute face frame :height height)))

    ;; Completion packages.
    (dolist (face
             '(company-tooltip
               company-tooltip-selection
               company-tooltip-common
               company-tooltip-common-selection
               company-tooltip-annotation
               company-scrollbar-fg
               company-scrollbar-bg))
      (when (facep face)
        (set-face-attribute face frame :height height)))

    ;; Helm.
    (dolist (face
             '(helm-selection
               helm-match
               helm-source-header
               helm-header
               helm-candidate-number
               helm-separator))
      (when (facep face)
        (set-face-attribute face frame :height height)))

    ;; LSP UI.
    (dolist (face
             '(lsp-ui-peek-header
               lsp-ui-peek-selection
               lsp-ui-peek-highlight
               lsp-ui-doc-background
               lsp-ui-doc-header
               lsp-ui-sideline-code-action
               lsp-ui-sideline-current-symbol
               lsp-ui-sideline-symbol))
      (when (facep face)
        (set-face-attribute face frame :height height)))

    ;; Posframe / popup-related faces.
    (dolist (face
             '(posframe-border
               child-frame-border
               popup-face))
      (when (facep face)
        (set-face-attribute face frame :height height)))))

(defun my/normalize-package-fonts ()
  "Normalize popup and completion faces to the default font size."
  (my/apply-unified-font-height))

(with-eval-after-load 'company
  (my/normalize-package-fonts))

(with-eval-after-load 'helm
  (my/normalize-package-fonts))

(with-eval-after-load 'lsp-ui
  (my/normalize-package-fonts))

(with-eval-after-load 'posframe
  (my/normalize-package-fonts))

(when (not (eq system-type 'darwin))
  (use-package ligature
    :load-path "path-to-ligature-repo"
    :config
    ;; Enable the "www" ligature in every possible major mode
    (ligature-set-ligatures 't '("www"))
    ;; Enable traditional ligature support in eww-mode, if the
    ;; `variable-pitch' face supports it
    (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
    ;; Enable all Cascadia and Fira Code ligatures in programming modes
    (ligature-set-ligatures 'prog-mode
                            '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
                              ;; =:= =!=
                              ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
                              ;; ;; ;;;
                              (";" (rx (+ ";")))
                              ;; && &&&
                              ("&" (rx (+ "&")))
                              ;; !! !!! !. !: !!. != !== !~
                              ("!" (rx (+ (or "=" "!" "\." ":" "~"))))
                              ;; ?? ??? ?:  ?=  ?.
                              ("?" (rx (or ":" "=" "\." (+ "?"))))
                              ;; %% %%%
                              ("%" (rx (+ "%")))
                              ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
                              ;; |->>-||-<<-| |- |== ||=||
                              ;; |==>>==<<==<=>==//==/=!==:===>
                              ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\]"
                                              "-" "=" ))))
                              ;; \\ \\\ \/
                              ("\\" (rx (or "/" (+ "\\"))))
                              ;; ++ +++ ++++ +>
                              ("+" (rx (or ">" (+ "+"))))
                              ;; :: ::: :::: :> :< := :// ::=
                              (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
                              ;; // /// //// /\ /* /> /===:===!=//===>>==>==/
                              ("/" (rx (+ (or ">"  "<" "|" "/" "\\" "\*" ":" "!"
                                              "="))))
                              ;; .. ... .... .= .- .? ..= ..<
                              ("\." (rx (or "=" "-" "\?" "\.=" "\.<" (+ "\."))))
                              ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
                              ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
                              ;; *> */ *)  ** *** ****
                              ("*" (rx (or ">" "/" ")" (+ "*"))))
                              ;; www wwww
                              ("w" (rx (+ "w")))
                              ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
                              ;; <$> </> <|  <||  <||| <|||| <- <-| <-<<-|-> <->>
                              ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
                              ;; << <<< <<<<
                              ("<" (rx (+ (or "\+" "\*" "\$" "<" ">" ":" "~"  "!"
                                              "-"  "/" "|" "="))))
                              ;; >: >- >>- >--|-> >>-|-> >= >== >>== >=|=:=>>
                              ;; >> >>> >>>>
                              (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
                              ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
                              ("#" (rx (or ":" "=" "!" "(" "\?" "\[" "{" "_(" "_"
                                           (+ "#"))))
                              ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
                              ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
                              ;; __ ___ ____ _|_ __|____|_
                              ("_" (rx (+ (or "_" "|"))))
                              ;; Fira code: 0xFF 0x12
                              ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
                              ;; Fira code:
                              "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
                              ;; The few not covered by the regexps.
                              "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^="))

    ;; Enables ligature checks globally in all buffers. You can also do it
    ;; per mode with `ligature-mode'.
    (global-ligature-mode t)))

(load-theme 'modus-vivendi t)

;; Centralized palette used by the rest of the configuration.
(defvar my/accent-primary "#007f7f"
  "Primary active accent.")

(defvar my/accent-muted "#008389"
  "Muted accent for structural borders.")

(defvar my/accent-bg-soft "#1b4950"
  "Soft background tint for active selections.")

(defvar my/dark-bg "#1a1e24"
  "Base background.")

(defvar my/panel-bg "#222831"
  "Elevated surface/panel background.")

(defvar my/text-bright "#eeeeee"
  "High-contrast text.")

(custom-set-faces
 `(default
   ((t (:background ,my/dark-bg
                    :foreground ,my/text-bright))))

 `(cursor
   ((t (:background ,my/accent-primary))))

 `(region
   ((t (:background ,my/accent-bg-soft
                    :foreground ,my/text-bright))))

 `(hl-line
   ((t (:background ,my/panel-bg))))

 `(fringe
   ((t (:background ,my/dark-bg
                    :foreground ,my/accent-muted))))

 `(vertical-border
   ((t (:foreground ,my/accent-muted))))

 `(minibuffer-prompt
   ((t (:foreground ,my/accent-primary
                    :weight bold))))

 `(link
   ((t (:foreground ,my/accent-primary
                    :underline t))))

 ;; Active mode line.
 `(mode-line
   ((t (:background ,my/panel-bg
                    :foreground ,my/accent-primary
                    :box (:line-width 1
                                      :color ,my/accent-primary)))))

 ;; Inactive windows use a subdued palette.
 `(mode-line-inactive
   ((t (:background ,my/dark-bg
                    :foreground "#8f9ba8"
                    :box (:line-width 1
                                      :color "#2d3748")))))

 `(mode-line-buffer-id
   ((t (:foreground ,my/accent-primary
                    :weight bold))))

 ;; Search.
 `(isearch
   ((t (:background ,my/accent-primary
                    :foreground ,my/dark-bg
                    :weight bold))))

 `(lazy-highlight
   ((t (:background ,my/accent-bg-soft
                    :foreground ,my/accent-primary)))))

;; Helm & Helm-Core
(with-eval-after-load 'helm
  (custom-set-faces
   `(helm-selection
     ((t (:background ,my/accent-bg-soft
                      :foreground ,my/accent-primary
                      :weight bold))))
   `(helm-match
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(helm-source-header
     ((t (:background ,my/panel-bg
                      :foreground ,my/accent-primary
                      :weight bold
                      :height 1.1))))
   `(helm-header
     ((t (:background ,my/dark-bg
                      :foreground ,my/accent-primary))))
   `(helm-candidate-number
     ((t (:foreground ,my/accent-muted
                      :weight bold))))
   `(helm-separator
     ((t (:foreground ,my/accent-muted))))))

;; Company
(with-eval-after-load 'company
  (custom-set-faces
   `(company-tooltip-selection
     ((t (:background ,my/accent-bg-soft
                      :foreground ,my/accent-primary
                      :weight bold))))
   `(company-tooltip-common
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(company-scrollbar-fg
     ((t (:background ,my/accent-primary))))
   `(company-scrollbar-bg
     ((t (:background ,my/panel-bg))))))

;; Magit & Magit-Todos
(with-eval-after-load 'magit
  (custom-set-faces
   `(magit-section-heading
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(magit-branch-local
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(magit-branch-current
     ((t (:foreground ,my/accent-primary
                      :box (:line-width 1
                                        :color ,my/accent-primary)))))
   `(magit-diff-hunk-heading
     ((t (:background ,my/panel-bg
                      :foreground ,my/accent-primary))))
   `(magit-diff-hunk-heading-highlight
     ((t (:background ,my/accent-bg-soft
                      :foreground ,my/accent-primary))))))

;; Flycheck
(with-eval-after-load 'flycheck
  (custom-set-faces
   `(flycheck-fringe-warning
     ((t (:foreground ,my/accent-primary))))
   `(flycheck-fringe-info
     ((t (:foreground ,my/accent-primary))))))

;; LSP UI (Peek/Doc Popups)
(with-eval-after-load 'lsp-ui
  (custom-set-faces
   `(lsp-ui-peek-header
     ((t (:background ,my/panel-bg
                      :foreground ,my/accent-primary
                      :weight bold))))
   `(lsp-ui-peek-selection
     ((t (:background ,my/accent-bg-soft
                      :foreground ,my/accent-primary))))
   `(lsp-ui-peek-highlight
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(lsp-ui-doc-background
     ((t (:background ,my/panel-bg))))
   `(lsp-ui-doc-header
     ((t (:background ,my/panel-bg
                      :foreground ,my/accent-primary
                      :weight bold))))))

;; Symbol-Overlay
(with-eval-after-load 'symbol-overlay
  (custom-set-faces
   `(symbol-overlay-default-face
     ((t (:background ,my/accent-bg-soft
                      :foreground ,my/accent-primary
                      :weight bold))))))

;; Hl-Todo
(with-eval-after-load 'hl-todo
  (add-to-list 'hl-todo-keyword-faces
               `("TODO" . ,my/accent-primary))
  (add-to-list 'hl-todo-keyword-faces
               '("FIXME" . "#ff4500")))

;; Posframe
(with-eval-after-load 'posframe
  (custom-set-faces
   `(posframe-border
     ((t (:background ,my/accent-primary))))))

;; Web-Mode / Markdown-Mode
(with-eval-after-load 'web-mode
  (custom-set-faces
   `(web-mode-html-tag-face
     ((t (:foreground ,my/accent-primary
                      :weight bold))))
   `(web-mode-html-attr-name-face
     ((t (:foreground "#4fc3f7"))))))

(with-eval-after-load 'markdown-mode
  (custom-set-faces
   `(markdown-header-face-1
     ((t (:foreground ,my/accent-primary
                      :weight bold
                      :height 1.2))))
   `(markdown-header-face-2
     ((t (:foreground "#38bdf8"
                      :weight bold))))))

(use-package winner
  :config
  ;; Track window layouts so maximized windows can be restored.
  (winner-mode 1))

(defun my/toggle-window-zoom ()
  "Toggle between maximizing the current window and restoring the split layout."
  (interactive)
  (if (one-window-p)
      (winner-undo)
    (delete-other-windows)))

(global-set-key (kbd "C-c z") #'my/toggle-window-zoom)

(global-tab-line-mode 1)

(setq tab-line-switch-cycling nil)                        ; default:t
(setq tab-line-close-tab-function 'kill-buffer)           ; default:bury-buffer
(setq tab-line-close-button-show 'selected)               ; default:t (close tab button on all tabs)

(defun my/tab-line-buffer-group (buffer)
  "Group buffers in a simple and useful way."
  (with-current-buffer buffer
    (cond
     ((derived-mode-p 'magit-mode) "magit")
     ((string-match "*helm.*" (buffer-name)) "helm")
     ((string-equal "*" (substring (buffer-name) 0 1)) "*emacs*")
     ((derived-mode-p 'vterm-mode 'eshell-mode 'shell-mode 'term-mode) "terminal")
     ((and-let* ((project (project-current nil))) (project-name project)))
     (t "files"))))  ;; Fallback

(setq tab-line-tabs-function #'tab-line-tabs-buffer-groups)       ; default:tab-line-tabs-fixed-window-buffers
(setq tab-line-tabs-buffer-group-function #'my/tab-line-buffer-group)  ; default:nil

(setq tab-line-exclude-buffers
      '(or "\\*scratch\\*"
           "\\*GNU Emacs\\*"
           "\\*Help\\*"
           "\\*Messages\\*"
           (derived-mode special-mode
                         magit-mode
                         completion-list-mode
                         dired-mode)))

(setq tab-line-tabs-function 'tab-line-tabs-fixed-window-buffers)  ; default:tab-line-tabs-fixed-window-buffers
(setq tab-line-tabs-window-buffers-filter-function #'tab-line-tabs-non-excluded)

(setq tab-line-define-keys nil)  ; default:t

;; better bindings than C-x RIGHT|LEFT
(global-set-key (kbd "C-<prior>") #'tab-line-switch-to-prev-tab)  ; Ctrl + PageUp  → previous
(global-set-key (kbd "C-<next>")  #'tab-line-switch-to-next-tab)  ; Ctrl + PageDown → next

(defun my/tab-line-select-nth (n)
  "Switch to the N-th tab (1-based) in the current window's tab line."
  (interactive "p")
  (let* ((tabs (funcall tab-line-tabs-function))
         (tab  (nth (1- n) tabs)))
    (cond
     ((null tab)
      (message "No tab %d (only %d tabs)" n (length tabs)))
     ((bufferp tab)
      (switch-to-buffer tab))
     ((and (consp tab) (assq 'buffer tab))
      (switch-to-buffer (cdr (assq 'buffer tab))))
     (t
      (message "Tab %d is not a buffer" n)))))

;; M-1 … M-9
(dotimes (i 9)
  (let ((n (1+ i)))
    (global-set-key (kbd (format "M-%d" n))
                    `(lambda ()
                       (interactive)
                       (my/tab-line-select-nth ,n)))))

(defun my/tab-line-open-in-other-window (event)
  "Open the clicked tab in another window."
  (interactive "e")
  (when-let* ((pos         (event-start event))
              (window      (posn-window pos))
              ((window-live-p window))
              (string-info (posn-string pos))
              (buffer      (get-pos-property 1 'tab (car string-info)))
              ((buffer-live-p buffer)))
    (pop-to-buffer buffer
                   '((display-buffer-use-some-window)
                     (inhibit-same-window . t)))))

(define-key tab-line-tab-map [tab-line double-mouse-1] #'my/tab-line-open-in-other-window)

(setq uniquify-buffer-name-style 'forward)

;;; since, C-x k <return> too much acrobatics
(global-set-key (kbd "C-d") #'kill-buffer)  ; same as terminal

(defvar my/recent-closed-file-stack nil
  "Stack of absolute file paths closed.")

(defvar my/recent-closed-file-stack-size 50
  "Maximum number of paths to keep in the closed file stack.")

(defun my/recent-closed-file-track ()
  "Record the file of the buffer being killed (if any)."
  (when buffer-file-name
    (let ((file (expand-file-name buffer-file-name)))
      ;; add-to-history handles uniqueness, moves to front, and limits size automatically!
      (add-to-history 'my/recent-closed-file-stack file my/recent-closed-file-stack-size))))

(add-hook 'kill-buffer-hook #'my/recent-closed-file-track)

(defun my/recent-closed-file-open ()
  "Reopen recent closed file."
  (interactive)
  (let ((found nil))
    (while (and my/recent-closed-file-stack (not found))
      (let ((file (pop my/recent-closed-file-stack)))
        (cond
         ((find-buffer-visiting file))  ; already open → keep looking
         ((not (file-exists-p file)))   ; missing → keep looking
         (t
          (find-file file)
          (setq found t)))))
    (unless found
      (message "No more closed files in this session!"))))

(global-set-key (kbd "C-S-t") #'my/recent-closed-file-open)

(use-package which-key
  :hook (after-init . which-key-mode)
  :diminish
  :custom
  ;; Display pending key sequences in a bottom-side window.
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha)
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1)
  (which-key-min-display-lines 6)
  (which-key-idle-delay 0.3)
  (which-key-allow-imprecise-window-fit nil))

(column-number-mode t)
(display-battery-mode t)
(display-time-mode t)
(size-indication-mode t)

;; Keep buffer-boundary indicators on the left fringe.
(setq indicate-buffer-boundaries
      '((top . left)
        (bottom . left)
        (up . left)
        (down . left)))

(defvar my/ediff-clipboard-buffer nil
  "Temporary buffer used for clipboard comparisons.")

(defun my/ediff--clipboard-buffer ()
  "Create and return a temporary buffer containing the clipboard."
  (let ((buffer (generate-new-buffer "*Ediff Clipboard*"))
        (text (or (and (fboundp 'gui-get-selection)
                       (gui-get-selection 'CLIPBOARD))
                  (current-kill 0))))
    (with-current-buffer buffer
      (insert (or text ""))
      (set-buffer-modified-p nil))
    buffer))

(defun my/ediff--cleanup-buffer ()
  "Delete the temporary Ediff clipboard buffer."
  (when (buffer-live-p my/ediff-clipboard-buffer)
    (kill-buffer my/ediff-clipboard-buffer)))

(defun my/ediff-current-buffer-with-clipboard ()
  "Compare the current buffer with the clipboard."
  (interactive)
  (setq my/ediff-clipboard-buffer
        (my/ediff--clipboard-buffer))
  (add-hook 'ediff-after-quit-hook-internal
            #'my/ediff--cleanup-buffer)
  (ediff-buffers
   (current-buffer)
   my/ediff-clipboard-buffer))

(defun my/ediff-current-buffer-with-buffer (buffer)
  "Compare the current buffer with BUFFER."
  (interactive
   (list
    (read-buffer
     "Compare current buffer with: "
     (other-buffer (current-buffer) t)
     t)))
  (ediff-buffers (current-buffer) (get-buffer buffer)))

(global-set-key (kbd "C-c e c") #'my/ediff-current-buffer-with-clipboard)
(global-set-key (kbd "C-c e b") #'my/ediff-current-buffer-with-buffer)

(setq ediff-split-window-function #'split-window-horizontally
      ediff-window-setup-function #'ediff-setup-windows-plain)

(use-package helm
  :init
  (helm-mode 1)

  :config
  (setq helm-allow-mouse t)

  ;; Use a file-manager-style keymap for Helm file selection.
  (customize-set-variable 'helm-ff-lynx-style-map t)

  ;; Route common built-in commands through Helm.
  (define-key global-map
              [remap list-buffers]
              #'helm-buffers-list)

  (define-key global-map
              [remap execute-extended-command]
              #'helm-M-x)

  (define-key global-map
              [remap find-file]
              #'helm-find-files)

  (define-key global-map
              [remap switch-to-buffer]
              #'helm-mini))

(with-eval-after-load 'helm
  ;; Keep TAB-based navigation while retaining persistent actions on arrows.
  (define-key helm-map (kbd "<tab>")     #'helm-next-line)
  (define-key helm-map (kbd "<backtab>") #'helm-previous-line)
  (define-key helm-map (kbd "<right>")   #'helm-execute-persistent-action)
  (define-key helm-map (kbd "<left>")    #'helm-execute-persistent-action))

(with-eval-after-load 'helm
  ;; Use Helm's Lisp completion when its completion command is available.
  (when (fboundp 'helm-lisp-completion-at-point)
    (define-key lisp-interaction-mode-map
                [remap completion-at-point]
                #'helm-lisp-completion-at-point)

    (define-key emacs-lisp-mode-map
                [remap completion-at-point]
                #'helm-lisp-completion-at-point)))

(use-package undo-tree
  :init
  ;; Replace Emacs's undo backend with undo-tree while keeping Emacs's
  ;; standard undo keybindings intact.
  (global-undo-tree-mode 1)

  :config
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-tree-auto-save-history t

        ;; Keep undo history outside project directories.
        undo-tree-history-directory-alist
        '(("." . "~/.emacs.d/var/undo-tree/"))))

;; No custom undo bindings: keep Emacs's native undo commands.
;;
;; Examples:
;;   C-/   / C-_   undo
;;   C-x u         undo
;;   M-x undo-tree-visualize

(use-package expand-region
  :bind
  ;; Shift-C-SPC expands; C-SPC contracts when a region already exists.
  (("C-S-SPC" . er/expand-region)
   ("C-SPC" .
    (lambda ()
      (interactive)
      (if (use-region-p)
          (er/contract-region 1)
        (call-interactively #'set-mark-command))))))

(use-package yafolding
  :hook (prog-mode . yafolding-mode))

(use-package magit
  :commands magit-status
  :bind ("C-x g" . magit-status))

(global-set-key (kbd "C-x C-l") #'magit-log-buffer-file)

;; Allow Transient menus to expose the full configured command hierarchy.
(setq transient-default-level 7)

(use-package magit-difftastic
 :ensure t
 :demand t
 :config
 ;; Force it to default to a side-by-side layout inside Magit
 (setq magit-difftastic-display-mode 'side-by-side)

 ;; Turn on the global minor mode to replace stock Magit rendering
 (magit-difftastic-mode 1))

(use-package org
  :defer t
  :custom
  (org-ellipsis " ▾")
  (org-hide-leading-stars t)
  (org-log-done 'time)
  (org-adapt-indentation t)
  (org-support-shift-select t))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C      . t)
   (js     . t)
   (python . t)
   (shell  . t)
   (sql    . t)))

(setq org-babel-default-header-args
      '((:noweb . "yes")
        (:eval  . "no-export")))

;; do not ask each time
(setq org-confirm-babel-evaluate nil)

(use-package yasnippet
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'org-mode-hook  #'yas-minor-mode))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package lsp-mode
  :commands (lsp lsp-deferred)

  :hook
  ((python-mode     . lsp-deferred)
   (js-mode         . lsp-deferred)
   (js2-mode        . lsp-deferred)
   (typescript-mode . lsp-deferred)
   (html-mode       . lsp-deferred)
   (js-ts-mode      . lsp-deferred)
   (css-mode        . lsp-deferred)
   (css-ts-mode     . lsp-deferred))

  :init
  ;; All LSP commands live under C-c l.
  (setq lsp-keymap-prefix "C-c l")

  :config
  (setq lsp-enable-indentation t
        lsp-diagnostics-provider :flycheck)

  ;; Expose LSP's prefix map through which-key.
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)

  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-sideline-enable t

        ;; Do not independently enlarge documentation text.
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'at-point

        ;; Keep popup documentation compact.
        lsp-ui-doc-max-width 100
        lsp-ui-doc-max-height 20))

(add-hook 'python-mode-hook #'flycheck-mode)

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :config
  ;; Ruff is enabled through pylsp; redundant Python linters stay disabled.
  (setq lsp-pylsp-plugins-ruff-enabled t
        lsp-pylsp-plugins-pyright-enabled nil
        lsp-pylsp-plugins-flake8-enabled nil
        lsp-pylsp-plugins-mccabe-enabled nil
        lsp-pylsp-plugins-pycodestyle-enabled nil))

;; `indent-bars' depends on compatibility helpers on some Emacs versions.
(use-package compat)

(use-package indent-bars
  :hook ((prog-mode yaml-mode conf-mode) . indent-bars-mode))

;; Use tree-sitter JavaScript for modern module files.
(add-to-list 'auto-mode-alist
             '("\\.mjs\\'" . js-ts-mode))

;; Define a Flycheck checker for Biome.
(with-eval-after-load 'flycheck
  (flycheck-define-checker javascript-biome
    "A JavaScript/TypeScript syntax and style checker using Biome."
    :command ("biome" "check" "--reporter=github"
              (eval (buffer-file-name)))
    :error-patterns
    ((error
      line-start
      "::error file=" (file-name)
      ",line=" line
      ",col=" column
      "::" (message)
      line-end)
     (warning
      line-start
      "::warning file=" (file-name)
      ",line=" line
      ",col=" column
      "::" (message)
      line-end))
    :modes (js-mode
            js-ts-mode
            typescript-mode
            typescript-ts-mode
            jsx-ts-mode
            tsx-ts-mode))

  (add-to-list 'flycheck-checkers 'javascript-biome)
  (flycheck-add-next-checker
   'javascript-eslint
   'javascript-biome))

(defun my/js-ts-mode-setup ()
  "Configure Flycheck for JavaScript and TypeScript."
  (setq-local flycheck-checker 'javascript-eslint)
  (flycheck-mode))

(add-hook 'js-ts-mode-hook #'my/js-ts-mode-setup)

(global-set-key (kbd "C-<f9>") #'project-compile)
(global-set-key (kbd "C-S-f")  #'project-find-file)
(global-set-key (kbd "C-S-g")  #'project-find-regexp)

;; Preserve ANSI colors in compilation and Magit process output.
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
(setq magit-process-apply-ansi-colors t)

;; Unbind suspend-frame — too easy to hit accidentally.
(global-unset-key (kbd "C-z"))

(use-package web-mode
  :mode
  (("\\.djhtml\\'"      . web-mode)
   ("\\.html\\.djhtml\\'" . web-mode))

  :init
  ;; Turn on modern tree-sitter context parsing when available.
  (setq web-mode-enable-tree-sitter t)

  :config
  ;; Force Django templates for .djhtml files.
  (setq web-mode-engines-alist
        '(("django" . "\\.djhtml\\'")))

  ;; Match the global four-space indentation convention.
  (setq web-mode-markup-indent-offset 4
        web-mode-css-indent-offset    4
        web-mode-code-indent-offset   4
        web-mode-sql-indent-offset    4)

  ;; Automatically manage pairs, closing tags, and quotes.
  (setq web-mode-enable-auto-pairing t
        web-mode-enable-auto-closing t
        web-mode-enable-auto-quoting t)

  ;; Company may be loaded later, so enable it only when available.
  (add-hook 'web-mode-hook
            (lambda ()
              (when (fboundp 'company-mode)
                (company-mode 1)))))

(use-package company
  :config
  ;; Global completion engine for programming and template buffers.
  (global-company-mode 1)

  ;; Keep completion responsive while typing.
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1))

;; YAML highlighting for Ansible/K8s/Docker Compose and similar files.
(use-package yaml-mode
  :mode "\\.yml\\'")

;; Dockerfile syntax highlighting.
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

(use-package gptel
  :ensure t
  :bind (("C-c C-g" . gptel-send)   ; Safe shortcut to send active region/buffer
         ("C-c g"   . gptel-menu))  ; Quick access menu to swap models/servers
  :config
  ;; Default to org-mode instead of markdown-mode for dedicated chats
  (setq gptel-default-mode 'org-mode)

  ;; Configure the remote Ollama server
  (setq gptel-work
        (gptel-make-ollama "ollama-office"
          :host "192.168.100.120:11434"
          :stream t
          :models '("qwen2.5-coder:3b"
                    "gemma4:e4b-it-qat"
                    "gemma4:e2b-it-qat"
                    "gemma4:26b-a4b-mtp-it")))

  ;; Configure the local Ollama server
  (setq gptel-local
        (gptel-make-ollama "ollama-beta-lt-pc-002"
          :host "localhost:11434"
          :stream t
          :models '("gemma4:e4b"
                    "qwen2.5-coder:0.5b"
                    "qwen2.5-coder:1.5b"
                    "qwen2.5-coder:3b"
                    "qwen2.5-coder:7b")))

  ;; Set the default backend and model
  (setq gptel-backend gptel-work)
  (setq gptel-model "gemma4:26b-a4b-mtp-it"))

(defun my/gptel-switch-backend ()
  "Interactively switch the active gptel backend and model."
  (interactive)
  (let ((candidates
         ;; Flatten all backends into a single list of (label . (backend . model)) pairs.
         (mapcan
          (lambda (pair)
            (let ((name    (car pair))   ; Backend display name (string)
                  (backend (cdr pair)))  ; The actual gptel-backend struct
              (mapcar (lambda (model)
                        (cons (format "%s → %s" name model)
                              (cons backend model)))
                      (gptel-backend-models backend))))
          gptel--known-backends)))
    (when-let* ((choice (completing-read "Select Model: "
                                         (mapcar #'car candidates)
                                         nil t))
                (selected (cdr (assoc choice candidates))))
      ;; selected is (backend-object . model-symbol)
      (setq gptel-backend (car selected)
            gptel-model   (cdr selected))
      (message "gptel: %s → %s"
               (gptel-backend-name gptel-backend)
               gptel-model))))

(use-package vterm
  :bind
  ("C-c t" . vterm)

  :custom
  (vterm-max-scrollback 10000)

  :config
  ;; Automatically clean up the vterm buffer and its window when the shell exits.
  (add-hook 'vterm-exit-functions
            (lambda (buffer event)
              (let ((window (get-buffer-window buffer)))
                (when (window-live-p window)
                  (delete-window window)))
              (when (buffer-live-p buffer)
                (kill-buffer buffer)))))

(use-package multi-vterm
  :after vterm
  :bind ("C-c M-t" . multi-vterm))

;; Posframe provides the floating window used by vterm-toggle.
(use-package posframe)

(use-package vterm-toggle
  :after (vterm posframe)
  :bind ("C-`" . vterm-toggle)
  :config
  ;; Show vterm in a centered floating window rather than a normal split.
  (setq vterm-toggle-use-posframe t
        vterm-toggle-posframe-style  'center
        vterm-toggle-posframe-width  90
        vterm-toggle-posframe-height 25))

(use-package vertico
  :defer t
  :custom
  ;; Uncomment to switch from Helm to Vertico.
  ;; (vertico-mode 1)
  (vertico-cycle t))

(use-package marginalia
  :defer t
  ;; Uncomment to enable minibuffer annotations.
  ;; :config (marginalia-mode 1)
  )
