#include "TFile.h"
#include "TTree.h"
#include <vector>
#include "/pscratch/sd/l/lmlepin/edep-sim-MR5/edep-sim_install/include/EDepSim/TG4Event.h"
#include "TLorentzVector.h"

void filter_capture_events_v2(std::string input_file,
                           std::string output_file, 
                           bool is_spill,
                           int spillFileId,
                           double EVENT_PERIOD /*in s*/){

    /*
    
    ROOT macro to filter out neutron capture events
    It will create a new root file that will keep
    the events with a neutron capture occurring in any
    of the 2x2 modules. 

    We also modify the starting time of each event
    to be separated by 1.2 s or (your event_period of preference)
    This is in order to make it compatible with larnd-sim and nd-flow



    to run:

    root -l -b -q input_file.root filter_capture_events.C 
    
    */

    bool verbose = true; 
    double tpc_dist_x = 3.07;
    double tpc_dist_z = 2.68;
    double x_bound = 63.931;
    double y_bound = 61.85;
    double z_bound = 64.3163;

     
    TFile *inputFile = TFile::Open(input_file.c_str());
    auto geom = (TGeoManager*) inputFile->Get("EDepSimGeometry");
    TTree* events = (TTree*) inputFile->Get("EDepSimEvents");
    TG4Event* event = NULL;
    events->SetBranchAddress("Event", &event);
    Long64_t nEntries = events->GetEntries();
    std::cout << "Number of events in input file: " << nEntries << std::endl;

    // Create a new file to keep capture events:
    TFile *outFile = new TFile(output_file.c_str(), "RECREATE");
    TTree *newTree = events->CloneTree(0);  // Create an empty copy of the tree structure
    TMap *event_spill_map = new TMap(nEntries);


    int n_captures = 0;    

    // New approach, looking for neutrons whose trajectories
    // end inside the 2x2 modules 
    for(Long64_t i=0; i < nEntries; i++){
        events->GetEntry(i);
        std::vector<TG4Trajectory> trajs= event->Trajectories;
        int nTrajs = trajs.size();

        // variables to store capture vertex and time 
        double ar_T = -1;
        double ar_vx = -1;
        double ar_vy = -1;
        double ar_vz = -1; 

        bool has_capture = false;
        
        // Iterate over the trajectories of this event
        for(int itraj=0; itraj < nTrajs; itraj++){
            
            TG4Trajectory traj = trajs.at(itraj);
            int traj_pdg = traj.GetPDGCode();
            auto traj_name = traj.GetName();
            int traj_parent_id = traj.GetParentId();
            int traj_trackid = traj.GetTrackId();
            TLorentzVector p_i = traj.GetInitialMomentum(); 
            std::vector<TG4TrajectoryPoint> points = traj.Points;

            // Starting point
            // Retrieve trajectory end point 
            TG4TrajectoryPoint end_point = points.back();

            // We check if a neutron on argon happened in any of the 2x2 modules 
            // Capture code on geant4 : 4::131  
            if(traj_pdg == 2112 && end_point.GetProcess() == 4 && end_point.GetSubprocess() == 131 && 
               (TMath::Abs(end_point.GetPosition()[0]/10.) < x_bound && TMath::Abs(end_point.GetPosition()[0]/10.) > tpc_dist_x) &&
               (TMath::Abs(end_point.GetPosition()[1]/10.) < y_bound ) &&
               (TMath::Abs(end_point.GetPosition()[2]/10.) < z_bound && TMath::Abs(end_point.GetPosition()[2]/10.) > tpc_dist_z)){

                // Get time of neutron capture
                ar_vx = end_point.GetPosition()[0]/10.;
                ar_vy = end_point.GetPosition()[1]/10.;
                ar_vz = end_point.GetPosition()[2]/10.;
                ar_T = end_point.GetPosition()[3]; 

                has_capture = true;
                
                if(verbose){
                    std::cout << "Event " << i << ", with eventd_id: " << event->EventId << ", with traj id: " << traj_trackid <<  std::endl;
                     std::cout << "Particle PDG " << traj_pdg << " captured at T = " << end_point.GetPosition()[3] << 
                     ", X = " << end_point.GetPosition()[0]/10. << ", Y = " << end_point.GetPosition()[1]/10. << " Z = " << end_point.GetPosition()[2]/10. << std::endl;
                }

                int globalSpillId = int(1E3)*spillFileId + (n_captures+1);
                double event_time = (1e9)*EVENT_PERIOD*(n_captures+1);
                double old_event_time = 0.;


                std::string event_string = std::to_string(event->RunId) + " " + std::to_string(event->EventId);
                std::string spill_string = std::to_string(globalSpillId);
                TObjString* event_tobj = new TObjString(event_string.c_str());
                TObjString* spill_tobj = new TObjString(spill_string.c_str());
                
                if (event_spill_map->FindObject(event_string.c_str()) == 0)
                event_spill_map->Add(event_tobj, spill_tobj);
                else {
                std::cerr << "[ERROR] redundant event ID " << event_string.c_str() << std::endl;
                std::cerr << "event_spill_map entries = " << event_spill_map->GetEntries() << std::endl;
                throw;
                }

                // Modify times 
                // ... interaction vertex
                for (std::vector<TG4PrimaryVertex>::iterator v = event->Primaries.begin(); v != event->Primaries.end(); ++v) {
                    //v->Position.T() = event_time;
                    old_event_time = v->Position.T();
                    v->Position.SetT(event_time);
                    // TMS reco wants the InteractionNumber to be the entry number of the
                    // vertex in DetSimPassThru/gRooTracker. Since, by construction, our
                    // EDepSimEvents and gRooTracker trees are aligned one-to-one, we just
                    // trivially set InteractionNumber to be the current entry number.
                    // https://github.com/DUNE/2x2_sim/issues/54
                    //v->InteractionNumber = n_captures+1;
                    }
                    
                    // ... trajectories
                    for (std::vector<TG4Trajectory>::iterator t = event->Trajectories.begin(); t != event->Trajectories.end(); ++t) {
                    // loop over all points in the trajectory
                    for (std::vector<TG4TrajectoryPoint>::iterator p = t->Points.begin(); p != t->Points.end(); ++p) {
                    double offset = p->Position.T() - old_event_time;
                    p->Position.SetT(event_time + offset);
                    }
                    }
                    
                    // ... and, finally, energy depositions
                    for (auto d = event->SegmentDetectors.begin(); d != event->SegmentDetectors.end(); ++d) {
                    for (std::vector<TG4HitSegment>::iterator h = d->second.begin(); h != d->second.end(); ++h) {
                    double start_offset = h->Start.T() - old_event_time;
                    double stop_offset = h->Stop.T() - old_event_time;
                    h->Start.SetT(event_time + start_offset);
                    h->Stop.SetT(event_time + stop_offset);
                    }
                }
             }
           }
        // Copy this entry to the new output file
        if(has_capture){newTree->Fill(); n_captures+=1;}
    }

       

    std::cout << "Number of captures identified: " << n_captures << std::endl;
    std::cout << "Saving temporary file... " << n_captures << std::endl;
    newTree->Write();
    event_spill_map->Write("event_spill_map", 1);
    auto p = new TParameter<double>("spillPeriod_s", EVENT_PERIOD);
    p->Write();
    geom->Write();
    outFile->Close();
}