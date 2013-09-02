;;;; baseball-bet.lisp

;;;; on 2013-08-31 in http://sports.yahoo.com/mlb/standings/ the wins
;;;; and losses for a team follow a string that only occurs once on
;;;; the page, "/mlb/teams/XXX", where XXX is a 3-letter abbreviation,
;;;; e.g., "bos" for the Boston Red Sox, so this tells where to start
;;;; scannning for "Wins" and "Losses".

(in-package #:baseball-bet)

(defun scan-start (str string-to-scan)
  "Return the end position of a string within a larger one."
  (multiple-value-bind (start end)
      (cl-ppcre:scan str string-to-scan)
    (declare (ignore start))
    end))

(defun wins-or-losses (regex string-to-scan start)
  "Return the number of wins/losses in a string, starting at a location."
  (multiple-value-bind (entire-match captures)
      (cl-ppcre:scan-to-strings regex string-to-scan :start start)
    (declare (ignore entire-match))
    (parse-integer (aref captures 0))))

(defun show-spread ()
  "Get the standings and do the arithmetic."
  (let* ((raw-standings (drakma:http-request "http://sports.yahoo.com/mlb/standings/"))
	 (wins-regex '(:SEQUENCE "\"Wins\">"
		       (:REGISTER (:GREEDY-REPETITION 1 NIL :DIGIT-CLASS)) #\<))
	 (losses-regex '(:SEQUENCE "\"Losses\">"
			 (:REGISTER (:GREEDY-REPETITION 1 NIL :DIGIT-CLASS)) #\<))
	 (bos "/mlb/teams/bos")
	 (stl "/mlb/teams/stl")
	 (rd-al-wins (wins-or-losses wins-regex raw-standings
				     (scan-start bos raw-standings)))
	 (rd-al-losses (wins-or-losses losses-regex raw-standings
				       (scan-start bos raw-standings)))
	 (rd-nl-wins (wins-or-losses wins-regex raw-standings
				     (scan-start stl raw-standings)))
	 (rd-nl-losses (wins-or-losses losses-regex raw-standings
				       (scan-start stl raw-standings)))
	 (rd-ws (+ rd-al-wins rd-nl-wins))
	 (rd-ls (+ rd-al-losses rd-nl-losses))
	 (det "/mlb/teams/det")
	 (atl "/mlb/teams/atl")
	 (se-al-wins (wins-or-losses wins-regex raw-standings
				     (scan-start det raw-standings)))
	 (se-al-losses (wins-or-losses losses-regex raw-standings
				       (scan-start det raw-standings)))
	 (se-nl-wins (wins-or-losses wins-regex raw-standings
				     (scan-start atl raw-standings)))
	 (se-nl-losses (wins-or-losses losses-regex raw-standings
				       (scan-start atl raw-standings)))
	 (se-ws (+ se-al-wins se-nl-wins))
	 (se-ls (+ se-al-losses se-nl-losses)))
    (multiple-value-bind (sec min hour date month year day) (get-decoded-time)
      (format t "~a ~4d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~%"
	      (aref #("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun") day)
	      year month date hour min sec))
    (format t "RD's total wins   = ~d~%" rd-ws)
    (format t "SE's total wins   = ~d~%" se-ws)
    (format t "RD's total losses = ~d~%" rd-ls)
    (format t "SE's total losses = ~d~%" se-ls)
    (+ (/ (- se-ws rd-ws) 2.0)
       (/ (- rd-ls se-ls) 2.0))))
