#include "TG4Event.h"

// Simple root macro meant to take in an output file from edep-sim
// containing single neutrino interactions (from some flux) in the
// event tree and overlay these events into full spills.
//
// The output will have two changes with respect to the input:
//
//   (1) The EventId is now non-unique for each tree entry
//       (= individual neutrino interaction) and indicates which
//       spill the event should be assigned to.
//
//   (2) The timing information is edited to impose the timing
//       microstructure of the numi/lbnf beamline.
// returns a random time for a neutrino interaction to take place within
// a LBNF/NuMI spill, given the beam's micro timing structure

double getInteractionTime_LBNF() {

  // time unit is nanoseconds
  double t;
  bool finding_time = true;

  while(finding_time) {
    unsigned int batch = gRandom->Integer(6); // batch number between 0 and 5 (6 total)
    unsigned int bunch = gRandom->Integer(84); // bunch number between 0 and 83 (84 total)
    if((bunch==0||bunch==1||bunch==82||bunch==83)&&gRandom->Uniform(1.)<0.5) continue;
    else {
      t = gRandom->Uniform(1.)+bunch*19.+batch*1680;
      finding_time = false;
    }
  }

  return t;

}

void overlaySinglesIntoSpills(std::string inFileName1, std::string inFileName2, std::string outFileName = "spillFile", double inFile1POT = 1.024E19, double inFile2POT = 1.024E19, double spillPOT = 6.5E13) {

  // get input nu-LAr files 
  TChain* edep_evts_1 = new TChain("EDepSimEvents");
  edep_evts_1->Add(inFileName1.c_str());
  //edep_evts_1->Add("");

  // get input nu-Rock files 
  TChain* edep_evts_2 = new TChain("EDepSimEvents");
  edep_evts_2->Add(inFileName2.c_str());
  //edep_evts_2->Add("");

  unsigned int N_evts_1 = edep_evts_1->GetEntries();
  double evts_per_spill_1 = ((double)N_evts_1)/(inFile1POT/spillPOT);

  unsigned int N_evts_2 = edep_evts_2->GetEntries();
  double evts_per_spill_2 = ((double)N_evts_2)/(inFile2POT/spillPOT);

  std::cout << "File: " << inFileName1 << std::endl;
  std::cout << "    Number of spills: "<< inFile1POT/spillPOT << std::endl;
  std::cout << "    Events per spill: "<< evts_per_spill_1 << std::endl;

  std::cout << "File: " << inFileName2 << std::endl;
  std::cout << "    Number of spills: "<< inFile2POT/spillPOT << std::endl;
  std::cout << "    Events per spill: "<< evts_per_spill_2 << std::endl;

  TG4Event* edep_evt_1 = NULL;
  edep_evts_1->SetBranchAddress("Event",&edep_evt_1);
  unsigned int N_left_1 = N_evts_1;

  TG4Event* edep_evt_2 = NULL;
  edep_evts_2->SetBranchAddress("Event",&edep_evt_2);
  unsigned int N_left_2 = N_evts_2;

  // Poisson fluctuation of average number of events per spill in this file
  int Nevts_this_spill_1 = gRandom->Poisson(evts_per_spill_1);
  int evt_it_1 = 0;

  // Poisson fluctuation of average number of events per spill in this file
  int Nevts_this_spill_2 = gRandom->Poisson(evts_per_spill_2);
  int evt_it_2 = 0;

  int spillN = 0;

  //while((N_left_1 > Nevts_this_spill_1) && (N_left_2 > Nevts_this_spill_2)) {
  while((N_left_1 > Nevts_this_spill_1) && (N_left_2 > Nevts_this_spill_2) && spillN<128*4) {

    spillN++;
    std::cout << "working on spill # " << spillN << std::endl;

    // make output file
    TFile* outFile = new TFile(Form("%s_%d.root",outFileName.c_str(),spillN),"RECREATE");
    TTree* new_tree = edep_evts_1->CloneTree(0);
    TTree* new_tree2 = edep_evts_2->CloneTree(0);

    // loop over the correct number of nu-LAr events for this spill
    int evt_spill_counter_1=0;
    while(evt_spill_counter_1 < Nevts_this_spill_1) {
      edep_evts_1->GetEntry(evt_it_1);
      // change the eventID to correspond to the spill ID
      // this ID will not be unique for each entry in the tree
      //edep_evt_1->EventId = spillN;

      // assign time offsets to...
      double event_time = getInteractionTime_LBNF();
      double old_event_time = 0.;

      // ... interaction vertex
      for (std::vector<TG4PrimaryVertex>::iterator v = edep_evt_1->Primaries.begin(); v != edep_evt_1->Primaries.end(); ++v) {
        //v->Position.T() = event_time;
        old_event_time = v->Position.T();
        v->Position.SetT(event_time);
      }

      // ... trajectories
      for (std::vector<TG4Trajectory>::iterator t = edep_evt_1->Trajectories.begin(); t != edep_evt_1->Trajectories.end(); ++t) {
        // loop over all points in the trajectory  
        for (std::vector<TG4TrajectoryPoint>::iterator p = t->Points.begin(); p != t->Points.end(); ++p) {
          double offset = p->Position.T() - old_event_time;
          p->Position.SetT(event_time + offset);
        }
      }

      // ... and, finally, energy depositions
      for (auto d = edep_evt_1->SegmentDetectors.begin(); d != edep_evt_1->SegmentDetectors.end(); ++d) {
        for (std::vector<TG4HitSegment>::iterator h = d->second.begin(); h != d->second.end(); ++h) {
          double start_offset = h->Start.T() - old_event_time;
          double stop_offset = h->Stop.T() - old_event_time;
          h->Start.SetT(event_time + start_offset);
          h->Stop.SetT(event_time + stop_offset);
        }
      }
      new_tree->Fill();
      evt_spill_counter_1++;
      evt_it_1++;
      N_left_1--;
    } // nu-LAr event loop

    // loop over the correct number of nu-Rock events for this spill
    int evt_spill_counter_2=0;
    while(evt_spill_counter_2 < Nevts_this_spill_2) {
      edep_evts_2->GetEntry(evt_it_2);
      // change the eventID to correspond to the spill ID
      // this ID will not be unique for each entry in the tree
      //edep_evt_2->EventId = spillN;

      // assign time offsets to...
      double event_time = getInteractionTime_LBNF();
      double old_event_time = 0.;

      // ... interaction vertex
      for (std::vector<TG4PrimaryVertex>::iterator v = edep_evt_2->Primaries.begin(); v != edep_evt_2->Primaries.end(); ++v) {
        //v->Position.T() = event_time;
        old_event_time = v->Position.T();
        v->Position.SetT(event_time);
      }

      // ... trajectories
      for (std::vector<TG4Trajectory>::iterator t = edep_evt_2->Trajectories.begin(); t != edep_evt_2->Trajectories.end(); ++t) {
        // loop over all points in the trajectory  
        for (std::vector<TG4TrajectoryPoint>::iterator p = t->Points.begin(); p != t->Points.end(); ++p) {
          double offset = p->Position.T() - old_event_time;
          p->Position.SetT(event_time + offset);
        }
      }

      // ... and, finally, energy depositions
      for (auto d = edep_evt_2->SegmentDetectors.begin(); d != edep_evt_2->SegmentDetectors.end(); ++d) {
        for (std::vector<TG4HitSegment>::iterator h = d->second.begin(); h != d->second.end(); ++h) {
          double start_offset = h->Start.T() - old_event_time;
          double stop_offset = h->Stop.T() - old_event_time;
          h->Start.SetT(event_time + start_offset);
          h->Stop.SetT(event_time + stop_offset);
        }
      }

      new_tree2->Fill();
      evt_spill_counter_2++;
      evt_it_2++;
      N_left_2--;
    } // nu-Rock event loop

    // write this spill file out
    TList* tree_list = new TList;
    tree_list->Add(new_tree);
    tree_list->Add(new_tree2);
    TTree* fullSpillTree = TTree::MergeTrees(tree_list);
    fullSpillTree->SetName("EDepSimEvents");
    outFile->cd();
    fullSpillTree->Write();
    outFile->Close();
    //delete new_tree;
    delete outFile;

    // for next spill
    Nevts_this_spill_1 = gRandom->Poisson(evts_per_spill_1); 
    Nevts_this_spill_2 = gRandom->Poisson(evts_per_spill_2); 

  } // spill loop

}
