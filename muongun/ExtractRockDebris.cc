// Takes edep-sim's rock sim output, extracts particles that enter the hall, and
// dumps them back to gtrac for use by the spill builder (or direct to detector
// edep-sim)

#ifndef CINT
#include <TG4Event.h>
#endif

#include <TFile.h>
#include <TTree.h>

void ExtractRockDebris(const char* edep_path = "edep.root",
                       const char* out_path = "rock_debris.root")
{
  TFile fin(edep_path);
  auto in_tree = (TTree*) fin.Get("EDepSimEvents");
  TG4Event* event = nullptr;
  in_tree->SetBranchAddress("Event", &event);

  TFile fout(out_path, "RECREATE");
  TTree out_tree("gRooTracker", "Rock rootracker");


}
