{
    gSystem->Load("libTG4Event/libTG4Event.so");
    gROOT->ProcessLine(".L ../run-edep-sim/geometry/inspectgeom.C");
    gROOT->ProcessLine(".L ../run-edep-sim/geometry/eve_display.C");
    gROOT->ProcessLine(".L DrawTracks.C");
}
