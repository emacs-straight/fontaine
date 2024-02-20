;;; fontaine.el --- Set font configurations using presets -*- lexical-binding: t -*-

;; Copyright (C) 2022-2024  Free Software Foundation, Inc.

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; Maintainer: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://github.com/protesilaos/fontaine
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Fontaine lets the user specify presets of font configurations and set
;; them on demand on graphical Emacs frames.  The user option
;; `fontaine-presets' holds all such presets.
;;
;; Consult the manual for all the available features.  And remember
;; that Fonts, Ornaments, and Neat Typography Are Irrelevant in
;; Non-graphical Emacs (FONTAINE).

;;; Code:

(eval-when-compile (require 'subr-x))

(defgroup fontaine ()
  "Set font configurations using presets."
  :group 'font)

(defconst fontaine--weights-widget
  '(choice :tag "Font weight (must be supported by the typeface)"
           (const :tag "Normal" normal)
           (const :tag "Regular (same as normal)" regular)
           (const :tag "Thin" thin)
           (const :tag "Ultra-light" ultralight)
           (const :tag "Extra-light" extralight)
           (const :tag "Light" light)
           (const :tag "Semi-light" semilight)
           (const :tag "Medium" medium)
           (const :tag "Semi-bold" semibold)
           (const :tag "Bold" bold)
           (const :tag "Extra-bold" extrabold)
           (const :tag "Ultra-bold" ultrabold))
  "Widget with font weights for `fontaine-presets'.")

(defcustom fontaine-presets
  '((regular
     :default-height 100)
    (large
     :default-weight semilight
     :default-height 140
     :bold-weight extrabold)
    (t
     ;; I keep all properties for didactic purposes, but most can be
     ;; omitted.
     :default-family "Monospace"
     :default-weight regular
     :default-height 100

     :fixed-pitch-family nil ; falls back to :default-family
     :fixed-pitch-weight nil ; falls back to :default-weight
     :fixed-pitch-height 1.0

     :fixed-pitch-serif-family nil ; falls back to :default-family
     :fixed-pitch-serif-weight nil ; falls back to :default-weight
     :fixed-pitch-serif-height 1.0

     :variable-pitch-family "Sans"
     :variable-pitch-weight nil
     :variable-pitch-height 1.0

     :mode-line-active-family nil ; falls back to :default-family
     :mode-line-active-weight nil ; falls back to :default-weight
     :mode-line-active-height 1.0

     :mode-line-inactive-family nil ; falls back to :default-family
     :mode-line-inactive-weight nil ; falls back to :default-weight
     :mode-line-inactive-height 1.0

     :header-line-family nil ; falls back to :default-family
     :header-line-weight nil ; falls back to :default-weight
     :header-line-height 1.0

     :line-number-family nil ; falls back to :default-family
     :line-number-weight nil ; falls back to :default-weight
     :line-number-height 1.0

     :tab-bar-family nil ; falls back to :default-family
     :tab-bar-weight nil ; falls back to :default-weight
     :tab-bar-height 1.0

     :tab-line-family nil ; falls back to :default-family
     :tab-line-weight nil ; falls back to :default-weight
     :tab-line-height 1.0

     :bold-family nil ; use whatever the underlying face has
     :bold-weight bold
     :italic-family nil
     :italic-slant italic
     :line-spacing nil))
  "Alist of desired typographic properties.

The car of each cell is an arbitrary symbol that identifies
and/or describes the set of properties (e.g. small, reading).

A preset whose car is t is treated as the default option.  This
makes it easier to specify multiple presets without duplicating
their properties.  The other presets beside t act as overrides of
the defaults and, as such, need only consist of the properties
that change from the default.  See the default value of this
variable for how that is done.

The cdr is a plist that specifies the typographic properties of
the faces `default', `fixed-pitch', `variable-pitch', `bold', and
`italic'.  It also covers the `line-spacing' variable.

The properties in detail:

- `:default-family' is the family of the `default' face.  If not
  specified, it falls back to Monospace.

- `:default-weight' is the weight of the `default' face.  The
  fallback value is `normal'.  Available weights are `normal' or
  `regular', `thin', `ultralight', `extralight', `light',
  `semilight', `medium', `semibold', `extrabold', `ultrabold' and
  must be supported by the underlying typeface.

