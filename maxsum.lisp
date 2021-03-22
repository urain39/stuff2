(defun my-max (x y)
	(if (> x y) x y))

(defun max-one (x y z)
	(my-max (my-max x y) z))

(defun max-second (x y z)
	(let ((max (max-one x y z)))
		(cond
			((= x max) (my-max y z))
			((= y max) (my-max x z))
			((= z max) (my-max x y))
		)
	))

(defun my-sum (x y z)
	(+ (max-one x y z) (max-second x y z)))

(my-sum 1 6 3)
