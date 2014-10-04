;;; -*- lexical-binding: t -*-
;;;; Quick Selector - mostly copied from slime.el's slime-selector

(require 'dash)
(require 'dash-functional)

(defvar quick-selector-methods nil
  "List of buffer-selection methods for the `slime-select' command.
Each element is a list (KEY DESCRIPTION FUNCTION).
DESCRIPTION is a one-line description of what the key selects.")

(defvar quick-selector-other-window nil
  "If non-nil use switch-to-buffer-other-window.")

(defcustom quick-selector-mode-keys
  '((?l . lisp-mode)
    (?e . emacs-lisp-mode)
    (?u . ruby-mode)
    (?j . js-mode))
  "List of modes that quick-selector-mode sets up jump keys for.

Each entry has the form (CHAR . MODE)."
  :type '(alist :value-type symbol :key-type character))

(defun quick-selector (&optional other-window)
  "Select a new buffer by type, indicated by a single character.
The user is prompted for a single character indicating the method by
which to choose a new buffer. The `?' character describes the
available methods.

See `def-quick-selector-method' for defining new methods."
  (interactive)
  (message "Select [%s]: "
           (apply #'string (mapcar #'car quick-selector-methods)))
  (let* ((quick-selector-other-window other-window)
         (ch (save-window-excursion
               (select-window (minibuffer-window))
               (read-char)))
         (method (assoc ch quick-selector-methods)))
    (cond (method
           (funcall (nth 2 method)))
          (t
           (message "No method for character: ?\\%c" ch)
           (ding)
           (sleep-for 1)
           (discard-input)
           (quick-selector)))))

(defmacro def-quick-selector-method (key description &rest body)
  "Define a new `slime-select' buffer selection method.

KEY is the key the user will enter to choose this method.

DESCRIPTION is a one-line sentence describing how the method
selects a buffer.

BODY is a series of forms which are evaluated when the selector
is chosen. The returned buffer (if non-nil) is selected with
switch-to-buffer."
  (let ((method `(lambda ()
                   (let ((buffer (progn ,@body)))
                     (cond ((not buffer)
                            nil)
                           ((not (get-buffer buffer))
                            (message "No such buffer: %S" buffer)
                            (ding))
                           ((get-buffer-window buffer)
                            (select-window (get-buffer-window buffer)))
                           (quick-selector-other-window
                            (switch-to-buffer-other-window buffer))
                           (t
                            (switch-to-buffer buffer)))))))
    `(setq quick-selector-methods
           (-sort (-on '< 'car)
                  (cons (list ,key ,description ,method)
                        (-remove (-compose (-partial '= ,key) 'car) quick-selector-methods))))))

(def-quick-selector-method ?? "Selector help buffer."
  (ignore-errors (kill-buffer "*Select Help*"))
  (with-current-buffer (get-buffer-create "*Select Help*")
    (insert "Select Methods:\n\n")
    (dolist (entry quick-selector-methods)
      (insert (format "%c:\t%s\n" (car entry) (cadr entry))))
    (goto-char (point-min))
    (help-mode)
    (display-buffer (current-buffer) t))
  (quick-selector)
  (current-buffer))

(add-to-list 'quick-selector-methods
             (list ?4 "Select in other window" (lambda () (quick-selector t)))
             nil
             (-on '= 'car))

(def-quick-selector-method ?q "Abort."
  (top-level))

(dolist (key-mode-spec quick-selector-mode-keys)
  (let ((key (car key-mode-spec))
        (mode (cdr key-mode-spec)))
   (def-quick-selector-method key
     (format "most recently visited %s buffer." mode)
     (qs--recently-visited-buffer mode))))

(defun qs--recently-visited-buffer (mode)
  "Return the most recently visited buffer whose major-mode is MODE.
Only considers buffers that are not already visible."
  (or (-first (lambda (buffer)
                (and (with-current-buffer buffer (eq major-mode mode))
                     (not (string-match "^ " (buffer-name buffer)))
                     (null (get-buffer-window buffer 'visible))))
              (buffer-list))
      (error "Can't find unshown buffer in %S" mode)))

(require 'qs-slime)
(provide 'quick-selector)
