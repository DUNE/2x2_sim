{
  const char* edepsim = getenv("EDEPSIM");
  if (edepsim) {
    // gSystem->AddIncludePath(Form("-I %s/include/EDepSim", edepsim));
    gInterpreter->AddIncludePath(Form("%s/include/EDepSim", edepsim));
    // gSystem->AddLinkedLibs("-ledepsim_io");
  } else {
    gSystem->AddIncludePath("-I libTG4Event");
    gInterpreter->AddIncludePath("libTG4Event");
    gSystem->Load("libTG4Event/libTG4Event.so");
  }
  gROOT->ProcessLine(".L ../run-edep-sim/geometry/inspectgeom.C");
  gROOT->ProcessLine(".L ../run-edep-sim/geometry/eve_display.C");
  // gROOT->ProcessLine(".L DrawTracks.C");
}