- `:default-height' is the height of the `default' face.  The
  fallback value is 100 (the height is 10x the point size).

- `:fixed-pitch-family', `:fixed-pitch-weight',
  `:fixed-pitch-height' apply to the `fixed-pitch' face.  Their
  fallback values are `:default-family', `:default-weight', and
  1.0, respectively.

- `:fixed-pitch-serif-family', `:fixed-pitch-serif-weight',
  `:fixed-pitch-serif-height' apply to the `fixed-pitch-serif'
  face.  Their fallback values are `:default-family',
  `:default-weight', and 1.0, respectively.

- The `:variable-pitch-family', `:variable-pitch-weight', and
  `:variable-pitch-height' apply to the `variable-pitch' face.
  They all fall back to the respective default values, as
  described above.

- The `:mode-line-active-family', `:mode-line-active-weight', and
  `:mode-line-active-height' apply to the `mode-line' and
  `mode-line-active' faces.  They all fall back to the respective
  default values, as described above.

- The `:mode-line-inactive-family', `:mode-line-inactive-weight',
  and `:mode-line-inactive-height' apply to the
  `mode-line-inactive' face.  They all fall back to the
  respective default values, as described above.

- The `:header-line-family', `:header-line-weight', and
  `:header-line-height' apply to the `header-line' face.  They
  all fall back to the respective default values, as described
  above.

- The `:line-number-family', `:line-number-weight', and
  `:line-number-height' apply to the `line-number' face.  They
  all fall back to the respective default values, as described
  above.

- The `:tab-bar-family', `:tab-bar-weight', and `:tab-bar-height'
  apply to the `tab-bar' face.  They all fall back to the
  respective default values, as described above.

- The `:tab-line-family', `:tab-line-weight', and
  `:tab-line-height' apply to the `tab-line' face.  They all fall
  back to the respective default values, as described above.

- The `:bold-family' and `:italic-family' are the font families
  of the `bold' and `italic' faces, respectively.  Only set them
  if you want to override that of the underlying face.

- The `:bold-weight' specifies the weight of the `bold' face.
  Its fallback value is bold, meaning the weight, not the face.

- The `:italic-slant' specifies the slant of the `italic' face.
  Its fallback value is italic, in reference to the slant, not
  the face.  Acceptable values are `italic', `oblique', `normal',
  `reverse-italic', `reverse-oblique' and must be supported by
  the underlying typeface.

- The `:line-spacing' specifies the value of the `line-spacing'
  variable.

- The `:inherit' contains the name of another named preset.  This
  tells the relevant Fontaine functions to get the properties of
  that preset and blend them with those of the current one.  The
  properties of the current preset take precedence over those of
  the inherited one, thus overriding them.  In practice, this is
  a way to have something like an extra-large preset copy the
  large preset and then only modify its individual properties.
  Remember that all named presets fall back to the preset whose
  name is t: the `:inherit' is not a substitute for that generic
  fallback but rather an extra method of specifying font
  configuration presets.

Use the desired preset with the command `fontaine-set-preset'.

For detailed configuration: Info node `(fontaine) Shared and
implicit fallback values for presets'.

Caveats or further notes:

- On a Windows system, setting a `default' weight other than
  `regular' or `normal' will not work.  This is a limitation with
  Emacs on that system.

