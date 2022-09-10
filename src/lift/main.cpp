#include "/opt/CLI11/CLI11.hpp"

int main(int argc, char** argv) {
  CLI::App app{"Lift binary to LLVM IR"};
  app.option_defaults()->required();

  std::string binary_filename = "";
  std::string output_filename = "";
  app.add_option("--binary", binary_filename, "Binary input filename");
  app.add_option("--output", output_filename, "Output filename");
  CLI11_PARSE(app, argc, argv);



  system(("mcsema-disass --disassembler /ida/idat64 --os linux --arch amd64 --binary " + binary_filename +" --output /tmp/a.cfg").c_str());
  system("mcsema-lift-10.0 --os linux --arch amd64 --cfg /tmp/a.cfg --output /tmp/a.bc");
  system(("llvm-dis-10 /tmp/a.bc -o " + output_filename).c_str());
  return 0;
}
