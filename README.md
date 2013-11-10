[![Build Status](https://travis-ci.org/m22spencer/heat.png)](https://travis-ci.org/m22spencer/heat)

#heat (Haxe Editor AssistanT)



## Sample flycheck elisp
```
(require 'flycheck)

(setq flycheck-haxe-server nil)
(setq flycheck-haxe-hxml nil)
(setq flycheck-haxe-openfl nil)

(flycheck-define-checker haxe
  "A haxe compiler check on the current file"
  :command ("haxelib" "run" "heat"
            "--remap" source-original source
            "--syntax-check"
            "--target-hx" source-original
            (option "--project-file" flycheck-haxe-hxml))

  :error-patterns
  ((warning line-start (file-name) ":" line ": "
            (or "lines" "characters") " " (one-or-more digit) "-" (one-or-more digit)
            " : Warning : " (message) line-end)
   (error line-start (file-name) ":" line ": "
            (or "lines" "characters") " " (one-or-more digit) "-" (one-or-more digit)
            " : " (message) line-end))

  :modes 'haxe-mode)

(defun setup-flycheck-haxe-compile
  (add-to-list 'flycheck-checkers 'haxe))

(provide 'flycheck-haxe-compile)
```