- All the properties for `bold' and `italic' will only have a
  noticeable effect if the active theme does not hardcode a
  weight and a slant, but instead inherits the relevant
  face (such as the `modus-themes').

- A height attribute for anything other than the `default' face
  must be set to a floating point, which is understood as a
  multiple of the default height (this allows all faces to scale
  harmoniously).  The `:default-height' always is a natural
  number.

- Fontaine does not [yet] support Emacs' fontsets for other
  scripts or character sets (e.g. Emoji).  Read the documentation
  in the Info node `(emacs) Modifying Fontsets'."
  :type `(alist
          :value-type
          (plist :options
                 (((const :tag "Default font family" :default-family) string)
                  ((const :tag "Default weight" :default-weight) ,fontaine--weights-widget)
                  ((const :tag "Default height" :default-height) natnum)

                  ((const :tag "Fixed pitch font family" :fixed-pitch-family) string)
                  ((const :tag "Fixed pitch regular weight" :fixed-pitch-weight) ,fontaine--weights-widget)
                  ((const :tag "Fixed pitch height" :fixed-pitch-height) float)

                  ((const :tag "Fixed pitch serif font family" :fixed-pitch-serif-family) string)
                  ((const :tag "Fixed pitch serif regular weight" :fixed-pitch-serif-weight) ,fontaine--weights-widget)
                  ((const :tag "Fixed pitch serif height" :fixed-pitch-serif-height) float)

                  ((const :tag "Variable pitch font family" :variable-pitch-family) string)
                  ((const :tag "Variable pitch regular weight" :variable-pitch-weight) ,fontaine--weights-widget)
                  ((const :tag "Variable pitch height" :variable-pitch-height) float)

                  ((const :tag "Active mode line font family" :mode-line-active-family) string)
                  ((const :tag "Active mode line regular weight" :mode-line-active-weight) ,fontaine--weights-widget)
                  ((const :tag "Active mode line height" :mode-line-active-height) float)

                  ((const :tag "Inactive mode line font family" :mode-line-inactive-family) string)
                  ((const :tag "Inactive mode line regular weight" :mode-line-inactive-weight) ,fontaine--weights-widget)
                  ((const :tag "Inactive mode line height" :mode-line-inactive-height) float)

                  ((const :tag "Header line font family" :header-line-family) string)
                  ((const :tag "Header line regular weight" :header-line-weight) ,fontaine--weights-widget)
                  ((const :tag "Header line height" :header-line-height) float)

                  ((const :tag "Line number font family" :line-number-family) string)
                  ((const :tag "Line number regular weight" :line-number-weight) ,fontaine--weights-widget)
                  ((const :tag "Line number height" :line-number-height) float)

                  ((const :tag "Tab bar font family" :tab-bar-family) string)
                  ((const :tag "Tab bar regular weight" :tab-bar-weight) ,fontaine--weights-widget)
                  ((const :tag "Tab bar height" :tab-bar-height) float)

                  ((const :tag "Tab line font family" :tab-line-family) string)
                  ((const :tag "Tab line regular weight" :tab-line-weight) ,fontaine--weights-widget)
                  ((const :tag "Tab line height" :tab-line-height) float)

                  ((const :tag "Font family of the `bold' face" :bold-family) string)
                  ((const :tag "Weight for the `bold' face" :bold-weight) ,fontaine--weights-widget)

                  ((const :tag "Font family of the `italic' face" :italic-family) string)
                  ((const :tag "Slant for the `italic' face" :italic-slant)
                   (choice
                    (const italic)
                    (const oblique)
                    (const normal)
                    (const reverse-italic)
                    (const reverse-oblique)))

                  ((const :tag "Line spacing" :line-spacing) ,(get 'line-spacing 'custom-type))
                  ;; FIXME 2023-01-19: Adding the (choice
                  ;; ,@(fontaine--inheritable-presets-widget)) instead
                  ;; of `symbol' does not have the desired effect
                  ;; because it does not re-read `fontaine-presets'.
                  ((const :tag "Inherit another preset" :inherit) symbol)))
          :key-type symbol)
  :package-version '(fontaine . "1.1.0")
  :group 'fontaine
  :link '(info-link "(fontaine) Shared and implicit fallback values for presets"))

;; ;; See FIXME above in `fontaine-presets' :type.
;; ;;
;; (defun fontaine--inheritable-presets-widget ()
;;   "Return widget with choice among named presets."
;;   (mapcar (lambda (s)
;;             (list 'const s))
;;           (delq t (mapcar #'car fontaine-presets))))

(defcustom fontaine-latest-state-file
  (locate-user-emacs-file "fontaine-latest-state.eld")
  "File to save the latest value of `fontaine-set-preset'.
Saving is done by the `fontaine-store-latest-preset' function,
which should be assigned to a hook (e.g. `kill-emacs-hook').

This is then used to restore the last value with the function
`fontaine-restore-latest-preset'."
  :type 'file
  :package-version '(fontaine . "0.1.0")
  :group 'fontaine)

(defcustom fontaine-font-families nil
  "An alist of preferred font families.

The expected value of this option is a triplet of cons cells
where the car is `default', `fixed-pitch', or `variable-pitch'
and the cdr is a list of strings that reference font family
names.  For example:

    (setq fontaine-font-families
          \\='((default \"Iosevka Comfy\" \"Hack\" \"Roboto Mono\")
            (fixed-pitch \"Mononoki\" \"Source Code Pro\" \"Fira Code\")
            (variable-pitch \"Noto Sans\" \"Roboto\" \"FiraGO\")))


This is used at the minibuffer prompt while using the command
`fontaine-set-face-font' to prompt for a font family.  When this
user option is nil, that prompt will try to find all relevant
fonts installed on the system, which might not always be
reliable (depending on the Emacs build and the environment it
runs in).

If only the `default' is nil and the others are specified, the
command `fontaine-set-face-font' will produce results that
combine the other two lists."
  :type '(set
          (cons :tag "Default font families"
                (const default)
                (repeat string))
          (cons :tag "Fixed pitch font families"
                (const fixed-pitch)
                (repeat string))
          (cons :tag "Variable pitch font families"
                (const variable-pitch)
                (repeat string)))
  :package-version '(fontaine . "0.2.0")
  :group 'fontaine)

