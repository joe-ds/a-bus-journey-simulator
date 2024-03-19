;;;; +_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_
;;;;
;;;; A Bus Journey Simulator
;;;;
;;;; Author:  Joe Peterson
;;;;    URL:  gitlab.com/l3mu
;;;; License: GNU GPL v3
;;;;
;;;;   Usage: (journey stops seats)
;;;;          Note: seats must be even!
;;;;          (journey 10 30) is what I used.
;;;;
;;;; Description:
;;;;   This is a whimsical simulator of the way in which I saw that I and other
;;;;   passengers on buses take our seats. We follow a two-step process:
;;;;     1) If there are whole seats with no one in them, sit there.
;;;;     2) If there aren't, sit next to someone.
;;;;   And that's what I tried to simulate. It may be a general rule, or it
;;;;   might be a quirk of riding buses in just this city, but I thought it was
;;;;   a bit amusing.
;;;;   Note that no more than nine passengers get on the bus at any one stop in
;;;;   this simulation.
;;;;
;;;;   Tested in GNU CLISP 2.49.93+ running on Fedora 29 64-bit.
;;;;
;;;; +_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_

;;; random looks for its state in *random-state* by default.

(defparameter *random-state*
  (make-random-state t))

(defun new-passenger (stops)
  "Creates a passenger with a random number of stops under stops."
  (list :stops (random stops)))

;;; Unlike the above, this function creates a passenger with a determined
;;; number of stops.

(defun make-passenger (stops)
  "Creates a passenger with :stops set to stops."
  (list :stops stops))

(defun sit (passenger seat seats)
  "Seats a passenger in the chosen seat."
  (setf (nth seat seats) passenger))

;;; Helper for find-seats

(defun is-empty (seat seats)
  "Helper. Returns T if the seat is empty, NIL otherwise."
  (null (nth seat seats)))

;;; This *can* be optimised, but I created it to be approximately like how a
;;; person goes about looking for a seat.

(defun find-seat (seats)
  "Simulates looking for a seat. First looks for empty seats, and then for
   one next to a passenger."
  (let ((no-of-seats (list-length seats)))
    (block look-around
	   (loop for i from 1 to no-of-seats by 2
		 do (if (and
			 (is-empty i seats)
			 (is-empty (1- i) seats))
			(return-from look-around (1- i))))
	   (dotimes (seat no-of-seats)
	     (if (is-empty seat seats)
		 (return-from look-around seat))))))

(defun board (passenger seats)
  "Combines find-seat and sit to allow a passenger to board the bus."
  (let ((seat (find-seat seats)))
    (if seat (sit passenger seat seats))))

;;; At each stop, the people whose stop it is get off, and the others have one
;;; less stop to their destination.

(defun pulse (seats)
  "Removes passengers with :stops equal to zero. Reduces :stops for all other
   passengers."
  (let ((no-of-seats (list-length seats)))
    (loop for i from 0 to no-of-seats unless (null (nth i seats))
	  do (let ((stops (getf (nth i seats) :stops)))
	       (if (> stops 0)
		   (setf (nth i seats) (make-passenger (1- stops)))
		 (setf (nth i seats) ()))))))

;;; Helper to prettily print our seats. Occupied seats show [o] and
;;; unoccupied seats [ ].

(defun show-seats (seats)
  "Prettily prints out seats."
  (let ((output (map 'list
		     #'(lambda (x) (if (null x) (string "[ ]")
				     (string "[o]")))
		     seats)))
    (format t "~{~a~a~%~}~%" output)))

;;; The main function.

(defun journey (stops seats)
  "The main function. Simulates a journey of stops stops on a bus with seats
   seats."
  (let ((seats (make-list seats :initial-element ())))
    (dotimes (passed stops)
      (progn
	(format t "STOP #~a~2%" passed)
	(pulse seats)
	(dotimes (n (random 10))        ; No more than nine get on at a stop.
	  (board (new-passenger (- stops passed)) seats))
	(show-seats seats)))
    (format t "STOP #~a~2%" stops)
    (pulse seats)
    (show-seats seats)))
