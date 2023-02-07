// XXX add EvtCode so that edep-sim doesn't complain

// Takes edep-sim's rock sim output, extracts particles that enter the hall, and
// dumps them back to gtrac for use by the spill builder (or direct to detector
// edep-sim)

#ifndef CINT
#include <TG4Event.h>
#endif

#include <Math/Vector3D.h>
#include <TDatabasePDG.h>
#include <TFile.h>
#include <TLorentzVector.h>
#include <TMath.h>
#include <TTree.h>

using ROOT::Math::XYZVector;

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


class RockExtractor {
public:
  RockExtractor(const char* edep_path = "edep.root",
                const char* out_path = "rock_debris.root");

  void Extract();

private:
  bool IsOutsideHall(const TLorentzVector& pos);
  void SaveParticle(const TG4Trajectory& traj, size_t pointId, int entryId);
  void SaveDivider();

  TFile fInFile;
  TTree* fInTree;
  TG4Event* fEvent = nullptr;
  int fLastEntryId = -1;

  TFile fOutFile;
  TTree* fOutTree;

  static const Int_t MAXN = 1;
  // output branches:
  Int_t bEvtNum;
  Double_t bEvtVtx[4];
  Int_t bStdHepN;
  Int_t bStdHepPDG[MAXN];
  Int_t bStdHepStatus[MAXN];
  Double_t bStdHepP4[MAXN][4];

  static constexpr double LEN_SCALE = 1e-3;    // gRooTracker uses m; EDepSimEvents uses mm
  static constexpr double E_SCALE = 1e-3;      // gRooTracker and TDatabasePDG use GeV; EDepSimEvents uses MeV
  const XYZVector BOXDIMS = {10000, 5500, 20000}; // Edep units (mm)
};

RockExtractor::RockExtractor(const char* edep_path, const char* out_path)
  : fInFile(edep_path), fOutFile(out_path, "RECREATE")
{
  fInTree = (TTree*) fInFile.Get("EDepSimEvents");
  fInTree->SetBranchAddress("Event", &fEvent);

  fOutFile.cd();
  fOutTree = new TTree("gRooTracker", "Rock rootracker");

  fOutTree->Branch("EvtNum", &bEvtNum, "EvtNum/I");
  fOutTree->Branch("EvtVtx", bEvtVtx, "EvtVtx[4]/D");
  fOutTree->Branch("StdHepN", &bStdHepN, "StdHepN/I");
  fOutTree->Branch("StdHepPDG", bStdHepPDG, "StdHepPDG[StdHepN]/I");
  fOutTree->Branch("StdHepStatus", bStdHepStatus, "StdHepStatus[StdHepN]/I");
  fOutTree->Branch("StdHepP4", bStdHepP4, "StdHepP4[StdHepN][4]/D");
}

bool RockExtractor::IsOutsideHall(const TLorentzVector& pos)
{
  return
    pos.X() < -BOXDIMS.X()/2 || BOXDIMS.X()/2 < pos.X() ||
    pos.Y() < -BOXDIMS.Y()/2 || BOXDIMS.Y()/2 < pos.Y() ||
    pos.Z() < -BOXDIMS.Z()/2 || BOXDIMS.Z()/2 < pos.Z();
}

void RockExtractor::SaveParticle(const TG4Trajectory& traj, size_t pointId, int entryId)
{
  if (fLastEntryId != -1 && fLastEntryId != entryId)
    SaveDivider();

  const TG4TrajectoryPoint& p = traj.Points[pointId];
  bStdHepN = 1;
  bStdHepPDG[0] = traj.PDGCode;
  bEvtVtx[0] = p.Position.X() * LEN_SCALE;
  bEvtVtx[1] = p.Position.Y() * LEN_SCALE;
  bEvtVtx[2] = p.Position.Z() * LEN_SCALE;
  bEvtVtx[3] = p.Position.T(); // XXX time scale factor?
  bStdHepStatus[0] = 1;
  const double pX = bStdHepP4[0][0] = p.Momentum.X();
  const double pY = bStdHepP4[0][1] = p.Momentum.Y();
  const double pZ = bStdHepP4[0][2] = p.Momentum.Z();
  const double m_MeV = E_SCALE *
    TDatabasePDG::Instance()->GetParticle(traj.PDGCode)->Mass();
  bStdHepP4[0][3] = TMath::Sqrt(pX*pX + pY*pY + pZ*pZ + m_MeV*m_MeV);

  fOutTree->Fill();
  ++bEvtNum;

  fLastEntryId = entryId;
}

void RockExtractor::SaveDivider()
{
  bStdHepN = 1;
  bStdHepPDG[0] = 0;
  bEvtVtx[0] = 0;
  bEvtVtx[1] = 0;
  bEvtVtx[2] = 0;
  bEvtVtx[3] = 0;
  bStdHepStatus[0] = -1;
  bStdHepP4[0][0] = 0;
  bStdHepP4[0][1] = 0;
  bStdHepP4[0][2] = 0;
  bStdHepP4[0][3] = 0;

  fOutTree->Fill();
  ++bEvtNum;
}