(defcustom fontaine-set-preset-hook nil
  "Hook that runs after setting fonts with `fontaine-set-preset'."
  :type 'hook
  :package-version '(fontaine . "1.1.0")
  :group 'fontaine)

;;;; General utilities

(defun fontaine--frame (frame)
  "Return FRAME for `internal-set-lisp-face-attribute'."
  (cond
   ((framep frame) frame)
   (frame nil)
   (t 0)))

(defun fontaine--set-face-attributes (face family &optional weight height frame)
  "Set FACE font to FAMILY, with optional HEIGHT, WEIGHT, FRAME."
  (let ((family (or family "Monospace"))
        (height (or height (if (eq face 'default) 100 1.0)))
        (weight (or weight 'normal))
        (frames (fontaine--frame frame)))
    ;; ;; Read this: <https://debbugs.gnu.org/cgi/bugreport.cgi?bug=45920>
    ;; ;; Hence why the following fails.  Keeping it for posterity...
    ;; (set-face-attribute face nil :family family :weight weight :height height)
    (if (eq (face-attribute face :weight) weight)
        (internal-set-lisp-face-attribute face :family family frames)
      (internal-set-lisp-face-attribute face :weight weight frames)
      (internal-set-lisp-face-attribute face :family family frames)
      (internal-set-lisp-face-attribute face :weight weight frames))
    (internal-set-lisp-face-attribute face :height height frames)))

(defun fontaine--set-italic-slant (family slant &optional frame)
  "Set FAMILY and SLANT of `italic' face on optional FRAME."
  (let ((slant (or slant 'italic))
        (family (or family 'unspecified))
        (frames (fontaine--frame frame)))
    (if (eq (face-attribute 'italic :slant) slant)
        (internal-set-lisp-face-attribute 'italic :family family frames)
      (internal-set-lisp-face-attribute 'italic :slant slant frames)
      (internal-set-lisp-face-attribute 'italic :family family frames)
      (internal-set-lisp-face-attribute 'italic :slant slant frames))))

;;;; Apply preset configurations

(defun fontaine--preset-p (preset)
  "Return non-nil if PRESET is one of the named `fontaine-presets'."
  (let ((presets (delq t (mapcar #'car fontaine-presets))))
    (memq preset presets)))

(defun fontaine--get-inherit-name (preset)
  "Get the `:inherit' value of PRESET."
  (when-let* ((inherit (plist-get (alist-get preset fontaine-presets) :inherit))
              (fontaine--preset-p inherit))
    inherit))

(defun fontaine--get-preset-properties (preset)
  "Return list of properties for PRESET in `fontaine-presets'."
  (let ((presets fontaine-presets))
    (append (alist-get preset presets)
            (when-let ((inherit (fontaine--get-inherit-name preset)))
              (alist-get inherit presets))
            (alist-get t presets))))

(defmacro fontaine--apply-preset (fn doc args)
  "Produce function to apply preset.
FN is the symbol of the function, DOC is its documentation, and
ARGS are its routines."
  `(defun ,fn (preset &optional frame)
     ,doc
     (if-let ((properties (fontaine--get-preset-properties preset)))
         ,args
       ;; FIXME 2022-09-07: Because we `append' the t of
       ;; `fontaine-presets' this error is only relevant when the list
       ;; is empty.  Perhaps we can harden the condition.  Otherwise we
       ;; should reword this.
       (user-error "%s is not in `fontaine-presets' or is empty" preset))))

(fontaine--apply-preset
 fontaine--apply-default-preset
 "Set `default' face attributes based on PRESET for optional FRAME."
 (progn
   (fontaine--set-face-attributes
    'default
    (plist-get properties :default-family)
    (plist-get properties :default-weight)
    (plist-get properties :default-height)
    frame)
   (setq-default line-spacing (plist-get properties :line-spacing))))

(fontaine--apply-preset
 fontaine--apply-fixed-pitch-preset
 "Set `fixed-pitch' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'fixed-pitch
  (or (plist-get properties :fixed-pitch-family) (plist-get properties :default-family))
  (or (plist-get properties :fixed-pitch-weight) (plist-get properties :default-weight))
  (or (plist-get properties :fixed-pitch-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-fixed-pitch-serif-preset
 "Set `fixed-pitch-serif' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'fixed-pitch-serif
  (or (plist-get properties :fixed-pitch-family) (plist-get properties :default-family))
  (or (plist-get properties :fixed-pitch-weight) (plist-get properties :default-weight))
  (or (plist-get properties :fixed-pitch-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-variable-pitch-preset
 "Set `variable-pitch' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'variable-pitch
  (or (plist-get properties :variable-pitch-family) (plist-get properties :default-family))
  (or (plist-get properties :variable-pitch-weight) (plist-get properties :default-weight))
  (or (plist-get properties :variable-pitch-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-mode-line-preset
 "Set `mode-line' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'mode-line
  (or (plist-get properties :mode-line-family) (plist-get properties :default-family))
  (or (plist-get properties :mode-line-weight) (plist-get properties :default-weight))
  (or (plist-get properties :mode-line-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-mode-line-active-preset
 "Set `mode-line-active' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'mode-line-active
  (or (plist-get properties :mode-line-active-family) (plist-get properties :default-family))
  (or (plist-get properties :mode-line-active-weight) (plist-get properties :default-weight))
  (or (plist-get properties :mode-line-active-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-mode-line-inactive-preset
 "Set `mode-line-inactive' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'mode-line-inactive
  (or (plist-get properties :mode-line-inactive-family) (plist-get properties :default-family))
  (or (plist-get properties :mode-line-inactive-weight) (plist-get properties :default-weight))
  (or (plist-get properties :mode-line-inactive-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-header-line-preset
 "Set `header-line' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'header-line
  (or (plist-get properties :header-line-family) (plist-get properties :default-family))
  (or (plist-get properties :header-line-weight) (plist-get properties :default-weight))
  (or (plist-get properties :header-line-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-line-number-preset
 "Set `line-number' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'line-number
  (or (plist-get properties :line-number-family) (plist-get properties :default-family))
  (or (plist-get properties :line-number-weight) (plist-get properties :default-weight))
  (or (plist-get properties :line-number-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-tab-bar-preset
 "Set `tab-bar' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'tab-bar
  (or (plist-get properties :tab-bar-family) (plist-get properties :default-family))
  (or (plist-get properties :tab-bar-weight) (plist-get properties :default-weight))
  (or (plist-get properties :tab-bar-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-tab-line-preset
 "Set `tab-line' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'tab-line
  (or (plist-get properties :tab-line-family) (plist-get properties :default-family))
  (or (plist-get properties :tab-line-weight) (plist-get properties :default-weight))
  (or (plist-get properties :tab-line-height) 1.0)
  frame))

(fontaine--apply-preset
 fontaine--apply-bold-preset
 "Set `bold' face attributes based on PRESET for optional FRAME."
 (fontaine--set-face-attributes
  'bold
  (or (plist-get properties :bold-family) 'unspecified)
  (or (plist-get properties :bold-weight) 'bold)
  'unspecified
  frame))

(fontaine--apply-preset
 fontaine--apply-italic-preset
 "Set `italic' face attributes based on PRESET for optional FRAME."
 (fontaine--set-italic-slant
  (or (plist-get properties :italic-family) 'unspecified)
  (or (plist-get properties :italic-slant) 'italic)
  frame))

(defvar fontaine--font-display-hist '()
  "History of inputs for display-related font associations.")

(defun fontaine--presets-no-fallback ()
  "Return list of `fontaine-presets', minus the fallback value."
  (delete
   nil
   (mapcar (lambda (symbol)
             (unless (eq (car symbol) t)
               symbol))
           fontaine-presets)))

(defun fontaine--set-fonts-prompt ()
  "Prompt for font set (used by `fontaine-set-fonts')."
  (let* ((def (nth 1 fontaine--font-display-hist))
         (prompt (if def
                     (format "Apply font configurations from PRESET [%s]: " def)
                   "Apply font configurations from PRESET: ")))
    (intern
     (completing-read
      prompt
      (fontaine--presets-no-fallback)
      nil t nil 'fontaine--font-display-hist def))))

(defvar fontaine-current-preset nil
  "Current font set in `fontaine-presets'.
This is the preset last used by `fontaine-set-preset'.  Also see
the command `fontaine-apply-current-preset'.")

;;;###autoload
(defun fontaine-set-preset (preset &optional frame)
  "Set font configurations specified in PRESET.
PRESET is a symbol that represents the car of a list in
`fontaine-presets'.  If there is only one available, apply it
outright, else prompt with completion.

Unless optional FRAME argument is supplied, apply the change to
all frames.  If FRAME satisfies `framep', then make the changes
affect only it.  If FRAME is non-nil, interpret it as the current
frame and apply the effects to it.

When called interactively with a universal prefix
argument (\\[universal-argument]), FRAME is interpreted as
non-nil.

Set `fontaine-current-preset' to PRESET.  Also see the command
`fontaine-apply-current-preset'.

Call `fontaine-set-preset-hook' as a final step."
  (interactive
   (list
    (if (= (length fontaine-presets) 1)
        (caar fontaine-presets)
      (fontaine--set-fonts-prompt))
    current-prefix-arg))
  (if (and (not (daemonp)) (not window-system))
      (user-error "Cannot use this in a terminal emulator; try the Emacs GUI")
    (fontaine--apply-default-preset preset frame)
    (fontaine--apply-fixed-pitch-preset preset frame)
    (fontaine--apply-fixed-pitch-serif-preset preset frame)
    (fontaine--apply-variable-pitch-preset preset frame)
    (fontaine--apply-mode-line-active-preset preset frame)
    (fontaine--apply-mode-line-inactive-preset preset frame)
    (fontaine--apply-header-line-preset preset frame)
    (fontaine--apply-line-number-preset preset frame)
    (fontaine--apply-tab-bar-preset preset frame)
    (fontaine--apply-tab-line-preset preset frame)
    (fontaine--apply-bold-preset preset frame)
    (fontaine--apply-italic-preset preset frame)
    (setq fontaine-current-preset preset)
    (unless frame
      (add-to-history 'fontaine--preset-history (format "%s" preset)))
    (run-hooks 'fontaine-set-preset-hook)))

;;;###autoload
(defun fontaine-apply-current-preset (&optional _theme)
  "Use `fontaine-set-preset' on `fontaine-current-preset'.
The value of `fontaine-current-preset' must be one of the keys in
`fontaine-presets'.

Re-applying the current preset is useful when a new theme is
loaded which overrides certain font families.  For example, if
the theme defines the `bold' face without a `:family', loading
that theme will make `bold' use the `default' family, even if the
`fontaine-presets' are configured to have different families
between the two.  In such a case, applying the current preset at
the post `load-theme' phase (e.g. via a hook) ensures that font
configurations remain consistent.

Some themes that provide hooks of this sort are the
`modus-themes', `ef-themes', `standard-themes' (all by
Protesilaos).  Alternatively, Emacs 29 provides the special
`enable-theme-functions' hook, which passes the THEME argument
for this function."
  (interactive)
  (when-let* ((current fontaine-current-preset)
              ((alist-get current fontaine-presets)))
    (fontaine-set-preset current)))

;;;; Modify individual faces

(defconst fontaine--font-faces
  '(default fixed-pitch fixed-pitch-serif variable-pitch bold italic)
  "List of faces whose typographic attributes we may change.")

(defconst fontaine--font-weights
  '( normal regular thin ultralight extralight light semilight
     medium semibold bold extrabold ultrabold)
  "List of font weights.")

(defconst fontaine--font-slants
  '( normal oblique italic reverse-oblique reverse-italic)
  "List of font slants.")

(defvar fontaine--face-history '()
  "Minibuffer history of `fontaine-set-face-font'.")

(defvar fontaine--default-font-family-history '()
  "Minibuffer history of selected `default' font families.")

;; We have `font-family-list', which is unfiltered.
(defun fontaine--family-list-fixed-pitch (&optional frame)
  "Return a list of available monospaced font families.
Target FRAME, if provided as an optional argument."
  (seq-uniq
   (seq-map
    (lambda (fam)
      (symbol-name (aref fam 0)))
    (seq-filter
     (lambda (fam)
       (aref fam 5))
     ;; NOTE 2022-04-26: `x-family-fonts' and `x-list-fonts' accept a
     ;; pattern, but I cannot find how to use it properly to filter out
     ;; certain families.
     (x-family-fonts nil frame)))))

;; NOTE 2022-04-29: This is known to not work on Windows, except for
;; Emacs 29.  Read:
;; <https://lists.gnu.org/archive/html/emacs-devel/2022-04/msg01281.html>.
(defun fontaine--family-list-variable-pitch (&optional frame)
  "Return a list of available proportionately spaced font families.
Target FRAME, if provided as an optional argument."
  (seq-uniq
   (seq-map
    (lambda (fam)
      (symbol-name (aref fam 0)))
    (seq-filter
     (lambda (fam)
       (null (aref fam 5)))
     (x-family-fonts nil frame)))))

(defvar fontaine--natnum-history '()
  "Minibuffer history for natural numbers.")

(defun fontaine--set-default (&optional frame)
  "Set `default' attributes, optionally for FRAME."
  (let* ((families (or (alist-get 'default fontaine-font-families)
                       (append (alist-get 'fixed-pitch fontaine-font-families)
                               (alist-get 'variable-pitch fontaine-font-families))
                       (font-family-list)))
         (family (completing-read "Font family of `default': "
                                  families nil t
                                  nil 'fontaine--default-font-family-history))
         (weight (intern (completing-read "Select weight for `default': "
                                          fontaine--font-weights nil)))
         (height (read-number "Height of `default' face (must be a natural number): "
                              (and fontaine--natnum-history
                                   (string-to-number (nth 0 fontaine--natnum-history)))
                              'fontaine--natnum-history)))
    (if (natnump height)
        (fontaine--set-face-attributes 'default family weight height frame)
      (user-error "Height of `default' face must be a natural number"))))

(defvar fontaine--float-history '()
  "Minibuffer history for floating point numbers.")

(defvar fontaine--fixed-pitch-font-family-history '()
  "Minibuffer history of selected `fixed-pitch' font families.")

(defun fontaine--set-fixed-pitch (&optional frame serif)
  "Set `fixed-pitch' attributes, optionally for FRAME.
If optional SERIF is non-nil, operate on the `fixed-pitch-serif'
face."
  (let* ((families (or (alist-get 'fixed-pitch fontaine-font-families)
                       (fontaine--family-list-fixed-pitch)))
         (family (completing-read "Font family of `fixed-pitch': "
                                  families nil t nil
                                  'fontaine--fixed-pitch-font-family-history))
         (weight (intern (completing-read "Select weight for `fixed-pitch': "
                                          fontaine--font-weights nil)))
         (height (read-number "Height of `fixed-pitch' face (must be a floating point): "
                              1.0 'fontaine--float-history))
         (face (if serif 'fixed-pitch-serif 'fixed-pitch)))
    (if (floatp height)
        (fontaine--set-face-attributes face family weight height frame)
      (user-error "Height of `fixed-pitch' face must be a floating point"))))

(defvar fontaine--variable-pitch-font-family-history '()
  "Minibuffer history of selected `variable-pitch' font families.")

(defun fontaine--set-variable-pitch (&optional frame)
  "Set `variable-pitch' attributes, optionally for FRAME."
  (let* ((families (or (alist-get 'variable-pitch fontaine-font-families)
                       (fontaine--family-list-variable-pitch)))
         (family (completing-read "Font family of `variable-pitch': "
                                  families nil t nil
                                  'fontaine--variable-pitch-font-family-history))
         (weight (intern (completing-read "Select weight for `variable-pitch': "
                                          fontaine--font-weights nil)))
         (height (read-number "Height of `variable-pitch' face (must be a floating point): "
                              1.0 'fontaine--float-history)))
    (if (floatp height)
        (fontaine--set-face-attributes 'variable-pitch family weight height frame)
      (user-error "Height of `variable-pitch' face must be a floating point"))))

(defun fontaine--set-bold (&optional frame)
  "Set `bold' attributes, optionally for FRAME."
  (let ((weight (intern (completing-read "Select weight for `bold': "
                                         fontaine--font-weights nil t))))
    (fontaine--set-face-attributes 'bold 'unspecified weight 'unspecified frame)))

(defun fontaine--set-italic (&optional frame)
  "Set `italic' attributes, optionally for FRAME."
  (let ((slant (intern (completing-read "Select slant for `italic': "
                                        fontaine--font-slants nil t))))
    (fontaine--set-italic-slant 'unspecified slant frame)))

;;;###autoload
(defun fontaine-set-face-font (face &optional frame)
  "Set font and/or other attributes of FACE.

When called interactively, prompt for FACE and then continue
prompting for the relevant face attributes each of which depends
on the FACE (for example, the `default' FACE accepts a family, a
height as a natural number, and a weight, whereas `bold' only
accepts a weight).

With regard to the font family that some faces accept, the
candidates are those specified in the user option
`fontaine-font-families'.  If none are specified, try to find
relevant installed fonts and provide them as completion
candidates.

Note that changing the `bold' and `italic' faces only has a
noticeable effect if the underlying does not hardcode a weight
and slant but inherits from those faces instead (e.g. the
`modus-themes').

When called from Lisp (albeit discouraged), if FACE is not part
of `fontaine--font-faces', fall back to interactively calling
`fontaine-set-preset'.

Unless optional FRAME argument is supplied, apply the change to
all frames.  If FRAME satisfies `framep', then make the changes
affect only it.  If FRAME is non-nil, interpret it as the current
frame and apply the effects to it.

When called interactively with a universal prefix
argument (\\[universal-argument]), FRAME is interpreted as
non-nil."
  (declare (interactive-only t))
  (interactive
   (list
    (intern
     (completing-read "Which face to change? "
                      fontaine--font-faces nil t nil
                      'fontaine--face-history))
    current-prefix-arg))
  (pcase face
    ('bold (fontaine--set-bold frame))
    ('default (fontaine--set-default frame))
    ('fixed-pitch (fontaine--set-fixed-pitch frame))
    ('fixed-pitch-serif (fontaine--set-fixed-pitch frame :serif))
    ('italic (fontaine--set-italic frame))
    ('variable-pitch (fontaine--set-variable-pitch frame))
    (_ (call-interactively #'fontaine-set-preset))))

;;;; Store and restore preset

(defvar fontaine--preset-history '()
  "Minibuffer history of preset configurations.")

;;;###autoload
(defun fontaine-store-latest-preset ()
  "Write latest cursor state to `fontaine-latest-state-file'.
Can be assigned to `kill-emacs-hook'."
  (when-let ((hist fontaine--preset-history))
    (with-temp-file fontaine-latest-state-file
      (insert ";; Auto-generated file; don't edit -*- mode: "
              (if (<= 28 emacs-major-version)
                  "lisp-data"
                "emacs-lisp")
              " -*-\n")
      (pp (intern (car hist)) (current-buffer)))))

(defvar fontaine-recovered-preset nil
  "Recovered value of latest store cursor preset.")

;;;###autoload
(defun fontaine-restore-latest-preset ()
  "Restore latest preset set by `fontaine-set-preset'.
The value is stored in `fontaine-latest-state-file'."
  (when-let* ((file fontaine-latest-state-file)
              ((file-exists-p file)))
    (setq fontaine-recovered-preset
          (unless (zerop
                   (or (file-attribute-size (file-attributes file))
                       0))
            (with-temp-buffer
              (insert-file-contents file)
              (read (current-buffer)))))))

(provide 'fontaine)
;;; fontaine.el ends here
