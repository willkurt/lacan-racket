# Programming Lacan's Symoblic Chain using Racket

## The signifier and the signified

"I teach that the unconscious is the fact that man is inhabited by the signifier"

"the signifier that most thoroughly annihilates every signifcation--namely, money"

### Freud, the death drive and the repetition compulsion

Lacan starts this section by discussing Freud's controversial writing "Beyond the Pleasure Principle". In this text Freud struggles with the question of the *repetition compulsion* (or automatism) in which patients repeatedly return to thinking about tramautic events in their lifes.Freud, typically explaining most of our behavior in terms libidinal desires, that is pleasure seeking, sexual urges. For Freud most of the complexity of human psychology is the way we resist these desires as part of our everyday lifes. The trouble is that if our behavior driven exclusively by a pleasure instinct wh  would anyone be compelled to revisit painful experiences over and over again? Freud's theoretical solution to this problem to the establishment of the idea of the 'death drive'. Freud argues that human behavior is in fact driven by the conflict between our libido and this death drive (Eros and Thanatos). Understandably even Freud's most ardent followers.

### Repition compulsion explain through the symbolic chain

Lacan's response is that while Freud's solution is easily dismissed, the problem he describes does need some explaination. Lacan argues that the *autonomy of the symbolic* is enough to explain the repetition compulsion.


Lacan starts with two symbols + and - representing, abstractly, presents or absence respectively. In Racket we can represent a list of these symbosl likes this:

```
'( + + - + + - - - +)
```

He then creates some simple rules that can can be used to transform a sequence of three of these symbols into three new symbols `'(1 2 3)`.

To demonstrate Lacan's rules we'll implement series of racket functions that check.

The symbol 1 is defined as either +++ or ---

```
(define (is-one? xs)
  (or (equal? xs '(+ + +))
      (equal? xs '(- - -))))

```

The symbol 2 can be +--, -++, ++-, --+


```
(define (is-two? xs)
  (or (equal? xs '(+ - -))
      (equal? xs '(- + +))
      (equal? xs '(+ + -))
      (equal? xs '(- - +))))
```

And the symbol 3 is +-+ or -+-

```
(define (is-three? xs)
   (or (equal? xs '(+ - +))
       (equal? xs '(- + -))))
```


The next step is to imagine a string of these + and - base representations and how they would be translated.To be clear, if we have 3 +/- symbols we can generate 1 1/2/3 symble, and if we have 4 +/- we can generate two. To make this more clear (and allow you to play with this process) we 

Our encoder takes the list in 3 at a time and then generates new symbols from the set 1 2 3 based on the rules we have. In racket we have implemented a function named `encode-1-3` which takes a +/- representation and encodes it as a 1-3 symbol representation.



```
> (encode-1-3 '(+ + +))
'(1)
> (encode-1-3 '(+ + + -))
'(1 2)
> (encode-1-3 '(+ + + - -))
'(1 2 2)
> (encode-1-3 '(+ + + - - -))
'(1 2 2 1)
> 
```

At this point it's worth noting that every string of +/- symbols can be encoded in exactly one sequence of {1,2,3} symbols. Something interesting happens when we try to go the other way. Just looking at our original symbol definitions we know that there are more than one possible encoding for our symbols. We'll use a `decode-1-3` function do see how we can decode these:

```
> (decode-1-3 '(1))
'((- - -) (+ + +))
> 
```

We can also see our more complex chains can be decoded:

```
> (decode-1-3 '(1 2 3))
'((- - - + -) (+ + + - +))
> (decode-1-3 '(2 2 2))
'((- + + - -) (- - + + -) (+ + - - +) (+ - - + +))
> (decode-1-3 '(2 3 2))
'((- - + - -) (+ + - + +))
> 
```

What is particularly interesting, especially to Lacan, is that our relatively simple encoding rules mean that certain 1-3 symbolic combinations cannot be decoded, and therefore cannot exist in our simple symbolic chains. For example if you try to make a 1 2 1 3 chain you'll see that the decoder returns and empty list:

```
> (decode-1-3 '(1 2 1 3))
'()

```

That is because, try as you might, you cannot find a pattern of {+,-} that encodes this sequence!

To explore what chains are possible there is a `solve-1-3` function that will allow us to use `_` as a wildcare in our chains and will return all possible chains that satistify the other constraints:

```
> (solve-1-3 '(1 _))
'((1 1) (1 2))
> (solve-1-3 '(1 2 _))
'((1 2 2) (1 2 3))
> (solve-1-3 '(1 2 _ _ _))
'((1 2 2 1 1) (1 2 3 2 1) (1 2 3 3 2) (1 2 2 2 2) (1 2 2 2 3) (1 2 3 3 3) (1 2 3 2 2) (1 2 2 1 2))

```

Lacan uses the following diagram to represent the possible transistions:



What Lacan is demonstrating is that "the series *will remember*" some of the information it has. And in case you're curious Lacan does cite by Poincare and Markov as inspiring this thoughts on this process. Clearly what we have here is a Markov Chain [link]

So what does this have to do with Freud and the repeatition compulsion?

Lacan continues to demostrate the power of symbolic chain by builiding another one on top of the {1,2,3} symbols using { α, β, γ, δ}