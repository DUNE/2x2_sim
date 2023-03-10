namespace std {}
using namespace std;
#include "libTG4EventProjectHeaders.h"

#include "libTG4EventLinkDef.h"

#include "libTG4EventProjectDict.cxx"

struct DeleteObjectFunctor {
   template <typename T>
   void operator()(const T *ptr) const {
      delete ptr;
   }
   template <typename T, typename Q>
   void operator()(const std::pair<T,Q> &) const {
      // Do nothing
   }
   template <typename T, typename Q>
   void operator()(const std::pair<T,Q*> &ptr) const {
      delete ptr.second;
   }
   template <typename T, typename Q>
   void operator()(const std::pair<T*,Q> &ptr) const {
      delete ptr.first;
   }
   template <typename T, typename Q>
   void operator()(const std::pair<T*,Q*> &ptr) const {
      delete ptr.first;
      delete ptr.second;
   }
};

#ifndef TG4Event_cxx
#define TG4Event_cxx
TG4Event::TG4Event() {
}
TG4Event::TG4Event(const TG4Event & rhs)
   : TObject(const_cast<TG4Event &>( rhs ))
   , RunId(const_cast<TG4Event &>( rhs ).RunId)
   , EventId(const_cast<TG4Event &>( rhs ).EventId)
   , Primaries(const_cast<TG4Event &>( rhs ).Primaries)
   , Trajectories(const_cast<TG4Event &>( rhs ).Trajectories)
   , SegmentDetectors(const_cast<TG4Event &>( rhs ).SegmentDetectors)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
   TG4Event &modrhs = const_cast<TG4Event &>( rhs );
   modrhs.Primaries.clear();
   modrhs.Trajectories.clear();
   modrhs.SegmentDetectors.clear();
}
TG4Event::~TG4Event() {
}
#endif // TG4Event_cxx

#ifndef TG4PrimaryVertex_cxx
#define TG4PrimaryVertex_cxx
TG4PrimaryVertex::TG4PrimaryVertex() {
}
TG4PrimaryVertex::TG4PrimaryVertex(const TG4PrimaryVertex & rhs)
   : TObject(const_cast<TG4PrimaryVertex &>( rhs ))
   , Particles(const_cast<TG4PrimaryVertex &>( rhs ).Particles)
   , Informational(const_cast<TG4PrimaryVertex &>( rhs ).Informational)
   , Position(const_cast<TG4PrimaryVertex &>( rhs ).Position)
   , GeneratorName(const_cast<TG4PrimaryVertex &>( rhs ).GeneratorName)
   , Reaction(const_cast<TG4PrimaryVertex &>( rhs ).Reaction)
   , Filename(const_cast<TG4PrimaryVertex &>( rhs ).Filename)
   , InteractionNumber(const_cast<TG4PrimaryVertex &>( rhs ).InteractionNumber)
   , CrossSection(const_cast<TG4PrimaryVertex &>( rhs ).CrossSection)
   , DiffCrossSection(const_cast<TG4PrimaryVertex &>( rhs ).DiffCrossSection)
   , Weight(const_cast<TG4PrimaryVertex &>( rhs ).Weight)
   , Probability(const_cast<TG4PrimaryVertex &>( rhs ).Probability)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
   TG4PrimaryVertex &modrhs = const_cast<TG4PrimaryVertex &>( rhs );
   modrhs.Particles.clear();
   modrhs.Informational.clear();
   modrhs.GeneratorName.clear();
   modrhs.Reaction.clear();
   modrhs.Filename.clear();
}
TG4PrimaryVertex::~TG4PrimaryVertex() {
}
#endif // TG4PrimaryVertex_cxx

