# When in doubt just `make`
THEME?=simple
STANDALONE?=false
SLIDE_INDEX_TITLE?=Talks index
SLIDE_SOURCES:=$(shell find slides -type f -name index.md -exec grep -oHP 'date:\K.*' {} \;  | sort -t',' -k2 -r | cut -d: -f1)
SLIDE_TARGETS?=$(shell find slides -type f -name index.md | sed -e 's/slides/docs/' -e 's/.md/.html/')

ifeq ($(STANDALONE),true)
REVEALJS_FLAGS=-V revealjs-url=../reveal-js
QRCODEJS_FLAGS=-V revealjs-url=../qrcode-js
IMAGEURL_FIX_CMD=sed -i -e "s%../../docs/img%img%g" $1
else
REVEALJS_FLAGS=-V revealjs-url=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0
QRCODEJS_FLAGS=-V qrcodejs-url=https://cdn.jsdelivr.net/npm/davidshimjs-qrcodejs@0.0.2
IMAGEURL_FIX_CMD=sed -i -e "s%../../docs/img%https\://jossemargt.github.io/talks/img%g" $1
endif

.PHONY: all
all: $(SLIDE_TARGETS)

docs/index.html:
	rm -rf .tmp
	mkdir .tmp
	@-$(foreach slide,$(SLIDE_SOURCES), sed -ne '1{/^---$$/!q;};1,/^---$$/p' $(slide) | \
											sed -e 's/title:/##/' -e '/---/d' | \
											sed -E 's#([^:]*):(.*)#<span class="\1">\2</span>#' >>.tmp/$(subst /,-,$(slide)); \
										echo $(slide) | cut -d/ -f2 | sed -e 's#[^\w]*#[Slides](&/)\n#' >>.tmp/$(subst /,-,$(slide));)
	csplit -z --quiet --prefix=.tmp/slides-external --suffix-format=%02d.md --suppress-matched slides/externals.md /^$$/ {*}
	cat $$(find .tmp -type f -exec grep -oHP 'date"\K.*' {} \; | sed -e 's/>/ /' | LC_ALL=en_US sort -k4nr -k2Mr -k3nr | cut -d: -f1) >>.tmp/index.tmp.md
	sed -i -E 's/(##.*)/\n\1/g' .tmp/index.tmp.md
	@echo '<base target="_blank" />' >.tmp/head-overrides.html
	pandoc --standalone --self-contained --section-divs --css=index.css -H .tmp/head-overrides.html --metadata='title=$(SLIDE_INDEX_TITLE)' -t html5 -o $@ .tmp/index.tmp.md

docs/%.html: slides/%.md
	mkdir -p $(shell dirname $@)
	pandoc -t revealjs -s --incremental $(REVEALJS_FLAGS) $(QRCODEJS_FLAGS) --slide-level 2 --template slide.template -V theme=$(THEME) -o $@ $< config.yaml
	$(call IMAGEURL_FIX_CMD,$@)

docs/reveal-js:
	curl -L https://github.com/hakimel/reveal.js/archive/master.tar.gz -o revealjs.tar.gz
	tar -xvzf revealjs.tar.gz
	mv reveal.js-master docs/reveal-js
	rm revealjs.tar.gz

docs/qrcode-js:
	curl -L https://github.com/davidshimjs/qrcodejs/archive/master.tar.gz -o qrcodejs.tar.gz
	tar -xvzf qrcodejs.tar.gz
	mv qrcodejs-master docs/qrcode-js
	rm qrcodejs.tar.gz
