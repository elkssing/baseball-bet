;;;; baseball-bet.asd

(asdf:defsystem #:baseball-bet
  :serial t
  :description "Scrape MLB standings from Yahoo! and figure out whether RD or SE is up."
  :author "Steve Elkins <sgelkins@gmail.com>"
  :license "MIT"
  :depends-on (#:drakma
               #:cl-ppcre)
  :components ((:file "package")
               (:file "baseball-bet")))
