#lang racket

; useful helper functions
(define (all xs)
  (foldl (lambda (x y) (and x y))
         `#t xs))

(define (any xs)
  (foldl (lambda (x y) (or x y))
         `#f xs))


;Encoding and Decoding Laca's 1-3 and alpha-delta symbol chains.

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
  (or (all xs)
      (all (map not xs))))

; 3 defined as +-+ or -+-
(define (is-three? xs)
  (and (not (is-one? xs))
       (equal? xs
               (reverse xs))))

; defined as ++- or -++
(define (is-two? xs)
  (and (not (is-one? xs))
       (not (is-three? xs))))

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
  (decode sym-exp is-n? '(#f #t) 3))

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

;; first we need the symbol checker

;; Lacan's language here is a bit confusing but we can end code his rules anyway

(define (first-last-in-pairs? triple options)
  (let ([pair (list
               (first triple)
               (last triple))])
    (any (map (λ (opt) (equal? pair opt) options)))))

(define (is-α-δ? xs a)
  (cond [(equal? a α)
         (first-last-in-pairs? xs
                               '((1 1)
                                 (3 3)
                                 (1 3)
                                 (3 1)))]
        [(equal? a β)
         (first-last-in-pairs? xs
                               '((1 2)
                                 (3 2)))]
        [(equal? a γ)
         (first-last-in-pairs? xs
                               '((2 2)))]
        [(equal? a δ)
         (first-last-in-pairs? xs
                               '((2 1)
                                 (2 3)))]
        [else (error "illegal α, β, γ, δ symbol")

        

;; this is a bit different see we need to generate all possible
;; binary representation of this expression.
; nts might need to reverse these in the end.
;(define (encode-1-3-exp exp)
;  (map
;   reverse
;   (if (equal? '_ (car exp))
;       (encode-1-3-exp_ (cdr exp) base-encodings)
;       (encode-1-3-exp_ (cdr exp) (encode-1-3 (car exp))))))

;; we'll need a helper function to build this out...
;(define (encode-1-3-exp_ exp encodings)
;  (cond [(empty? exp) encodings] ; if the expression is empty, it has been parsed
;        [(empty? encodings) '()] ; if this is empty a parse failed somewhere
;        [(equal? '_ (car exp))
;                 (encode-1-3-exp_
;                         (cdr exp)
;                         (append (map (λ (enc) (cons #t enc)) encodings)
;                                         (map (λ (enc) (cons #f enc)) encodings)))] ; allows for a wildcard syntax...
;        [else (encode-1-3-exp_
;                         (cdr exp)
;                         (filter (λ (alt)
;                                   (is-n? (take alt 3) (car exp)))
;                                 (append (map (λ (enc) (cons #t enc)) encodings)
;                                         (map (λ (enc) (cons #f enc)) encodings))))]))


                    
; gets encodings for a single 1,2,3 symbol
;(define (encode-1-3 n)
; (filter (λ (encoding) (is-n? encoding n))
;          base-encodings))
  

;(define (is-valid-1-3? exp)
;  (empty? (encode-1-3-exp exp)))


;;and we can solve for wild cards
;(define (solve-1-3 exp)
;  (remove-duplicates
;   (map parse-1-3-bin (encode-1-3-exp exp))))



;;; α, β, γ, δ

;note: ah! this parse is wrong since it skips a term... I think at least, need to reread

; Lacan continues to expand this to another layer of symobls on top of this
; we can just go ahead and use cond for all the conditions of this
; all of these mirror what we see for the first part so we can probably
; refactor this all quite a bit.

;(define (match-option pair-1-3 opts)
;  (any (map (lambda (opt) (equal? pair-1-3 opt))
;            opts)))
;; α
;
;(define (is-alpha? pair-1-3)
;  (match-option pair-1-3 '((1 1)
;                           (1 3)
;                           (3 1)
;                           (3 3))))
;; γ
;(define (is-gamma? pair-1-3)
;  (match-option pair-1-3 '((2 2))))
;
;; β
;(define (is-beta? pair-1-3)
;  (match-option pair-1-3 '((1 2)
;                           (3 2))))
;; δ
;(define (is-delta? pair-1-3)
;  (match-option pair-1-3 '((2 1)
;                           (2 3))))
;
;(define base-encodings-1-3 `((1 1)
;                             (1 2)
;                             (1 3)
;                             (2 1)
;                             (2 2)
;                             (2 3)
;                             (3 1)
;                             (3 2)
;                             (3 3)))
;
;(define (is-sym? pair-1-3 sym)
;  (cond [(equal? sym 'α) (is-alpha? pair-1-3)]
;        [(equal? sym 'γ) (is-gamma? pair-1-3)]
;        [(equal? sym 'β) (is-beta? pair-1-3)]
;        [(equal? sym 'δ) (is-delta? pair-1-3)]
;        [else #f]))
;
;; this could be cleaned up so much it hurts
;(define (encode-alpha-delta n)
;  (filter (λ (encoding) (is-sym? encoding n))
;          base-encodings-1-3))
;
;(define (parse-alpha-delta pair-1-3)
;   (car (filter (λ (n) (is-sym? pair-1-3 n)) '(α β γ δ))))
;
;(define (parse-alpha-delta-1-3 exp-1-3)
;  (cond [(empty? exp-1-3) '()]
;        [(< (length exp-1-3) 2) '()]
;        [else (cons (parse-alpha-delta (take exp-1-3 2))
;                    (parse-alpha-delta-1-3 (drop exp-1-3 1)))]
;        ))
;
;
;
;;; this is a bit different see we need to generate all possible
;;; binary representation of this expression.
;; nts might need to reverse these in the end.
;(define (encode-alpha-delta-exp exp)
;  (map
;   reverse
;   (if (equal? '_ (car exp))
;       (encode-alpha-delta-exp_ (cdr exp) base-encodings-1-3)
;       (encode-alpha-delta-exp_ (cdr exp) (encode-alpha-delta (car exp))))))
;
;;; we'll need a helper function to build this out...
;(define (encode-alpha-delta-exp_ exp encodings)
;  (cond [(empty? exp) encodings] ; if the expression is empty, it has been parsed
;        [(empty? encodings) '()] ; if this is empty a parse failed somewhere
;        [(equal? '_ (car exp))
;                 (encode-alpha-delta-exp_
;                         (cdr exp)
;                         ;this part gets more complex
;                         (append (map (λ (enc) (cons 1 enc)) encodings)
;                                 (map (λ (enc) (cons 2 enc)) encodings)
;                                 (map (λ (enc) (cons 3 enc)) encodings)))] 
;        [else (encode-alpha-delta-exp_
;                         (cdr exp)
;                         (filter (λ (alt)
;                                   (is-sym? (take alt 2) (car exp)))
;                                (append (map (λ (enc) (cons 1 enc)) encodings)
;                                        (map (λ (enc) (cons 2 enc)) encodings)
;                                        (map (λ (enc) (cons 3 enc)) encodings))))]))
;
;
;
;(define (is-valid-alpha-delta? exp)
;  (empty? (encode-alpha-delta-exp exp)))
;
;
;(define (solve-alpha-delta exp)
;  (remove-duplicates
;   (map parse-alpha-delta-1-3 (encode-alpha-delta-exp exp))))