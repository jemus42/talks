TIKZ= tree-cart.tex tree-planted-simple.tex tree-planted-large.tex
TIKZPDF=$(TIKZ:%.tex=%.pdf)

all: rpf.pdf

$(TIKZPDF): %.pdf: %.tex
	latexmk -halt-on-error -pdf $<

list:
	echo $(TIKZ)
	echo $(TIKZPDF)

tikz: $(TIKZPDF)

rpf.pdf: rpf.qmd $(TIKZPDF)
	quarto render $<

clean:
	latexmk -c $(TIKZ)
	rm rpf.pdf
