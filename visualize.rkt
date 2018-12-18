#lang racket
(require "poly-matrix.rkt")
(require plot/pict)
(require db)
(require "data.rkt")
(require "plot.rkt")

(define (s-curve-data start end)
  (define *db*
    (sqlite3-connect #:database
                     "data/ohcl-2018-08-22-00:17:13.sqlite"))
  (date-range *db*
              start
              end))

(define (extract data)
  (values (map (lambda (v)(vector-ref v 0)) data)
          (map (lambda (v)(vector-ref v 1)) data)))


(define (plot-it)
  (plot-with-x-as-time (s-curve-data '(0 50 18 21 8 2018)
                                     '(0 20 20 21 8 2018))))

(define top-of-s (s-curve-data '(0 50 18 21 8 2018)
                               '(0 20 20 21 8 2018)))

(define (new-plot)
  (parameterize ([plot-x-ticks (time-ticks)])
    (plot (list (points top-of-s)
                (function (fitf top-of-s))))))



(define (plot-top-of-s)
  (let*-values ([(data) (s-curve-data '(0 50 18 21 8 2018)
                                      '(0 20 20 21 8 2018))]
                [(x y) (extract data)])
    (parameterize ([plot-x-ticks (time-ticks)])
      (plot (list (points data)
                  (function (poly (fit x y 2))))))))

(define (plot-bottom-of-s)
  (let*-values ([(data) (s-curve-data '(0 20 19 21 8 2018)
                                      '(0 20 21 21 8 2018))]
                [(x y) (extract data)])
    (parameterize ([plot-x-ticks (time-ticks)])
      (plot (list (points data)
                  (function (poly (fit x y 2))))))))

(define (fit-top-of-s)
  (let*-values ([(data) (s-curve-data '(0 50 18 21 8 2018)
                                      '(0 20 20 21 8 2018))]
                [(x y) (extract data)])
    (fit x y 2)))


(define (fit-bottom-of-s)
  (let*-values ([(data) (s-curve-data '(0 20 19 21 8 2018)
                                      '(0 20 21 21 8 2018))]
                [(x y) (extract data)])
    (fit x y 2)))

(define (plot-full-s-curve-data)
  (let*-values ([(data) (s-curve-data '(0 50 18 21 8 2018)
                                      '(0 20 21 21 8 2018))]
                [(x y) (extract data)])
    (parameterize ([plot-x-ticks (time-ticks)])
      (plot (list (points data)
                  (function (poly (fit x y 2))))))))

(define (fit-full-s-curve-data)
  (let*-values ([(data) (s-curve-data '(0 50 18 21 8 2018)
                                      '(0 20 21 21 8 2018))]
                [(x y) (extract data)])
    (fit x y 2)))


(define (x-for-max-y data)
  (let*-values ([(xs ys) (extract data)]
                [(fitf) (poly (fit xs ys 2))])
    (foldl (lambda (x a)
             (if (< (fitf a)
                    (fitf x))
                 x
                 a))
           (car xs)
           xs)))