PYQWT5_CVS       := $(HOME)/CVS/PyQwt/pyqwt5
PYQWT4_CVS       := $(HOME)/CVS/PyQwt/pyqwt4
PYQWT3D_CVS      := $(HOME)/CVS/pyqwt3d

EXAMPLES         := BodeDemo CliDemo DataDemo ErrorBarDemo StackOrder
EXAMPLES_PNG     := $(EXAMPLES:%=$(PYQWT4_CVS)/qt3examples/%*.png) 
EXAMPLES_HTML    := $(EXAMPLES:%=$(PYQWT4_CVS)/qt3examples/%.py.html) 

EXAMPLES_3D      := ParametricSurfaceDemo SimplePlot TestNumeric
EXAMPLES_3D_PNG  := $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/examples/%.png) 
EXAMPLES_3D      += Grab
EXAMPLES_3D_HTML := $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/examples/%.py.html) 

SOURCES          := $(shell echo *.ht)
TARGETS          := $(filter-out *.html,$(SOURCES:%.ht=%.html))
GENERATED_HTML   := $(SOURCES:.ht=.html)

HTROOT           := .
HT2HTML          := python ht2html-2.0/ht2html.py
HTSTYLE          := PyQwtGenerator 
HTALLFLAGS       := -f -s $(HTSTYLE)
HTFLAGS          := $(HTALLFLAGS) -r $(HTROOT)

DEST             := pyqwt.sourceforge.net:/home/groups/p/py/pyqwt/htdocs
EXCLUDES         := --exclude CVS
EXCLUDES         += --exclude ht2html-2.0
EXCLUDES         += --exclude *.pyc
EXCLUDES         += --exclude *~
ARGS             := --rsh=ssh -v -r -l -t --update  --delete $(EXCLUDES)

# pattern rules
%.html: %.ht links.h PyQwtGenerator.py
	touch $<
	$(HT2HTML) $(HTFLAGS) $<
	perl -pi -e 's|</head>|<link rel="SHORTCUT ICON" href="doc/pyfav.png">\n</head>|g' $@

# targets
all: $(TARGETS)
	mkdir -p doc5
	(cd $(PYQWT5_CVS)/Doc; make htdoc)
	cp -vpur $(PYQWT5_CVS)/Doc/html/htdoc/* doc5
	mkdir -p doc4
	(cd $(PYQWT4_CVS)/Doc; make htdoc)
	cp -vpur $(PYQWT4_CVS)/Doc/html/htdoc/* doc4
	(cd $(PYQWT3D_CVS)/Doc; make htdoc)
	cp -vpur $(PYQWT3D_CVS)/Doc/html/htdoc/* doc3d
	cp -vpu home.html index.html
	cp -vpu patent-protest strike.html

.PHONY: examples examples3d

examples: $(EXAMPLES_PNG) $(EXAMPLES_HTML)
	cp -puv $^ examples

examples3d: $(EXAMPLES_3D_PNG) $(EXAMPLES_3D_HTML)
	cp -puv $^ examples3d

clean:
	rm -f *~
	rm -f $(GENERATED_HTML)

install: clean all
	rsync $(ARGS) . $(DEST)

snarf:
	rsync --rsh=ssh -v -r -l -t --update $(DEST)/snapshot .
	rsync --rsh=ssh -v -r -l -t --update $(DEST)/support .
