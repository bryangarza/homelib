#lang rkt

(require (file "./app.rkt"))

(send frame show #t)
(delete-frame-children)

(define isbn-teardown (isbn-setup frame))
(isbn-teardown)

(send outer-panel show #t)

(send inner-panel set-alignment 'center 'bottom)

(define msg (new message%
                 [parent isbn-dialog]
                 [label "Look up book by ISBN"]))

(send isbn-field show #f)

(define lookup-btn
  (new button%
       [parent frame]
       [label "Lookup"]
       [callback (λ (button event)
                   (send lookup-btn show #f))]))

(send msg show #f)

(send frame show #t)
(send frame delete-child lookup-btn)

(new message%
     [parent frame]
     [label (cadar (isbn-lookup "0521663504"))])

(isbn-lookup "0521663504")(book "Purely functional data structures" ("Chris Okasaki") 1999 ("Cambridge University Press") ("Functional programming languages" "Data structures (Computer science)"))
(isbn-lookup "0700604553")

(book? (book "Splitting the difference" ("Martin Benjamin") 1990 ("University Press of Kansas") ("Compromise (Ethics)" Ethics Integrity)))

'((title "Purely functional data structures")
  (authors ("Chris Okasaki"))
  (pubdate 1999)
  (publishers ("Cambridge University Press"))
  (subjects ("Functional programming languages" "Data structures (Computer science)")))
