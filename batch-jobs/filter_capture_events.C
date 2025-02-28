#include "TFile.h"
#include "TTree.h"
#include <vector>
#include "TG4Event.h"
#include "TLorentzVector.h"

void filter_capture_events(){

    /*
    
    ROOT macro to filter out neutron capture events
    It will create a new root file that will keep
    the events with a neutron capture occurring 
    inside the 2x2 modules 

    to run:

    root -l -b -q input_file.root filter_capture_events.C 
    
    */

    bool verbose = false; 
    double tpc_dist = 3.07;
    double x_bound = 63.931;
    double y_bound = 62.076;
    double z_bound = 64.3163;

    TTree* events = (TTree*) gFile->Get("EDepSimEvents");
    TG4Event* event = NULL;
    events->SetBranchAddress("Event", &event);
    Long64_t nEntries = events->GetEntries();


    // Create a new file to keep capture events:
    char *outputFile = "2x2_captures_filtered_edepsim.root";
    TFile *outFile = new TFile(outputFile, "RECREATE");
    TTree *newTree = events->CloneTree(0);  // Create an empty copy of the tree structure
 

    int n_captures = 0;    
    for(Long64_t i=0; i < nEntries; i++){

    
        events->GetEntry(i);
        std::vector<TG4Trajectory> trajs= event->Trajectories;
        std::vector<TG4Trajectory> nc_photons;
        int nTrajs = trajs.size();

        // check if there is an argon41 (product of n-capture)
        int n_ar41 = 0; 

        // variables to store capture vertex and time 
        double ar_T = -1;
        double ar_vx = -1;
        double ar_vy = -1;
        double ar_vz = -1; 
        
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
            TG4TrajectoryPoint starting_point = points[0];

            // We check if a neutron on argon happened in any of the 2x2 modules 
            // Capture code on geant4 : 4::131  
            if(traj_parent_id == 0 && starting_point.GetProcess() == 4 && starting_point.GetSubprocess() == 131 && 
               (TMath::Abs(starting_point.GetPosition()[0]/10.) < x_bound && TMath::Abs(starting_point.GetPosition()[0]/10.) > tpc_dist) &&
               (TMath::Abs(starting_point.GetPosition()[1]/10.) < y_bound ) &&
               (TMath::Abs(starting_point.GetPosition()[2]/10.) < z_bound && TMath::Abs(starting_point.GetPosition()[2]/10.) > tpc_dist) &&
               traj_pdg == 1000180410){
                n_ar41 +=1;
                // Get time of n-Ar inelastic interaction 
                ar_vx = starting_point.GetPosition()[0]/10.;
                ar_vy = starting_point.GetPosition()[1]/10.;
                ar_vz = starting_point.GetPosition()[2]/10.;
                ar_T = starting_point.GetPosition()[3]; 
                
                if(verbose){
                    std::cout << "Event " << i << ", with eventd_id: " << event->EventId <<  std::endl;
                     std::cout << "Primary particle PDG " << traj_pdg << " created at T = " << starting_point.GetPosition()[3] << 
                     ", X = " << starting_point.GetPosition()[0]/10. << ", Y = " << starting_point.GetPosition()[1]/10. << " Z = " << starting_point.GetPosition()[2]/10. << std::endl;
                }
            }
        }

         // If there is a capture, look for associated gammas 
        if(n_ar41==1){
            for(int itraj=0; itraj < nTrajs; itraj++){
                TG4Trajectory traj = trajs.at(itraj);
                int traj_pdg = traj.GetPDGCode();
                auto traj_name = traj.GetName();
                int traj_parent_id = traj.GetParentId();
                int traj_trackid = traj.GetTrackId();
                TLorentzVector p_i = traj.GetInitialMomentum(); 
                std::vector<TG4TrajectoryPoint> points = traj.Points;
                // Check for inelastic photons produced at the same time as Ar  
                if(traj_parent_id == 0 && points[0].GetProcess() == 4 && points[0].GetSubprocess() == 131
                && traj_pdg == 22 && points[0].GetPosition()[3] == ar_T){
                    if(verbose){
                        std::cout << "Primary particle PDG " << traj_pdg << " created at T = " << points[0].GetPosition()[3] << 
                        ", X = " << points[0].GetPosition()[0]/10. << ", Y = " << points[0].GetPosition()[1]/10. << " Z = " << points[0].GetPosition()[2]/10. << ", E = " <<  p_i[3]  << std::endl;
                    }
                    nc_photons.push_back(traj);
                }
                
        }
        }


        if(n_ar41 == 1 && nc_photons.size() > 1){
            if(verbose){
                std::cout << "n capture identified..." << std::endl;
                std::cout << "Number of gammas released " << nc_photons.size() << std::endl;

            }
            // Copy this entry to the new output file
            // Don't forget to change the event_id 
            event->EventId = n_captures;
            newTree->Fill();
            n_captures+=1;
            
        }
        nc_photons.clear();
        }

    std::cout << "Number of captures identified: " << n_captures << std::endl;
    std::cout << "Saving temporary file... " << n_captures << std::endl;
    newTree->Write();
    outFile->Close();
}