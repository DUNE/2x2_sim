#!/usr/bin/env python3

import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import h5py
import argparse
from matplotlib.backends.backend_pdf import PdfPages

SPILL_PERIOD = 1.2e7 # units = ticks

def main(sim_file):

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

        # get the packet data and create some masks:
        packets = sim_h5['packets']
        packet_index = np.array(list(range(0,len(packets))))
        data_packet_mask = packets['packet_type'] == 0
        trig_packet_mask = packets['packet_type'] == 7
        sync_packet_mask = packets['packet_type'] == 4
        rollover_packet_mask = (packets['packet_type'] == 6) & (packets['trigger_type'] == 83)
        other_packet_mask= ~(data_packet_mask | trig_packet_mask | sync_packet_mask | rollover_packet_mask)

        ### Plot time structure of packets: 
        plt.plot(packets['timestamp'][data_packet_mask],packet_index[data_packet_mask],'o',label='data packets',linestyle='None')
        plt.plot(packets['timestamp'][trig_packet_mask],packet_index[trig_packet_mask],'o',label='lrs triggers',linestyle='None')
        plt.plot(packets['timestamp'][sync_packet_mask],packet_index[sync_packet_mask],'o',label='PPS packets',linestyle='None')
        plt.plot(packets['timestamp'][other_packet_mask],packet_index[other_packet_mask],'o',label='other',linestyle='None')
        plt.plot(packets['timestamp'][rollover_packet_mask],packet_index[rollover_packet_mask],'o',label='rollover packets',linestyle='None')
        plt.xlabel('timestamp')
        plt.ylabel('packet index')
        plt.legend()
        output.savefig()
        plt.close()

        plt.hist(packets['timestamp'],bins=100)
        plt.xlabel('timestamp')
        output.savefig()
        plt.close()

        plt.plot(packets['receipt_timestamp'][data_packet_mask],packet_index[data_packet_mask],'o',label='data packets',linestyle='None')
        plt.plot(packets['timestamp'][trig_packet_mask],packet_index[trig_packet_mask],'o',label='lrs triggers',linestyle='None')
        plt.plot(packets['timestamp'][sync_packet_mask],packet_index[sync_packet_mask],'o',label='PPS packets',linestyle='None')
        plt.plot(packets['receipt_timestamp'][other_packet_mask],packet_index[other_packet_mask],'o',label='other',linestyle='None')
        plt.xlabel('receipt_timestamp')
        plt.ylabel('packet index')
        plt.legend()
        output.savefig()
        plt.close()

        plt.hist(packets['receipt_timestamp'],bins=100)
        plt.xlabel('receipt_timestamp')
        output.savefig()
        plt.close()

        ### Plot charge vs. time per io_group/tpc
        for iog in range(1,9,1):
            iog_mask = (packets['io_group'] == iog) & data_packet_mask
            plt.hist(packets['timestamp'][iog_mask]%SPILL_PERIOD,weights=packets['dataword'][iog_mask],bins=200,label='io_group '+str(iog),alpha=0.5)
        plt.xlabel('timestamp%spill_period')
        plt.ylabel('charge [ADC]')
        plt.legend(ncol=4,bbox_to_anchor=(-0.05,1.00),loc='lower left')
        output.savefig()
        plt.close()

        genie_hdr = sim_h5['genie_hdr']
        n_vertices = np.zeros(genie_hdr['spillID'].max())
        for i in range(len(n_vertices)):
            n_vertices[i] = np.count_nonzero(genie_hdr['spillID'] == i)
        plt.title('Total interactions per spill')
        plt.xlabel('Interactions')
        plt.ylabel('Counts')
        plt.hist(n_vertices, bins = np.arange(-0.5, n_vertices.max() + 1.5, 1))
        output.savefig()
        plt.close()
        
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sim_file', default=None, type=str,help='''string corresponding to the path of the larnd-sim output simulation file to be considered''')
    args = parser.parse_args()
    main(**vars(args))


