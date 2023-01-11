#include "libTG4Event/TG4Trajectory.h"
#include "libTG4Event/TG4TrajectoryPoint.h"
#include <optional>

using namespace ROOT;

// Mostly less painful than TVector3; has constructor from TVector3
using ROOT::Math::XYZVector;

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
        cout << "Processing #" << entry << endl;
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


// Assumes that the box is axis-aligned and centered on the origin
// (e.g. the MINOS hall in our geometry)
// Also assumes that p1 and p2 are both outside the box!
// (NO) Returns (if possible) the position where the particle ENTERS the box

// std::optional<XYZVector>
bool
SegmentBoxIntersect(XYZVector p1, XYZVector p2, XYZVector boxDims)
{
  auto get = [](const XYZVector& p, size_t axis) { // TVector3 provides operator()...
    double coords[3];
    p.GetCoordinates(coords);
    return coords[axis];
  };

  auto on_box = [&](const XYZVector& p, size_t axis) {
    const double coord = get(p, axis);
    const double lim = get(boxDims, axis) / 2;
    return -lim <= coord && coord <= lim;
  };

  for (size_t axis : {0, 1, 2}) {
    for (int sign : {1, -1}) {  // which of the two normal-to-this-axis faces?
      const double faceCoord = sign * get(boxDims, axis) / 2;
      const double p1height = get(p1, axis) - faceCoord;
      const double p2height = get(p2, axis) - faceCoord;
      // Are we potentially entering the hall via this face?
      if (p1height*p2height < 0    // opposite sides of the face?
          and p1height*sign > 0) { // pointing inside?
        // distance from p1 to plane is height*sec(theta) where cos(theta) = unit(p1ToP2)[axis]
        // rayLen is length to face along (p1->p2) direction:
        const double rayLen = p1height / get((p2-p1).Unit(), axis);
        XYZVector isect = p1 + rayLen * (p2-p1).Unit(); // where the segment intersects the plane
        if (on_box(isect, (axis+1)%3) && on_box(isect, (axis+2)%3))
          // return isect;          // Found the entrance point!
          return true;          // Found the entrance point!
      }
    }
  }

  // return std::nullopt;
  return false;
}

bool IsEnteringCavern(const TG4Trajectory& traj)
{
  double xlims[] = {-5000, 5000};
  double ylims[] = {-2750, 2750};
  double zlims[] = {-10000, 10000};

  // TODO Get from EDepSimGeometry?
  const XYZVector boxDims = {10000, 5500, 20000};

  bool entering = false;

  for (int i = 0; i < traj.Points.size() - 1; ++i) {
    const TLorentzVector& pos1 = traj.Points[i].Position;
    const TLorentzVector& pos2 = traj.Points[i+1].Position;

    auto is_outside = [&](const TLorentzVector& pos) {
      return
        pos.X() < xlims[0] || xlims[1] < pos.X() ||
        pos.Y() < ylims[0] || ylims[1] < pos.Y() ||
        pos.Z() < zlims[0] || zlims[1] < pos.Z();
    };

    // Maybe a particle gets produced inside the cavern, e.g. from a decay
    // if (i == 0 and not is_outside(pos1))
    //   DoSomething();

    // if (bothOutside and segmentCrossesHall)
    //   DoSomething();

    // The real way to do this: Take the two positions, connect them, and ask
    // whether this segment has any points that lie inside the hall

    // XXX need to account for trajectories that cross the entire cavern between
    // two points (i.e. both points are "outside" but on opposite sides in at
    // least one dimension). Also trajectories that have their final point
    // inside the rock, but point into the cavern? The real question is, do we
    // get a point every time the particle crosses volumes, even if there's no
    // hard interaction?
    //
    // How to check: Look for trajectories where the final point lies inside the
    // rock, but the momentum points into the cavern

    // event 446 (particle produced in sensitive shell?):
    // if (not is_outside(pos2))
    if (is_outside(pos1) and not is_outside(pos2)) {
      // std::cout << "PDGCode = " << traj.PDGCode << ", TotE = "
      //           << traj.InitialMomentum.E() << std::endl;
      // traj.Points[i].Dump();
      // traj.Points[i+1].Dump();
      // if (i != traj.Points.size() - 2) traj.Points[i+2].Dump();

      // XXX Remember to include _all_ incoming particles. Don't exit loop after
      // finding just one!
      entering = true;
    }
  }

  return entering;
}

