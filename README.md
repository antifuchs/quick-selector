# quick-selector - slime's selector without slime

This is a super quick and dirty hack: I wanted the slime-selector
hotkey, but I didn't want to load SLIME everytime. So, I ripped it out
and made it sliiightly more accessible (and ported it over to dash,
because apparently loading `'cl` is no longer a thing emacs packages
do).

## Requirements

Emacs 24. For some reason, this requires lexical scoping (patches that
make it less horrible are welcome!)

## Usage

``` emacs-lisp
(require 'quick-selector)
(define-key global-map (kbd "<M-kp-enter>") 'quick-selector)
```

(Any contributions that make this a packagable thing are welcome (:
