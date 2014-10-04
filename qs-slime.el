;;;; SLIME-specific selectors

(eval-after-load 'slime
  '(progn 
     (def-quick-selector-method ?i
       "*inferior-lisp* buffer."
       (cond ((and (slime-connected-p) (slime-process))
	      (process-buffer (slime-process)))
	     (t
	      "*inferior-lisp*")))

     (def-quick-selector-method ?v
       "*slime-events* buffer."
       slime-event-buffer-name)

     (def-quick-selector-method ?c
       "SLIME connections buffer."
       (slime-list-connections)
       slime-connections-buffer-name)

     (def-quick-selector-method ?n
       "Cycle to the next Lisp connection."
       (slime-cycle-connections)
       (concat "*slime-repl "
	       (slime-connection-name (slime-current-connection))
	       "*"))

     (def-quick-selector-method ?t
       "SLIME threads buffer."
       (slime-list-threads)
       slime-threads-buffer-name)

     (def-quick-selector-method ?d
       "*sldb* buffer for the current connection."
       (or (sldb-get-default-buffer)
	   (error "No debugger buffer")))))

(provide 'qs-slime)
