import numpy as np
import h5py
import argparse

segments_dtype = np.dtype([("event_id","u4"),("vertex_id", "u8"), ("segment_id", "u4"),
                           ("z_end", "f4"),("traj_id", "u4"), ("file_traj_id", "u4"), ("tran_diff", "f4"),
                           ("z_start", "f4"), ("x_end", "f4"),
                           ("y_end", "f4"), ("n_electrons", "u4"),
                           ("pdg_id", "i4"), ("x_start", "f4"),
                           ("y_start", "f4"), ("t_start", "f8"),
                           ("t0_start", "f8"), ("t0_end", "f8"), ("t0", "f8"),
                           ("dx", "f4"), ("long_diff", "f4"),
                           ("pixel_plane", "i4"), ("t_end", "f8"),
                           ("dEdx", "f4"), ("dE", "f4"), ("t", "f8"),
                           ("y", "f4"), ("x", "f4"), ("z", "f4"),
                           ("n_photons","f4")], align=True)

trajectories_dtype = np.dtype([("event_id","u4"), ("vertex_id", "u8"),
                               ("traj_id", "u4"), ("file_traj_id", "u4"), ("parent_id", "i4"), ("primary", "?"),
                               ("E_start", "f4"), ("pxyz_start", "f4", (3,)),
                               ("xyz_start", "f4", (3,)), ("t_start", "f8"),
                               ("E_end", "f4"), ("pxyz_end", "f4", (3,)),
                               ("xyz_end", "f4", (3,)), ("t_end", "f8"),
                               ("pdg_id", "i4"), ("start_process", "u4"),
                               ("start_subprocess", "u4"), ("end_process", "u4"),
                               ("end_subprocess", "u4"),("dist_travel", "f4")], align=True)

vertices_dtype = np.dtype([("event_id","u4"), ("vertex_id","u8"),
                           ("x_vert","f4"), ("y_vert","f4"), ("z_vert","f4"),
                           ("t_vert","f8"), ("t_event","f8")], align=True)

genie_stack_dtype = np.dtype([("event_id", "u4"), ("vertex_id", "u8"), ("traj_id", "i4"), ("file_traj_id", "i4"),
                              ("part_4mom", "f4", (4,)), ("part_pdg", "i4"),
                              ("part_status", "i4")], align=True)

genie_hdr_dtype = np.dtype([("event_id", "u4"), ("vertex_id", "u8"),
                            ("x_vert","f4"), ("y_vert","f4"), ("z_vert","f4"),
                            ("t_vert","f8"), ("target", "u4"), ("reaction", "i4"),
                            ("isCC", "?"), ("isQES", "?"), ("isMEC", "?"),
                            ("isRES", "?"), ("isDIS", "?"), ("isCOH", "?"),
                            ("Enu", "f4"), ("nu_4mom", "f4", (4,)), ("nu_pdg", "i4"),
                            ("Elep", "f4"), ("lep_mom", "f4"), ("lep_ang", "f4"), ("lep_pdg", "i4"),
                            ("q0", "f4"), ("q3", "f4"), ("Q2", "f4"),
                            ("x", "f4"), ("y", "f4")], align=True)

def random_value_from_distribution(x_vals, normalized_distribution):
    return np.random.choice(x_vals, p=normalized_distribution/np.sum(normalized_distribution))

def MIP_dEdx(mc_array):

    bin_centers = mc_array[:,0]
    fitted_data = mc_array[:,1]
    
    random_sample = random_value_from_distribution(bin_centers, fitted_data)
    return random_sample

def main(n_events, mip_dedx_array, output_file):
    # Here we create a series of events, where each event is composed of a single 
    # segment. When you get to flow, you'll also want to set 
    # sync_noise_cut_enabled: False
    # in yamls/proto_nd_flow/reco/charge/RawEventGeneratorMC.yaml
    if mip_dedx_array:
        mip_array = np.load(mip_dedx_array)

    # Regarding n_events, there's a ndlar_flow paramter called MAX_EVENTS_PER_FILE. 
    # It's default is 1000 I think, so it'd be good to either not go over this or to increase the default value.
    if output_file:
        outfile = output_file
    else:
        outfile = 'test_simple_edepsim_'+str(n_events)+'_events.hdf5'
    segments = np.zeros(n_events, dtype = segments_dtype)
    trajectories = np.zeros(n_events, dtype = trajectories_dtype)
    vertices = np.zeros(n_events, dtype = vertices_dtype)
    #mc_stack = np.zeros(n_events, dtype = genie_stack_dtype)
    mc_hdr = np.zeros(n_events, dtype = genie_hdr_dtype)

    c = 29979.2458 # cm/us 
    x_values = np.linspace(5, 30, 26)

    for i in range(n_events):

        # upstream_z = np.random.choice([0,1])
        # if upstream_z == 0:
        #     z_start = 20
        #     z_end = 21
        # else:
        #     z_start = -21
        #     z_end = -20
        x_value_idx = int(i % 26)

        s = segments[i]

        s['event_id'] = i+1
        s['segment_id'] = i

        # Each segment starts at (20, 0, 20) cm and runs a single cm in the z direction
        s['x_start'] = x_values[x_value_idx]
        s['x_end'] = x_values[x_value_idx]
        #print("x_start: ", s['x_start'])
        s['x'] = (s['x_start'] + s['x_end'])/2

        s['y_start'] = 0
        s['y_end'] = 0
        s['y'] = (s['y_start'] + s['y_end'])/2

        s['z_start'] = 20
        s['z_end'] = 21
        s['z'] = (s['z_start'] + s['z_end'])/2

        s['dE'] = 2.#MIP_dEdx(mip_array)
        s['dx'] = np.linalg.norm(np.array([s['x_end'], s['y_end'], s['z_end']]) - np.array([s['x_start'], s['y_start'], s['z_start']]))
        s['dEdx'] = s['dE'] / s['dx']

        # Using flow with the MR6 settings assumes the beam spill happens at intervals of
        # 1.2e6 microseconds, so you have to have the event happen sometime after that

        s['t0_start'] = s['event_id'] * 1.2e6
        s['t0_end'] = s['t0_start'] + s['dx']/c
        s['t0']= (s['t0_start'] + s['t0_end'])/2.

        s['pdg_id'] = 13

    f = h5py.File(outfile,'w')
    f.create_dataset("segments", data=segments, dtype = segments_dtype)
    f.create_dataset("trajectories", data=trajectories, dtype = trajectories_dtype)
    f.create_dataset("vertices", data=vertices, dtype = vertices_dtype)
    #f.create_dataset("mc_stack", data=mc_stack, dtype = genie_stack_dtype)
    f.create_dataset("mc_hdr", data=mc_hdr, dtype = genie_hdr_dtype)
    f.close()


if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--n_events', default=None, required=True, type=int, \
                        help='''int corresponding to the number of events to be created''')
    parser.add_argument('-mip', '--mip_dedx_array', default=None, required=False, type=str, \
                    help='''string corresponding to a file with a numpy array of MIP dE/dx \
                        values i.e. [[bin_centers for de/dx], [fitted_data of probabilities]]''')
    parser.add_argument('-o', '--output_file', default=None, required=False, type=str, \
                        help='''string corresponding to the name of the output file''')
    args = parser.parse_args()
    main(**vars(args))