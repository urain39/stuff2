(defun my-min (x y)
	(if (< x y) x y))

(defun min-one (x y z)
	(my-min (my-min x y) z))

(defun max-sum (x y z)
	(let ((min_ (min-one x y z)))
		(cond
			((= x min_) (+ y z))
			((= y min_) (+ x z))
			((= z min_) (+ x y))
		)
	))

(max-sum 1 6 3)
