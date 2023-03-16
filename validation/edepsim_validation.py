import matplotlib
import matplotlib.pyplot as plt
import h5py
import argparse
import numpy as np
from matplotlib.backends.backend_pdf import PdfPages

def main(sim_file, input_type):

    sim_h5 = h5py.File(sim_file,'r')
    print('\n----------------- File content -----------------')
    print('File:',sim_file)
    print('Keys in file:',list(sim_h5.keys()))
    for key in sim_h5.keys():
        print('Number of',key,'entries in file:', len(sim_h5[key]))
    print('------------------------------------------------\n')

    output_pdf_name = sim_file.split('.h5')[0]+'_validations.pdf'
    # temperarily, put output in this directory, not the same as the
    # simulation file itself
    output_pdf_name = output_pdf_name.split('/')[-1] # !!
    with PdfPages(output_pdf_name) as output:

        # Logic to load the correct dataset name in the h5 file
        # Key name if input file is from larndsim
        if input_type == 'larnd':
            segment_key_name = 'tracks'
        # Key name if input file is from edep-sim via dumpTree
        elif input_type == 'edep':
            segment_key_name = 'segments'
        # Yell at the screen if somehow a different option is given
        else:
            print("Not valid energy deposit key name.")

        try:
            segments = sim_h5[segment_key_name]
        except KeyError:
            print("Energy deposit segments not found in file!")

        ### Plot time structure of packets:
        plt.hist(segments['t0_start'], bins=100)
        plt.xlabel('t0_start')
        plt.ylabel(r'N segments')
        output.savefig()
        plt.close()

        ### Plot dEdx for each segment
        plt.hist(segments['dEdx'], bins=100, range=[0, 100])
        plt.title('dEdx')
        plt.xlabel(r'dEdx [MeV/cm]')
        plt.ylabel(r'N segments')
        output.savefig()
        plt.close()

        ### Plot the outgoing muon momentum
        traj = sim_h5['trajectories']
        muon_mask = (np.abs(traj['pdgId']) == 13) & (traj['parentID'] == -1)
        muon_pvec = traj['pxyz_start'][muon_mask]
        muon_pmag = np.linalg.norm(muon_pvec, axis=1)
        plt.hist(muon_pmag, bins=20, range=[0, 20000])
        plt.title('True muon momentum')
        plt.xlabel(r'$p_\mu$ [MeV]')
        plt.ylabel(r'Event rate')
        output.savefig()
        plt.close()

        ### Plot the outgoing muon angle w.r.t. the neutrino beam direction
        beam_dir  = np.asarray([0.0, -0.05836, 1.0]) # -3.34 degrees in the y-direction
        beam_norm = np.linalg.norm(beam_dir)
        muon_angle = np.arccos(muon_pvec.dot(beam_dir) / (beam_norm * muon_pmag)) * (180.0 / np.pi)
        plt.hist(muon_angle, bins=60, range=[0, 180])
        plt.title('True muon angle')
        plt.xlabel(r'$\theta_\mu$ [degrees]')
        plt.ylabel(r'Event rate')
        output.savefig()
        plt.close()

        ### Plot total number of primary tracks from the vertex
        event_ids = np.unique(traj['eventID'])
        n_primaries = np.zeros(event_ids.size)
        current_evt = 0
        current_id = traj['eventID'][0]
        for trk in traj:
            if trk['eventID'] != current_id:
                current_id = trk['eventID']
                current_evt += 1

            if trk['parentID'] == -1:
                n_primaries[current_evt] += 1

        plt.hist(n_primaries, bins=40, range=[0, 40])
        plt.title('N primary tracks')
        plt.xlabel(r'N tracks')
        plt.ylabel(r'Event rate')
        output.savefig()
        plt.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--sim_file', default=None, required=True, type=str, help='''string corresponding to the path of the edep-sim output simulation file to be considered''')
    parser.add_argument('-t', '--input_type', default='edep', choices=['edep', 'larnd'], type=str, help='''string corresponding to the output file type: edep or larnd''')
    args = parser.parse_args()
    main(**vars(args))
