YEAR  := $(shell date +%Y)
MONTH := $(shell date +%m)
DIR    = $(YEAR)/$(MONTH)-$(TALK)

.PHONY: help new
help: ## List targets (default)
	@echo "Repo root:"
	@grep -hE '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
	@echo "Inside a talk folder: make help"

new: ## New talk in YYYY/MM-slug/ (this month): TALK=slug, optional MONTH=12 YEAR=2027
	@test -n "$(TALK)" || { echo "usage: make new TALK=slug"; exit 1; }
	@test ! -e "$(DIR)" || { echo "$(DIR) exists"; exit 1; }
	mkdir -p $(DIR)/img
	echo 'include ../../talk.mk' > $(DIR)/Makefile
	ln -s ../../assets/bips-logo.png $(DIR)/bips-logo.png
	sed -e 's/{{YEAR}}/$(YEAR)/' -e 's/{{MONTH}}/$(MONTH)/' -e 's/{{DAY}}/$(shell date +%d)/' \
		template/slides.typ > $(DIR)/slides.typ
	@echo "created $(DIR)"
