import matplotlib as mlp
import matplotlib.pyplot as plt
import numpy as np
import h5py
import argparse
from matplotlib.backends.backend_pdf import PdfPages

SPILL_PERIOD = 1.2e7 # units = ticks

def main(flow_file):

    flow_h5 = h5py.File(flow_file,'r')
    print('\n----------------- File content -----------------')
    print('File:',flow_file)
    print('Keys in file:',list(flow_h5.keys()))
    for key in flow_h5.keys():
        print('Number of',key,'entries in file:', len(flow_h5[key]))
    print('------------------------------------------------\n')

    output_pdf_name = flow_file.split('.h5')[0]+'_validations.pdf'
    # temperarily, put output in this directory, not the same as the
    # simulation file itself
    #output_pdf_name = output_pdf_name.split('/')[-1] # !!
    with PdfPages(output_pdf_name) as output:

        hits = flow_h5['/charge/calib_prompt_hits/data']
        # optionally, use this mask to select a time window and key in on a
        # subset of spills
        spill_mask = (hits['ts_pps'] > 0) & (hits['ts_pps'] < 9999999999999)

        ### Event display

        # 3D - all spills
        fig = plt.figure(figsize=(10,10))
        ax = fig.add_subplot(projection='3d')
        ax.set_facecolor('none')
        fig.tight_layout()        
        dat = ax.scatter(hits[spill_mask]['z'],hits[spill_mask]['x'],
                   hits[spill_mask]['y'],c=hits[spill_mask]['Q'],
                   s=3,cmap='viridis',norm=mlp.colors.LogNorm())
                   #norm=mpl.colors.LogNorm())#, cmap='Greys')
        fig.colorbar(dat,ax=ax,label="detected charge",shrink=0.5)
        ax.set_title("edep-sim + larnd-sim + proto_nd_flow",fontsize=20)
        ax.set_xlabel('z [mm]')
        ax.set_ylabel('x [mm]')
        ax.set_zlabel('y [mm]')
        del ax, fig
        output.savefig()
        plt.close()


        # 3D - several individual spills
        fig = plt.figure(figsize=(10,10),layout="tight")
        gs = fig.add_gridspec(3,3)
        ax = []
        for a in range(9):
            ax.append(fig.add_subplot(gs[a//3,a%3],projection='3d'))
            spill_mask = (hits['ts_pps'] > ((a+1)-0.5)*SPILL_PERIOD) & (hits['ts_pps'] < ((a+1)+0.5)*SPILL_PERIOD)
            dat = ax[a].scatter(hits[spill_mask]['z'],hits[spill_mask]['x'],
                       hits[spill_mask]['y'],c=hits[spill_mask]['Q'],
                       s=1,cmap='viridis',norm=mlp.colors.LogNorm())
            #cb = fig.colorbar(dat, ax=ax[a], label="detected charge",
            #                  shrink=0.5, location='left', pad = 0.)
            #cb.ax.yaxis.set_ticks([matplotlib.ticker.FixedLocator([])])
            ax[a].set_title(f"spill {a+1}",fontsize=12)
            ax[a].set_xlabel('z [mm]')
            ax[a].set_ylabel('x [mm]')
            ax[a].set_zlabel('y [mm]')
        output.savefig()
        plt.close()

        # 2D
        fig = plt.figure(layout="constrained")
        gs = fig.add_gridspec(5,3,height_ratios=[1,3,1,3,1])
        ax1 = fig.add_subplot(gs[1,0])
        ax2 = fig.add_subplot(gs[1,1])
        ax3 = fig.add_subplot(gs[1,2])
        ax4 = fig.add_subplot(gs[3,0])
        ax5 = fig.add_subplot(gs[3,1])
        ax6 = fig.add_subplot(gs[3,2])
        
        #ax1.hist2d(hits['z'],hits['y'],weights=hits['E'],bins=(300,300))
        ax4.scatter(hits['z'],hits['y'],s=0.5,alpha=0.1)
        ax1.set_xlabel(r'z [mm]')
        ax1.set_ylabel(r'y [mm]')
        ax4.set_xlabel(r'z [mm]')
        ax4.set_ylabel(r'y [mm]')
        #ax2.hist2d(hits['x'],hits['z'],weights=hits['E'],bins=(300,300))
        ax5.scatter(hits['x'],hits['z'],s=0.5,alpha=0.1)
        ax2.set_xlabel(r'x [mm]')
        ax2.set_ylabel(r'z [mm]')
        ax5.set_xlabel(r'x [mm]')
        ax5.set_ylabel(r'z [mm]')
        #ax3.hist2d(hits['x'],hits['y'],weights=hits['E'],bins=(300,300))
        ax6.scatter(hits['x'],hits['y'],s=0.5,alpha=0.1)
        ax3.set_xlabel(r'x [mm]')
        ax3.set_ylabel(r'y [mm]')
        ax6.set_xlabel(r'x [mm]')
        ax6.set_ylabel(r'y [mm]')
        output.savefig()
        plt.close()

        ### Hit level 1D position distributions
        plt.hist(hits['z'],bins=300)
        plt.title('/charge/calib_prompt_hits/data')
        plt.xlabel('z [cm]')
        plt.ylabel('number of packets per bin')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.show()
        plt.hist(hits['y'],bins=300)
        plt.title('/charge/calib_prompt_hits/data')
        plt.xlabel('y [cm]')
        plt.ylabel('number of packets per bin')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(hits['x'],bins=300)
        plt.title('/charge/calib_prompt_hits/data')
        plt.xlabel('x [cm]')
        plt.ylabel('number of packets per bin')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        # get the packet data and create some masks:
        packets = flow_h5['/charge/packets/data']
        packet_index = np.array(list(range(0,len(packets))))
        data_packet_mask = packets['packet_type'] == 0
        trig_packet_mask = packets['packet_type'] == 7
        sync_packet_mask = packets['packet_type'] == 4
        other_packet_mask= ~(data_packet_mask | trig_packet_mask | sync_packet_mask)

        ### Plot time structure of packets: 
        plt.plot(packets['timestamp'][data_packet_mask],packet_index[data_packet_mask],'o',label='data packets',linestyle='None')
        plt.plot(packets['timestamp'][trig_packet_mask],packet_index[trig_packet_mask],'o',label='lrs triggers',linestyle='None')
        plt.plot(packets['timestamp'][sync_packet_mask],packet_index[sync_packet_mask],'o',label='PPS packets',linestyle='None')
        plt.plot(packets['timestamp'][other_packet_mask],packet_index[other_packet_mask],'o',label='other',linestyle='None')
        plt.title('/charge/packets/data')
        plt.xlabel('timestamp')
        plt.ylabel('packet index')
        plt.legend()
        output.savefig()
        plt.close()

        plt.hist(packets['timestamp'],bins=100)
        plt.title('/charge/packets/data')
        plt.xlabel('timestamp')
        plt.ylabel('number of packets per bin')
        output.savefig()
        plt.close()

        plt.plot(packets['receipt_timestamp'][data_packet_mask],packet_index[data_packet_mask],'o',label='data packets',linestyle='None')
        plt.plot(packets['receipt_timestamp'][trig_packet_mask],packet_index[trig_packet_mask],'o',label='lrs triggers',linestyle='None')
        plt.plot(packets['receipt_timestamp'][sync_packet_mask],packet_index[sync_packet_mask],'o',label='PPS packets',linestyle='None')
        plt.plot(packets['receipt_timestamp'][other_packet_mask],packet_index[other_packet_mask],'o',label='other',linestyle='None')
        plt.title('/charge/packets/data')
        plt.xlabel('receipt_timestamp')
        plt.ylabel('packet index')
        plt.legend()
        output.savefig()
        plt.close()

        plt.hist(packets['receipt_timestamp'],bins=100)
        plt.title('/charge/packets/data')
        plt.xlabel('receipt_timestamp')
        plt.ylabel('number of packets per bin')
        output.savefig()
        plt.close()

        ### Plot charge vs. time per io_group/tpc
        for iog in range(1,9,1):
            iog_mask = (packets['io_group'] == iog) & data_packet_mask
            plt.hist(packets['timestamp'][iog_mask]%SPILL_PERIOD,weights=packets['dataword'][iog_mask],bins=200,label='io_group '+str(iog),alpha=0.5)
        plt.title('/charge/packets/data')
        plt.xlabel('timestamp%spill_period')
        plt.ylabel('charge [ADC]')
        plt.legend(ncol=4,bbox_to_anchor=(-0.05,1.00),loc='lower left')
        output.savefig()
        plt.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--flow_file', default=None, type=str,help='''string corresponding to the path of the ndlar_flow output file to be considered''')
    args = parser.parse_args()
    main(**vars(args))


