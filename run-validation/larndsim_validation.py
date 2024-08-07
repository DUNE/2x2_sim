#!/usr/bin/env python3

import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib import cm, colors
import matplotlib.patches as mpatches
import numpy as np
import awkward as ak
import h5py
import argparse
import sys
from matplotlib.backends.backend_pdf import PdfPages

from validation_utils import rasterize_plots
rasterize_plots()

SPILL_PERIOD = 1.2e7 # units = ticks
RESET_PERIOD = 1.0e7 # units = ticks

def main(sim_file, charge_only):

    sim_h5 = h5py.File(sim_file,'r')
    print('\n----------------- File content -----------------')
    print('File:',sim_file)
    print('Keys in file:',list(sim_h5.keys()))
    for key in sim_h5.keys():
        print('Number of',key,'entries in file:', len(sim_h5[key]))
    print('------------------------------------------------\n')

    output_pdf_name = sim_file.split('.hdf5')[0]+'_validations.pdf'
    # temperarily, put output in this directory, not the same as the
    # simulation file itself
    output_pdf_name = output_pdf_name.split('/')[-1] # !!
    with PdfPages(output_pdf_name) as output:

        # get the packet data and create some masks:
        packets = sim_h5['packets']
        packet_index = np.array(list(range(0,len(packets))))
        data_packet_mask = packets['packet_type'] == 0
        trig_packet_mask = packets['packet_type'] == 7
        timestamp_packet_mask = packets['packet_type'] == 4
        sync_packet_mask = (packets['packet_type'] == 6) & (packets['trigger_type'] == 83)
        other_packet_mask= ~(data_packet_mask | trig_packet_mask | sync_packet_mask | timestamp_packet_mask)
        io_groups_uniq = set(packets['io_group'])

        ### Plot time structure of packets: 
        io_group_count = 0
        io_groups_per_page = 8
        for iog in io_groups_uniq:
            # Skip io_group 0.
            if iog == 0: continue
            
            if io_group_count % io_groups_per_page == 0:
                fig = plt.figure(figsize=(10,10))
                gs = fig.add_gridspec(ncols=1,nrows=io_groups_per_page)
                fig.subplots_adjust(left=0.075,bottom=0.075,wspace=None, hspace=0.)
                ax = []
                ax.append(fig.add_subplot(gs[io_group_count % io_groups_per_page,0]))
            else: ax.append(fig.add_subplot(gs[io_group_count % io_groups_per_page,0],sharex=ax[0]))

            iog_mask = packets['io_group'] == iog
            temp_mask = np.logical_and(iog_mask,data_packet_mask)
            ax[io_group_count % io_groups_per_page].plot(packet_index[temp_mask],packets['timestamp'][temp_mask],'o',label='data packets',linestyle='None',ms=2)
            temp_mask = np.logical_and(iog_mask,trig_packet_mask)
            ax[io_group_count % io_groups_per_page].plot(packet_index[temp_mask],packets['timestamp'][temp_mask],'o',label='lrs triggers',linestyle='None',ms=2)
            temp_mask = np.logical_and(iog_mask,sync_packet_mask)
            ax[io_group_count % io_groups_per_page].plot(packet_index[temp_mask],packets['timestamp'][temp_mask],'o',label='PPS packets',linestyle='None',ms=2)
            temp_mask = np.logical_and(iog_mask,other_packet_mask)
            ax[io_group_count % io_groups_per_page].plot(packet_index[temp_mask],packets['timestamp'][temp_mask],'o',label='other',linestyle='None',ms=2)
            temp_mask = np.logical_and(iog_mask,timestamp_packet_mask)
            ax[io_group_count % io_groups_per_page].plot(packet_index[temp_mask],packets['timestamp'][temp_mask],'o',label='timestamp packets',linestyle='None',ms=2)
            ax[io_group_count % io_groups_per_page].grid()
            temp_ax = ax[io_group_count % io_groups_per_page].twinx()
            temp_ax.set_ylabel('io_group = '+str(iog))
            temp_ax.tick_params(labelright=False)
            temp_ax.tick_params(axis='y',rotation=180)

            # Minus 2 here because we skipped io_group 0.
            if io_group_count % io_groups_per_page == io_groups_per_page-1 or io_group_count == len(io_groups_uniq)-2:
                for i in range(0,len(ax)-1): ax[i].tick_params(labelbottom=False)
                #for i in range(0,len(ax)-1): ax[i].set_xlim(0, 1e6)
                ax[len(ax)-1].set_xlabel('packet index',fontsize=10) 
                ax[len(ax)//2].set_ylabel('packet timestamp',fontsize=10)
                output.savefig()
                plt.close()
            io_group_count += 1

        plt.plot(packet_index[data_packet_mask],packets['timestamp'][data_packet_mask],'o',label='data packets',linestyle='None',ms=1)
        plt.plot(packet_index[trig_packet_mask],packets['timestamp'][trig_packet_mask],'o',label='lrs triggers',linestyle='None',ms=1)
        plt.plot(packet_index[sync_packet_mask],packets['timestamp'][sync_packet_mask],'o',label='PPS packets',linestyle='None',ms=1)
        plt.plot(packet_index[other_packet_mask],packets['timestamp'][other_packet_mask],'o',label='other',linestyle='None',ms=1)
        plt.plot(packet_index[timestamp_packet_mask],packets['timestamp'][timestamp_packet_mask],'o',label='timestamp packets',linestyle='None',ms=1)
        plt.ylabel('timestamp')
        plt.xlabel('packet index')
        #plt.xlim([0,10000])
        plt.legend()
        output.savefig()
        plt.close()

        plt.hist(packets['timestamp'][data_packet_mask],bins=100)
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
        packets_stack = []
        weights_stack = []
        io_group_count = 0
        io_groups_per_page = 4
        for iog in io_groups_uniq:
            # Skip io_group 0.
            if iog == 0: continue

            iog_mask = (packets['io_group'] == iog) & data_packet_mask
            packets_stack.append(packets['timestamp'][iog_mask]%(SPILL_PERIOD%RESET_PERIOD))
            weights_stack.append(packets['dataword'][iog_mask])
            plt.hist(packets['timestamp'][iog_mask]%(SPILL_PERIOD%RESET_PERIOD),weights=packets['dataword'][iog_mask],bins=200,label='io_group '+str(iog),alpha=0.5)
           
            # Minus 2 here because we skipped io_group 0.
            if io_group_count % io_groups_per_page == io_groups_per_page-1 or io_group_count == len(io_groups_uniq)-2:
                plt.xlabel('timestamp%(spill_period%reset_period)')
                plt.ylabel('charge [ADC]')
                plt.legend(ncol=2,bbox_to_anchor=(-0.05,1.00),loc='lower left')
                output.savefig()
                plt.close()

            io_group_count += 1

        ### Plot charge vs. time
        plt.hist(packets_stack,weights=weights_stack,stacked=True,bins=200,alpha=0.5)
        plt.xlabel('timestamp%(spill_period%reset_period)')
        plt.ylabel('charge [ADC]')
        output.savefig()
        plt.close()

        ### Plot interactions per spill
        mc_hdr = sim_h5['mc_hdr']
        event_ids = np.unique(mc_hdr['event_id'])
        n_vertices = np.zeros(len(event_ids))
        for i in range(len(n_vertices)):
            n_vertices[i] = np.count_nonzero(mc_hdr['event_id'] == event_ids[i])
        plt.title('Total interactions per spill')
        plt.xlabel('Interactions')
        plt.ylabel('Counts')
        plt.hist(n_vertices, bins = np.arange(-0.5, n_vertices.max() + 1.5, 1))
        output.savefig()
        plt.close()

        ### Plot hits per event
        segments = sim_h5['segments']
        def get_eventIDs(event_packets, mc_packets_assn):
            """Takes as input the packets and mc_packets_assn fields, and
            returns the eventIDs that deposited that energy"""
    
            event_IDs = []
            eventID = segments['event_id'] # eventIDs associated to each segment
            segment_id_assn = mc_packets_assn['segment_ids'] # segment indices corresponding to each packet

            # Loop over each packet
            for ip, packet in enumerate(event_packets):

                if packet['packet_type'] != 0:
                    continue
                    
                # For packet ip, get segment indices that contributed to hit
                packet_segment_ids = segment_id_assn[ip]
                packet_segment_ids = packet_segment_ids[packet_segment_ids != -1]
                
                # For segment indices, get the corresponding eventID
                packet_event_IDs = eventID[packet_segment_ids]
                
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
        
        if charge_only: sys.exit(0)
        # Now we validate the light simulation:
        # For questions on the light validations below, see DUNE ND Prototype Workshop (May 2023) Coding Tutorial, 
        # or message Angela White on the DUNE Slack. Not yet looked at for a full NDLAr geometry.
        
        # Account for the timestamp turnover:
        light_trig = sim_h5['light_trig']
        tstamp_trig7 = packets['timestamp'][trig_packet_mask]
        l_tsync_real = light_trig['ts_s']
        ## IDENTIFY THE INDEX WHERE THE TURNOVER OCCURS
        light_cutoff=[0]
        for i in range(len(tstamp_trig7)):              
            if tstamp_trig7[i]<tstamp_trig7[i-1] and i >0:
                light_cutoff.append(i)
        tstamp_real_trig7=[]

        for i in range(len(light_cutoff)):
            if(i+1 < len(light_cutoff)):
                tstamp_real_trig7=np.concatenate((tstamp_real_trig7, ((1e7*i)+tstamp_trig7[(light_cutoff[i]):(light_cutoff[i+1])])))
            else:
                tstamp_real_trig7 = np.concatenate((tstamp_real_trig7, ((1e7*i)+tstamp_trig7[(light_cutoff[i]):])))
        ## DEFINE SPILLID (EVENTID) FOR PACKETS AND LIGHT
        light_spillIDs = (np.rint(l_tsync_real/1.2)).astype(int)
        packet7_spillIDs = (np.rint(tstamp_real_trig7/2e6)).astype(int)
        list_spillIDs = np.unique(light_spillIDs)
        ## DEFINE THE INDICES OF EACH TIMESTAMP
        indices = np.arange(0,len(packets['timestamp']),1)
        indices_7 = indices[trig_packet_mask]
        ## PLOT INDICE VS. TIMESTAMP
        #fig = plt.figure(figsize=(18,6))
        #plt.plot(tstamp_real_trig0,indices_0, "o", color='dodgerblue', label='larpix')
        #plt.plot(tstamp_real_trig7,indices_7,".", color='tomato', label='light')
        #plt.axvline(x=(2**31), label='LArPix Clock Rollover')
        #plt.title('Larpix (Spill) Trigger vs. Light Trigger\n', fontsize=18)
        #plt.xlabel(r'Timestamp [0.01$\mu$s]', fontsize=14)
        #plt.ylabel('Packet Index', fontsize=16)
        #plt.legend(fontsize=16)
        #output.savefig()
        #plt.close()     
        
        ## INSPECT PACMAN VS LIGHT TRIGGERS PER SPILL
        fig = plt.figure(figsize=(14,6))
        bins = np.linspace(min(packet7_spillIDs),max(packet7_spillIDs),(max(packet7_spillIDs)*2)+1)
        bin_width = bins[2] - bins[1]
        counts, bins = np.histogram(np.array(light_spillIDs), bins=bins)
        plt.hist(bins[:-1], bins, weights=counts, color='tomato', label='Light: '+str(len(light_trig['ts_sync']))+' triggers')
        counts, bins = np.histogram(np.array(packet7_spillIDs), bins=bins)
        plt.hist(bins[:-1], bins, weights=counts, histtype="step", color='dodgerblue', label='Pacman: '+str(len(packet7_spillIDs))+' triggers')
        plt.title('Triggers Per Spill ('+str(len(list_spillIDs))+' Spills)\n', fontsize=16)
        plt.xlabel('Spill', fontsize=14)
        plt.ylabel('Triggers', fontsize=14)
        plt.ylim(0,max(counts)+2)
        plt.xlim(0,max(packet7_spillIDs))
        plt.grid(axis='y', color='0.85')
        plt.legend(loc='upper left', fontsize=14)
        output.savefig()
        plt.close()
        
        ## PLOT A SINGLE WAVEFORM
        light_wvfm = sim_h5['light_wvfm']
        SAMPLES = len(light_wvfm[0][0])
        BIT = min(x for x in abs(light_wvfm[0][0]) if x != 0)
        fig = plt.figure(figsize=(10,4))
        plt.plot(np.linspace(0,SAMPLES-1,SAMPLES),light_wvfm[0][0]/BIT, label='Opt. Chan. 0')
        plt.title('Module 1, Event '+str(light_spillIDs[0])+', Optical Channel 1', fontsize=16)
        plt.xlabel(r'Time Sample [0.01 $\mu$s]', fontsize=14)
        plt.ylabel('SiPM Channel Output', fontsize=14)
        output.savefig()
        plt.close()

        ## INSPECT PRE-TRIGGER NOISE FOR 150 SPILLS
        PRE_NOISE = 65
        #NUM_LIGHT_EVENTS = len(light_wvfm)
        NUM_LIGHT_EVENTS = 150 # Save processing time
        THRESHOLD = 50 # change this if you want to exclude events from noise analysis
        SAMPLE_RATE = 6.25e7
        ## SEPARATE WAVEFORMS FROM LCM AND ACL
        larray_geom = np.array([1,1,1,1,1,1,0,0,0,0,0,0]*8*4)
        lcm_events = [light_wvfm[i][larray_geom==1] for i in range(NUM_LIGHT_EVENTS)]/BIT
        acl_events = [light_wvfm[i][larray_geom!=1] for i in range(NUM_LIGHT_EVENTS)]/BIT
        lcm_wvfms = ak.flatten(lcm_events, axis=1)
        acl_wvfms = ak.flatten(acl_events, axis=1)
        
        def noise_datasets(no_ped_adc,CUTOFF):
            max_abs_values=np.max(np.abs(no_ped_adc), axis=1)
            mask = max_abs_values > THRESHOLD
            adc_signal_indices= np.flatnonzero(mask)
            adc_normal_pretrig=no_ped_adc[adc_signal_indices,0:PRE_NOISE]
            adc_normal_pretrig = np.array(adc_normal_pretrig[0:3000])
            norms=np.max(np.abs(adc_normal_pretrig), axis=1)
            norms_big=np.expand_dims(norms, axis=1)
            ns_wvfms=np.divide(adc_normal_pretrig,norms_big)
            # Calculate power spectra using FFT
            freqs = np.fft.fftfreq(PRE_NOISE, 1/SAMPLE_RATE)
            freqs = freqs[:PRE_NOISE//2] # keep only positive frequencies
            freq_matrix = np.tile(np.array(freqs), (len(adc_normal_pretrig),1))
            frequencies = np.ndarray.flatten(np.array(freq_matrix))
            spectrum_arr=np.fft.fft(ns_wvfms, axis=1)
            psds= np.abs(spectrum_arr[:,:PRE_NOISE//2])**2 / (PRE_NOISE * SAMPLE_RATE)
            psds[:,1:] *=2 #Double the power except for the DC component
            ref = 1 #(everything is in integers?)
            power = np.ndarray.flatten(np.array(psds))
            p_dbfs = 20 * np.log10(power/ref)
            return adc_signal_indices, frequencies, adc_normal_pretrig, p_dbfs

        
        def power_hist_maxes(adc_dataset):
            adc_freq = adc_dataset[1]
            adc_pdbfs = adc_dataset[3]
            hist, *edges = np.histogram2d(adc_freq[(adc_pdbfs)>-500]/1e6, adc_pdbfs[(adc_pdbfs)>-500], bins=32)
            ycenters = (edges[1][:-1] + edges[1][1:]) / 2
            xcenters = (edges[0][:-1] + edges[0][1:]) / 2
            maxes = []
            for array in hist:
                maxes.append(np.where(array == max(array))[0][0])
            max_bins = [ycenters[i] for i in maxes]
            return xcenters, max_bins
        
        ACL_dataset = noise_datasets(-acl_wvfms, THRESHOLD)
        LCM_dataset = noise_datasets(-lcm_wvfms, THRESHOLD)
        ACL_maxes = power_hist_maxes(ACL_dataset)
        LCM_maxes = power_hist_maxes(LCM_dataset)
        
        def power_spec_plots(adc0_dataset, adc0_max, adc1_dataset, adc1_max, CUTOFF): 
            fig = plt.figure(figsize=(12,3))
            x = np.linspace(0,CUTOFF-1,CUTOFF)
            y0 = adc0_dataset[2][35]
            y1 = adc1_dataset[2][35]
            plt.plot(x, y0, "-", color='green', label='ACL')
            plt.plot(x, y1, "-", color='yellowgreen', label='LCM')
            plt.title('Pre-Trigger Noise Example (No Pedestal): Module 3', fontsize=16)
            plt.xlabel(r'Time Sample [0.016 $\mu$s]', fontsize=14)
            plt.ylabel('SiPM Channel Output', fontsize=14)
            plt.legend()
            output.savefig()
            plt.close()

            fig, ax = plt.subplots(nrows=1, ncols=2, sharey=True, figsize=(9, 5))
            adc0_freq = adc0_dataset[1]
            adc0_pdbfs = adc0_dataset[3]
            adc1_freq = adc1_dataset[1]
            adc1_pdbfs = adc1_dataset[3]
            hist1 = ax[0].hist2d(adc0_freq[adc0_pdbfs>-500]/1e6, adc0_pdbfs[adc0_pdbfs>-500], bins=32, \
                                   norm=mpl.colors.LogNorm(vmax=1.1e3), cmap='viridis')
            fig.colorbar(hist1[3], ax=ax, location='bottom')
            ax[0].plot(adc0_max[0],adc0_max[1],'o-k')
            ax[0].set_title('ACL Pre-Trigger Noise Power Spectrum')
            ax[0].set_ylim(-310,-130)
            ax[0].set_xlabel('Frequency [MHz]',fontsize=14)
            hist2 = ax[1].hist2d(adc1_freq[adc1_pdbfs>-500]/1e6, adc1_pdbfs[adc1_pdbfs>-500], bins=32, \
                                   norm=mpl.colors.LogNorm(vmax=1.1e3), cmap='viridis')
            ax[1].plot(adc1_max[0],adc1_max[1],'o-k')
            ax[1].set_title('LCM Pre-Trigger Noise Power Spectrum')
            ax[1].set_ylim(-310,-130)
            ax[1].set_xlabel('Frequency [MHz]',fontsize=14)
            fig.supylabel('Power Spectrum [dB]',fontsize=14, x=0.04, y=0.62)
            fig.suptitle('larnd-sim: Pre-Trigger Noise, {} Waveforms\n'.format(len(adc1_dataset[2])), fontsize=16, x=0.5, y=1.0)
            # Show the plot
            plt.subplots_adjust(hspace=0.2, wspace=0.02, bottom = 0.35)
            output.savefig()
            plt.close()
            
        power_spec_plots(ACL_dataset, ACL_maxes, LCM_dataset, LCM_maxes, PRE_NOISE)

        ## ANOTHER PRE-TRIGGER NOISE CHECK: CONSISTENT?
        ptrig_wvfm = -light_wvfm[:,:,0:50]/BIT
        end_wvfm = -light_wvfm[:,:,950:]/BIT
        avg_ptrig = np.mean(np.abs(ptrig_wvfm), axis=2)
        avg_end = np.mean(np.abs(end_wvfm), axis=2)
        ratio_noise = avg_end/avg_ptrig
        flat_ratios = np.concatenate(ratio_noise)
        flat_channels = np.concatenate(light_trig['op_channel'])
        fig, ax = plt.subplots(figsize=(16, 8))
        # Plot the 2D histogram
        regions = [(0, 96, 'yellow', 0.2, 'Mod 0'),
                   (96, 192, 'orange', 0.3, 'Mod 1'),
                   (192, 288, 'red', 0.2, 'Mod 2'),
                   (288, 384, 'magenta', 0.2, 'Mod 3'),]
        # Plot transparent colored x-axis regions
        for xmin, xmax, color, alpha, label in regions:
            ax.axvspan(xmin, xmax, facecolor=color, alpha=alpha, label=label)
        ax.axhline(y=1, color='red', linestyle='--', label='Ratio = 1')
        for i in range(0, 383, 12):
            ax.axvspan(i, i + 6, alpha=0.2, color='green')
        ax.axvline(x=48, color='black', linestyle=':')
        ax.axvline(x=96, color='black', linestyle=':')
        ax.axvline(x=144, color='black', linestyle=':')
        ax.axvline(x=192, color='black', linestyle=':')
        ax.axvline(x=240, color='black', linestyle=':')
        ax.axvline(x=288, color='black', linestyle=':')
        ax.axvline(x=336, color='black', linestyle=':')
        ax.axvline(x=384, color='black', linestyle=':')
        hist1 = ax.hist2d(flat_channels, flat_ratios, bins=(384,2000), norm=mpl.colors.LogNorm(vmax=192), cmap='viridis')
        fig.colorbar(hist1[3], ax=ax, location='bottom')

        # Customize the plot
        ax.set_title('MiniRun5: Ratios of the Average Noise Amplitude: [950:1000]/[0:50]', fontsize=16)
        ax.set_xlabel('Channel ID')
        ax.set_ylabel('Ratio End/Pretrigger')
        ax.set_ylim(0,6)
        plt.legend(loc='upper right')
        output.savefig()
        plt.close()

        ## SELECT ONE EVENT TO INSPECT
        SPILL = 10
        ## ASSIGN "SUM CHANNEL" POSITIONS (this would be one side of one TPC)
        SiPM_struct = np.array([0,0,0,0,0,0,
                                1,1,1,1,1,1,
                                2,2,2,2,2,2,
                                3,3,3,3,3,3])
        ## SELECT DATASETS BELONGING TO YOUR SPILL
        spill_light = np.where(light_spillIDs == SPILL)[0]
        opt_chan = np.array(sim_h5['light_trig']['op_channel'])
        ## CREATE EMPTY DATASETS FOR EACH LIGHT ARRAY (one side of one TPC)
        l_mod1_1L = np.zeros((24,SAMPLES))
        l_mod1_1R = np.zeros((24,SAMPLES))
        l_mod1_2L = np.zeros((24,SAMPLES))
        l_mod1_2R = np.zeros((24,SAMPLES))

        l_mod2_3L = np.zeros((24,SAMPLES))
        l_mod2_3R = np.zeros((24,SAMPLES))
        l_mod2_4L = np.zeros((24,SAMPLES))
        l_mod2_4R = np.zeros((24,SAMPLES)) 

        l_mod3_5L = np.zeros((24,SAMPLES))
        l_mod3_5R = np.zeros((24,SAMPLES))
        l_mod3_6L = np.zeros((24,SAMPLES))
        l_mod3_6R = np.zeros((24,SAMPLES))

        l_mod4_7L = np.zeros((24,SAMPLES))
        l_mod4_7R = np.zeros((24,SAMPLES))
        l_mod4_8L = np.zeros((24,SAMPLES))
        l_mod4_8R = np.zeros((24,SAMPLES)) 
        ## SORT THE LIGHT DATA BY MODULE, TPC, and SIDE
        for j in spill_light:
            l_mod1_2L = np.add(l_mod1_2L,light_wvfm[j][0:24])
            l_mod1_2R = np.add(l_mod1_2R,light_wvfm[j][24:48])
            l_mod1_1R = np.add(l_mod1_1R,light_wvfm[j][48:72])
            l_mod1_1L = np.add(l_mod1_1L,light_wvfm[j][72:96])

            l_mod2_4L = np.add(l_mod2_4L,light_wvfm[j][96:120])
            l_mod2_4R = np.add(l_mod2_4R,light_wvfm[j][120:144])
            l_mod2_3R = np.add(l_mod2_3R,light_wvfm[j][144:168])
            l_mod2_3L = np.add(l_mod2_3L,light_wvfm[j][168:192])

            l_mod3_6L = np.add(l_mod3_6L,np.array(light_wvfm[j][192:216]))
            l_mod3_6R = np.add(l_mod3_6R,np.array(light_wvfm[j][216:240]))
            l_mod3_5R = np.add(l_mod3_5R,np.array(light_wvfm[j][240:264]))
            l_mod3_5L = np.add(l_mod3_5L,np.array(light_wvfm[j][264:288])) 

            l_mod4_8L = np.add(l_mod4_8L,np.array(light_wvfm[j][288:312]))
            l_mod4_8R = np.add(l_mod4_8R,np.array(light_wvfm[j][312:336]))
            l_mod4_7R = np.add(l_mod4_7R,np.array(light_wvfm[j][336:360]))
            l_mod4_7L = np.add(l_mod4_7L,np.array(light_wvfm[j][360:384]))

        def assign_io(x_pos, z_pos):
            if z_pos > 0:
                if x_pos > 0:
                    return 1 if z_pos > 33.5 else 2
                else:
                    return 3 if z_pos > 33.5 else 4
            else:
                if x_pos > 0:
                    return 5 if z_pos > -33.5 else 6
                else: 
                    return 7 if z_pos > -33.5 else 8
                
        def data_readout(io_first, io_second, spill):
        ## SET UP AN 18-PLOT DISPLAY    
            fig = plt.figure(figsize=(13.8,8),tight_layout=True)
            subfigs = fig.subfigures(1, 6, wspace=0.1, width_ratios=[0.8,1.5,0.8,0.8,1.5,0.8], height_ratios=[1])
            axs0 = subfigs[0].subplots(4, 1,sharey=True,gridspec_kw={'hspace': 0})
            axs1 = subfigs[1].subplots(1, 1)
            axs2 = subfigs[2].subplots(4, 1,sharey=True,gridspec_kw={'hspace': 0})
            axs3 = subfigs[3].subplots(4, 1,sharey=True,gridspec_kw={'hspace': 0})
            axs4 = subfigs[4].subplots(1, 1)
            axs5 = subfigs[5].subplots(4, 1,sharey=True,gridspec_kw={'hspace': 0})
            ## CREATE AN EMPTY ARRAY TO AVOID RE-PLOTTING SEGMENTS
            plotted_segments = []
            ## SET UP LABELING AND COLOR SCHEME
            titles = ["mod. 2, io_group 3","mod. 1, io_group 1","mod. 2, io_group 4","mod. 1, io_group 2",
                      "mod. 4, io_group 7","mod. 3, io_group 5","mod. 4, io_group 8","mod. 3, io_group 6"]
            colors = ['aqua','aqua','lightgreen','lightgreen','yellow','yellow','orangered','orangered']
            cmap = cm.jet
            ## ENFORCE GEOMETRY
            ios = [3,1,4,2,7,5,8,6]
            left_data = [l_mod2_3L,l_mod1_1L,l_mod2_4L,l_mod1_2L,l_mod4_7L,l_mod3_5L,l_mod4_8L,l_mod3_6L]
            right_data = [l_mod2_3R,l_mod1_1R,l_mod2_4R,l_mod1_2R,l_mod4_7R,l_mod3_5R,l_mod4_8R,l_mod3_6R]
            charge_id = (segments['event_id'][0]+spill)
            event_mask = (segments['event_id'] == charge_id)
            segment_ids = segments['segment_id'][event_mask==1]
            for segmentid in segment_ids:
                if segmentid >= 0 and segmentid not in plotted_segments:
                    plotted_segments.append(segmentid)
                    X_start = segments[segmentid]['x_start']
                    X_end = segments[segmentid]['x_end']
                    Z_start = segments[segmentid]['z_start']
                    Z_end = segments[segmentid]['z_end']  
                    Y_start = segments[segmentid]['y_start']
                    Y_end = segments[segmentid]['y_end']
                    io_group = assign_io(X_start, Z_start)
                    if io_group==io_first:
                        X = (X_start,X_end)
                        Y = (Y_start,Y_end)
                        Z = (Z_start,Z_end)
                        axs1.plot(X,Y,c=colors[ios.index(io_first)],alpha=1,lw=1.5)
                    if io_group==io_second:
                        X = (X_start,X_end)
                        Y = (Y_start,Y_end)
                        Z = (Z_start,Z_end)
                        axs4.plot(X,Y,c=colors[ios.index(io_second)],alpha=1,lw=1.5)
                    else:
                        pass
            ## LABEL THE LIGHT PLOTS                            
            axs0[0].set_title("Left:\nio_group "+str(io_first))
            axs2[0].set_title("Right:\nio_group "+str(io_first))
            axs3[0].set_title("Left:\nio_group "+str(io_second))
            axs5[0].set_title("Right:\nio_group "+str(io_second))
            axs0[3].set_xlabel(r"Samples [0.01 $\mu$s]")
            axs2[3].set_xlabel(r"Samples [0.01 $\mu$s]")
            axs3[3].set_xlabel(r"Samples [0.01 $\mu$s]")
            axs5[3].set_xlabel(r"Samples [0.01 $\mu$s]")
            fig.supylabel("Pulse Sum Over Light Collection Module",x=-0.07,y=0.53)
            ## SUM THE LIGHT DATA (IN PARTS)  
            all_sums=[]
            for i in range(4):
                if (i%2)==0:
                    clr = 'greenyellow'
                else:
                    clr = 'lightgreen'
                wvfm_scndL = [sum(w) for w in zip(*(left_data[ios.index(io_second)])[SiPM_struct==i]/BIT)]
                wvfm_scndR = [sum(w) for w in zip(*(right_data[ios.index(io_second)])[SiPM_struct==i]/BIT)]
                wvfm_frstL = [sum(w) for w in zip(*(left_data[ios.index(io_first)])[SiPM_struct==i]/BIT)]
                wvfm_frstR = [sum(w) for w in zip(*(right_data[ios.index(io_first)])[SiPM_struct==i]/BIT)]
                all_sums.extend(wvfm_scndL+wvfm_scndR+wvfm_frstL+wvfm_frstR)
                ## SET UNIVERSAL AXIS LIMITS
                y_min = (min(all_sums)-500)
                y_max = (max(all_sums))
                ## PLOT LIGHT WAVEFORMS
                axs0[i].plot(np.linspace(0,SAMPLES-1,SAMPLES),wvfm_frstL,color='k')
                axs0[i].set_facecolor(clr) 
                axs0[i].set_box_aspect(1)
                axs0[i].label_outer()
                axs0[i].set_ylim(y_min,y_max)
    
                axs2[i].plot(np.linspace(0,SAMPLES-1,SAMPLES),wvfm_frstR,color='k')
                axs2[i].set_facecolor(clr)
                axs2[i].label_outer()
                axs2[i].set_box_aspect(1)
                axs2[i].set_ylim(y_min,y_max)
                axs2[i].yaxis.set_ticklabels([])
    
                axs3[i].plot(np.linspace(0,SAMPLES-1,SAMPLES),wvfm_scndL,color='k')
                axs3[i].set_facecolor(clr)
                axs3[i].label_outer()
                axs3[i].set_box_aspect(1)
                axs3[i].set_ylim(y_min,y_max)
                axs3[i].yaxis.set_ticklabels([])
    
                axs5[i].plot(np.linspace(0,SAMPLES-1,SAMPLES),wvfm_scndR,color='k')
                axs5[i].set_facecolor(clr)
                axs5[i].label_outer()
                axs5[i].set_box_aspect(1)
                axs5[i].set_ylim(y_min,y_max)
                axs5[i].yaxis.set_ticklabels([])
            ## COLOR THE CHARGE PLOTS
            #axs1.plot(1234.5,-333,c='navy',alpha=0.1)
            #axs4.plot(15,-333,c='navy',alpha=0.1)
            tpc_rectL = plt.Rectangle((-66,-65), 65, 130, linewidth=0.75, edgecolor='b', facecolor=cmap(0),zorder=-1)
            tpc_rectR = plt.Rectangle((1,-65), 65, 130, linewidth=0.75, edgecolor='b', facecolor=cmap(0),zorder=-1)
            ## LABEL THE CHARGE PLOTS    
            axs1.add_patch(tpc_rectL)
            axs1.set_aspect("equal")
            axs1.set_xlabel("z [cm]")
            axs1.set_ylim(-66,66)
            axs1.set_xlim(-67, 0)
            axs1.set_title(titles[ios.index(io_first)])
            axs1.yaxis.set_ticklabels([]) 

            axs4.add_patch(tpc_rectR) 
            axs4.set_xlabel("z [cm]")
            axs4.set_ylim(-66,66)
            axs4.set_xlim(0, 67)
            axs4.set_aspect("equal")
            axs4.set_title(titles[ios.index(io_second)])
            axs4.yaxis.set_ticklabels([]) 
            output.savefig()
            plt.close()
            
        data_readout(3,1,SPILL)
        data_readout(4,2,SPILL)
        data_readout(7,5,SPILL)
        data_readout(8,6,SPILL)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sim_file', default=None, type=str,help='''string corresponding to the path of the larnd-sim output simulation file to be considered''')
    parser.add_argument('--charge_only', action='store_true', help='''boolean to flag that light has not been simualted''')
    args = parser.parse_args()
    main(**vars(args))


