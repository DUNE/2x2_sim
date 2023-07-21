#include "TG4Event.h"

void CheckTrajsPerSeg(const char* fname)
{
  TFile f(fname);

  auto tree = (TTree*) f.Get("EDepSimEvents");
  TG4Event* event = nullptr;
  tree->SetBranchAddress("Event", &event);

  size_t max_contribs = 0;

  for (size_t iEvt = 0; iEvt < tree->GetEntries(); ++iEvt) {
    tree->GetEntry(iEvt);

    for (const auto &sd : event->SegmentDetectors) {
      if (sd.first == "volLArActive") {
        for (const TG4HitSegment& seg : sd.second) {
          max_contribs = std::max(max_contribs, seg.Contrib.size());
        }
      }
    }
  }

  std::cout << max_contribs << std::endl;
}
