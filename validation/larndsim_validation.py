import matplotlib
import matplotlib.pyplot as plt
import h5py
import argparse

def main(sim_file):

    sim_h5 = h5py.File(sim_file,'r')
    print('\n----------------- File content -----------------')
    print('File:',sim_file)
    print('Keys in file:',list(sim_h5.keys()))
    for key in sim_h5.keys():
        print('Number of',key,'entries in file:', len(sim_h5[key]))
    print('------------------------------------------------\n')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sim_file', default=None, type=str,help='''string corresponding to the path of the larnd-sim output simulation file to be considered''')
    args = parser.parse_args()
    main(**vars(args))


