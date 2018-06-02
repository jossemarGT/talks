# When in doubt just `make` :D
THEME?=simple
STANDALONE?=false
TARGET_SLIDES?=$(shell find ./slides -type f -name *.md | sed -e "s/slides/static/" -e "s/.md/.html/")

ifeq ($(STANDALONE),true)
REVEALJS_FLAGS=-V revealjs-url=../reveal-js
IMAGEURL_FIX_CMD=true
else
REVEALJS_FLAGS=-V revealjs-url=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0
IMAGEURL_FIX_CMD=sed -i -e "s/..\/img/https\:\/\/jossemargt.github.io\/pandoc-slides\/static\/img/g" $1
endif

.PHONY: all
all: $(TARGET_SLIDES)

static/%.html: slides/%.md
	mkdir -p $(shell dirname $@)
	pandoc -t revealjs -s --incremental $(REVEALJS_FLAGS) --slide-level 2 -V theme=$(THEME) -o $@ $<
	$(call IMAGEURL_FIX_CMD,$@)

static/reveal-js:
	curl -L https://github.com/hakimel/reveal.js/archive/master.tar.gz -o revealjs.tar.gz
	tar -xvzf revealjs.tar.gz
	mv reveal.js-master static/reveal-js
	rm revealjs.tar.gz