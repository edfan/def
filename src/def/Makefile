TARGET = def

LLVM_VER ?= 4.0

ifneq ($(TAPIRPATH),)
	TAPIROCAML = $(TAPIRPATH)/build/lib/ocaml
	TAPIRC = $(TAPIRPATH)/include
	TAPIRCPP = $(TAPIRPATH)/build/include
else
	TAPIROCAML = /
	TAPIRC = /usr/include/llvm-c-$(LLVM_VER)
	TAPIRCPP = /usr/include/llvm-$(LLVM_VER)
endif

OCAMLC = OCAMLPATH=$(TAPIROCAML) ocamlfind ocamlopt -g
PACKAGE = -package llvm,llvm.analysis,llvm.scalar_opts,llvm.ipo,llvm.target,llvm.irreader,llvm.bitreader,llvm.bitwriter,llvm.passmgr_builder,llvm.all_backends,str,unix
LINKPKG = -linkpkg $(PACKAGE) -cclib -lz
APPENDLINK = -cclib -lLLVMTransformUtils
CLANGPP = clang++-$(LLVM_VER)
CPPFLAGS = -fPIC -std=c++11 -fno-exceptions -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -I$(TAPIRC) -I$(TAPIRCPP)

SRC = version.ml llvmext.ml config.ml error.ml util.ml report.ml parsetree.ml cmdline.ml link.ml types.ml ast.ml header.ml templates.ml cfg.ml lower.ml defparse.mly deflex.mll scrubber.ml iropt.ml irfactory.ml build.ml main.ml
GENERATED = version.mli llvmext.mli config.mli report.mli ast.mli defparse.ml defparse.mli deflex.ml deflex.mli

FILES1 = $(SRC:.mly=.ml)
FILES2 = $(FILES1:.mll=.ml)

OBJ = cmpxchg.o cilky.o $(FILES2:.ml=.cmx)
INTERFACE_OBJ = $(FILES2:.ml=.cmi)

$(TARGET): $(INTERFACE_OBJ) $(OBJ)
	$(OCAMLC) -o $@ $(LINKPKG) $(OBJ) $(APPENDLINK)

clean:
	rm -f $(TARGET) $(OBJ) $(GENERATED) *.cmx *.cmi *.o

%.o:	%.cpp
	$(CLANGPP) -o $@ -c $(CPPFLAGS) $<

%.cmx: %.ml
	$(OCAMLC) $(PACKAGE) -c $<

%.cmi: %.mli
	$(OCAMLC) $(PACKAGE) -c $<

%.ml: %.mll
	ocamllex $<

%.ml: %.mly
	menhir --infer $<

ast.mli: ast.ml
	$(OCAMLC) -i $< > $@

report.mli: report.ml
	$(OCAMLC) -i $< > $@

defparse.mli: defparse.ml
	$(OCAMLC) -i $< > $@

deflex.mli: deflex.ml
	$(OCAMLC) -i $< > $@

config.mli: config.ml
	$(OCAMLC) -i $< > $@

llvmext.mli: llvmext.ml
	$(OCAMLC) $(PACKAGE) -i $< > $@

version.mli: version.ml
	$(OCAMLC) -i $< > $@