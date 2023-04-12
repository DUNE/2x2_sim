#!/usr/bin/env python3

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

    # Logic to load the correct dataset name in the h5 file
    # Key name if input file is from larndsim
    if input_type == 'larnd':
        segment_key_name = 'tracks'
        output_pdf_tag = '_EDEPTRUTH'
    # Key name if input file is from edep-sim via dumpTree
    elif input_type == 'edep':
        segment_key_name = 'segments'
        output_pdf_tag = '_DUMPTREE'
    # Yell at the screen if somehow a different option is given
    else:
        print('Not valid energy deposit key name.')
        # Should we just exit here if we (somehow) get invalid input?
        # Or keep going to see if the trajectories dataset is valid?

    output_pdf_name = sim_file.split('.h5')[0]+output_pdf_tag+'_validations.pdf'
    # temperarily, put output in this directory, not the same as the
    # simulation file itself
    output_pdf_name = output_pdf_name.split('/')[-1] # !!
    print('Writing to {}'.format(output_pdf_name))
    with PdfPages(output_pdf_name) as output:

        # One more check to get the correct dataset from the file
        try:
            segments = sim_h5[segment_key_name]
        except KeyError:
            print('Energy deposit segments not found in file!')

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

        ### Now by their powers combined -- 2D muon momentum vs angle
        plt.hist2d(muon_angle, muon_pmag, bins=[60, 40], range=[[0, 180],[0, 20000]])
        plt.title('True muon momentum vs angle')
        plt.xlabel(r'$\theta_\mu$ [degrees]')
        plt.ylabel(r'$p_\mu$ [MeV]')
        plt.colorbar(label='Event rate')
        output.savefig()
        plt.close()

        NDHallwidths = [1000.,550.,2000.] # cm

        def tpc_bounds(i):
            """A sad little function that returns the bounds of each 2x2 tpc in one dimension.
            The dimension is chosen by i: 0, 1, 2 -> x, y, z.
            Values are taken from 2x2_sim/run-edep-sim/geometry/Merged2x2MINERvA_v2"""
            
            active_tpc_widths = [30.6, 130., 64.] # cm
            
            # The positions in cm of the center of each tpc relative to a module center.
            # There are two tpcs for each module.            
            tpcs_relative_to_module = [[-15.7,0.,0.], [15.7, 0., 0.]]

            # The positions in cm of each of the four modules, relative to the 2x2 center position.
            modules_relative_to_2x2= [[-33.5,0.,-33.5],
                                      [33.5,0.,-33.5],
                                      [-33.5,0.,33.5],
                                      [33.5,0.,33.5]]
            
            # The position of the 2x2 center, relative to the center of the ND hall
            detector_center = [0.,52.25,0.]
        
            # Get the tpc bounds relative to the tpc center in the ith coordinates
            tpc_bounds = np.array([-active_tpc_widths[i]/2., active_tpc_widths[i]/2.])
            
            tpc_bounds_relative_to_2x2 = []
            for tpc in tpcs_relative_to_module:
                tpc_bound_relative_to_module = tpc_bounds + tpc[i]
                for module in modules_relative_to_2x2:
                    bound = tpc_bound_relative_to_module + module[i]
                    tpc_bounds_relative_to_2x2.append(bound)
                    
            bounds_relative_to_NDhall = np.array(tpc_bounds_relative_to_2x2) + detector_center[i]
            
            return np.unique(bounds_relative_to_NDhall, axis = 0)


        def MINERvA_bounds(i):
            """A sadder littler function that returns the bounds of the MINERvA detector for a given
            dimension i: 0, 1, 2 -> x, y, z.
            For now, I take the detector to just simply be two monolithic hexagonal prisms,
            downstream and upstream of the 2x2 modules. 
            """
            
            # Taken from the gdml file.
            MINERvA_center = [0., 43., -654.865]
                        
            # From GDML file, the length of one side of the outer detector in cm
            side_length = 199.439876988864
            
            # Properties of a hexagon, given a side length
            long_diameter = 2*side_length
            short_diameter = np.sqrt(3)/2.*long_diameter 
            
            width = short_diameter 
            height = long_diameter
            
            # The detector bounds, in each dimention. The bounds of the z dimension for each prism
            # were obtained by looking at the central positions of the first and last HCal frame 
            # position for each slab. 
            detector_bounds = np.array([ 
                [[-width/2., width/2.], [-height/2., height/2.], [403.27185, 451.18895]],
                [[-width/2., width/2.], [-height/2., height/2.], [858.54105, 997.2314]]
            ])
            
            bounds_relative_to_NDhall = [] 
            for bound in detector_bounds:
                
                bounds_relative_to_NDhall.append(bound[i] + MINERvA_center[i])
            
            return np.unique(np.array(bounds_relative_to_NDhall), axis = 0)
            
        ### Plot the outgoing muon start position as proxy for vertex position
        muon_vtx = traj['xyz_start'][muon_mask]
        for i, coord in enumerate(['x', 'y', 'z']):
            counts, bins, _ = plt.hist(muon_vtx[:,i], bins=100)
            
            if bins[0] < -NDHallwidths[i]/2:
                plt.axvspan(bins[0], -NDHallwidths[i]/2.,0,1., facecolor = 'gray', alpha = 0.5, label = 'Dirt')
            if bins[-1] > NDHallwidths[i]/2:
                plt.axvspan(NDHallwidths[i]/2, bins[-1],0,1., facecolor = 'gray', alpha = 0.5)
            
            for i_bounds, bounds in enumerate(MINERvA_bounds(i)):
                if i_bounds == 0:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'red', alpha=0.5, label = 'MINERvA')
                else:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'red', alpha=0.5)
            for i_bounds, bounds in enumerate(tpc_bounds(i)):
                if i_bounds == 0:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'green', alpha=0.5, label = 'Active 2x2')
                else:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'green', alpha=0.5)

            plt.title('Muon vertex {}'.format(coord))
            plt.xlabel(r'{} position [cm]'.format(coord))
            plt.ylabel(r'Event rate')
            plt.legend()
            output.savefig()
            plt.close()
            
        ### Plot the interaction vertex positions. The distinction from the above is that
        ### this includes events that did not produce muons. (NC events?)
        vertex = sim_h5['genie_hdr']['vertex']
        for i, coord in enumerate(['x_vert', 'y_vert', 'z_vert']):
            counts, bins, _ = plt.hist(vertex[:, i], bins=200)

            if bins[0] < -NDHallwidths[i]/2:
                plt.axvspan(bins[0], -NDHallwidths[i]/2.,0,1., facecolor = 'gray', alpha = 0.5, label = 'Dirt')
            if bins[-1] > NDHallwidths[i]/2:
                plt.axvspan(NDHallwidths[i]/2, bins[-1],0,1., facecolor = 'gray', alpha = 0.5)

            for i_bounds, bounds in enumerate(MINERvA_bounds(i)):
                if i_bounds == 0:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'red', alpha=0.5, label = 'MINERvA')
                else:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'red', alpha=0.5)
            for i_bounds, bounds in enumerate(tpc_bounds(i)):
                if i_bounds == 0:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'green', alpha=0.5, label = 'Active 2x2')
                else:
                    plt.axvspan(bounds[0], bounds[1], 0, 1., facecolor = 'green', alpha=0.5)
            plt.vlines( [-NDHallwidths[i]/2., NDHallwidths[i]/2.], 0,counts.max(), colors = 'gray')
            plt.title('Interaction Vertex {}'.format(coord))
            plt.xlabel(r'{} position [cm]'.format(coord))
            plt.ylabel(r'Event rate')
            plt.legend()
            output.savefig()
            plt.close()
                        
        r_squared = vertex[:,0]**2 + vertex[:,1] **2 + vertex[:,2] **2 
        plt.hist(np.sqrt(r_squared), bins=100)
        plt.title('Interaction vertex, distance from center')
        plt.xlabel(r'Radial distance')
        plt.ylabel(r'Event rate')
        output.savefig()
        plt.close()
            
        plt.axes().set_aspect('equal')
        plt.hist2d(vertex[:,0], vertex[:,1], bins = 100)
        plt.title('Interaction vertex, x vs y')
        plt.xlabel('x [cm]')
        plt.ylabel('y [cm]')
        output.savefig()
        plt.close()
   
        plt.axes().set_aspect('equal')
        plt.hist2d(vertex[:,2], vertex[:,1], bins = 100)
        plt.title('Interaction vertex, z vs y')
        plt.xlabel('z [cm]')
        plt.ylabel('y [cm]')
        output.savefig()
        plt.close()
        
        plt.axes().set_aspect('equal')
        plt.hist2d(vertex[:,2], vertex[:,0], bins = 100)
        plt.title('Interaction vertex, z vs x')
        plt.xlabel('z [cm]')
        plt.ylabel('x [cm]')
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
