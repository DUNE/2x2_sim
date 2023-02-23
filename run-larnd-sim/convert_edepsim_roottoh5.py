#! /usr/bin/env python
"""
Converts ROOT file created by edep-sim into HDF5 format
"""

from math import sqrt
import os
import numpy as np
import fire
import h5py
from tqdm import tqdm
import glob

from ROOT import TG4Event, TFile, TMap

# Output array datatypes
segments_dtype = np.dtype([("spillID","u4"),("eventID", "u4"), ("segment_id", "u4"),
                           ("z_end", "f4"),("trackID", "u4"), ("tran_diff", "f4"),
                           ("z_start", "f4"), ("x_end", "f4"),
                           ("y_end", "f4"), ("n_electrons", "u4"),
                           ("pdgId", "i4"), ("x_start", "f4"),
                           ("y_start", "f4"), ("t_start", "f4"),
                           ("t0_start", "f8"), ("t0_end", "f8"), ("t0", "f8"),
                           ("dx", "f4"), ("long_diff", "f4"),
                           ("pixel_plane", "i4"), ("t_end", "f4"),
                           ("dEdx", "f4"), ("dE", "f4"), ("t", "f4"),
                           ("y", "f4"), ("x", "f4"), ("z", "f4"),
                           ("n_photons","f4")], align=True)

trajectories_dtype = np.dtype([("spillID","u4"), ("eventID", "u4"),
                               ("trackID", "u4"), ("parentID", "i4"),
                               ("pxyz_start", "f4", (3,)),
                               ("xyz_start", "f4", (3,)), ("t_start", "f4"),
                               ("pxyz_end", "f4", (3,)),
                               ("xyz_end", "f4", (3,)), ("t_end", "f4"),
                               ("pdgId", "i4"), ("start_process", "u4"),
                               ("start_subprocess", "u4"), ("end_process", "u4"),
                               ("end_subprocess", "u4")], align=True)

vertices_dtype = np.dtype([("spillID","u4"), ("eventID","u4"),
                           ("x_vert","f4"), ("y_vert","f4"),
                           ("z_vert","f4")], align=True)

# Convert from EDepSim default units (mm, ns)
edep2cm = 0.1   # convert to cm
edep2us = 0.001 # convert to microseconds

# Print the fields in a TG4PrimaryParticle object
def printPrimaryParticle(depth, primaryParticle):
    print(depth,"Class: ", primaryParticle.ClassName())
    print(depth,"Track Id:", primaryParticle.GetTrackId())
    print(depth,"Name:", primaryParticle.GetName())
    print(depth,"PDG Code:",primaryParticle.GetPDGCode())
    print(depth,"Momentum:",primaryParticle.GetMomentum().X(),
          primaryParticle.GetMomentum().Y(),
          primaryParticle.GetMomentum().Z(),
          primaryParticle.GetMomentum().E(),
          primaryParticle.GetMomentum().P(),
          primaryParticle.GetMomentum().M())

# Print the fields in an TG4PrimaryVertex object
def printPrimaryVertex(depth, primaryVertex):
    print(depth,"Class: ", primaryVertex.ClassName())
    print(depth,"Position:", primaryVertex.GetPosition().X(),
          primaryVertex.GetPosition().Y(),
          primaryVertex.GetPosition().Z(),
          primaryVertex.GetPosition().T())
    print(depth,"Generator:",primaryVertex.GetGeneratorName())
    print(depth,"Reaction:",primaryVertex.GetReaction())
    print(depth,"Filename:",primaryVertex.GetFilename())
    print(depth,"InteractionNumber:",primaryVertex.GetInteractionNumber())
    depth = depth + ".."
    for infoVertex in primaryVertex.Informational:
        printPrimaryVertex(depth,infoVertex)
    for primaryParticle in primaryVertex.Particles:
        printPrimaryParticle(depth,primaryParticle)

