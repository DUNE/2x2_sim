#include <fstream>

#include "TFile.h"
#include "TTree.h"


int main(int argc, char *argv[]) {

  // Grab command line arguments.
  std::string ghep_file_list = argv[1];
  std::string pot_out_file = argv[2];


  // Read input file list.
  std::ifstream ghep_file_stream(ghep_file_list);

  std::string ghep_file = "";
  double total_pot = 0.;

  while(std::getline(ghep_file_stream, ghep_file)) {
    TFile *f = new TFile(ghep_file.c_str(), "READ");
    total_pot += ((TTree*)f->Get("gtree"))->GetWeight();
    f->Close();
    delete f;
  }

  ghep_file_stream.close();


  // Write the total POT to file.
  std::ofstream pot_out_file_stream;
  pot_out_file_stream.open(pot_out_file);
  pot_out_file_stream << total_pot << std::endl;
  pot_out_file_stream.close();


  return 0;
}
