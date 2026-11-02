# Shared build for typst talks. In a talk folder (YYYY/MM-slug/):
#   include ../../talk.mk
# Override NAME/SRC before the include if needed.

YEAR := $(notdir $(patsubst %/,%,$(dir $(CURDIR))))
SLUG := $(notdir $(CURDIR))

SRC  ?= slides.typ
# ponytail: download filename = URL filename, so it must be self-describing
NAME ?= burk-$(YEAR)-$(SLUG)

HANDOUT := $(NAME).pdf
PRESENT := $(NAME)-present.pdf
URL     := https://slides.lukasburk.de/$(YEAR)/$(SLUG)/$(HANDOUT)

TYPST := typst compile --input url=$(URL)

.PHONY: all handout present watch clean help
all: handout present ## Build both PDFs (default)

handout: $(HANDOUT) ## Handout only (no pauses, QR target)
present: $(PRESENT) ## Presenting version only (with pauses)

$(HANDOUT): $(SRC) $(wildcard *.bib img/*)
	$(TYPST) --input handout=true $< $@

$(PRESENT): $(SRC) $(wildcard *.bib img/*)
	$(TYPST) $< $@

watch: ## Live-recompile the presenting version
	typst watch --input url=$(URL) $(SRC) $(PRESENT)

clean: ## Delete both PDFs
	rm -f $(HANDOUT) $(PRESENT)

help: ## List targets
	@echo "Talk: $(YEAR)/$(SLUG) -> $(HANDOUT), $(PRESENT)"
	@grep -hE '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
	@echo "Override before include: NAME := ..., SRC := ..."