# Print the fields in a TG4TrajectoryPoint object
def printTrajectoryPoint(depth, trajectoryPoint):
    print(depth,"Class: ", trajectoryPoint.ClassName())
    print(depth,"Position:", trajectoryPoint.GetPosition().X(),
          trajectoryPoint.GetPosition().Y(),
          trajectoryPoint.GetPosition().Z(),
          trajectoryPoint.GetPosition().T())
    print(depth,"Momentum:", trajectoryPoint.GetMomentum().X(),
          trajectoryPoint.GetMomentum().Y(),
          trajectoryPoint.GetMomentum().Z(),
          trajectoryPoint.GetMomentum().Mag())
    print(depth,"Process",trajectoryPoint.GetProcess())
    print(depth,"Subprocess",trajectoryPoint.GetSubprocess())

# Print the fields in a TG4Trajectory object
def printTrajectory(depth, trajectory):
    print(depth,"Class: ", trajectory.ClassName())
    depth = depth + ".."
    print(depth,"Track Id/Parent Id:",
          trajectory.GetTrackId(),
          trajectory.GetParentId())
    print(depth,"Name:",trajectory.GetName())
    print(depth,"PDG Code",trajectory.GetPDGCode())
    print(depth,"Initial Momentum:",trajectory.GetInitialMomentum().X(),
          trajectory.GetInitialMomentum().Y(),
          trajectory.GetInitialMomentum().Z(),
          trajectory.GetInitialMomentum().E(),
          trajectory.GetInitialMomentum().P(),
          trajectory.GetInitialMomentum().M())
    for trajectoryPoint in trajectory.Points:
        printTrajectoryPoint(depth,trajectoryPoint)

# Print the fields in a TG4HitSegment object
def printHitSegment(depth, hitSegment):
    print(depth,"Class: ", hitSegment.ClassName())
    print(depth,"Primary Id:", hitSegment.GetPrimaryId())
    print(depth,"Energy Deposit:",hitSegment.GetEnergyDeposit())
    print(depth,"Secondary Deposit:", hitSegment.GetSecondaryDeposit())
    print(depth,"Track Length:",hitSegment.GetTrackLength())
    print(depth,"Start:", hitSegment.GetStart().X(),
          hitSegment.GetStart().Y(),
          hitSegment.GetStart().Z(),
          hitSegment.GetStart().T())
    print(depth,"Stop:", hitSegment.GetStop().X(),
          hitSegment.GetStop().Y(),
          hitSegment.GetStop().Z(),
          hitSegment.GetStop().T())
    print(depth,"Contributor:", [contributor for contributor in hitSegment.Contrib])

# Print the fields in a single element of the SegmentDetectors map.
# The container name is the key, and the hitSegments is the value (a
# vector of TG4HitSegment objects).
def printSegmentContainer(depth, containerName, hitSegments):
    print(depth,"Detector: ", containerName, hitSegments.size())
    depth = depth + ".."
    for hitSegment in hitSegments: printHitSegment(depth, hitSegment)

# Prep HDF5 file for writing
def initHDF5File(output_file):
    with h5py.File(output_file, 'w') as f:
        f.create_dataset('trajectories', (0,), dtype=trajectories_dtype, maxshape=(None,))
        f.create_dataset('segments', (0,), dtype=segments_dtype, maxshape=(None,))
        f.create_dataset('vertices', (0,), dtype=vertices_dtype, maxshape=(None,))

# Resize HDF5 file and save output arrays
def updateHDF5File(output_file, trajectories, segments, vertices):
    if any([len(trajectories), len(segments), len(vertices)]):
        with h5py.File(output_file, 'a') as f:
            if len(trajectories):
                ntraj = len(f['trajectories'])
                f['trajectories'].resize((ntraj+len(trajectories),))
                f['trajectories'][ntraj:] = trajectories

            if len(segments):
                nseg = len(f['segments'])
                f['segments'].resize((nseg+len(segments),))
                f['segments'][nseg:] = segments

            if len(vertices):
                nvert = len(f['vertices'])
                f['vertices'].resize((nvert+len(vertices),))
                f['vertices'][nvert:] = vertices