void DumpTrajectories(const char* edepfile = "edep.root")
{
  auto f = new TFile(edepfile);
  auto tree = f->Get<TTree>("EDepSimEvents");
  TG4Event* event = nullptr;
  tree->SetBranchAddress("Event", &event);

  for (int entry = 0; tree->GetEntry(entry); ++entry) {
    for (const auto& traj : event->Trajectories) {
      // if (abs(traj.PDGCode) != 13)
      //   continue;

      if (IsEnteringCavern(traj)) {
        // std::cout << "--> Event " << entry << std::endl << std::endl;
        std::cout << "--> Event " << entry << std::endl;
        break;
      }
    }
  }
}

// NOTE: Run eve_display.C first!
struct TrackArtist {
  TFile* m_file;
  TTree* m_tree;
  TG4Event* m_event = nullptr;

  // std::vector<std::unique_ptr<TEveLine>> m_lines;
  std::vector<TEveElement*> m_elements;

  TrackArtist(const char* edepfile = "edep.root")
  {
    m_file = new TFile(edepfile);
    m_tree = m_file->Get<TTree>("EDepSimEvents");
    m_tree->SetBranchAddress("Event", &m_event);
  }

  void DrawTracks(int entry, bool drawPoints = true, EColor color = kRed)
  {
    m_tree->GetEntry(entry);

    const double scale = 0.1; // Edep uses mm; TGeo uses cm

    for (const auto& traj : m_event->Trajectories) {
      const size_t npoints = traj.Points.size();
      // auto& line = m_lines.emplace_back(std::make_unique<TEveLine>(npoints));
      auto line = (TEveLine*) m_elements.emplace_back(new TEveLine(npoints));
      auto pointSet = drawPoints
        ? (TEvePointSet*) m_elements.emplace_back(new TEvePointSet(npoints))
        : nullptr;
      for (size_t i = 0; i < npoints; ++i) {
        const TLorentzVector& pos = traj.Points[i].Position;
        line->SetPoint(i, scale*pos.X(), scale*pos.Y(), scale*pos.Z());
        if (drawPoints)
          pointSet->SetPoint(i, scale*pos.X(), scale*pos.Y(), scale*pos.Z());
      }
      line->SetLineColor(color);
      // line->SetMarkerColor(kYellow);
      // line->SetMarkerSize(3);
      // gEve->AddElement(line.get());
      gEve->AddElement(line);
      if (drawPoints) {
        pointSet->SetMarkerColor(kYellow);
        pointSet->SetMarkerSize(1);
        gEve->AddElement(pointSet);
      }
    }

    gEve->FullRedraw3D(true);
  }

  void Clear()
  {
    for (auto& pEle : m_elements)
      // gEve->RemoveElement(pLine.get(), gEve->GetGlobalScene());
      // gEve->RemoveElement(pLine, gEve->GetGlobalScene());
      pEle->Destroy();

    m_elements.clear();

    gEve->FullRedraw3D(true);
  }

