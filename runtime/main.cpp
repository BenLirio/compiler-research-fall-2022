#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorOr.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Analysis/LoopAnalysisManager.h"
#include "llvm/Analysis/CGSCCPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Bitcode/BitcodeWriter.h"

using namespace llvm;

static cl::opt<std::string> FileName(cl::Positional, cl::desc("Bitcode file"), cl::Required);
static cl::opt<std::string> OutputName(cl::Positional, cl::desc("Bitcode output"), cl::Required);

int main(int argc, char** argv)
{
	cl::ParseCommandLineOptions(argc, argv, "LLVM hello world\n");
	LLVMContext context;

	ErrorOr<std::unique_ptr<MemoryBuffer>> mb = MemoryBuffer::getFile(FileName);
	if (std::error_code ec = mb.getError()) {
		errs() << ec.message();
		return -1;
	}

	Expected<std::unique_ptr<Module>> m = parseBitcodeFile(mb->get()->getMemBufferRef(), context);
	if (std::error_code ec = errorToErrorCode(m.takeError())) {
		errs() << "Error reading bitcode: " << ec.message() << "\n";
		return -1;
	}

	// Create the analysis managers.
	LoopAnalysisManager LAM;
	FunctionAnalysisManager FAM;
	CGSCCAnalysisManager CGAM;
	ModuleAnalysisManager MAM;

	// Create the new pass manager builder.
	// Take a look at the PassBuilder constructor parameters for more
	// customization, e.g. specifying a TargetMachine or various debugging
	// options.
	PassBuilder PB;

	// Register all the basic analyses with the managers.
	PB.registerModuleAnalyses(MAM);
	PB.registerCGSCCAnalyses(CGAM);
	PB.registerFunctionAnalyses(FAM);
	PB.registerLoopAnalyses(LAM);
	PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);

	// Create the pass manager.
	// This one corresponds to a typical -O2 optimization pipeline.
	ModulePassManager MPM = PB.buildPerModuleDefaultPipeline(PassBuilder::OptimizationLevel::O2);

	// Optimize the IR!
	MPM.run(**m, MAM);

	std::error_code EC;
	llvm::raw_fd_ostream OS(OutputName, EC, llvm::sys::fs::F_None);
	WriteBitcodeToFile(**m, OS);
	OS.flush();

	return 0;
}
