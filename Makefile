ODIN_FLAGS ?= -debug -o:none

all: run

dev:
	rm -f kartik
	make run

run: 
	odin run . $(ODIN_FLAGS)

