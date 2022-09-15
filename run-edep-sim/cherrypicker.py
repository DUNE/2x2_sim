#!/usr/bin/env python3

import sys
import ROOT
from optparse import OptionParser

def is_in_region(pos):
    ## Is this in the LAr active region?
    if abs(pos[0]) > 0.67:
        return False
    if abs(pos[1] - 0.43) > 0.67:
        return False
    if abs(pos[2]) > 0.67:
        return False
    return True


def skim_file(input_file_name, output_file_name):

    ## Open the input file
    chain = ROOT.TChain("gRooTracker")
    chain .Add(input_file_name)
    chain .LoadTree(0)

    ## Make the skim file and tree
    skim_file = ROOT.TFile(output_file_name, "RECREATE")
    skim_tree = chain.GetTree().CloneTree(0)

    ## Count the number saved
    nsaved = 0
    
    ## Loop over events, decide if they're in the active region
    nevt = chain.GetEntries()
    print("Skimming", nevt, "events from", input_file_name)
    
    for x in range(nevt):
        chain.GetEntry(x)

        npart = chain.StdHepN
        vtx = chain.EvtVtx
        vtx .SetSize(4)

        ## Save this event?
        if not is_in_region(vtx): continue
        nsaved += 1
        skim_tree .Fill()

    ## Save output
    skim_tree.Write()
    skim_file.Close()
    print("Saved", nsaved, "events to", output_file_name, "(%.3f)"%(nsaved/float(nevt)))
    return
    
if __name__ == '__main__':

    ## Get arguments
    parser = OptionParser()
    parser .add_option("-i", "--inFile",  action="store", type="string", dest="inFile"     )
    parser .add_option("-o", "--outFile", action="store", type="string", dest="outFile"    )
    (options, sys.argv[1:]) = parser.parse_args()

    ## Skim!
    skim_file(options.inFile, options.outFile)
