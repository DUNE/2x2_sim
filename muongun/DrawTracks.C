using namespace ROOT;

// RDataFrame/RVec don't support multidimensional C arrays
// (e.g. StdHepX4), so must use TTreeReader instead
void DrawGenieTracksRVec(const char* gfile="gntp.0.gtrac.root")
{
  RDataFrame df("gRooTracker", gfile);

  bool doPrint = true;

  auto DrawEvent = [&doPrint](int StdHepN, RVecI StdHepPdg, RVecI StdHepStatus,
                              RVecD StdHepX4, RVecD StdHepP4)
                      // RVec<RVecD> StdHepX4, RVec<RVecD> StdHepP4)
  {
    if (! doPrint)
      return;

    cout << StdHepPdg.size() << endl;
    cout << StdHepX4.size() << endl;
    cout << StdHepP4.size() << endl;

    for (int i = 0; i < StdHepX4.size(); ++i)
      cout << StdHepX4[i] << endl;

    for (int i = 0; i < StdHepP4.size(); ++i)
      cout << StdHepP4[i] << endl;

    // for (int i = 0; i < StdHepN; ++i) {
    //   if (abs(StdHepPdg[i]) == 13 && StdHepStatus[i] == 1) {
    //     // double* x4 = &StdHepX4[4*i];
    //     // double* p4 = &StdHepP4[4*i];

    //     double x4[4] = {StdHepX4[4*i], StdHepX4[4*i + 1], StdHepX4[4*i + 2], StdHepX4[4*i + 3]};
    //     double p4[4] = {StdHepP4[4*i], StdHepP4[4*i + 1], StdHepP4[4*i + 2], StdHepP4[4*i + 3]};

    //     cout << x4[0] << " " << x4[1] << " " << x4[2] << " " << x4[3] << endl;
    //     cout << p4[0] << " " << p4[1] << " " << p4[2] << " " << p4[3] << endl;
    //     cout << endl;
    //   }
    // }

    doPrint = false;
  };

  df.Foreach(DrawEvent,
             {"StdHepN", "StdHepPdg", "StdHepStatus",
              "StdHepX4", "StdHepP4"});
}


void DrawGenieTracks(const char* gfile="gntp.0.gtrac.root")
{
  TTreeReader r("gRooTracker", new TFile(gfile));
  TTreeReaderValue<Int_t> StdHepN(r, "StdHepN");
  TTreeReaderArray<Int_t> StdHepPdg(r, "StdHepPdg");
  TTreeReaderArray<Int_t> StdHepStatus(r, "StdHepStatus");
  TTreeReaderArray<Double_t> EvtVtx(r, "EvtVtx");
  // TTreeReaderArray<Double_t> StdHepX4(r, "StdHepX4");
  TTreeReaderArray<Double_t> StdHepP4(r, "StdHepP4");

  // r.Next();
  // cout << StdHepX4.GetSize() << endl;

  // for (int i = 0; i < 4*StdHepX4.GetSize(); ++i) {
  //   cout << StdHepX4[i] << endl;
  // }

  // for (int i = 0; i < 4*StdHepP4.GetSize(); ++i) {
  //   cout << StdHepP4[i] << endl;
  // }

  while (r.Next()) {
    for (int i = 0; i < *StdHepN; ++i) {
      if (abs(StdHepPdg[i]) == 13 && StdHepStatus[i] == 1) {
        // double* x4 = &StdHepX4[4*i];
        double* x4 = &EvtVtx[0];
        double* p4 = &StdHepP4[4*i];

        cout << x4[0] << " " << x4[1] << " " << x4[2] << " " << x4[3] << endl;
        cout << p4[0] << " " << p4[1] << " " << p4[2] << " " << p4[3] << endl;
        cout << endl;

        const double scale = 100; // GENIE uses m; TGeo uses cm
        auto l = new TEveLine(2);
        l->SetPoint(0, scale*x4[0], scale*x4[1], scale*x4[2]);
        // l->SetPoint(1, 100*x4[0], 100*x4[1] + 100, 100*x4[2]);
        const bool downward = p4[1] < 0;
        l->SetLineColor(downward ? kRed : kRed);
        double pmag = sqrt(p4[0]*p4[0] + p4[1]*p4[1] + p4[2]*p4[2]);
        double trklen = 5 * p4[3]; // in m (p4[3] is in GeV)
        double dx = trklen * p4[0]/pmag;
        double dy = trklen * p4[1]/pmag;
        double dz = trklen * p4[2]/pmag;
        // l->SetLineWidth(2);
        l->SetPoint(1, scale*(x4[0]+dx), scale*(x4[1]+dy), scale*(x4[2]+dz));
        // l->SetLineColor(kRed);
        gEve->AddElement(l);
      }
    }
    // return;
  }
}

void HistEnergies(int pdgCode=-14, int status=-1, const char* gfile="gntp.0.gtrac.root")
{
  TTreeReader r("gRooTracker", new TFile(gfile));
  TTreeReaderValue<Int_t> StdHepN(r, "StdHepN");
  TTreeReaderArray<Int_t> StdHepPdg(r, "StdHepPdg");
  TTreeReaderArray<Int_t> StdHepStatus(r, "StdHepStatus");
  // TTreeReaderArray<Double_t> EvtVtx(r, "EvtVtx");
  // TTreeReaderArray<Double_t> StdHepX4(r, "StdHepX4");
  TTreeReaderArray<Double_t> StdHepP4(r, "StdHepP4");

  std::set<double> energies;
  while (r.Next()) {
    for (int i = 0; i < *StdHepN; ++i) {
      if (StdHepPdg[i] != pdgCode)
        continue;
      if (status != -1 && StdHepStatus[i] != status)
        continue;
      double* p4 = &StdHepP4[4*i];
      energies.insert(p4[3]);
    }
  }

  const double minE = *energies.begin();
  const double maxE = *energies.rbegin();
  auto* h = new TH1F("h", "h", 20, floor(minE), ceil(maxE));
  for (auto e : energies)
    h->Fill(e);

  h->Draw();
  return h;
}