# Read a file and dump it.
def dump(input_files, output_file, spill_period=1.2E6):

    """
    Script to convert edep-sim root output to an h5 file formatted in a way
    that larnd-sim expects for consumption.

    Args:
        input_file (str): path to one or more input root files. Each file is expected
            expected to correspond to a single spill.
        output_file (str): name of the h5 output file to which the information should
            be written
        spill_period (double): the spill period to be simulate. Each spill in the inputs
            will be separated by this much time [in microseconds]
    """

    # Prep output file
    initHDF5File(output_file)

    segment_id = 0
 
    for it, inputFile_name in enumerate(glob.glob(input_files)):

        print("----------------------------------------------------")
        print(it)
        print("----------------------------------------------------")
        # Get the input tree out of the file.
        inputFile = TFile(inputFile_name)
        inputTree = inputFile.Get("EDepSimEvents")
        #print("Class:", inputTree.ClassName())

        # Attach a brach to the events.
        event = TG4Event()
        inputTree.SetBranchAddress("Event",event)

        # map that gives which spill each event lives in
        event_spill_map = inputFile.Get("event_spill_map")

        # Read all of the events.
        entries = inputTree.GetEntriesFast()

        segments_list = list()
        trajectories_list = list()
        vertices_list = list()

        for jentry in tqdm(range(entries)):
            #print(jentry,"/",entries)
            nb = inputTree.GetEntry(jentry)

            spill_it_tobj = event_spill_map.GetValue(str(event.EventId))
            spill_it = int(spill_it_tobj.GetName())
            #print("event",event.EventId,"in spill",spill_it)

            # write to file
            if len(trajectories_list) >= 1000 or nb <= 0:
                updateHDF5File(
                    output_file,
                    np.concatenate(trajectories_list, axis=0) if trajectories_list else np.empty((0,)),
                    np.concatenate(segments_list, axis=0) if segments_list else np.empty((0,)),
                    np.concatenate(vertices_list, axis=0) if vertices_list else np.empty((0,)))
                trajectories_list = list()
                segments_list = list()
                vertices_list = list()

            if nb <= 0:
                continue

            no_active_hits = True
            for containerName, hitSegments in event.SegmentDetectors:
                if not containerName == 'volLArActive':
                    continue
                no_active_hits = False
            if no_active_hits:
                continue

            #print("Class: ", event.ClassName())
            #print("Event number:", event.EventId)

            # Dump the primary vertices
            vertex = np.empty(len(event.Primaries), dtype=vertices_dtype)
            for primaryVertex in event.Primaries:
                #printPrimaryVertex("PP", primaryVertex)
                vertex["spillID"] = spill_it
                vertex["eventID"] = event.EventId + 1e5*spill_it
                vertex["x_vert"] = primaryVertex.GetPosition().X()
                vertex["y_vert"] = primaryVertex.GetPosition().Y()
                vertex["z_vert"] = primaryVertex.GetPosition().Z()
                vertices_list.append(vertex)

            # Dump the trajectories
            #print("Number of trajectories ", len(event.Trajectories))
            trajectories = np.empty(len(event.Trajectories), dtype=trajectories_dtype)
            for iTraj, trajectory in enumerate(event.Trajectories):
                start_pt, end_pt = trajectory.Points[0], trajectory.Points[-1]
                trajectories[iTraj]["spillID"] = spill_it
                trajectories[iTraj]["eventID"] = event.EventId + 1e5*spill_it
                #trajectories[iTraj]["trackID"] = trajectory.GetTrackId() + 1e6*spill_it
                trajectories[iTraj]["trackID"] = trajectory.GetTrackId()
                trajectories[iTraj]["parentID"] = trajectory.GetParentId()
                trajectories[iTraj]["pxyz_start"] = (start_pt.GetMomentum().X(), start_pt.GetMomentum().Y(), start_pt.GetMomentum().Z())
                trajectories[iTraj]["pxyz_end"] = (end_pt.GetMomentum().X(), end_pt.GetMomentum().Y(), end_pt.GetMomentum().Z())
                trajectories[iTraj]["xyz_start"] = (start_pt.GetPosition().X(), start_pt.GetPosition().Y(), start_pt.GetPosition().Z())
                trajectories[iTraj]["xyz_end"] = (end_pt.GetPosition().X(), end_pt.GetPosition().Y(), end_pt.GetPosition().Z())
                trajectories[iTraj]["t_start"] = start_pt.GetPosition().T() * edep2us + spill_period*spill_it
                trajectories[iTraj]["t_end"] = end_pt.GetPosition().T() * edep2us + spill_period*spill_it
                trajectories[iTraj]["start_process"] = start_pt.GetProcess()
                trajectories[iTraj]["start_subprocess"] = start_pt.GetSubprocess()
                trajectories[iTraj]["end_process"] = end_pt.GetProcess()
                trajectories[iTraj]["end_subprocess"] = end_pt.GetSubprocess()
                trajectories[iTraj]["pdgId"] = trajectory.GetPDGCode()

            trajectories_list.append(trajectories)

            # Dump the segment containers
            #print("Number of segment containers:", event.SegmentDetectors.size())
            for containerName, hitSegments in event.SegmentDetectors:
                if not containerName == 'volLArActive':
                    continue
                segment = np.empty(len(hitSegments), dtype=segments_dtype)
                for iHit, hitSegment in enumerate(hitSegments):
                    segment[iHit]["spillID"] = spill_it
                    segment[iHit]["eventID"] = event.EventId + 1e5*spill_it
                    segment[iHit]["segment_id"] = segment_id
                    segment_id += 1
                    try:
                        segment[iHit]["trackID"] = trajectories[hitSegment.Contrib[0]]["trackID"]
                    except IndexError as e:
                        print(e)
                        print("iHit:",iHit)
                        print("len(segment):",len(segment))
                        print("hitSegment.Contrib[0]:",hitSegment.Contrib[0])
                        print("len(trajectories):",len(trajectories))
                    segment[iHit]["x_start"] = hitSegment.GetStart().X() * edep2cm
                    segment[iHit]["y_start"] = hitSegment.GetStart().Y() * edep2cm
                    segment[iHit]["z_start"] = hitSegment.GetStart().Z() * edep2cm
                    segment[iHit]["t0_start"] = hitSegment.GetStart().T() * edep2us + spill_period*spill_it
                    segment[iHit]["t_start"] = 0
                    segment[iHit]["x_end"] = hitSegment.GetStop().X() * edep2cm
                    segment[iHit]["y_end"] = hitSegment.GetStop().Y() * edep2cm
                    segment[iHit]["z_end"] = hitSegment.GetStop().Z() * edep2cm
                    segment[iHit]["t0_end"] = hitSegment.GetStop().T() * edep2us + spill_period*spill_it
                    segment[iHit]["t_end"] = 0
                    segment[iHit]["dE"] = hitSegment.GetEnergyDeposit()
                    xd = segment[iHit]["x_end"] - segment[iHit]["x_start"]
                    yd = segment[iHit]["y_end"] - segment[iHit]["y_start"]
                    zd = segment[iHit]["z_end"] - segment[iHit]["z_start"]
                    dx = sqrt(xd**2 + yd**2 + zd**2)
                    segment[iHit]["dx"] = dx
                    segment[iHit]["x"] = (segment[iHit]["x_start"] + segment[iHit]["x_end"]) / 2.
                    segment[iHit]["y"] = (segment[iHit]["y_start"] + segment[iHit]["y_end"]) / 2.
                    segment[iHit]["z"] = (segment[iHit]["z_start"] + segment[iHit]["z_end"]) / 2.
                    segment[iHit]["t0"] = (segment[iHit]["t0_start"] + segment[iHit]["t0_end"]) / 2.
                    segment[iHit]["t"] = 0
                    segment[iHit]["dEdx"] = hitSegment.GetEnergyDeposit() / dx if dx > 0 else 0
                    segment[iHit]["pdgId"] = trajectories[hitSegment.Contrib[0]]["pdgId"]
                    segment[iHit]["n_electrons"] = 0
                    segment[iHit]["long_diff"] = 0
                    segment[iHit]["tran_diff"] = 0
                    segment[iHit]["pixel_plane"] = 0
                    segment[iHit]["n_photons"] = 0

                segments_list.append(segment)

        # save any lingering data not written to file
        updateHDF5File(
            output_file,
            np.concatenate(trajectories_list, axis=0) if trajectories_list else np.empty((0,)),
            np.concatenate(segments_list, axis=0) if segments_list else np.empty((0,)),
            np.concatenate(vertices_list, axis=0) if vertices_list else np.empty((0,)))

if __name__ == "__main__":
    fire.Fire(dump)
