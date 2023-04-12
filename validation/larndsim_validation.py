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

        ### Plot interactions per spill
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

        ### Plot hits per event
        tracks = sim_h5['tracks']
        def get_eventIDs(event_packets, mc_packets_assn):
            """Takes as input the packets and mc_packets_assn fields, and
            returns the eventIDs that deposited that energy"""
    
            event_IDs = []
            eventID = tracks['eventID'] # eventIDs associated to each track
            track_id_assn = mc_packets_assn['track_ids'] # track indices corresponding to each packet

            # Loop over each packet
            for ip, packet in enumerate(event_packets):

                if packet['packet_type'] != 0:
                    continue
                    
                # For packet ip, get track indices that contributed to hit
                packet_track_ids = track_id_assn[ip]
                packet_track_ids = packet_track_ids[packet_track_ids != -1]
                
                # For track indices, get the corresponding eventID
                packet_event_IDs = eventID[packet_track_ids]
                
                # Make sure that there's only one eventID corresponding to hit.
                # In principle, a hit could come from two events. But I'll deal
                # with that when it happens.
                unique_packet_event_ID = np.unique(packet_event_IDs)
                assert(len(unique_packet_event_ID == 1))
                
                packet_event_ID = unique_packet_event_ID[0]
                
                event_IDs.append(packet_event_ID)

            return np.array(event_IDs)

        mc_packets_assn = sim_h5['mc_packets_assn']
        event_IDs = get_eventIDs(packets, mc_packets_assn)
        unique_event_IDs, hit_counts = np.unique(event_IDs, return_counts = True)
        plt.hist(hit_counts, bins = 50)
        plt.title("Pixels hit per event")
        plt.xlabel("Pixels")
        plt.ylabel("Counts")
        output.savefig()
        plt.close()     

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sim_file', default=None, type=str,help='''string corresponding to the path of the larnd-sim output simulation file to be considered''')
    args = parser.parse_args()
    main(**vars(args))


