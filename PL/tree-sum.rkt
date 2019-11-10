#lang racket
(define tree-sum
  (lambda (exp)
    (match exp
      [(? number? x) x]
      [`(,el, e2)
       (let ([v1 (tree-sum el)]
             [v2 (tree-sum e2)])
         (+ v1 v2))])))


(tree-sum `(1 2))
(tree-sum `(1 (2 3)))
