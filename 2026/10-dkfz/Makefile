# `make results` only when R/ changes (slow, CFI and SAGE dominate)
.PHONY: all pdf handout watch results plots

all: pdf handout

results:
	Rscript R/run.R

plots:
	Rscript R/plot.R

pdf:
	typst compile slides.typ

handout:
	typst compile --input handout=true slides.typ slides-handout.pdf

watch:
	typst watch slides.typ