void DrawEdepSegments(int maxEvts=-1, const char* edepfile="edep.root")
{
  auto f = new TFile(edepfile);
  auto tree = f->Get<TTree>("EDepSimEvents");
  TG4Event* event = nullptr;
  tree->SetBranchAddress("Event", &event);
  // tree->GetEntry(68);
  // do stuff with event->SegmentDetectors

  const double scale = 0.1; // Edep uses mm; TGeo uses cm

  int nEvts = 0;
  for (int entry = 0; tree->GetEntry(entry); ++entry) {
    // if (event->SegmentDetectors.size() == 0)
    //   continue;

    for (auto& p : event->SegmentDetectors) {
      if (p.first == "volSensShell") {
        cout << endl << "Processing #" << entry << endl;
        ++nEvts;
        auto& segs = p.second;
        for (auto& seg : segs) {
          auto l = new TEveLine(2);
          l->SetPoint(0, scale*seg.Start.X(), scale*seg.Start.Y(), scale*seg.Start.Z());
          l->SetPoint(1, scale*seg.Stop.X(), scale*seg.Stop.Y(), scale*seg.Stop.Z());
          l->SetLineColor(kRed);
          l->SetLineWidth(3);
          gEve->AddElement(l);
          // cout << seg.Start.X() << " " << seg.Start.Y() << " " << seg.Start.Z() << endl;
          // cout << seg.Stop.X() << " " << seg.Stop.Y() << " " << seg.Stop.Z() << endl;
        }
      }
    }

    if (nEvts == maxEvts) return;
  }
}

// https://github.com/DUNE/dune-tms/blob/main/scripts/FlatTree/dumpSSRITree.cpp

void DrawEdepSegmentsContig(int maxEvts=-1, const char* edepfile="edep.root")
{
  auto f = new TFile(edepfile);
  auto tree = f->Get<TTree>("EDepSimEvents");
  TG4Event* event = nullptr;
  tree->SetBranchAddress("Event", &event);
  // tree->GetEntry(68);
  // do stuff with event->SegmentDetectors

  const double scale = 0.1; // Edep uses mm; TGeo uses cm

  int nEvts = 0;
  for (int entry = 0; tree->GetEntry(entry); ++entry) {
    // if (event->SegmentDetectors.size() == 0)
    //   continue;

    for (auto& p : event->SegmentDetectors) {
      if (p.first == "volSensShell") {
        cout << endl << "Processing #" << entry << endl;
        ++nEvts;
        auto& segs = p.second;
        auto l = new TEveLine(2*segs.size());
        for (int iseg = 0; iseg < segs.size(); ++iseg) {
          auto& seg = segs[iseg];
          l->SetPoint(2*iseg, scale*seg.Start.X(), scale*seg.Start.Y(), scale*seg.Start.Z());
          l->SetPoint(2*iseg + 1, scale*seg.Stop.X(), scale*seg.Stop.Y(), scale*seg.Stop.Z());
          // cout << seg.Start.X() << " " << seg.Start.Y() << " " << seg.Start.Z() << endl;
          // cout << seg.Stop.X() << " " << seg.Stop.Y() << " " << seg.Stop.Z() << endl;
        }
        l->SetLineColor(kRed);
        // l->SetLineColor(rand() % 800);
        // l->SetLineWidth(3);
        gEve->AddElement(l);
      }
    }

    if (nEvts == maxEvts) return;
  }
}

bool IsEnteringCavern(const TG4Trajectory& traj)
{
  // Get from EDepSimGeometry?
  double xlims[] = {-5000, 5000};
  double ylims[] = {-2750, 2750};
  double zlims[] = {-10000, 10000};

  for (int i = 0; i < traj.Points.size() - 1; ++i) {
    const TLorentzVector& pos1 = traj.Points[i].Position;
    const TLorentzVector& pos2 = traj.Points[i+1].Position;

    bool crossesX =
      (pos1.X() < xlims[0] && xlims[0] <= pos2.X()) ||
      (pos2.X() < xlims[1] && xlims[1] <= pos1.X());
    bool crossesY =
      (pos1.Y() < ylims[0] && ylims[0] <= pos2.Y()) ||
      (pos2.Y() < ylims[1] && ylims[1] <= pos1.Y());
    bool crossesZ =
      (pos1.Z() < zlims[0] && zlims[0] <= pos2.Z()) ||
      (pos2.Z() < zlims[1] && zlims[1] <= pos1.Z());

    if (crossesX && crossesY && crossesZ)
      return true;
  }

  return false;
}

void DrawTrajectories(const char* edepfile = "edep.root")
{
  auto f = new TFile(edepfile);
  auto tree = f->Get<TTree>("EDepSimEvents");
  TG4Event* event = nullptr;
  tree->SetBranchAddress("Event", &event);

  for (int entry = 0; tree->GetEntry(entry); ++entry) {
    for (const auto& traj : event->Trajectories) {
      if (abs(traj.PDGCode) != 13)
        continue;

      if (IsEnteringCavern(traj)) {
        std::cout << "Track " << entry << " enters" << std::endl;
        continue;
      }
    }
  }
}
