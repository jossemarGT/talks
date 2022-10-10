# When in doubt just `make`
THEME?=simple
STANDALONE?=false
TARGET_SLIDES?=$(shell find ./slides -type f -name '*.md' -printf '%Ts\t%p\n' | sort -n | cut -f2 | sed -e "s/slides/static/" -e "s/.md/.html/")

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
all: $(TARGET_SLIDES)

static/index.html:
	rm -f index.tmp.md
	echo '## The slide index' > index.tmp.md
	echo $(TARGET_SLIDES) | sed -e 's/[^[:space:]]*/\n- [&](&)/g' -e 's%/index.html]%]%g' -e 's%\./static/%%g' >> index.tmp.md
	pandoc -t revealjs -s $(REVEALJS_FLAGS) --metadata pagetitle="jossemarGT's slides" -V theme=$(THEME) -o $@ index.tmp.md

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
