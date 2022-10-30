# When in doubt just `make`
THEME?=simple
STANDALONE?=false
SLIDE_INDEX_TITLE?=Talks index
SLIDE_SOURCES:=$(shell find slides -type f -name index.md -exec grep -oHP 'date:\K.*' {} \;  | sort -t',' -k2 -r | cut -d: -f1)
SLIDE_TARGETS?=$(shell find slides -type f -name index.md | sed -e 's/slides/static/' -e 's/.md/.html/')

ifeq ($(STANDALONE),true)
REVEALJS_FLAGS=-V revealjs-url=../reveal-js
QRCODEJS_FLAGS=-V revealjs-url=../qrcode-js
IMAGEURL_FIX_CMD=sed -i -e "s/..\/..\/static\/img/..\/img/g" $1
else
REVEALJS_FLAGS=-V revealjs-url=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0
QRCODEJS_FLAGS=-V qrcodejs-url=https://cdn.jsdelivr.net/npm/davidshimjs-qrcodejs@0.0.2
IMAGEURL_FIX_CMD=sed -i -e "s/..\/..\/static\/img/https\:\/\/jossemargt.github.io\/talks\/static\/img/g" $1
endif

.PHONY: all
all: $(SLIDE_TARGETS)

static/index.html:
	rm -rf .tmp
	mkdir .tmp
	@-$(foreach slide,$(SLIDE_SOURCES), sed -ne '1{/^---$$/!q;};1,/^---$$/p' $(slide) | \
											sed -e 's/title:/##/' -e '/---/d' | \
											sed -E 's#([^:]*):(.*)#<span class="\1">\2</span>#' >>.tmp/$(subst /,-,$(slide)); \
										echo $(slide) | cut -d/ -f2 | sed -e 's#[^\w]*#[Slides](&/)\n#' >>.tmp/$(subst /,-,$(slide));)
	csplit -z --quiet --prefix=.tmp/slides-external --suffix-format=%02d.md --suppress-matched slides/externals.md /^$$/ {*}
	cat $$(find .tmp -type f -exec grep -H 'date' {} \; | sort -t',' -k2 -r | cut -d: -f1) >>.tmp/index.tmp.md
	sed -i -E 's/(##.*)/\n\1/g' .tmp/index.tmp.md
	pandoc --standalone --self-contained --section-divs --css=index.css --metadata='title=$(SLIDE_INDEX_TITLE)' -t html5 -o $@ .tmp/index.tmp.md

static/%.html: slides/%.md
	mkdir -p $(shell dirname $@)
	pandoc -t revealjs -s --incremental $(REVEALJS_FLAGS) $(QRCODEJS_FLAGS) --slide-level 2 --template slide.template -V theme=$(THEME) -o $@ $< config.yaml
	$(call IMAGEURL_FIX_CMD,$@)

static/reveal-js:
	curl -L https://github.com/hakimel/reveal.js/archive/master.tar.gz -o revealjs.tar.gz
	tar -xvzf revealjs.tar.gz
	mv reveal.js-master static/reveal-js
	rm revealjs.tar.gz

static/qrcode-js:
	curl -L https://github.com/davidshimjs/qrcodejs/archive/master.tar.gz -o qrcodejs.tar.gz
	tar -xvzf qrcodejs.tar.gz
	mv qrcodejs-master static/qrcode-js
	rm qrcodejs.tar.gz
