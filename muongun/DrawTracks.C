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
  TTreeReaderArray<Double_t> StdHepVtx(r, "StdHepX4");
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
        double* x4 = &StdHepVtx[0];
        double* p4 = &StdHepP4[4*i];

        cout << x4[0] << " " << x4[1] << " " << x4[2] << " " << x4[3] << endl;
        cout << p4[0] << " " << p4[1] << " " << p4[2] << " " << p4[3] << endl;
        cout << endl;

        auto l = new TEveLine(2);
        l->SetPoint(0, 100*x4[0], 100*x4[1], 100*x4[2]);
        // l->SetPoint(1, 100*x4[0], 100*x4[1] + 100, 100*x4[2]);
        const bool downward = p4[1] < 0;
        l->SetLineColor(downward ? kRed : kBlue);
        double pmag = sqrt(p4[0]*p4[0] + p4[1]*p4[1] + p4[2]*p4[2]);
        double trklen = p4[3]; // 1 GeV ~ 1 M
        double dx = trklen * p4[0]/pmag;
        double dy = trklen * p4[1]/pmag;
        double dz = trklen * p4[2]/pmag;
        // l->SetLineWidth(2);
        l->SetPoint(1, 100*(x4[0]+dx), 100*(x4[1]+dy), 100*(x4[2]+dz));
        // l->SetLineColor(kRed);
        gEve->AddElement(l);
      }
    }
    // return;
  }
}
