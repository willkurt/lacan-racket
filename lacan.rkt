#lang racket

;Encoding and Decoding Lacan's 1-3 and alpha-delta symbol chains.

;;; 1 - 3 
;; Lacan's 1 - 3 rules
;; we'll substitue + for #t and - for #f


; encode lower level reprentation to higher level this is a 1 -> 1 mapping
(define (encode
          base-rep  ; this is the base form which needs to be parsed
          encode-token ; this is a funciton that parses a single token
          token-size) ; this is the size of the representation
  (cond [(empty? base-rep) '()]
        [(< (length base-rep) token-size) '()]
        [else (cons (encode-token (take base-rep token-size))
                    (encode (drop base-rep 1)
                             encode-token
                             token-size))]
        ))

; the logic for encoding a single token
(define (encode-token ;token to encode
         base-form
         symbol-check ;symbol checker
         symbols) ; list of valid symptoes
  (car (filter (λ (sym) (symbol-check base-form sym)) symbols)))

; Here is the 1-3 encoder which converts a binary string to 1-3 symbols

; 1 defined as +++ or ---
(define (is-one? xs)
  (or (equal? xs '(+ + +))
      (equal? xs '(- - -))))

(define (is-two? xs)
  (or (equal? xs '(+ - -))
      (equal? xs '(- + +))
      (equal? xs '(+ + -))
      (equal? xs '(- - +))))

(define (is-three? xs)
   (or (equal? xs '(+ - +))
       (equal? xs '(- + -))))

(define (is-n? xs n)
  (cond [(equal? n 1)
         (is-one? xs)]
        [(equal? n 2)
         (is-two? xs)]
        [(equal? n 3)
         (is-three? xs)]
        [else (error "illegal 1,2,3 symbol")]))

(define (encode-1-3-token bin)
  (encode-token bin
                is-n?
                '(1 2 3)))

(define (encode-1-3 bin)
  (encode bin
          encode-1-3-token
          3))

;; next we want a decoder that will take a symbol and decode it.

;; to start with we want to generate all possible base representations.
;; for example for 1-3 the base representations are
;; (#f #f #f), (#f #f #t), (#f #t #f), etc
;; our assumption will be that the base representations are a set of symbols
;; and that all possible strings of length end are valid token representations

; note this need a let to reduce unnecessary calles to gen-rep in the recursive call
(define (gen-rep syms size)
  (cond [(< size 1) '()]
        [(equal? size 1) (map (λ (x) (list x))
                              syms)]
        [else
          (foldl append '()
                 (map (λ (sym)
                 (map (λ (alt)
                        (cons sym alt))
                      (gen-rep syms (- size  1))))
                 syms))]))

;; now we can build our decoder
;; we'll start with a helper function that will do most of the work
;; the wrap this in something more user friendly

(define (valid-alts symbol-tester
                    syms
                    decodings)
  (filter symbol-tester
          (foldl append '()
                 (map (λ (sym)
                        (map (λ (decoding)
                               (cons sym decoding))
                             decodings)) syms))))
  
(define (decode sym-exp 
                symbol-check
                base-syms
                token-size)
  (map reverse (decode_ sym-exp
                symbol-check
                base-syms
                token-size
                (gen-rep base-syms (- token-size 1)))))

(define (decode_ sym-exp ; list of symbols representing our expression
                 symbol-check
                 base-syms ; sympols that make up the base rep
                 token-size 
                 decodings) ; decodings so far
  (cond [(empty? sym-exp) decodings] ; if the expression is empty, it has been parsed
        [(empty? decodings) '()] ; if this is empty a parse failed somewhere sop
        ; refactor these do functions can definitely be cleaned up
        [(equal? '_ (car sym-exp)) ; if a wild car just append all valid encodings
                 (decode_ (cdr sym-exp)
                          symbol-check
                          base-syms
                          token-size
                          (valid-alts
                           (λ (x) #t) base-syms decodings))] ; wild cards just don't filter anything
        [else (decode_ (cdr sym-exp)
                       symbol-check
                       base-syms
                       token-size
                       (valid-alts
                           (λ (x) (symbol-check
                                   (reverse (take x token-size))
                                   (car sym-exp)
                                   )) base-syms decodings))]))

; next we can build out our decoders for 1-3 and then repeat all of this very quickly for
; alpha-delta

(define (decode-1-3 sym-exp)
  (decode sym-exp is-n? '(+ -) 3))

;; and now we can create a general solver that will solve any wild card problems

(define (solve exp encoder decoder)
 (remove-duplicates
   (map encoder (decoder exp))))

(define (solve-1-3 exp)
  (solve exp
         encode-1-3
         decode-1-3))

; α, β, γ, δ
;; Next the α-δ symbols

;; the makes it easy to not have to type in greek letters all the time...
(define (symbol-to-greek symbol)
  (cond [(equal? symbol 'alpha) 'α]
        [(equal? symbol 'beta) 'β]
        [(equal? symbol 'gamma) 'γ]
        [(equal? symbol 'delta) 'δ]
        [else symbol]))
;; first we need the symbol checker

;; Lacan's language here is a bit confusing but we can encode his rules anyway

(define (first-last-in-pairs? triple options)
  (let ([pair (list
               (first triple)
               (last triple))])
    (foldl (λ (x y) (or x y)) '#f
           (map (λ (opt) (equal? pair opt)) options))))

(define (is-alpha-delta? xs a)
  (cond [(equal? a 'α)
         (first-last-in-pairs? xs
                               '((1 1)
                                 (3 3)
                                 (1 3)
                                 (3 1)))]
        [(equal? a 'β)
         (first-last-in-pairs? xs
                               '((1 2)
                                 (3 2)))]
        [(equal? a 'γ)
         (first-last-in-pairs? xs
                               '((2 2)))]
        [(equal? a 'δ)
         (first-last-in-pairs? xs
                               '((2 1)
                                 (2 3)))]
        [else (error "illegal α, β, γ, δ symbol")]))



; encoding
(define (encode-alpha-delta-token rep)
  (encode-token rep
                is-alpha-delta?
                '(α β γ δ)))

(define (encode-alpha-delta rep)
  (encode rep
          encode-alpha-delta-token
          3))

; decoding
(define (decode-alpha-delta sym-exp)
  (decode sym-exp is-alpha-delta? '(1 2 3) 3))

(define (solve-alpha-delta exp)
  (solve exp
         encode-alpha-delta
         decode-alpha-delta))