# Notes on Lacan's "Purloined Letter" Seminar in Racket.

**Description:** This is code and supporting writing up some rather interesting exposition of Jacques Lacan in his first appendix to the *Seminar on the "Purloined Letter"* notes published in his English translation of Écrits (Norton 2006).

The main write up can be viewed on the github page: [https://willkurt.github.io/lacan-racket/](https://willkurt.github.io/lacan-racket/)


The index page is built using Pandoc and can be generated with the following command:

`pandoc -s ./markdown/lacan.md -f markdown -t html --metadata-file=./markdown/metadata.yaml --css ./markdown/pandoc.css -o index.html`


The original `pandoc.css` file comes from [https://gist.github.com/killercup/5917178#file-pandoc-css](https://gist.github.com/killercup/5917178#file-pandoc-css)

The code used in the post is all in `./code/lacan.rkt`