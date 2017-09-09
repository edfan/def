LLVM_VER ?= 4.0

BINDIR = bin
INSTALL_DIR = /usr/local
BUILDDIR = build
DEF = def
BUILDDEF = $(BUILDDIR)/$(DEF)
SRCDIR = src
SRCFILES = 		\
	ast.ml		\
	build.ml	\
	build.mli	\
	cmdline.ml	\
	cmdline.mli	\
	cilky.cpp	\
	cmpxchg.cpp	\
	cfg.ml		\
	cfg.mli		\
	config.ml	\
	deflex.mll	\
	defparse.mly	\
	header.ml	\
	header.mli	\
	irfactory.ml	\
	irfactory.mli	\
	iropt.ml	\
	iropt.mli	\
	llvmext.ml	\
	link.ml		\
	link.mli	\
	lower.ml	\
	lower.mli	\
	main.ml		\
	main.mli	\
	Makefile	\
	parsetree.ml	\
	parsetree.mli	\
	report.ml	\
	scrubber.ml	\
	scrubber.mli	\
	templates.ml	\
	templates.mli	\
	types.ml	\
	types.mli	\
	util.ml		\
	util.mli	\
	version.ml

BUILDSRC = $(addprefix $(BUILDDIR)/,$(SRCFILES))

all: $(BINDIR)/$(DEF)

install: $(INSTALL_DIR)/bin/$(DEF)

$(INSTALL_DIR)/bin/$(DEF): $(BINDIR)/$(DEF)
	cp $< $(INSTALL_DIR)/bin/`bash version_info.sh patch`
	ln -f -s `bash version_info.sh patch` $(INSTALL_DIR)/bin/`bash version_info.sh minor`
	ln -f -s `bash version_info.sh minor` $@

$(BINDIR):
	mkdir -p $@

$(BUILDDIR):
	mkdir -p $@

$(BINDIR)/$(DEF): $(BUILDDEF) $(BINDIR)
	cp $< $@

$(BUILDDEF): $(BUILDDIR) $(BUILDSRC)
	make -C $<

clean:
	rm -rf $(BINDIR) $(BUILDDIR)

$(BUILDDIR)/Makefile: $(SRCDIR)/Makefile
	cp $< $@
	(cd $(BUILDDIR); ocamldep *.ml *.mli >> Makefile)

$(BUILDDIR)/version.ml:
	bash version_info.sh ocaml $(LLVM_VER) > $@

$(BUILDDIR)/%: $(SRCDIR)/%
	cp $< $@
