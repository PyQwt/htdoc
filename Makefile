PYQWT_WORK_COPY := $(HOME)/CVS/pyqwt

EXAMPLES        := CliDemo1 CliDemo2 DataDemo StackOrder
EXAMPLES_PNG    := $(EXAMPLES:%=$(PYQWT_WORK_COPY)/examples/%.png) 
EXAMPLES_HTML   := $(EXAMPLES:%=$(PYQWT_WORK_COPY)/examples/%.py.html) 

SOURCES         := $(shell echo *.ht)
TARGETS         := $(filter-out *.html,$(SOURCES:%.ht=%.html))
GENERATED_HTML  := $(SOURCES:.ht=.html)

HTROOT          := .
HT2HTML         := python ht2html-2.0/ht2html.py
HTSTYLE         := PyQwtGenerator 
HTALLFLAGS      := -f -s $(HTSTYLE)
HTFLAGS         := $(HTALLFLAGS) -r $(HTROOT)

DEST            := pyqwt.sourceforge.net:/home/groups/p/py/pyqwt/htdocs
EXCLUDES        := --exclude CVS --exclude ht2html-2.0 --exclude *.pyc
ARGS		:= --rsh=ssh -v -r -l -t --update --delete $(EXCLUDES)

.SUFFIXES: .ht .html

.ht.html:
	$(HT2HTML) $(HTFLAGS) $<

all: $(TARGETS)
	mkdir -p doc
	(cd $(PYQWT_WORK_COPY)/Doc; make htdoc)
	cp -vpur $(PYQWT_WORK_COPY)/Doc/html/htdoc/* doc

.PHONY: examples

examples: $(EXAMPLES_PNG) $(EXAMPLES_HTML)
	cp -puv $^ examples

clean:
	rm -f *~
	rm -f $(GENERATED_HTML)

install: clean all
	rsync $(ARGS) . $(DEST)
