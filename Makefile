ODIN_FLAGS ?= -debug -o:none

all: run

install: npmstuff

npmstuff:
	npm install ohm-js yargs atob pako

run: 
	odin build . $(ODIN_FLAGS)
	./fabghoststars

json:
	./transpile grammar.ohm fabricate.fab support.js <src.txt 
lisp:
	./transpile grammar.ohm lispfabricate.fab support.js <src.txt 
