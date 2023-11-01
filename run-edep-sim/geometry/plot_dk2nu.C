// root -l inspectgeom.C eve_display.C load_dk2nu.C plot_dk2nu.C g4numiv6_minervame_me000z-200i_42_0001.dk2nu
// eve_display("Merged2x2MINERvA_v3/Merged2x2MINERvA_v3_withRock.gdml")
// // auto [tree, dk2nu] = loadFlux(_file0);
// // auto tup = loadFlux(_file0); auto tree = std::get<0>(tup); auto dk2nu = std::get<1>(tup);
// bsim::Dk2Nu* dk2nu; auto& tree = loadFlux(*_file0, dk2nu)
// tree.GetEntry(0)
// drawTraj(*dk2nu)

// #include "dk2nu/tree/dk2nu.h"

// So ROOT doesn't complain when we pass this file on the cmdline
void plot_dk2nu() {}

using ROOT::Math::XYZVector;

static constexpr double ROTATION_X = -0.0582977560; // rad (from GNuMiFlux.xml)
static constexpr double BEAM_ORIGIN = 1036.48837;   // meter (from GNuMiFlux.xml)
// static constexpr double ZMIN = -15000;              // ROOT (cm)
// static constexpr double ZMAX = 5000;                // ROOT (cm)

TTree& loadFlux(TFile& f, bsim::Dk2Nu*& dk2nu_ptr)
{
  TTree& tree = *(TTree*)f.Get("dk2nuTree");
  dk2nu_ptr = nullptr;
  tree.SetBranchAddress("dk2nu", &dk2nu_ptr);
  return tree;
}

bsim::Traj beam2user(const bsim::Traj& beam)
{
  const double cosTh = TMath::Cos(ROTATION_X);
  const double sinTh = TMath::Sin(ROTATION_X);

  bsim::Traj user;

  user.trkpx = beam.trkpx;
  user.trkpy = cosTh*beam.trkpy + sinTh*beam.trkpz;
  user.trkpz = -sinTh*beam.trkpy + cosTh*beam.trkpz;

  user.trkx = beam.trkx;
  // user.trky = cosTh*beam.trky + sinTh*(beam.trkz - BEAM_ORIGIN);
  // user.trkz = -sinTh*beam.trky + cosTh*(beam.trkz - BEAM_ORIGIN);

  // the offsets for the fact that cryostat is not centered at origin in MR4
  user.trky = cosTh*beam.trky + sinTh*(beam.trkz - BEAM_ORIGIN) - 3.1;
  user.trkz = -sinTh*beam.trky + cosTh*(beam.trkz - BEAM_ORIGIN) + 13;

  return user;
}

bsim::Traj beam2root(const bsim::Traj& beam)
{
  bsim::Traj root = beam2user(beam);

  // GENIE uses m, ROOT uses cm

  root.trkx *= 100;
  root.trky *= 100;
  root.trkz *= 100;

  return root;
}

void drawTraj(const bsim::Dk2Nu& dk2nu)
{
  std::vector<XYZVector> points;

  for (const bsim::Traj& beam : dk2nu.traj) {
    bsim::Traj root = beam2root(beam);
    // std::cout << beam.trkx << " " << beam.trky << " " << beam.trkz << std::endl;
    // std::cout << root.trkx << " " << root.trky << " " << root.trkz << std::endl << std::endl;
    // if (root.trkz < ZMIN || root.trkz > ZMAX)
    //   continue;

    // Avoid wild coordinates in case they trip up Eve
    if (fabs(root.trkx) > 1e6 || fabs(root.trky) > 1e6 || fabs(root.trkz) > 1e6)
      continue;

    points.emplace_back(root.trkx, root.trky, root.trkz);
  }

  // std::cout << std::endl;

  auto line = new TEveLine(points.size());
  for (size_t i = 0; i < points.size(); ++i) {
    line->SetPoint(i, points[i].X(), points[i].Y(), points[i].Z());
    // std::cout << points[i].X() << " " << points[i].Y() << " " << points[i].Z() << std::endl;
  }
  line->SetLineColor(kRed);
  gEve->AddElement(line);
}

// plot_dk2nu(*_file0)
void plot_dk2nu(TFile& fluxFile,
                size_t nrays = 100,
                const char* geom = "Merged2x2MINERvA_v3/Merged2x2MINERvA_v3_withRock.gdml")
{
  // TODO: Set transparency of rock and hall
  static bsim::Dk2Nu* dk2nu;
  eve_display(geom);
  auto& tree = loadFlux(fluxFile, dk2nu);
  for (size_t i = 0; i < nrays; ++i) {
    tree.GetEntry(i);
    drawTraj(*dk2nu);
  }
}
