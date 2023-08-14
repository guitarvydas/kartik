ODIN_FLAGS ?= -debug -o:none

all: run

run: 
	odin run . $(ODIN_FLAGS)

