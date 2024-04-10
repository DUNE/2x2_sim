import ROOT as R
import numpy as np
import sys
import subprocess
import argparse
import configparser


DEBUG=False
R.gROOT.ProcessLine(
"struct struct_spill {\
   Int_t     entry_spill;\
};" );

R.gROOT.ProcessLine(
"struct struct_meta {\
   Int_t runnumber;\
   Float_t offset_x;\
   Float_t offset_y;\
   Float_t offset_z;\
   Char_t  processing [300] ;\
   Char_t  edepsim_file_name [300] ;\
};" );



def unique(list1):
 
    # initialize a null list
    unique_list = []
 
    # traverse for all elements
    for x in list1:
        # check if exists in unique_list or not
        if x not in unique_list:
            unique_list.append(x)
    # print list
    return unique_list

def get_evis(hit, fbirks):
    edep = hit.GetEnergyDeposit();
    niel = hit.GetSecondaryDeposit();
    length = hit.GetTrackLength();
    
    evis = edep;
        
        
    nloss = niel
    if nloss <0 :
        nloss = 0
    eloss = edep - nloss
    if ((eloss < 0) or (length <=0)):
        nloss = edep
        eloss = 0
    
    if (eloss > 0):
        eloss /= (1 + fbirks * eloss/length)
    
    if (nloss > 0):
        nloss /= (1 + fbirks * nloss/length)
    
    evis = nloss + eloss
    
    return evis