#ifndef TG4Trajectory_cxx
#define TG4Trajectory_cxx
TG4Trajectory::TG4Trajectory() {
}
TG4Trajectory::TG4Trajectory(const TG4Trajectory & rhs)
   : TObject(const_cast<TG4Trajectory &>( rhs ))
   , Points(const_cast<TG4Trajectory &>( rhs ).Points)
   , TrackId(const_cast<TG4Trajectory &>( rhs ).TrackId)
   , ParentId(const_cast<TG4Trajectory &>( rhs ).ParentId)
   , Name(const_cast<TG4Trajectory &>( rhs ).Name)
   , PDGCode(const_cast<TG4Trajectory &>( rhs ).PDGCode)
   , InitialMomentum(const_cast<TG4Trajectory &>( rhs ).InitialMomentum)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
   TG4Trajectory &modrhs = const_cast<TG4Trajectory &>( rhs );
   modrhs.Points.clear();
   modrhs.Name.clear();
}
TG4Trajectory::~TG4Trajectory() {
}
#endif // TG4Trajectory_cxx

#ifndef TG4PrimaryParticle_cxx
#define TG4PrimaryParticle_cxx
TG4PrimaryParticle::TG4PrimaryParticle() {
}
TG4PrimaryParticle::TG4PrimaryParticle(const TG4PrimaryParticle & rhs)
   : TObject(const_cast<TG4PrimaryParticle &>( rhs ))
   , TrackId(const_cast<TG4PrimaryParticle &>( rhs ).TrackId)
   , Name(const_cast<TG4PrimaryParticle &>( rhs ).Name)
   , PDGCode(const_cast<TG4PrimaryParticle &>( rhs ).PDGCode)
   , Momentum(const_cast<TG4PrimaryParticle &>( rhs ).Momentum)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
   TG4PrimaryParticle &modrhs = const_cast<TG4PrimaryParticle &>( rhs );
   modrhs.Name.clear();
}
TG4PrimaryParticle::~TG4PrimaryParticle() {
}
#endif // TG4PrimaryParticle_cxx

#ifndef TG4TrajectoryPoint_cxx
#define TG4TrajectoryPoint_cxx
TG4TrajectoryPoint::TG4TrajectoryPoint() {
}
TG4TrajectoryPoint::TG4TrajectoryPoint(const TG4TrajectoryPoint & rhs)
   : TObject(const_cast<TG4TrajectoryPoint &>( rhs ))
   , Position(const_cast<TG4TrajectoryPoint &>( rhs ).Position)
   , Momentum(const_cast<TG4TrajectoryPoint &>( rhs ).Momentum)
   , Process(const_cast<TG4TrajectoryPoint &>( rhs ).Process)
   , Subprocess(const_cast<TG4TrajectoryPoint &>( rhs ).Subprocess)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
}
TG4TrajectoryPoint::~TG4TrajectoryPoint() {
}
#endif // TG4TrajectoryPoint_cxx

#ifndef TG4HitSegment_cxx
#define TG4HitSegment_cxx
TG4HitSegment::TG4HitSegment() {
}
TG4HitSegment::TG4HitSegment(const TG4HitSegment & rhs)
   : TObject(const_cast<TG4HitSegment &>( rhs ))
   , Contrib(const_cast<TG4HitSegment &>( rhs ).Contrib)
   , PrimaryId(const_cast<TG4HitSegment &>( rhs ).PrimaryId)
   , EnergyDeposit(const_cast<TG4HitSegment &>( rhs ).EnergyDeposit)
   , SecondaryDeposit(const_cast<TG4HitSegment &>( rhs ).SecondaryDeposit)
   , TrackLength(const_cast<TG4HitSegment &>( rhs ).TrackLength)
   , Start(const_cast<TG4HitSegment &>( rhs ).Start)
   , Stop(const_cast<TG4HitSegment &>( rhs ).Stop)
{
   // This is NOT a copy constructor. This is actually a move constructor (for stl container's sake).
   // Use at your own risk!
   (void)rhs; // avoid warning about unused parameter
   TG4HitSegment &modrhs = const_cast<TG4HitSegment &>( rhs );
   modrhs.Contrib.clear();
}
TG4HitSegment::~TG4HitSegment() {
}
#endif // TG4HitSegment_cxx

