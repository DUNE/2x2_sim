#!/usr/bin/env python3

# This assumes the cryostat is near the origin.

########################################################################
# Script:      Charged Particle Multiplicity validation plots
# Analyzer:    Aleena Rafique
# File:        CPM_validation.py
#######################################################################
import matplotlib as mlp
import matplotlib.pyplot as plt
import numpy as np
import h5py
import argparse
from matplotlib.backends.backend_pdf import PdfPages

from validation_utils import rasterize_plots
rasterize_plots()

SPILL_PERIOD = 1.2e7 # units = ticks

def main(flow_file):

    flow_h5 = h5py.File(flow_file,'r')
    print('\n----------------- File content -----------------')
    print('File:',flow_file)
    print('Keys in file:',list(flow_h5.keys()))
    for key in flow_h5.keys():
        print('Number of',key,'entries in file:', len(flow_h5[key]))
    print('------------------------------------------------\n')
    
    output_pdf_name = flow_file.split('.hdf5')[0]+'_validations_CPM.pdf'
    output_pdf_name = output_pdf_name.split('/')[-1] # !!
    mcparticles = flow_h5['mc_truth/trajectories/data']
    print(flow_h5['mc_truth/trajectories/data'].dtype.names)
    mcpstartxyz = mcparticles['xyz_start']
    mcpstartx = mcpstartxyz[:, 0]
    mcpstarty = mcpstartxyz[:, 1]
    mcpstartz = mcpstartxyz[:, 2]
    mcpendxyz = mcparticles['xyz_end']
    mcpendx = mcpendxyz[:, 0]
    mcpendy = mcpendxyz[:, 1]
    mcpendz = mcpendxyz[:, 2]
    mcppdgid = mcparticles['pdg_id']
        
    tot_mcpar = len(mcpstartx)

    mcpstartxInaccep = []
    mcpstartyInaccep = []
    mcpstartzInaccep = []
    mcpendxInaccep = []
    mcpendyInaccep = []
    mcpendzInaccep = []
        
    for a in range(tot_mcpar):
        if ((mcpstartx[a]>-62) and (mcpstartx[a]<62) and (mcpstarty[a]>-20) and (mcpstarty[a]<1042) and (mcpstartz[a]>-62) and (mcpstartz[a]<62)):
            if(abs(mcppdgid[a])==13 or abs(mcppdgid[a])==211 or mcppdgid[a]==2212 or abs(mcppdgid[a])==321):	    
                mcpstartxInaccep.append(mcpstartx[a]) 
                mcpstartyInaccep.append(mcpstarty[a])
                mcpstartzInaccep.append(mcpstartz[a])
                mcpendxInaccep.append(mcpendx[a]) 
                mcpendyInaccep.append(mcpendy[a])
                mcpendzInaccep.append(mcpendz[a])

    with PdfPages(output_pdf_name) as output:	    

        plt.hist(mcpstartxInaccep,bins=30)
        plt.title('MCParticle x start position')
        plt.xlabel('start x [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(mcpstartyInaccep,bins=30)
        plt.title('MCParticle y start position')
        plt.xlabel('start y [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(mcpstartzInaccep,bins=30)
        plt.title('MCParticle z start position')
        plt.xlabel('start z [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(mcpendxInaccep,bins=30)
        plt.title('MCParticle x end position')
        plt.xlabel('end x [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(mcpendyInaccep,bins=30)
        plt.title('MCParticle y end position')
        plt.xlabel('end y [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(mcpendzInaccep,bins=30)
        plt.title('MCParticle z end position')
        plt.xlabel('end z [cm]')
        plt.ylabel('number of MC particles')
        #plt.yscale('log')
        #plt.ylim([1,2e3])
        output.savefig()
        plt.close()        
	

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--flow_file', default=None, type=str,help='''string corresponding to the path of the ndlar_flow output file to be considered''')
    args = parser.parse_args()
    main(**vars(args))
