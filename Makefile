THEME ?= simple

.PHONY:
slides: reveal-js
	pandoc -t revealjs --incremental -s -o static\slides.html concept-driven-infrastructure-design\slides.md -V revealjs-url=../reveal-js --slide-level 2 -V theme=$(THEME)

reveal-js:
	curl -L https://github.com/hakimel/reveal.js/archive/master.tar.gz -o revealjs.tar.gz
	tar -xvzf revealjs.tar.gz
	mv reveal.js-master reveal-js
	rm revealjs.tar.gz
