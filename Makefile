PYQWT5_CVS       := $(HOME)/CVS/PyQwt/pyqwt5
PYQWT4_CVS       := $(HOME)/CVS/PyQwt/pyqwt4
PYQWT3D_CVS      := $(HOME)/CVS/pyqwt3d

EXAMPLES         := BodeDemo CliDemo DataDemo ErrorBarDemo QwtImagePlotDemo
EXAMPLES         += StackOrder
EXAMPLES_PNG     := $(EXAMPLES:%=$(PYQWT4_CVS)/qt3examples/%*.png) 
EXAMPLES_HTML    := $(EXAMPLES:%=$(PYQWT4_CVS)/qt3examples/%.py.html) 

EXAMPLES_3D      := TestNumPy
EXAMPLES_3D_IMG  := $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/qt4examples/%.svg)
EXAMPLES_3D_IMG  += $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/qt4examples/%.ps)
EXAMPLES_3D      += ParametricSurfaceDemo SimplePlot EnrichmentDemo
EXAMPLES_3D_IMG  +:= $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/qt4examples/%*.png) 
EXAMPLES_3D      += Grab
EXAMPLES_3D_HTML := $(EXAMPLES_3D:%=$(PYQWT3D_CVS)/qt4examples/%.py.html) 

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
	cp -vpr $(PYQWT5_CVS)/Doc/html/htdoc/* doc5
	mkdir -p doc4
	(cd $(PYQWT4_CVS)/Doc; make htdoc)
	cp -vpr $(PYQWT4_CVS)/Doc/html/htdoc/* doc4
	(cd $(PYQWT3D_CVS)/Doc; make htdoc)
	mkdir -p doc3d
	cp -vpr $(PYQWT3D_CVS)/Doc/html/htdoc/* doc3d
	cp -vp home.html index.html
	cp -vp patent-protest strike.html

.PHONY: examples examples3d

examples: $(EXAMPLES_PNG) $(EXAMPLES_HTML)
	cp -pv $^ examples

examples3d: $(EXAMPLES_3D_IMG) $(EXAMPLES_3D_HTML)
	cp -pv $^ examples3d

clean:
	rm -f *~
	rm -f $(GENERATED_HTML)

install: clean all
	rsync $(ARGS) . $(DEST)

snarf:
	rsync --rsh=ssh -avut $(DEST)/snapshot .
	rsync --rsh=ssh -avut $(DEST)/support .