def main(args,option_type):

    # Default values
    offset_x = 0.0
    offset_y = 0.0
    offset_z = 0.0
    input_dir = ""
    input_file = ""
    runnum = 0
    output_dir = ""

    output_name = ""

    # Inline configuration
    if (option_type==1) :
        offset_x = args.offset_x
        offset_y = args.offset_y
        offset_z = args.offset_z
        input_dir = args.input_dir
        input_file = args.input_file
        runnum = args.run_number
        output_dir = args.output_dir
        output_name = args.output_file

    # config file


    
    if (option_type==0):
        my_arg_list = {"offset_x", "offset_y", }
        offset_x = float(args["offset_x"])
        offset_y = float(args["offset_y"])
        offset_z = float(args["offset_z"])
        input_dir = args["file_path"]
        input_file = args["file_name"]
        runnum = int(args["run_number"])
        output_dir = args["output_dir"]
        if "output_name" in args: 
            output_name = args["output_name"]

    print("Making flat file with the following arguments:")
    print(f"Offsets: x={offset_x}, y={offset_y}, z={offset_z}")
    print(f"File path: {input_dir}")
    print(f"File name: {input_file}")
    print(f"Run number: {runnum}")
    print(f"Output directory: {output_dir}")


    print("Processing input file:", input_file)
    tFile = R.TFile.Open(input_dir+"/"+input_file)

    # Get the event tree.
    events = tFile.Get("EDepSimEvents")
    tmap = tFile.Get("event_spill_map")

    # Set the branch address.
    event = R.TG4Event()
    events.SetBranchAddress("Event",R.AddressOf(event))

    if (output_name == None or output_name == "" ):
        output_name = "Flat_"+input_file

    print(f'Writing', output_name)
    froot = R.TFile(output_dir+"/"+output_name,"recreate")

    # froot = R.TFile("ouput_plain_root_small.root","recreate")
    t_hit = R.TTree("Event", "Hits deposited") 
    t_traj = R.TTree("Trajectories","Trajectories dumped into std vectors")
    t_meta = R.TTree("Meta","Metadata of the file")


    struct_spill = R.struct_spill()




    m_StartX = R.std.vector("float")()
    m_StopX = R.std.vector("float")()
    m_StartY = R.std.vector("float")()
    m_StopY = R.std.vector("float")()
    m_StartZ = R.std.vector("float")()
    m_StopZ = R.std.vector("float")()
    m_StartT = R.std.vector("float")()
    m_StopT = R.std.vector("float")()
    m_energy = R.std.vector("float")() 
    m_length = R.std.vector("float")()
    m_p = R.std.vector("float")()
    m_TrackId = R.std.vector("int")()
    m_energyAfterBirks = R.std.vector("float")()

    m_event_entry = R.std.vector("int")()
    m_real_entry = R.std.vector("int")()
    m_RunId = R.std.vector("int")()


    m_pdg = R.std.vector("int")()
    m_volume = R.std.vector("string")()
    # m_volume = R.std.vector("TString")()


    m_traj_real_TrackId = R.std.vector("int")() 
    m_traj_real_entry = R.std.vector("int")()

    m_trajTrackId = R.std.vector("int")()
    m_trajParentId = R.std.vector("int")()
    m_trajName = R.std.vector("string")()
    m_trajPdg = R.std.vector("int")()
    m_trajLongVertexId =R.std.vector("long int")()

    m_trajInitPx = R.std.vector(("float"))()
    m_trajInitPy = R.std.vector(("float"))()
    m_trajInitPz = R.std.vector(("float"))()
    m_trajInitE  = R.std.vector(("float"))()
    

    m_trajPointsx = R.std.vector(R.std.vector("float"))()
    m_trajPointsy = R.std.vector(R.std.vector("float"))()
    m_trajPointsz = R.std.vector(R.std.vector("float"))()
    m_trajPointsT = R.std.vector(R.std.vector("float"))()

    m_trajPointspx = R.std.vector(R.std.vector("float"))()
    m_trajPointspy = R.std.vector(R.std.vector("float"))()
    m_trajPointspz = R.std.vector(R.std.vector("float"))()
    m_trajPointsE  = R.std.vector(R.std.vector("float"))()
    

    t_hit.Branch('entry_spill', struct_spill,"entry_spill/I")
    t_hit.Branch('StartX', m_StartX)
    t_hit.Branch('StartY', m_StartY)
    t_hit.Branch('StartZ', m_StartZ)
    t_hit.Branch('StartT', m_StartT)

    t_hit.Branch('StopX', m_StopX)
    t_hit.Branch('StopY', m_StopY)
    t_hit.Branch('StopZ', m_StopZ)
    t_hit.Branch('StopT', m_StopT)

    t_hit.Branch('length', m_length)

    t_hit.Branch('energy', m_energy)
    t_hit.Branch('energyAfterBirks', m_energyAfterBirks)

    t_hit.Branch('p', m_p)
    t_hit.Branch('TrackId', m_TrackId)
    t_hit.Branch('volume', m_volume)

    t_hit.Branch('edepsim_entry', m_real_entry)
    t_hit.Branch('event_ID', m_event_entry)
    t_hit.Branch('run_ID', m_RunId)



    t_hit.Branch("PDG",m_pdg)


    t_traj.Branch("TrackId", m_trajTrackId)
    t_traj.Branch("ParentId", m_trajParentId)
    t_traj.Branch("edepsim_TrackId", m_traj_real_TrackId)
    t_traj.Branch("edepsim_entry", m_traj_real_entry)

    t_traj.Branch("Pdg", m_trajPdg)
    t_traj.Branch("trajName", m_trajName)

    t_traj.Branch("InitPx", m_trajInitPx)
    t_traj.Branch("InitPy", m_trajInitPy)
    t_traj.Branch("InitPz", m_trajInitPz)
    t_traj.Branch("InitE", m_trajInitE)


    t_traj.Branch("Pointsx", m_trajPointsx)
    t_traj.Branch("Pointsy", m_trajPointsy)
    t_traj.Branch("Pointsz", m_trajPointsz)
    t_traj.Branch("PointsT", m_trajPointsT)

    t_traj.Branch("Pointspx", m_trajPointspx)
    t_traj.Branch("Pointspy", m_trajPointspy)
    t_traj.Branch("Pointspz", m_trajPointspz)
    t_traj.Branch("EventId", m_trajLongVertexId)
    # t_traj.Branch("PointsE", m_trajPointsE)


    struct_meta = R.struct_meta()

    t_meta.Branch("meta", struct_meta, "runnumber/I:offset_x/F:offset_y/F:offset_z/F")
    t_meta.Branch("processing", R.addressof( struct_meta, 'processing' ), "processing/C")
    t_meta.Branch("edepsim_file_name", R.addressof( struct_meta, 'edepsim_file_name' ), "edepsim_file_name/C")

    # t_meta.Branch("struct_meta", R.AddressOf(struct_meta), "processing/C:edepsim_file_name/C:runnumber/I:offset_x/D:offset_y/D:offset_z/D")
    # t_meta.Branch("test_processing", struct_meta.processing)

    struct_meta.processing = ""
    struct_meta.edepsim_file_name = input_file
    struct_meta.runnumber = int(runnum)
    struct_meta.offset_x = offset_x
    struct_meta.offset_y = offset_y
    struct_meta.offset_z = offset_z

    



    birks_coeff = 0.0905

    max_entry = events.GetEntries()

    passed_entries = 0
    events.GetEntry(0)
    current_id = tmap.GetValue(f'{event.RunId} {event.EventId}')
    j=0
    last_track_id = 0
    print (max_entry)
    tot_track_ids = []
    id_incr=0

    spillRate=1.2 * 1e9

    traj_map = {}

    time_shift = 0
    for entry in range (max_entry):
        if (entry%int(max_entry/10) == 0):
            print(entry)

        events.GetEntry(entry)
        traj_map = {}
        
        if tmap.GetValue(f'{event.RunId} {event.EventId}') != f'{current_id}':
            current_id = tmap.GetValue(f'{event.RunId} {event.EventId}')
            t_hit.Fill()
            t_traj.Fill()
            time_shift+=spillRate

            tot_track_ids = []
            id_incr=0

            m_StartX.clear()
            m_StopX.clear()
            m_StartY.clear()
            m_StopY.clear()
            m_StartZ.clear()
            m_StopZ.clear()
            m_StartT.clear()
            m_StopT.clear()
            m_length.clear()
            m_p.clear()
            m_TrackId.clear()
            m_energy.clear()
            m_energyAfterBirks.clear()
            m_pdg.clear()
            m_volume.clear()


            m_trajTrackId.clear()
            m_trajParentId.clear()
            m_trajName.clear()
            m_trajPdg.clear()
            m_trajInitPx.clear()
            m_trajInitPy.clear()
            m_trajInitPz.clear()
            m_trajInitE.clear()
            m_trajPointsx.clear()
            m_trajPointsy.clear()
            m_trajPointsz.clear()
            m_trajPointsT.clear()
            m_trajPointspx.clear()
            m_trajPointspy.clear()
            m_trajPointspz.clear()
            m_trajPointsE.clear()
            m_event_entry.clear()
            m_RunId.clear()
            m_real_entry.clear()
            m_traj_real_TrackId.clear()
            m_traj_real_entry.clear()
            m_trajLongVertexId.clear()
            j=0


        
        primaries = event.Primaries # Primary vertices (a vector) 
        trajectories = event.Trajectories #G4 trajectories (a vector)
        segment = event.SegmentDetectors #Vector of hit segments

        if (segment.size()==0):
            continue
        struct_spill.entry_spill = int(str(current_id))
        passed_entries+=1
        j = int(str(current_id))

        
        trajs = []
        
        for key, seg in segment:
            
            if (((key[:15] != "DetectorPlanelv")) and ((key[:22] != "DetectorPlanelvTracker")) ):
                continue
            if (not ("DetectorPlanelvScint" in key)):
                continue

            for hit in seg:

                m_StartX.push_back(hit.GetStart().X()+ offset_x)
                m_StopX.push_back(hit.GetStop().X()+ offset_x)

                m_StartY.push_back(hit.GetStart().Y() + offset_y)
                m_StopY.push_back(hit.GetStop().Y() + offset_y)

                m_StartZ.push_back(hit.GetStart().Z() + offset_z)
                m_StopZ.push_back(hit.GetStop().Z() + offset_z)

                m_StartT.push_back(hit.GetStart().T() - time_shift)
                m_StopT.push_back(hit.GetStop().T() - time_shift)

                m_length.push_back(hit.GetTrackLength())

                m_p.push_back(-1)

                # m_TrackId.push_back(hit.GetPrimaryId())
                #tid = hit.GetPrimaryId()
                tid = hit.GetContributors()[0] 
                if not(tid in traj_map.keys()):
                    traj_map[tid] = id_incr
                    id_incr +=1
                #m_TrackId.push_back(traj_map[hit.GetPrimaryId()])
                m_TrackId.push_back(traj_map[hit.GetContributors()[0]])
                m_energy.push_back(hit.GetEnergyDeposit())

                m_energyAfterBirks.push_back(get_evis(hit, birks_coeff))


                #tid = hit.GetPrimaryId() 
                tid = hit.GetContributors()[0]
                # tid = hit.GetPrimaryId() + 10*j
                m_pdg.push_back(trajectories[tid].GetPDGCode())
                m_volume.push_back(key[8:])
                m_event_entry.push_back(event.EventId)
                m_RunId.push_back(event.RunId)
                m_real_entry.push_back(entry)
                

        for traj_id in traj_map.keys():
            # print("\t",i)
            traj = trajectories[traj_id]
            # m_trajTrackId.push_back(i)
            m_trajTrackId.push_back(traj_map[traj_id])
            tot_track_ids.append(traj_map[traj_id])
            m_traj_real_TrackId.push_back(traj_id) 
            m_traj_real_entry.push_back(entry)

            m_trajParentId.push_back(traj.GetParentId())
            m_trajName.push_back(traj.GetName())
            m_trajPdg.push_back(traj.GetPDGCode())

            m_trajInitPx.push_back(traj.GetInitialMomentum().X())
            m_trajInitPy.push_back(traj.GetInitialMomentum().Y())
            m_trajInitPz.push_back(traj.GetInitialMomentum().Z())
            m_trajInitE.push_back(traj.GetInitialMomentum().T())
            

            x = R.std.vector(("float"))()
            y = R.std.vector(("float"))()
            z = R.std.vector(("float"))()
            T  = R.std.vector(("float"))()

            px = R.std.vector(("float"))()
            py = R.std.vector(("float"))()
            pz = R.std.vector(("float"))()
            E  = R.std.vector(("float"))()

            for p in traj.Points:
                x.push_back(p.GetPosition().X() + offset_x)
                y.push_back(p.GetPosition().Y() + offset_y)
                z.push_back(p.GetPosition().Z() + offset_z)
                T.push_back(p.GetPosition().T() - time_shift)

                px.push_back(p.GetMomentum().X())
                py.push_back(p.GetMomentum().Y())
                pz.push_back(p.GetMomentum().Z())



            m_trajPointsx.push_back(x)
            m_trajPointsy.push_back(y)
            m_trajPointsz.push_back(z)
            m_trajPointsT.push_back(T)
            m_trajPointspx.push_back(px)
            m_trajPointspy.push_back(py)
            m_trajPointspz.push_back(pz)
            m_trajLongVertexId.push_back(int(event.RunId * 1e6 + event.EventId))
            # m_trajPointsE.push_back(E)



        
    t_hit.Fill()
    t_traj.Fill()    
    t_meta.Fill()
    t_meta.Write()       
    t_hit.Write()
    t_traj.Write()
    tot_entries=int(t_hit.GetEntries())
    froot.Close()

    print(f'{int(passed_entries/max_entry * 1000)/10} % efficiency events')
    print(tot_entries)
    #subprocess.call("source create_options.sh {runnum:05} {tot_entries}", shell=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Making flat edepsim file")

    # Add a single argument for the configuration file
    parser.add_argument("--config", type=str, help="Path to configuration file")

    # Add the previous command-line arguments as optional arguments
    parser.add_argument("--offset_x", type=float, help="Offset in x direction")
    parser.add_argument("--offset_y", type=float, help="Offset in y direction")
    parser.add_argument("--offset_z", type=float, help="Offset in z direction")
    parser.add_argument("--input_dir", type=str, help="Path to the input file")
    parser.add_argument("--input_file", type=str, help="Name of the input file")
    parser.add_argument("--run_number", type=int, help="Run number")
    parser.add_argument("--output_dir", type=str, help="Output directory")
    parser.add_argument("--output_file", type=str, help="Output filename")

    args = parser.parse_args()

    # If a config file is provided, read from it; otherwise, use command-line arguments
    if args.config:
        config = configparser.ConfigParser()
        config.read(args.config)
        main(config["data"],0) #config file
    else:
        main(args,1) #inline arguments
