INS = mtheme.ins
CONTRIB_SRC = contributors.py
CONTRIB_TEX = contributors.tex
DTX = $(wildcard *.dtx)
STY = $(patsubst %.dtx,%.sty,$(wildcard beamer*.dtx))
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR = $(TEXMFHOME)/tex/latex/mtheme
MANUAL_DIR = $(TEXMFHOME)/doc/latex/mtheme
TEMP_DIR = .temptex

DEMO_SRC = demo.tex
DEMO_PDF = demo.pdf
MANUAL_SRC = mtheme.dtx
MANUAL_PDF = mtheme.pdf
TEXC := latexmk -xelatex -output-directory=$(TEMP_DIR)

CTAN_CONTENT = $(INS) $(DTX) $(MANUAL_PDF)
CTAN_ARCHIVE = mtheme.zip

DOCKER_IMAGE = latex-image
DOCKER_CONTAINER = latex-container


.PHONY: sty manual demo ctan clean install uninstall docker-run docker-build docker-rm

all: sty manual demo

$(STY): $(DTX) $(INS)
	@latex $(INS)

$(DEMO_PDF): $(STY) $(DEMO_SRC)
	$(TEXC) $(DEMO_SRC)
	@cp $(TEMP_DIR)/$(DEMO_PDF) .

$(MANUAL_PDF): $(MANUAL_SRC)
	@$(TEXC) $(MANUAL_SRC)
	@cp $(TEMP_DIR)/$(MANUAL_PDF) .

sty: $(STY)

manual: $(MANUAL_PDF)

demo: $(DEMO_PDF)

ctan: $(CTAN_CONTENT) ctan-dir
	$(foreach file, $(CTAN_CONTENT), \
		$(shell cp $(file) mtheme/))
	@zip -q $(CTAN_ARCHIVE) mtheme/*
	@rm -rf mtheme

ctan-dir:
	@mkdir -p mtheme

clean:
	@git clean -xfd

install: $(STY) $(MANUAL_PDF)
	@mkdir -p $(INSTALL_DIR)
	@cp $(STY) $(INSTALL_DIR)
	@mkdir -p $(MANUAL_DIR)
	@cp $(MANUAL_PDF) $(MANUAL_DIR)

uninstall:
	@rm -f $(addprefix $(INSTALL_DIR)/, $(STY))
	@rm -f $(MANUAL_DIR)/$(MANUAL_PDF)
	@rmdir $(INSTALL_DIR)
	@rmdir $(MANUAL_DIR)

docker-run: docker-build
	docker run --rm=true --name $(DOCKER_CONTAINER) -i -t -v `pwd`:/data $(DOCKER_IMAGE) /data/build.sh

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-rm:
	docker rm $(DOCKER_CONTAINER)
