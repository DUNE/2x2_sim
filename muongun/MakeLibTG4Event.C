{
  auto* f = new TFile("edep.root");
  // recreate++?  see https://internal.dunescience.org/doxygen/edep-sim_2test_2dumpTree_8py_source.html
  f->MakeProject("libTG4Event", "*", "+"); // see dumpTree.py google
}
