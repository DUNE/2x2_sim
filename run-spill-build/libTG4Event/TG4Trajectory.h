//////////////////////////////////////////////////////////
//   This class has been generated by TFile::MakeProject
//     (Fri Feb 24 17:58:52 2023 by ROOT version 6.14/06)
//      from the StreamerInfo in file ../run-edep-sim/output/MiniRun1_1E19_RHC_nu/EDEPSIM/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.root
//////////////////////////////////////////////////////////


#ifndef TG4Trajectory_h
#define TG4Trajectory_h
class TG4Trajectory;

#include "Rtypes.h"
#include "TObject.h"
#include "Riostream.h"
#include <vector>
#include "TG4TrajectoryPoint.h"
#include <string>
#include "TLorentzVector.h"

class TG4Trajectory : public TObject {

public:
// Nested classes declaration.

public:
// Data Members.
   vector<TG4TrajectoryPoint> Points;      //
   int                        TrackId;     //
   int                        ParentId;    //
   string                     Name;        //
   int                        PDGCode;     //
   TLorentzVector             InitialMomentum;    //

   TG4Trajectory();
   TG4Trajectory(const TG4Trajectory & );
   virtual ~TG4Trajectory();

   ClassDef(TG4Trajectory,2); // Generated by MakeProject.
};
#endif
