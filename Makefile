PYQWT_WORK_COPY := $(HOME)/CVS/pyqwt

EXAMPLES        := BodeDemo CliDemo1 CliDemo2 DataDemo StackOrder
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
EXCLUDES        := --exclude CVS
EXCLUDES        += --exclude ht2html-2.0
EXCLUDES        += --exclude *.pyc
EXCLUDES        += --exclude *~
ARGS		:= --rsh=ssh -v -r -l -t --update  --delete $(EXCLUDES)

.SUFFIXES: .ht .html

.ht.html:
	$(HT2HTML) $(HTFLAGS) $<
	perl -pi -e 's|</head>|<link rel="SHORTCUT ICON" href="doc/pyfav.png">\n</head>|g' $@

all: $(TARGETS)
	mkdir -p doc
	(cd $(PYQWT_WORK_COPY)/Doc; make htdoc)
	cp -vpur $(PYQWT_WORK_COPY)/Doc/html/htdoc/* doc
	cp -vpu home.html index.html
	cp -vpu patent-protest strike.html

.PHONY: examples

examples: $(EXAMPLES_PNG) $(EXAMPLES_HTML)
	cp -puv $^ examples
	cp -puv /usr/share/ghostscript/6.53/lib/Fontmap.GS examples

clean:
	rm -f *~
	rm -f $(GENERATED_HTML)

install: clean all
	rsync $(ARGS) . $(DEST)

snarf:
	rsync --rsh=ssh -v -r -l -t --update $(DEST)/snapshot .
	rsync --rsh=ssh -v -r -l -t --update $(DEST)/support .