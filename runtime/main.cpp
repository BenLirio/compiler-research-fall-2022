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

#include <CLI11.hpp>

using namespace llvm;

struct Args {
	std::string input_filename;
	std::string output_filename;
};


Args parseArgs(int argc, char** argv) {
	Args args;
	CLI::App app{"Clean lifted LLVM IR"};
	app.option_defaults()->required();
	std::string input_filename, output_filename;
	app.add_option("--input", input_filename, "Input LLVM IR");
	app.add_option("--output", output_filename, "Output LLVM IR");
	try {
		app.parse(argc, argv);
	} catch (const CLI::ParseError &e) {
		app.exit(e);
		throw e;
	}
	return args;
}

std::unique_ptr<Module> readIR(std::string filename) {
	LLVMContext context;
	ErrorOr<std::unique_ptr<MemoryBuffer>> mb = MemoryBuffer::getFile(filename);
	if (std::error_code ec = mb.getError()) { throw ec; }

	Expected<std::unique_ptr<Module>> m = parseBitcodeFile(mb->get()->getMemBufferRef(), context);
	if (std::error_code ec = errorToErrorCode(m.takeError())) { throw ec; }
	return std::move(*m);
}

void writeIR(std::unique_ptr<Module> M, std::string filename) {
	std::error_code ec;
	llvm::raw_fd_ostream OS(filename, ec, sys::fs::F_None);
	WriteBitcodeToFile(*M, OS);
	if (ec) { throw ec; }
	OS.flush();
}

int main(int argc, char** argv) {
	try {
		Args args = mustParseArgs(argc, argv);
		std::unique_ptr<Module> M = mustReadIR(args.input_filename);
		// transform M
		mustWriteIR(std::move(M), args.output_filename);
	} catch (
	return 0;
}
