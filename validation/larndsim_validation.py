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
from matplotlib.backends.backend_pdf import PdfPages

from validation_utils import rasterize_plots
rasterize_plots()

SPILL_PERIOD = 1.2e7 # units = ticks

def main(sim_file):

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
        mc_hdr = sim_h5['mc_hdr']
        n_vertices = np.zeros(mc_hdr['event_id'].max())
        for i in range(len(n_vertices)):
            n_vertices[i] = np.count_nonzero(mc_hdr['event_id'] == i)
        plt.title('Total interactions per spill')
        plt.xlabel('Interactions')
        plt.ylabel('Counts')
        plt.hist(n_vertices, bins = np.arange(-0.5, n_vertices.max() + 1.5, 1))
        output.savefig()
        plt.close()

        ### Plot hits per event
        tracks = sim_h5['segments']
        def get_eventIDs(event_packets, mc_packets_assn):
            """Takes as input the packets and mc_packets_assn fields, and
            returns the eventIDs that deposited that energy"""
    
            event_IDs = []
            eventID = tracks['event_id'] # eventIDs associated to each track
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
        
        # Now we validate the light simulation:
        # For questions on the light validations below, see DUNE ND Prototype Workshop (May 2023) Coding Tutorial, 
        # or message Angela White on the DUNE Slack
        
        # Account for the timestamp turnover:
        light_trig = sim_h5['light_trig']
        tstamp_trig0 = packets['timestamp'][data_packet_mask]
        tstamp_trig7 = packets['timestamp'][trig_packet_mask]
        ## IDENTIFY THE INDEX WHERE THE TURNOVER OCCURS
        try:
            charge_cutoff = np.where(tstamp_trig0 > 1.999**31)[0][-1]
            light_cutoff = np.where(tstamp_trig7 > 1.999**31)[0][-1]
            wvfm_cutoff = np.where(light_trig['ts_sync'] > 1.999**31)[0][-1]
            tstamp_real_trig0 = np.concatenate((tstamp_trig0[:(charge_cutoff+1)],((2**31)+tstamp_trig0[(charge_cutoff+1):])))
            tstamp_real_trig7 = np.concatenate((tstamp_trig7[:(light_cutoff+1)],((2**31)+tstamp_trig7[(light_cutoff+1):])))
            l_tsync_real = np.concatenate((light_trig['ts_sync'][:(wvfm_cutoff+1)],((2**31)+light_trig['ts_sync'][(wvfm_cutoff+1):])))
        except: 
            tstamp_real_trig0 = tstamp_trig0
            tstamp_real_trig7 = tstamp_trig7
            l_tsync_real = light_trig['ts_sync']
        ## DEFINE SPILLID (EVENTID) FOR PACKETS AND LIGHT
        light_spillIDs = (np.rint(l_tsync_real/SPILL_PERIOD)).astype(int)
        packet0_spillIDs = (np.rint(tstamp_real_trig0/SPILL_PERIOD)).astype(int)
        packet7_spillIDs = (np.rint(tstamp_real_trig7/SPILL_PERIOD)).astype(int)
        list_spillIDs = np.unique(light_spillIDs)
        ## DEFINE THE INDICES OF EACH TIMESTAMP
        indices = np.arange(0,len(packets['timestamp']),1)
        indices_0 = indices[data_packet_mask]
        indices_7 = indices[trig_packet_mask]
        ## PLOT INDICE VS. TIMESTAMP
        fig = plt.figure(figsize=(18,6))
        plt.plot(tstamp_real_trig0,indices_0, "o", color='dodgerblue', label='larpix')
        plt.plot(tstamp_real_trig7,indices_7,".", color='tomato', label='light')
        plt.axvline(x=(2**31), label='LArPix Clock Rollover')
        plt.title('Larpix (Spill) Trigger vs. Light Trigger\n', fontsize=18)
        plt.xlabel(r'Timestamp [0.01$\mu$s]', fontsize=14)
        plt.ylabel('Packet Index', fontsize=16)
        plt.legend(fontsize=16)
        output.savefig()
        plt.close()     
        
        ## INSPECT PACMAN VS LIGHT TRIGGERS PER SPILL
        fig = plt.figure(figsize=(14,6))
        bins = np.linspace(min(packet7_spillIDs),max(packet7_spillIDs),392)
        bin_width = bins[2] - bins[1]
        counts, bins = np.histogram(np.array(light_spillIDs), bins=bins)
        plt.hist(bins[:-1], bins, weights=counts, color='tomato', label='Light: '+str(len(light_trig['ts_sync']))+' triggers')
        counts, bins = np.histogram(np.array(packet7_spillIDs), bins=bins)
        plt.hist(bins[:-1], bins, weights=counts, histtype="step", color='dodgerblue', label='Pacman: '+str(len(packet7_spillIDs))+' triggers')
        plt.title('Triggers Per Spill ('+str(len(list_spillIDs))+' Spills)\n', fontsize=16)
        plt.xlabel('Spill', fontsize=14)
        plt.ylabel('Triggers', fontsize=14)
        plt.ylim(0,max(counts)+2)
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
        SAMPLE_RATE = 1e8
        ## SEPARATE WAVEFORMS FROM LCM AND ACL
        larray_geom = np.array([1,1,1,1,1,1,0,0,0,0,0,0]*8)
        lcm_events = [light_wvfm[i][larray_geom==1] for i in range(NUM_LIGHT_EVENTS)]/BIT
        acl_events = [light_wvfm[i][larray_geom!=1] for i in range(NUM_LIGHT_EVENTS)]/BIT
        lcm_wvfms = ak.flatten(lcm_events, axis=1)
        acl_wvfms = ak.flatten(acl_events, axis=1)
        
        def noise_datasets(no_ped_adc,CUTOFF):
            adc_signal_indices=[]
            for i in range(len(no_ped_adc)):
                if max(abs(no_ped_adc[i]))>THRESHOLD:
                    adc_signal_indices.append(i)
                else:
                    pass
            adc_normal_pretrig = []
            for i in adc_signal_indices:
                waveform = no_ped_adc[i][0:PRE_NOISE]
                adc_normal_pretrig.append(np.array(waveform))
                if len(adc_normal_pretrig)>3000:
                    break
            adc_normal_pretrig = np.array(adc_normal_pretrig[0:3000])
            ns_wvfms = []
            for wave in adc_normal_pretrig:
                norm = max(abs(wave))
                ns_wvfms.append(wave/norm)
            # Calculate power spectra using FFT
            freqs = np.fft.fftfreq(PRE_NOISE, 1/SAMPLE_RATE)
            freqs = freqs[:PRE_NOISE//2] # keep only positive frequencies
            freq_matrix = np.tile(np.array(freqs), (len(adc_normal_pretrig),1))
            frequencies = np.ndarray.flatten(np.array(freq_matrix))
            psds = []
            for wave in ns_wvfms:
                spectrum = np.fft.fft(wave)
                psd = np.abs(spectrum[:PRE_NOISE//2])**2 / (PRE_NOISE * SAMPLE_RATE)
                psd[1:] *= 2 # double the power except for the DC component
                psds.append(psd)
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
            y0 = adc0_dataset[2][1]
            y1 = adc1_dataset[2][1]
            plt.plot(x, y0, "-", color='green', label='ACL')
            plt.plot(x, y1, "-", color='yellowgreen', label='LCM')
            plt.title('Pre-Trigger Noise Example (No Pedestal): Module 3', fontsize=16)
            plt.xlabel(r'Time Sample [0.01 $\mu$s]', fontsize=14)
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

        ## SELECT ONE EVENT TO INSPECT
        SPILL = 8
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
            if (opt_chan[j][0]) == 0: 
                l_mod1_1L = np.add(l_mod1_1L,light_wvfm[j][0:24])
                l_mod1_1R = np.add(l_mod1_1R,light_wvfm[j][24:48])
                l_mod1_2R = np.add(l_mod1_2R,light_wvfm[j][48:72])
                l_mod1_2L = np.add(l_mod1_2L,light_wvfm[j][72:96])
            if opt_chan[j][0]==96:
                l_mod2_3L = np.add(l_mod2_3L,light_wvfm[j][0:24])
                l_mod2_3R = np.add(l_mod2_3R,light_wvfm[j][24:48])
                l_mod2_4R = np.add(l_mod2_4R,light_wvfm[j][48:72])
                l_mod2_4L = np.add(l_mod2_4L,light_wvfm[j][72:96])
            if opt_chan[j][0]==192:
                l_mod3_5L = np.add(l_mod3_5L,np.array(light_wvfm[j][0:24]))
                l_mod3_5R = np.add(l_mod3_5R,np.array(light_wvfm[j][24:48]))
                l_mod3_6R = np.add(l_mod3_6R,np.array(light_wvfm[j][48:72]))
                l_mod3_6L = np.add(l_mod3_6L,np.array(light_wvfm[j][72:96])) 
            if opt_chan[j][0] == 288:
                l_mod4_7L = np.add(l_mod4_7L,np.array(light_wvfm[j][0:24]))
                l_mod4_7R = np.add(l_mod4_7R,np.array(light_wvfm[j][24:48]))
                l_mod4_8R = np.add(l_mod4_8R,np.array(light_wvfm[j][48:72]))
                l_mod4_8L = np.add(l_mod4_8L,np.array(light_wvfm[j][72:96]))
                
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
            ## CREATE AN EMPTY ARRAY TO AVOID RE-PLOTTING TRACKS
            plotted_tracks = []
            ## SET UP LABELING AND COLOR SCHEME
            titles = ["mod. 2, io_group 3","mod. 1, io_group 1","mod. 2, io_group 4","mod. 1, io_group 2",
                      "mod. 4, io_group 7","mod. 3, io_group 5","mod. 4, io_group 8","mod. 3, io_group 6"]
            colors = ['aqua','aqua','lightgreen','lightgreen','yellow','yellow','orangered','orangered']
            cmap = cm.jet
            ## ENFORCE GEOMETRY
            ios = [3,1,4,2,7,5,8,6]
            left_data = [l_mod2_3L,l_mod1_1L,l_mod2_4L,l_mod1_2L,l_mod4_7L,l_mod3_5L,l_mod4_8L,l_mod3_6L]
            right_data = [l_mod2_3R,l_mod1_1R,l_mod2_4R,l_mod1_2R,l_mod4_7R,l_mod3_5R,l_mod4_8R,l_mod3_6R]
            ## ENSURE THE TIMESTAMP TURNOVER ISN'T AN ISSUE
            packet_list = packets[data_packet_mask][packet0_spillIDs==spill]
            mc_assoc = mc_packets_assn[data_packet_mask][packet0_spillIDs==spill]
            ## MAP PACKETS TO TRACKS
            for ip,packet in enumerate(packet_list):
                track_ids = mc_assoc['track_ids'][ip]
                io_group = packet['io_group']
                ## GET THE POSITION OF CHARGE TRACKS AND SAVE TO THE CORRECT IO_GROUP
                for trackid in track_ids:
                    if trackid >= 0 and trackid not in plotted_tracks:
                        plotted_tracks.append(trackid)
                        if io_group==io_first:
                            X = (tracks[trackid]['x_start']*10,tracks[trackid]['x_end']*10)
                            Y = (tracks[trackid]['y_start']*10,tracks[trackid]['y_end']*10)
                            Z = (tracks[trackid]['z_start']*10,tracks[trackid]['z_end']*10)
                            axs1.plot(Z,Y,c=colors[ios.index(io_first)],alpha=1,lw=1.5)
                        if io_group==io_second:
                            X = (tracks[trackid]['x_start']*10,tracks[trackid]['x_end']*10)
                            Y = (tracks[trackid]['y_start']*10,tracks[trackid]['y_end']*10)
                            Z = (tracks[trackid]['z_start']*10,tracks[trackid]['z_end']*10)
                            axs4.plot(Z,Y,c=colors[ios.index(io_second)],alpha=1,lw=1.5)
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
            tpc_rectL = plt.Rectangle((1234.5,-333), 64, 130, linewidth=0.75, edgecolor='b', facecolor=cmap(0),zorder=-1)
            tpc_rectR = plt.Rectangle((1301.5,-333), 64, 130, linewidth=0.75, edgecolor='b', facecolor=cmap(0),zorder=-1)
            ## LABEL THE CHARGE PLOTS    
            axs1.add_patch(tpc_rectL)
            axs1.set_aspect("equal")
            axs1.set_xlabel("z [cm]")
            axs1.set_ylim(-334,-202)
            axs1.set_xlim(1233.5, 1299.5)
            axs1.set_title(titles[ios.index(io_first)])
            axs1.yaxis.set_ticklabels([]) 

            axs4.add_patch(tpc_rectR) 
            axs4.set_xlabel("z [cm]")
            axs4.set_ylim(-334,-202)
            axs4.set_xlim(1300.5, 1366.5)
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
    args = parser.parse_args()
    main(**vars(args))