void RockExtractor::Extract()
{
  bEvtNum = 0;

  for (int entry = 0; fInTree->GetEntry(entry); ++entry) {
    for (const auto& traj : fEvent->Trajectories) {
      if (abs(traj.PDGCode) == 12 || abs(traj.PDGCode) == 14 ||
          abs(traj.PDGCode) == 16)
        continue;

      if ((traj.PDGCode == 11 && traj.InitialMomentum.P() < 50) ||
          (traj.PDGCode == 22 && traj.InitialMomentum.P() < 5)) // XXX derived from histograms
        continue;

      for (size_t i = 0; i < traj.Points.size(); ++i) {
        const auto& p = traj.Points[i];

        if (not IsOutsideHall(p.Position)) {
          SaveParticle(traj, i, entry);
          break;
        }

        // Are this point and previous point both outside the hall, but joined
        // by a segment that crosses the hall? This shouldn't be happening now
        // that we've hacked away the SensDet requirement and set
        if (i == 0) continue;
        auto xyz = [](const auto& p) { return XYZVector(p.Position.Vect()); };
        if (SegmentBoxIntersect(xyz(traj.Points[i-1]), xyz(p), BOXDIMS)) {
          std::cout << "Through-goer, event " << entry
                    << ", TrackId " << traj.TrackId << std::endl;
          SaveParticle(traj, i-1, entry);
          break;
        }
      }
    }
  }

  fOutTree->Write();
}

// void ExtractRockDebris(const char* edep_path = "edep.root", const char* out_path = "rock_debris.root")
// {
//   TFile fin(edep_path);
//   auto in_tree = (TTree*) fin.Get("EDepSimEvents");
//   TG4Event* event = nullptr;
//   in_tree->SetBranchAddress("Event", &event);

//   TFile fout(out_path, "RECREATE");
//   TTree out_tree("gRooTracker", "Rock rootracker");

//   // const Int_t MAXN = 25000
//   const Int_t MAXN = 1;
//   Int_t bEvtNum;
//   Double_t bEvtVtx[4];
//   Int_t bStdHepN;
//   Int_t bStdHepPDG[MAXN];
//   Int_t bStdHepStatus[MAXN];
//   Double_t bStdHepP4[MAXN][4];

//   out_tree->Branch("EvtNum", &bEvtNum, "EvtNum/I");
//   out_tree->Branch("EvtVtx", bEvtVtx, "EvtVtx[4]/D");
//   out_tree->Branch("StdHepN", &bStdHepN, "StdHepN/I");
//   out_tree->Branch("StdHepPDG", bStdHepPDG, "StdHepPDG[StdHepN]/I");
//   out_tree->Branch("StdHepStatus", bStdHepStatus, "StdHepStatus[StdHepN]/I");
//   out_tree->Branch("StdHepP4", bStdHepP4, "StdHepP4[StdHepN][4]/D");


//   const XYZVector BOXDIMS = {10000, 5500, 20000}; // Edep units (mm)

//   auto is_outside = [&](const TLorentzVector& pos) {
//     return
//       pos.X() < -BOXDIMS.X()/2 || BOXDIMS.X()/2 < pos.X() ||
//       pos.Y() < -BOXDIMS.Y()/2 || BOXDIMS.Y()/2 < pos.Y() ||
//       pos.Z() < -BOXDIMS.Z()/2 || BOXDIMS.Z()/2 < pos.Z();
//   };

//   auto save_particle = [&](const TG4Trajectory& traj, size_t iPoint) {
//     const TG4TrajectoryPoint& p = traj.Points[iPoint];
//     bStdHepN = 1;
//     bStdHepPDG[0] = traj.PDGCode;
//     bEvtVtx[0][0] = p.Position.X();
//     bEvtVtx[0][1] = p.Position.Y();
//     bEvtVtx[0][2] = p.Position.Z();
//     bEvtVtx[0][3] = p.Position.T();
//     bStdHepStatus[0] = 1;
//     const double pX = bStdHepP4[0] = p.Momentum.X();
//     const double pY = bStdHepP4[1] = p.Momentum.Y();
//     const double pZ = bStdHepP4[2] = p.Momentum.Z();
//     const double m_MeV = e_scale *
//       TDatabasePDG::Instance()->GetParticle(traj.PDGCode)->Mass();
//     bStdHepP4[3] = TMath::Sqrt(pX*pX + pY*pY + pZ*pZ + m_MeV*m_MeV);

//     out_tree->Fill();
//     ++bEvtNum;
//   };

//   // See comments in EDepSimRooTrackerKinematicsGenerator.hh
//   auto save_divider = [&]() {
//     bStdHepN = 1;
//     bStdHepPDG[0] = 0;
//     bEvtVtx[0][0] = 0;
//     bEvtVtx[0][1] = 0;
//     bEvtVtx[0][2] = 0;
//     bEvtVtx[0][3] = 0;
//     bStdHepStatus[0] = -1;
//     bStdHepP4[0] = 0;
//     bStdHepP4[1] = 0;
//     bStdHepP4[2] = 0;
//     bStdHepP4[3] = 0;

//     out_tree->Fill();
//     ++bEvtNum;
//   }

//   bEvtNum = 0;
// }
