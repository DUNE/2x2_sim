import matplotlib
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
    output_pdf_name = output_pdf_name.split('/')[-1] # !!
    with PdfPages(output_pdf_name) as output:

        # get the packet data and create some masks:
        packets = flow_h5['/charge/packets/data']
        packet_index = np.array(list(range(0,len(packets))))
        data_packet_mask = packets['packet_type'] == 0

        ### Event display
        fig = plt.figure(layout="constrained")
        gs = fig.add_gridspec(5,3,height_ratios=[1,3,1,3,1])
        ax1 = fig.add_subplot(gs[1,0])
        ax2 = fig.add_subplot(gs[1,1])
        ax3 = fig.add_subplot(gs[1,2])
        ax4 = fig.add_subplot(gs[3,0])
        ax5 = fig.add_subplot(gs[3,1])
        ax6 = fig.add_subplot(gs[3,2])
        
        ax1.hist2d(flow_h5['/charge/calib_prompt_hits/data']['z'],flow_h5['/charge/calib_prompt_hits/data']['y'],weights=flow_h5['/charge/calib_prompt_hits/data']['E'],bins=(300,300))
        ax4.scatter(flow_h5['/charge/calib_prompt_hits/data']['z'],flow_h5['/charge/calib_prompt_hits/data']['y'],s=0.5,alpha=0.1)
        ax1.set_xlabel(r'z [mm]')
        ax1.set_ylabel(r'y [mm]')
        ax4.set_xlabel(r'z [mm]')
        ax4.set_ylabel(r'y [mm]')
        ax2.hist2d(flow_h5['/charge/calib_prompt_hits/data']['x'],flow_h5['/charge/calib_prompt_hits/data']['z'],weights=flow_h5['/charge/calib_prompt_hits/data']['E'],bins=(300,300))
        ax5.scatter(flow_h5['/charge/calib_prompt_hits/data']['x'],flow_h5['/charge/calib_prompt_hits/data']['z'],s=0.5,alpha=0.1)
        ax2.set_xlabel(r'x [mm]')
        ax2.set_ylabel(r'z [mm]')
        ax5.set_xlabel(r'x [mm]')
        ax5.set_ylabel(r'z [mm]')
        ax3.hist2d(flow_h5['/charge/calib_prompt_hits/data']['x'],flow_h5['/charge/calib_prompt_hits/data']['y'],weights=flow_h5['/charge/calib_prompt_hits/data']['E'],bins=(300,300))
        ax6.scatter(flow_h5['/charge/calib_prompt_hits/data']['x'],flow_h5['/charge/calib_prompt_hits/data']['y'],s=0.5,alpha=0.1)
        ax3.set_xlabel(r'x [mm]')
        ax3.set_ylabel(r'y [mm]')
        ax6.set_xlabel(r'x [mm]')
        ax6.set_ylabel(r'y [mm]')
        output.savefig()
        plt.close()

        ### Hit level 1D position distributions
        plt.hist(flow_h5['/charge/calib_prompt_hits/data']['z'],bins=300)
        plt.xlabel('z [cm]')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.show()
        plt.hist(flow_h5['/charge/calib_prompt_hits/data']['y'],bins=300)
        plt.xlabel('y [cm]')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        plt.hist(flow_h5['/charge/calib_prompt_hits/data']['x'],bins=300)
        plt.xlabel('x [cm]')
        plt.yscale('log')
        plt.ylim([1,2e3])
        output.savefig()
        plt.close()

        ### Plot time structure of packets: 
        plt.plot(packets['timestamp'][data_packet_mask],packet_index[data_packet_mask],'o',label='data packets',linestyle='None')
        plt.plot(packets['timestamp'][~data_packet_mask],packet_index[~data_packet_mask],'o',label='other',linestyle='None')
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
        plt.plot(packets['receipt_timestamp'][~data_packet_mask],packet_index[~data_packet_mask],'o',label='other',linestyle='None')
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

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--flow_file', default=None, type=str,help='''string corresponding to the path of the ndlar_flow output file to be considered''')
    args = parser.parse_args()
    main(**vars(args))


