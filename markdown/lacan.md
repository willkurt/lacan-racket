# Programming Lacan's Symoblic Chain using Racket

Jacques Lacan's *Seminar on "The Purloined Letter"* is a lecture that covers many of Lacan's essential themes and is a great introduction to understanding the basics of Lacanian psychology. When abstracted out, many of Lacan's ideas can be reasonably straightforward, however in the original context Lacan takes the audiences on a splendid journey through his thinking that, for the uninitiated, can be a bit confusing. These notes cover a surprisingly quantitative and technical section in this lecture as printed in *Écrits* under the subsection titled *Introduction* which in fact follows after the transcript of the seminar.


This Seminar focuses on a classic Edgar Allen Poe text, "The Purloined Letter" which is a mystery centering on a stolen letter. Lacan uses this letter as classic example of the 'primacy of the signified'. "What in the world does that mean!?" you might reasonably ask. Lacan was particularly interested in the different roles that the "signifier" and the "signified" play in our understanding of the world. In general we can think of the *signifier* as the "thing which points to something else" and the *signified* as the "thing pointed at". Take for example this image:

!["A cat reading Lacan's Écrits"](./images/cat_ecrits.png){width=300px}

We would say that there is a "cat" in this image. The word "cat" would be the signifier and the cat itself would be the signified. Typically we tend to think of the *signfied* at the real thing, but Lacan was interested in how incredibly important the signfier itself is in our understanding of the world. He proclaims in the Seminar:

>  "I teach that the unconscious is the fact that man is inhabited by the signifier"

For Lacan it is these signifiers, these symbols of things, that are in fact the reality of our unconcious life. That is we operate primarily in terms of symbols, not the least of which is language itself. As an example of the role these signifigers play, consider a statement such as "I am a male technologist". It turns our there in a emoji specifically for this very idea:

!["Emoji are a great representation of the signifier"](./images/man_technologist.png){width=300px}

Now when I say "male technologist" you likely have a pretty good idea what I mean, but if we pick apart what these words mean it we quickly find it is very tricky to point to what exactly I am signifying. For starters what does it mean to say that I am "male"? We can see this as expression of biological sex, but it also entrails notions of gender. What does it mean to be a "man"? You might be tempted to quickly make some statement about the number of X choromosomes, but even if that works for one technical definition of "male" it clearly doesn't do enough to explain it in all or even most social occasions. The more we explore "maleness" the more we realize that being "male" is more a signifier that a signified, it is like an emoji that we can't quite pin down exactly what it points to.

This is of course just one tiny example of how often times the signifier is what plays a primal role in our way of interacting with the world. Lacan also points out that there is one very important signifier in our contemporary existence, which is always something with points to something else, and yet nonetheless plays an essential role in our psychology:

"the signifier that most thoroughly annihilates every signifcation--namely, money"

