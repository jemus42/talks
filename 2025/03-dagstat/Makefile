TIKZ= tree-planted-large.tex

TIKZPDF=$(TIKZ:%.tex=%.pdf)

all: rpf.pdf

$(TIKZPDF): $(TIKZ)
	latexmk -halt-on-error -pdf $<

tikz: $(TIKZPDF)

rpf.pdf: rpf.qmd $(TIKZPDF)
	quarto render $<

clean:
	latexmk -c $(TIKZ)
	rm rpf.pdf
