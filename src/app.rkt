#lang racket

(require racket/gui/base)
(require racket/match)

(define homelib-version "0.1")
(define homelib-name "Home Library")
(define homelib-title (string-join (list homelib-name homelib-version)))

(define frame (new frame% [label homelib-title]))

(define (delete-frame-children)
  (map (λ (child) (send frame delete-child child)) (send frame get-children)))

(struct book (title authors pubdate publishers subjects))

(define (isbn-lookup isbn)
  (let* ([hl "~/code/ocaml/homelib/homelib.native"]
         [cmd (string-join (list hl isbn))]
         [aux (with-output-to-string (λ () (system cmd)))]
         [sp (open-input-string aux)] ; string port
         [res (read sp)]
         [data (map (lambda (x) (cadr x)) res)])
    `(book ,@data)))

'((title "Purely functional data structures")
  (authors ("Chris Okasaki"))
  (pubdate 1999)
  (publishers ("Cambridge University Press"))
  (subjects ("Functional programming languages" "Data structures (Computer science)")))

(define (isbn-setup p)
  (define (create-outer-panel msg)
    (define outer-panel%
      (class panel%
        (define/override (on-subwindow-char r e)
          (let ((keycode (send e get-key-code)))
            (match keycode
              ['#\return (let* ([isbn-text (send isbn-field get-value)]
                                [book-info "Ok"])
                           (delete-frame-children)
                           (new message%
                                [parent p]
                                [label (cadar (isbn-lookup isbn-text))]))]
              [_ #f])))
        (super-new [parent p])))
    (new outer-panel%))
  (define msg (new message%
                   [parent p]
                   [label "Look up book by ISBN"]))
  (define outer-panel (create-outer-panel msg))
  (define isbn-field
    (new text-field%
         [parent outer-panel]
         [label "ISBN"]
         [callback (λ (type event)
                     (send msg set-label (send isbn-field get-value)))]))
  (define inner-panel (new horizontal-panel%
                           [parent outer-panel]
                           [alignment '(center bottom)]))
  (define cancel-button (new button% [parent inner-panel] [label "Cancel"]))
  (define ok-button (new button% [parent inner-panel] [label "Ok"]))
  (λ ()
    (send p delete-child msg)
    (send p delete-child outer-panel)))
