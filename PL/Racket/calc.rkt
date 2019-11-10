#lang racket

(define calc
  (lambda (exp)
    (match exp
      [(? number? x) x]
      [`(,op, e1, e2)
       (let ([v1 (calc e1)]
             [v2 (calc e2)])
         (match op
           [`+ (+ v1 v2)]
           [`- (- v1 v2)]
           [`* (* v1 v2)]
           [`/ (/ v1 v2)]))])))

(calc `(+ 1 2))
(calc `(* (+ 1 2)(+ 3 4)))