  void DumpToFile(const char* fname = "rock_debris.root")
  {
    TFile file(fname, "RECREATE");
    TTree outTree("rock_debris", "Rock debris");

    const size_t MAXN = 256;
    UInt_t N;
    UInt_t SrcEntry;
    Int_t TrackId[MAXN], ParentId[MAXN], PointId[MAXN], PDGCode[MAXN];
    Float_t X[MAXN], Y[MAXN], Z[MAXN];
    Float_t PX[MAXN], PY[MAXN], PZ[MAXN];

    outTree.Branch("N", &N, "N/i");
    outTree.Branch("SrcEntry", &SrcEntry, "SrcEntry/i");
    outTree.Branch("TrackId", TrackId, "TrackId[N]/I");
    outTree.Branch("ParentId", ParentId, "ParentId[N]/I");
    outTree.Branch("PointId", PointId, "PointId[N]/I");
    outTree.Branch("PDGCode", PDGCode, "PDGCode[N]/I");
    outTree.Branch("X", X, "X[N]/F");
    outTree.Branch("Y", Y, "Y[N]/F");
    outTree.Branch("Z", Z, "Z[N]/F");
    outTree.Branch("PX", PX, "PX[N]/F");
    outTree.Branch("PY", PY, "PY[N]/F");
    outTree.Branch("PZ", PZ, "PZ[N]/F");

    const XYZVector BOXDIMS = {10000, 5500, 20000};

    auto is_outside = [&](const TLorentzVector& pos) {
      return
        pos.X() < -BOXDIMS.X()/2 || BOXDIMS.X()/2 < pos.X() ||
        pos.Y() < -BOXDIMS.Y()/2 || BOXDIMS.Y()/2 < pos.Y() ||
        pos.Z() < -BOXDIMS.Z()/2 || BOXDIMS.Z()/2 < pos.Z();
    };

    auto save_point_ = [&](const TG4Trajectory& traj, size_t iPoint, size_t thePointId = 0) {
      const TG4TrajectoryPoint& p = traj.Points[iPoint];
      TrackId[N] = traj.TrackId;
      ParentId[N] = traj.ParentId;
      PointId[N] = thePointId;
      PDGCode[N] = traj.PDGCode;
      X[N] = p.Position.X();
      Y[N] = p.Position.Y();
      Z[N] = p.Position.Z();
      PX[N] = p.Momentum.X();
      PY[N] = p.Momentum.Y();
      PZ[N] = p.Momentum.Z();
      // XXX correct momentum for ionization loss in remaining rock?
      // or do that downstream?
      ++N;
    };

    auto save_point = [&](const TG4Trajectory& traj, size_t iPoint) {
      const auto npoints = traj.Points.size();
      if (iPoint >= 1) save_point_(traj, iPoint-1, -1);
      if (iPoint >= 2) save_point_(traj, iPoint-2, -2);
      save_point_(traj, iPoint, 0);
      if (npoints >= 2 && iPoint <= npoints-2) save_point_(traj, iPoint+1, 1);
      if (npoints >= 3 && iPoint <= npoints-3) save_point_(traj, iPoint+2, 2);
    };

    for (int entry = 0; m_tree->GetEntry(entry); ++entry) {
      N = 0;
      SrcEntry = entry;
      assert(m_event->Trajectories.size() <= MAXN);

      for (const auto& traj : m_event->Trajectories) {
        assert(traj.Points.size() > 1);

        if (abs(traj.PDGCode) == 12 || abs(traj.PDGCode) == 14 ||
            abs(traj.PDGCode) == 16)
          continue;

        for (size_t i = 0; i < traj.Points.size(); ++i) {
          const auto& p = traj.Points[i];

          if (not is_outside(p.Position)) {
            if (i == 0)         // E.g. from a decay in the hall
              save_point(traj, i);
            else                // We want the point i-1 that shoots into the hall
              save_point(traj, i-1);
            break;
          }

          // Are this point and previous point both outside the hall, but joined
          // by a segment that crosses the hall?
          if (i == 0) continue;
          auto xyz = [](const auto& p) { return XYZVector(p.Position.Vect()); };
          if (SegmentBoxIntersect(xyz(traj.Points[i-1]), xyz(p), BOXDIMS)) {
            std::cout << "Through-goer, event " << entry
                      << ", TrackId " << traj.TrackId << std::endl;
            save_point(traj, i-1);
            break;
          }
        }
      }

      if (N > 0)
        outTree.Fill();
    }

    outTree.Write();
  }
};