For a bit more exposition on Lacan take a look at my talk on ["The Limits of Probability"](https://www.youtube.com/watch?v=S_dqEgtpgBg).

To demonstrate just how powerful pure symobls can be Lacan give an example of a very simple symbol language which nonetheless has some very interesting properities. Given that Racket is a programming language focused specifically on symbol manipulation I thought it would be a really fun exercise to implement this specific example fo Lacan's reasoning in Racket! 

## Freud, the death drive and the repetition compulsion

Lacan starts what is essential an appendix to the Seminar by discussing Freud's controversial writing *Beyond the Pleasure Principle*. In this text Freud struggles with the question of the *repetition compulsion* (or automatism) in which patients repeatedly return to thinking about tramautic events in their lifes. Freud typical explains most of our behavior in terms libidinal desires, that is pleasure seeking, sexual urges. For Freud most of the complexity of human psychology is the way we resist these desires as part of our everyday lifes. The trouble is that if our behavior is driven exclusively by a pleasure instinct why would anyone be compelled to revisit painful experiences over and over again? Freud's theoretical solution to this problem is the establishment of the idea of the 'death drive'. Freud argues that human behavior is in fact driven by the conflict between our libido and this death drive (Eros and Thanatos). Understandably even Freud's most ardent followers found this explaination a little difficult to digest.

### Repition compulsion explained through the symbolic chain

Lacan's response is that while Freud's solution is easily dismissed, the problem he describes does need some explaination. Lacan argues that the *autonomy of the symbolic* is enough to explain the repetition compulsion. What in the world is the "autonomy of the symbolic?" Lacan wants to show us that mere symbols and rules for creating those symbols can contain their own logic which can cause repitition without needing to refer to any more complicated system. From a standpoint of modern programming this is not at all surprising. Anyone who has writen a program has basically used symbols that have no intrinsic meaning and used the logic of these symobls create predictable behavior. This is why this is a particularly fun part of Lacan to implement in code!

To demonstrate this Lacan develops a very simple grammar from symobic manipulation to demonstrate the emergent rules that come from this. For Lacan this shows that we don't need complex ideas like the death drive to explain the compulsion to repeat: symbols themselves can cause this. Lacan starts with two symbols + and - representing, abstractly, presents or absence respectively. In Racket we can represent a list of these symbosl likes this:

```
'( + + - + + - - - +)
```

He then creates some simple rules that can can be used to transform a sequence of three of these symbols into three new symbols `'(1 2 3)`.

To demonstrate Lacan's rules we'll implement series of racket functions that check whether or not a given string of `+` and `-` maps to the target symbol. Lacan, being Lacan, expresses these symbols in a more indirect way, but the following definitions will suffice to showing Lacan's larger point.

The symbol 1 is defined as either `+++` or `---`

```
(define (is-one? xs)
  (or (equal? xs '(+ + +))
      (equal? xs '(- - -))))

```

The symbol 2 can be `+--`, `-++`, `++-`, `--+`


```
(define (is-two? xs)
  (or (equal? xs '(+ - -))
      (equal? xs '(- + +))
      (equal? xs '(+ + -))
      (equal? xs '(- - +))))
```

And the symbol 3 is `+-+` or `-+-`

```
(define (is-three? xs)
   (or (equal? xs '(+ - +))
       (equal? xs '(- + -))))
```


The next step is to imagine a string of these + and - base representations and how they would be translated. To be clear, if we have 3 +/- symbols we can generate  a single `1`,`2`, or `3` symbol, and if we have four `+`/`-` we can generate two symbols. To make this more clear (and allow you to play with this process) we will demonstrate this in Racket. Our encoder takes the list in 3 at a time and then generates new symbols from the set `1` `2` `3` based on the rules we have. In racket we have implemented a function named `encode-1-3` which takes a +/- representation and encodes it as a 1-3 symbol representation.


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

At this point it's worth noting that every string of `+`/`-` symbols can be encoded in exactly one sequence of {`1`,`2`,`3`} symbols. Something interesting happens when we try to go the other way. Just looking at our original symbol definitions we know that there are more than one possible encoding for our symbols. We'll use a `decode-1-3` function do see how we can decode these:

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

That is because, try as you might, you cannot find a pattern of {`+`,`-`} that encodes this sequence!

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

![Lacan's diagram should immediately invoke Finite State Machines and Markov Chains](./images/1-3_network.png){width=300px}


What Lacan is demonstrating is that "the series *will remember*" some of the information it has. And in case you're curious Lacan does cite by Poincare and Markov as inspiring this thoughts on this process. Clearly what we have here is a Markov Chain!

So what does this have to do with Freud and the repeatition compulsion?

Lacan continues to demostrate the power of symbolic chain by builiding another one on top of the {1,2,3} symbols using { `α`, `β`, `γ`, `δ`}. Each of these symbols is encoded as a triplet of the {`1`,`2`,`3`} symbols using the following rules based on the first and last symbols in the triplet.

Here are the rules in Scheme


```
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
```

We this rules we can created yet another encoder, `encode-alpha-delta`, that will encode sequences of  α-δ symbols. Here are some examples:

```
> (encode-alpha-delta '(1 2 3))
'(α)
> (encode-alpha-delta '(1 2 2))
'(β)
> (encode-alpha-delta '(2 1 2))
'(γ)
> (encode-alpha-delta '(2 1 1))
'(δ)
> (encode-alpha-delta '(2 1 1 1 1))
'(δ α α)
> (encode-alpha-delta '(1 2 3 1 2 3))
'(α δ β α)
> (encode-alpha-delta '(1 2 3 3 2 1))
'(α δ β α)
> (encode-alpha-delta '(1 2 3 3 1 1))
'(α δ α α)
```

If we want we can even combine these two encoders to go straight from our {`+`,`-`} representation all the way to α-δ

```
> (encode-alpha-delta (encode-1-3 '(+ + + - - -)))
'(β δ)
> (encode-alpha-delta (encode-1-3 '(+ + + - - - + + - +)))
'(β δ γ β γ δ)
```

There are once again many possible decodings of our  α-δ symbols into 1-3 triplets:

```
> (decode-alpha-delta '(β δ))
'((1 2 2 3) (3 2 2 3) (1 2 2 1) (3 2 2 1))
> (decode-alpha-delta '(β δ δ))
'((1 2 2 3 3) (3 2 2 3 3) (1 2 2 1 3) (3 2 2 1 3) (1 2 2 3 1) (3 2 2 3 1) (1 2 2 1 1) (3 2 2 1 1))
> (decode-alpha-delta '(β δ δ α))
'((1 2 2 3 3 3)
  (3 2 2 3 3 3)
  (1 2 2 1 3 3)
  (3 2 2 1 3 3)
  (1 2 2 3 1 3)
  (3 2 2 3 1 3)
  (1 2 2 1 1 3)
  (3 2 2 1 1 3)
  (1 2 2 3 3 1)
  (3 2 2 3 3 1)
  (1 2 2 1 3 1)
  (3 2 2 1 3 1)
  (1 2 2 3 1 1)
  (3 2 2 3 1 1)
  (1 2 2 1 1 1)
  (3 2 2 1 1 1))
```

And of course from all of this we can build another solver, `solve-alpha-delta`, which we will need to understand more deeply the next part of Lacan's discussion.


In his Delta distrbution section Lacan want's to show us how symbols early on can determine the future symbols we will see, even when there is a lot of flexibility in the middle



For example look at both α and δ as starting points in a three symbol chain.


```
> (solve-alpha-delta '(α _ _))
'((α α α) (α δ α) (α β α) (α γ α) (α α β) (α δ β) (α β β) (α γ β))
> (solve-alpha-delta '(δ _ _))
'((δ α α) (δ δ α) (δ β α) (δ γ α) (δ α β) (δ δ β) (δ β β) (δ γ β))
```

At time 1 if we start with either of these, all symbols are possible at step 2, but only α and  β are possible for step 3.

A similar pattern emerges when we look at γ and β as starting points:

```
> (solve-alpha-delta '(β _ _))
'((β α δ) (β δ δ) (β β δ) (β γ δ) (β α γ) (β δ γ) (β β γ) (β γ γ))
> (solve-alpha-delta '(γ _ _))
'((γ α δ) (γ δ δ) (γ β δ) (γ γ δ) (γ α γ) (γ δ γ) (γ β γ) (γ γ γ))
```

Given these two symbols in step 1, any symbol is possible in step 2 but only γ and δ are possible at step 3.

Lacan continues by showing two, somewhat confusing tables show which symbols are impossible provided we know the 1st and 4th symbol in a change. Here is his image for reference:

![The Omega and O tables](./images/omega_table.png){width=400px}

For me it was not entirely obvious what Lacan was trying to show here, but once we run this in Racket it becomes pretty clear.

For the Omega table:

```
> (solve-alpha-delta '(α _ _ γ _ _ α))
'((α β α γ α δ α)
  (α γ α γ α δ α)
  (α β β γ δ δ α)
  (α γ β γ δ δ α)
  (α β α γ α γ α)
  (α γ α γ α γ α)
  (α β β γ δ γ α)
  (α γ β γ δ γ α))
```

We can see that between `α` and `γ` the symbol `δ` is impossible and between the second half of `γ` back to  `α` the symbol `β` is impossible.

Likewise with the O table we can see a similar pattern:

```
> (solve-alpha-delta '(δ _ _ β _ _ δ))
'((δ α α β β δ δ)
  (δ δ α β β δ δ)
  (δ α β β γ δ δ)
  (δ δ β β γ δ δ)
  (δ α α β β γ δ)
  (δ δ α β β γ δ)
  (δ α β β γ γ δ)
  (δ δ β β γ γ δ))
```

Again we see certain symbols are impossible in each substring based on knowing only the 1st and 4th symbols seen.

For me this was an interesting case where Lacan's notation wasn't entirely clear but implementing Lacan's symoblic language as a bit of Racket code made the problem surprisingly clear and easy to understand.

## Our symbolic programming

Lacan never makes the explicit connection between programming and his symbolic language, but it leads to an interesting observation. Lacan's main argument here (if we can say that Lacan ever really makes an argument) is that Freud's delemea doesn't need the "Death Drive". We can see that if our mind is driven by symbols then we can clearly explain the repetition of events, tragic or not, by the rules that force symbols to behave in a certain way. From the perspective of a programmer it seems that Lacan is stating something that almost seems obivous in retrosepct: we can view ourselves as programmed by these symbols.

If you've ever watched the series True Detective this may invoke images of Rust's description of why he continues on living despite his deep pessism regarding existence:

**Marty Hart:** So what's the point of getting out of bed in the morning?

**Rust Cohle:** I tell myself I bear witness, but the real answer is that it's obviously my programming. And I lack the constitution for suicide.

![What is the relationship between the signifier and our programming?](./images/rust_cohle.jpg){width=300px}

What we've worked out here is a round about way of showing how Lacan's real point is that the signifiers which provide the foundation of our unconcious are, in there own way, our programming.
