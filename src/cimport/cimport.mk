CIMPORT_OBJ = cimport.o cimportext.cmx

CIMPORT_LIBDIR = $(TAPIRPATH)/build/lib

CIMPORT_LIBS =	\
	-lLLVMX86CodeGen	\
	-lLLVMX86AsmPrinter	\
	-lLLVMX86AsmParser	\
	-lLLVMX86Desc	\
	-lLLVMX86Info	\
	-lLLVMX86Disassembler	\
	-lLLVMX86Info	\
	-lLLVMX86Utils	\
	-lLLVMOption	\
	-lLLVMSupport	\
	-lclangAST	\
	-lclangBasic	\
	-lclangDriver	\
	-lclangFrontend	\
	-lclangRewriteFrontend	\
	-lclangStaticAnalyzerFrontend	\
	-lclangTooling	\
	-lLLVMAsmPrinter	\
	-lLLVMDebugInfoCodeView	\
	-lLLVMDebugInfoMSF	\
	-lLLVMGlobalISel	\
	-lLLVMSelectionDAG	\
	-lLLVMCodeGen	\
	-lLLVMBitWriter	\
	-lLLVMScalarOpts	\
	-lLLVMInstCombine	\
	-lLLVMTransformUtils	\
	-lLLVMTarget	\
	-lLLVMAnalysis	\
	-lLLVMX86AsmPrinter	\
	-lLLVMX86Utils	\
	-lLLVMObject	\
	-lLLVMMCDisassembler	\
	-lclangStaticAnalyzerCheckers	\
	-lclangStaticAnalyzerCore	\
	-lclangFrontend	\
	-lclangDriver	\
	-lLLVMOption	\
	-lclangParse	\
	-lLLVMMCParser	\
	-lclangSerialization	\
	-lclangSema	\
	-lclangEdit	\
	-lclangAnalysis	\
	-lLLVMBitReader	\
	-lLLVMProfileData	\
	-lclangASTMatchers	\
	-lclangFormat	\
	-lclangToolingCore	\
	-lclangAST	\
	-lclangRewrite	\
	-lclangLex	\
	-lclangBasic	\
	-lLLVMCore	\
	-lLLVMBinaryFormat	\
	-lLLVMMC	\
	-lLLVMSupport	\
	-lLLVMDemangle
