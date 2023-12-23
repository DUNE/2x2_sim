release=v100r5p1

source /cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/setup.sh

CMTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/external/lcgcmake/lcg_61a/external/cmt/v1r20p20090520/x86_64-slc7-gcc49-opt/CMT/v1r20p20090520"; export CMTROOT
CMTCONFIG=x86_64-slc7-gcc49-opt; export CMTCONFIG
FILTEREVENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/FilterEvent"; export FILTEREVENTROOT
EVENTANALYSISROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/EventAnalysis"; export EVENTANALYSISROOT
RECOSTUDIESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/RecoStudies"; export RECOSTUDIESROOT
ROCKMUONSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/RockMuons"; export ROCKMUONSROOT
ROCKMUONCALIBRATIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/RockMuonCalibration"; export ROCKMUONCALIBRATIONROOT
CALIBRATIONTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/CalibrationTools"; export CALIBRATIONTOOLSROOT
READOUTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/Readout"; export READOUTROOT
CROSSTALKROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/CrossTalk"; export CROSSTALKROOT
ANAUTILSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/AnaUtils"; export ANAUTILSROOT
EVENTRECONSTRUCTIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/EventReconstruction"; export EVENTRECONSTRUCTIONROOT
PARTICLEMAKERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/ParticleMaker"; export PARTICLEMAKERROOT
KLUDGELIBRARYROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/KludgeLibrary"; export KLUDGELIBRARYROOT
TRUTHMATCHERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/TruthMatcher"; export TRUTHMATCHERROOT
PRONGMAKERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/ProngMaker"; export PRONGMAKERROOT
TRACKSHORTPATRECROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/TrackShortPatRec"; export TRACKSHORTPATRECROOT
BLOBFORMATIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/BlobFormation"; export BLOBFORMATIONROOT
RAWTODIGITROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/RawToDigit"; export RAWTODIGITROOT
ATTENUATIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/Attenuation"; export ATTENUATIONROOT
VERTEXCREATIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/VertexCreation"; export VERTEXCREATIONROOT
TRACKLONGPATRECROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/TrackLongPatRec"; export TRACKLONGPATRECROOT
RECUTILSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/RecUtils"; export RECUTILSROOT
TRACKFITTERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/TrackFitter"; export TRACKFITTERROOT
ENERGYRECTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/EnergyRecTools"; export ENERGYRECTOOLSROOT
GEOUTILSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/GeoUtils"; export GEOUTILSROOT
RECINTERFACESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/RecInterfaces"; export RECINTERFACESROOT
BADCHANNELSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/BadChannels"; export BADCHANNELSROOT
CLUSTERFORMATIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/ClusterFormation"; export CLUSTERFORMATIONROOT
MINOSINTERFACEROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/MinosInterface"; export MINOSINTERFACEROOT
DSTWRITERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/DSTWriter"; export DSTWRITERROOT
GATEQUALITYROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/GateQuality"; export GATEQUALITYROOT
EVENTRECINTERFACESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/EventRecInterfaces"; export EVENTRECINTERFACESROOT
NUMIINTERFACEROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/NumiInterface"; export NUMIINTERFACEROOT
BEAMSTUDIESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/BeamStudies"; export BEAMSTUDIESROOT
CHRONOBUNCHERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Rec/ChronoBuncher"; export CHRONOBUNCHERROOT
MCREWEIGHTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/MCReweight"; export MCREWEIGHTROOT
MINERVAUTILSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/MinervaUtils"; export MINERVAUTILSROOT
MNVDETECTORMCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/MNVDetectormc"; export MNVDETECTORMCROOT
GIGACNVROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/GiGaCnv"; export GIGACNVROOT
MINERVAGENEVENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/MinervaGenEvent"; export MINERVAGENEVENTROOT
READOUTINTERFACESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/ReadoutInterfaces"; export READOUTINTERFACESROOT
MINERVAMCEVENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/MinervaMCEvent"; export MINERVAMCEVENTROOT
PEDESTALSUPPRESSIONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/PedestalSuppression"; export PEDESTALSUPPRESSIONROOT
PLEXROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/Plex"; export PLEXROOT
ANAINTERFACESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Ana/AnaInterfaces"; export ANAINTERFACESROOT
TEMPERATUREROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Cal/Temperature"; export TEMPERATUREROOT
DAQRECVROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/DaqRecv"; export DAQRECVROOT
GATEEXTRACTORROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/GateExtractor"; export GATEEXTRACTORROOT
MINERVAEVENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/MinervaEvent"; export MINERVAEVENTROOT
EVENTINTERFACESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/EventInterfaces"; export EVENTINTERFACESROOT
GAUDIROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/Gaudi"; export GAUDIROOT
GAUDISYSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/GaudiSys"; export GAUDISYSROOT
GAUDIGSLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiGSL"; export GAUDIGSLROOT
IDDETROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/IDDet"; export IDDETROOT
MTDETROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/MTDet"; export MTDETROOT
MINERVADETROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/MinervaDet"; export MINERVADETROOT
ODDETROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/ODDet"; export ODDETROOT
VETODETROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/VetoDet"; export VETODETROOT
SIMSVCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/SimSvc"; export SIMSVCROOT
DETDESCCNVROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Det/DetDescCnv"; export DETDESCCNVROOT
MINERVACONFROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Top/MinervaConf"; export MINERVACONFROOT
MINERVADDDBIFROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/MinervaDDDBIF"; export MINERVADDDBIFROOT
CONDDBENTITYRESOLVERROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Tools/CondDBEntityResolver"; export CONDDBENTITYRESOLVERROOT
DETCONDROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Det/DetCond"; export DETCONDROOT
DETDESCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Det/DetDesc"; export DETDESCROOT
LHCBALGSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Kernel/LHCbAlgs"; export LHCBALGSROOT
LHCBKERNELROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Kernel/LHCbKernel"; export LHCBKERNELROOT
LHCBMATHROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Kernel/LHCbMath"; export LHCBMATHROOT
GAUDIPYTHONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPython"; export GAUDIPYTHONROOT
GIGAROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/GiGa"; export GIGAROOT
GAUDIALGROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiAlg"; export GAUDIALGROOT
GAUDIPOOLDBROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPoolDb"; export GAUDIPOOLDBROOT
HISTOSTRINGSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Kernel/HistoStrings"; export HISTOSTRINGSROOT
GAUDIUTILSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiUtils"; export GAUDIUTILSROOT
GAUDIAUDROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiAud"; export GAUDIAUDROOT
GAUDISVCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiSvc"; export GAUDISVCROOT
PARTPROPSVCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/PartPropSvc"; export PARTPROPSVCROOT
ROOTHISTCNVROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/RootHistCnv"; export ROOTHISTCNVROOT
MINERVAEVENTBASEROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/MinervaEventBase"; export MINERVAEVENTBASEROOT
MINERVAKERNELROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Event/MinervaKernel"; export MINERVAKERNELROOT
XMLTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/Tools/XmlTools"; export XMLTOOLSROOT
CLHEPTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/ClhepTools"; export CLHEPTOOLSROOT
PRODUCTIONSCRIPTSROOT="/cvmfs/minerva.opensciencegrid.org/minerva/CentralizedProductionScripts/Tools/ProductionScripts"; export PRODUCTIONSCRIPTSROOT
ROOTCNVROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/RootCnv"; export ROOTCNVROOT
GAUDIKERNELROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiKernel"; export GAUDIKERNELROOT
GAUDIOBJDESCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiObjDesc"; export GAUDIOBJDESCROOT
MINERVAPOLICYROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Top/MinervaPolicy"; export MINERVAPOLICYROOT
G4READOUTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4readout"; export G4READOUTROOT
G4PHYSICS_LISTSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4physics_lists"; export G4PHYSICS_LISTSROOT
G4RUNROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4run"; export G4RUNROOT
G4EVENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4event"; export G4EVENTROOT
G4TRACKINGROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4tracking"; export G4TRACKINGROOT
G4PROCESSESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4processes"; export G4PROCESSESROOT
G4DIGITS_HITSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4digits_hits"; export G4DIGITS_HITSROOT
G4TRACKROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4track"; export G4TRACKROOT
G4PARTICLESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4particles"; export G4PARTICLESROOT
G4GEOMETRYROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4geometry"; export G4GEOMETRYROOT
G4MATERIALSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4materials"; export G4MATERIALSROOT
G4GRAPHICS_REPSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4graphics_reps"; export G4GRAPHICS_REPSROOT
G4INTERCOMSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4intercoms"; export G4INTERCOMSROOT
G4GLOBALROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4global"; export G4GLOBALROOT
GDMLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GDML"; export GDMLROOT
G4CONFIGROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/Geant4/G4config"; export G4CONFIGROOT
GAUDIPOLICYROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPolicy"; export GAUDIPOLICYROOT
REFLEXROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/Reflex"; export REFLEXROOT
POOLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/POOL"; export POOLROOT
GENIEROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE"; export GENIEROOT
COOLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/COOL"; export COOLROOT
MINOSGEOMROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/MinosGeom"; export MINOSGEOMROOT
NUMIBEAMDBROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NumiBeamDB"; export NUMIBEAMDBROOT
PPFXROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/ppfx"; export PPFXROOT
ROOTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/ROOT"; export ROOTROOT
CORALROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/CORAL"; export CORALROOT
BOOSTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/Boost"; export BOOSTROOT
PYTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/pytools"; export PYTOOLSROOT
MINERVADDDBROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaDDDB"; export MINERVADDDBROOT
NUCONDBROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NuConDB"; export NUCONDBROOT
PSYCOPG2ROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/psycopg2"; export PSYCOPG2ROOT
POSTGRES_CLIENTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/postgres_client"; export POSTGRES_CLIENTROOT
PYTHONROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/Python"; export PYTHONROOT
TCMALLOCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/tcmalloc"; export TCMALLOCROOT
LIBUNWINDROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/libunwind"; export LIBUNWINDROOT
GCCXMLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/GCCXML"; export GCCXMLROOT
XROOTDROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/xrootd"; export XROOTDROOT
AIDAROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/AIDA"; export AIDAROOT
UUIDROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/uuid"; export UUIDROOT
XERCESCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/XercesC"; export XERCESCROOT
GSLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/GSL"; export GSLROOT
CLHEPROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/CLHEP"; export CLHEPROOT
RELAXROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/RELAX"; export RELAXROOT
HEPPDTROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/HepPDT"; export HEPPDTROOT
MYSQLROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/mysql"; export MYSQLROOT
PYTHIA6ROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_GeneratorsInterfaces/pythia6"; export PYTHIA6ROOT
LHAPDFROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_GeneratorsInterfaces/lhapdf"; export LHAPDFROOT
HEPMCROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/HepMC"; export HEPMCROOT
SQLITEROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/sqlite"; export SQLITEROOT
MPARAMFILESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/MParamFiles"; export MPARAMFILESROOT
LOG4CPPROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/LOG4CPP"; export LOG4CPPROOT
MINEXTERNALROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/MINEXTERNAL"; export MINEXTERNALROOT
MINERVAXMLCONDITIONSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions"; export MINERVAXMLCONDITIONSROOT
MINERVASQLDDDBROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaSQLDDDB"; export MINERVASQLDDDBROOT
VALIDATIONTOOLSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/ValidationTools"; export VALIDATIONTOOLSROOT
MINOSFIELDMAPROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinosFieldMap"; export MINOSFIELDMAPROOT
GEANT4FILESROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Geant4Files/v91r0"; export GEANT4FILESROOT
SYSTEMTESTSROOT="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/SystemTests"; export SYSTEMTESTSROOT
CMTPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61"; export CMTPATH
PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/psycopg2/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/postgres_client/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../sqlite/3070900/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../COOL/COOL_2_8_20/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../pytools/1.6_python2.7/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../mysql/5.5.14/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../POOL/POOL_2_9_19/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../CORAL/CORAL_2_3_27a/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../XercesC/3.1.1p1/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../ROOT/5.34.36/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../xrootd/3.3.6/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../gccxml/0.9.0_20150423/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../tcmalloc/2.6.2/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../Python/2.7.11/x86_64-slc7-gcc49-opt/bin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/external/lcgcmake/lcg_61a/external/cmt/v1r20p20090520/x86_64-slc7-gcc49-opt/CMT/v1r20p20090520/Linux-x86_64:/cvmfs/minerva.opensciencegrid.org/product/prd/gcc/v4_9_3/Linux64bit-3-10-2-17/bin:/cvmfs/minerva.opensciencegrid.org/product/prd/ups/v4_7_4a/Linux-2/bin:/cvmfs/minerva.opensciencegrid.org/minerva/valgrind-3.5.0/bin:/usr/lib64/qt-3.3/bin:/opt/puppetlabs/bin:/opt/jobsub_lite/bin:/opt/encp:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MinervaScripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/cmake_sl7/bin:/cvmfs/minerva.opensciencegrid.org/minerva/ack:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/MINEXTERNAL/scripts:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/MinervaUtils/python:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/MNVDetectormc/x86_64-slc7-gcc49-opt"; export PATH
CLASSPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/external/lcgcmake/lcg_61a/external/cmt/v1r20p20090520/x86_64-slc7-gcc49-opt/CMT/v1r20p20090520/java"; export CLASSPATH
unset include
unset lib
NEWCMTCONFIG="x86_64-sl79-gcc493"; export NEWCMTCONFIG
unset intelplat
unset intel_home
unset icc_c_home
unset icc_f_home
unset LDFLAGS
unset CPPFLAGS
unset CFLAGS
unset CXXFLAGS
unset FFLAGS
unset CCACHE_PREFIX
COMPILER_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../gcc/4.9.1/x86_64-slc7/lib/gcc/x86_64-unknown-linux-gnu/4.9.1"; export COMPILER_PATH
LD_LIBRARY_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/ppfx/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/MinosGeom/x86_64-slc7-gcc49-opt:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NumiBeamDB/x86_64-slc7-gcc49-opt:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/psycopg2/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/postgres_client/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GDML/x86_64-slc7-gcc49-opt:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../sqlite/3070900/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../COOL/COOL_2_8_20/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../HepMC/2.06.08/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_GeneratorsInterfaces/pythia6/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Interfaces/ROOT/lib:/grid/fermiapp/minerva/sharedlib/x86_64-slc7-gcc49-opt/:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../MCGenerators_hepmc2.06.08/lhapdf/5.9.1/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../MCGenerators_hepmc2.06.08/pythia6/427.2/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/LOG4CPP/x86_64-slc7-gcc49-opt:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../pytools/1.6_python2.7/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../mysql/5.5.14/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../HepPDT/2.06.01/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../RELAX/RELAX_1_3_0p/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../POOL/POOL_2_9_19/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../CORAL/CORAL_2_3_27a/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../clhep/1.9.4.7/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../GSL/1.10/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../XercesC/3.1.1p1/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../uuid/1.38p1/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../Boost/1.57.0_python2.7/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../ROOT/5.34.36/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../xrootd/3.3.6/x86_64-slc7-gcc49-opt/lib64:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../tcmalloc/2.6.2/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../libunwind/5c2cade/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/product/prd/gcc/v4_9_3/Linux64bit-3-10-2-17/lib64:/cvmfs/minerva.opensciencegrid.org/product/prd/gcc/v4_9_3/Linux64bit-3-10-2-17/lib:/usr/lib64:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../Python/2.7.11/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NuConDB/x86_64-slc7-gcc49-opt"; export LD_LIBRARY_PATH
ATLAS_TAGS_MAP="none"; export ATLAS_TAGS_MAP
host_cmtconfig="x86_64-linux-unknownGcc-opt"; export host_cmtconfig
unset PYTHONHOME
DYLD_LIBRARY_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/ROOT/5.34.36/x86_64-slc7-gcc49-opt/lib"; export DYLD_LIBRARY_PATH
MANPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../mysql/5.5.14/x86_64-slc7-gcc49-opt/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../GSL/1.10/x86_64-slc7-gcc49-opt/share/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../uuid/1.38p1/x86_64-slc7-gcc49-opt/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../ROOT/5.34.36/x86_64-slc7-gcc49-opt/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../tcmalloc/2.6.2/x86_64-slc7-gcc49-opt/share/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../libunwind/5c2cade/x86_64-slc7-gcc49-opt/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../Python/2.7.11/x86_64-slc7-gcc49-opt/share/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../gccxml/0.9.0_20150423/x86_64-slc7-gcc49-opt/share/man:/opt/jobsub_lite/man:/opt/puppetlabs/puppet/share/man:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../ROOT/5.34.36/src/root/man"; export MANPATH
unset QMTEST_CLASS_PATH
POOLVERS="POOL_2_9_19"; export POOLVERS
COOLVERS="COOL_2_8_20"; export COOLVERS
CORALVERS="CORAL_2_3_27a"; export CORALVERS
ROOTVERS="5.34.36"; export ROOTVERS
BoostVERS="1.57.0"; export BoostVERS
uuidVERS="1.38p1"; export uuidVERS
GCCXMLVERS="0.9.0_20150423"; export GCCXMLVERS
AIDAVERS="3.2.1"; export AIDAVERS
XercesCVERS="3.1.1p1"; export XercesCVERS
GSLVERS="1.10"; export GSLVERS
PythonVERS="2.7.11"; export PythonVERS
HepMCVERS="2.06.08"; export HepMCVERS
QMtestVERS="2.4.1"; export QMtestVERS
LCGCMTVERS="minerva61a"; export LCGCMTVERS
GAUDI_DOXY_HOME="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/GaudiRelease/doc"; export GAUDI_DOXY_HOME
ROOTSYS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../ROOT/5.34.36/x86_64-slc7-gcc49-opt"; export ROOTSYS
PYTHONPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/python/lib-dynload:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/python/lib-dynload:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python/lib-dynload:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python/lib-dynload:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python/lib-dynload:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/python.zip:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/InstallArea/x86_64-slc7-gcc49-opt/python.zip:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/LHCB/LHCB_v33r0p1b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python.zip:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GEANT4/GEANT4_v94r2p2b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python.zip:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/python.zip:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/psycopg2/x86_64-slc7-gcc49-opt/lib/python2.6/site-packages:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../COOL/COOL_2_8_20/x86_64-slc7-gcc49-opt/python:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../pytools/1.6_python2.7/x86_64-slc7-gcc49-opt/lib/python2.7/site-packages:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../CORAL/CORAL_2_3_27a/x86_64-slc7-gcc49-opt/python:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../CORAL/CORAL_2_3_27a/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva/CentralizedProductionScripts/Tools/ProductionScripts/py_classes:/cvmfs/minerva.opensciencegrid.org/minerva/CentralizedProductionScripts/Tools/ProductionScripts/production_tools:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Top/MinervaConf/python/MinervaConf/:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/MinervaDDDBIF/python/MinervaDDDBIF/:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/ROOT/5.34.36/x86_64-slc7-gcc49-opt/lib:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MinervaScripts/python:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/MinervaUtils/python:/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NuConDB/python"; export PYTHONPATH
unset GaudiUtilsShr
unset GaudiAlgShr
unset GaudiAudShr
unset GaudiGSLShr
JOBOPTSEARCHPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPoolDb/options"; export JOBOPTSEARCHPATH
unset GaudiSvcShr
unset GaudiSvcTestShr
unset PartPropSvcShr
DATAPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/PartPropSvc/share"; export DATAPATH
unset RootHistCnvShr
GAUDIVERS="v22r4"; export GAUDIVERS
GAUDIEXE="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/InstallArea/x86_64-slc7-gcc49-opt/bin/Gaudi.exe"; export GAUDIEXE
alias Gaudi="Gaudi.exe"
alias GaudiRun="gaudirun.py"
MPARAMFILES="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/MParamFiles/data"; export MPARAMFILES
LHAPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE/${CMTCONFIG}/GENIE/data/evgen/pdfs"; export LHAPATH
GENIE="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE/${CMTCONFIG}/GENIE"; export GENIE
GMSGCONF="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/GENIE/minerva/Messenger.xml"; export GMSGCONF
PYTHIA6HOME="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../MCGenerators_hepmc2.06.08/pythia6/427.2/x86_64-slc7-gcc49-opt"; export PYTHIA6HOME
LHAPDF_HOME="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../MCGenerators_hepmc2.06.08/lhapdf/5.9.1/x86_64-slc7-gcc49-opt"; export LHAPDF_HOME
GSL_HOME="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../GSL/1.10/x86_64-slc7-gcc49-opt"; export GSL_HOME
EXTENDED_NIEVES="EXTENDED_NIEVES"; export EXTENDED_NIEVES
unset MinervaEventShr
unset XmlToolsShr
unset DetDescCnvShr
ODDETOPTS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/VetoDet/options"; export ODDETOPTS
unset ODDetShr
unset MinervaDetShr
IDDETOPTS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Det/IDDet/options"; export IDDETOPTS
unset IDDetShr
MINERVA_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalog.xml"; export MINERVA_CONDITIONS_PATH
MINERVA_FULL_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalog.xml"; export MINERVA_FULL_CONDITIONS_PATH
FROZEN_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalog.xml"; export FROZEN_CONDITIONS_PATH
TP_NUMI_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTPNumi.xml"; export TP_NUMI_CONDITIONS_PATH
TP_WIDEBAND_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTP.xml"; export TP_WIDEBAND_CONDITIONS_PATH
MTEST_20E20H_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTestBeam20E20H.xml"; export MTEST_20E20H_CONDITIONS_PATH
MTEST_20T20E_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTestBeam20T20E.xml"; export MTEST_20T20E_CONDITIONS_PATH
MTESTII_20E20H_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTestBeamII20E20H.xml"; export MTESTII_20E20H_CONDITIONS_PATH
MTESTII_SUPERHCAL_CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaXmlConditions/DDDB/Conditions/MainCatalogTestBeamIISuperHCal.xml"; export MTESTII_SUPERHCAL_CONDITIONS_PATH
CONDITIONS_PATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaDDDB/DDDB"; export CONDITIONS_PATH
SQLITEDBPATH="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaSQLDDDB/db"; export SQLITEDBPATH
unset DetCondShr
unset CondDBEntityResolverShr
unset PlexShr
MNV_DEFAULT_HISTOGRAM_LEVEL="3"; export MNV_DEFAULT_HISTOGRAM_LEVEL
unset MinervaUtilsShr
unset FilterEventShr
unset TruthMatcherShr
GIGAOPTS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/GiGa/options"; export GIGAOPTS
G4_native_version="9.4.p02"; export G4_native_version
G4VERS="v94r2p2"; export G4VERS
G4PATH="${SITEROOT}/lcg/external/Geant4"; export G4PATH
G4SHARE="${G4PATH}/${G4_native_version}/share/sources"; export G4SHARE
G4SRC="${G4SHARE}/source"; export G4SRC
G4_UNIX_COPY=" cp -a "; export G4_UNIX_COPY
unset GiGaShr
unset GiGaCnvShr
unset GeoUtilsLibShr
MINERVAOPTS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Top/MinervaConf/options"; export MINERVAOPTS
MINERVA_GEOMETRY="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinervaDDDB/DDDB"; export MINERVA_GEOMETRY
unset BadChannelsShr
unset VetoDetShr
unset ClusterFormationLibShr
unset EnergyRecToolsLibShr
unset RecUtilsLibShr
unset BlobFormationLibShr
unset MinosInterfaceShr
unset AttenuationCalShr
unset GateQualityShr
unset TemperatureShr
unset RawToDigitShr
unset VertexCreationLibShr
unset ProngMakerShr
unset AnaUtilsShr
unset RockMuonsShr
unset NUMIBEAMDB_BULD64
SRT_BASE_RELEASE="ThisAintSrt"; export SRT_BASE_RELEASE
ROOT_RELEASE="ThisAintSrt"; export ROOT_RELEASE
NUMIBEAMDB_FQ_DIR="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/NumiBeamDB/NumiBeamDB"; export NUMIBEAMDB_FQ_DIR
MINOSGEOM_FQ_DIR="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/MinosGeom/${CMTCONFIG}"; export MINOSGEOM_FQ_DIR
BMAPPATH="/minos/data/release_data/bmaps/"; export BMAPPATH
unset NumiInterfaceShr
unset DSTWriterShr
unset EventAnalysisShr
unset TrackFitterLibShr
unset TrackShortPatRecLibShr
unset ParticleMakerShr
unset RecoStudiesShr
unset BeamStudiesShr
unset PedestalSuppressionShr
unset RockMuonCalibrationShr
run_comparison="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Tools/ValidationTools/HistComp/run_comparison"; export run_comparison
unset RootCnvShr
unset CalibrationToolsShr
unset ChronoBuncherShr
unset TrackLongPatRecLibShr
unset KludgeLibraryShr
unset EventReconstructionShr
MINOSFIELDMAP="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Det/MinosFieldMap/cdf/field010.cdf"; export MINOSFIELDMAP
unset SimSvcShr
unset LHCbAlgsShr
G4DATA="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Geant4Files/v91r0/data"; export G4DATA
G4LEVELGAMMADATA="${G4DATA}/PhotonEvaporation2.0"; export G4LEVELGAMMADATA
G4RADIOACTIVEDATA="${G4DATA}/RadioactiveDecay3.2"; export G4RADIOACTIVEDATA
G4LEDATA="${G4DATA}/G4EMLOW5.1"; export G4LEDATA
G4NEUTRONHPDATA="${G4DATA}/G4NDL3.12"; export G4NEUTRONHPDATA
G4ABLADATA="${G4DATA}/G4ABLA3.0"; export G4ABLADATA
MNVDETECTORMCOPTS="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MINERVA/MINERVA_${release}/Sim/MNVDetectormc/options"; export MNVDETECTORMCOPTS
NeutronHPCrossSections="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/MDBASE/MDBASE_${release}/Geant4Files/v91r0/data/G4NDL"; export NeutronHPCrossSections
unset MNVDetectormcShr
unset MTDetShr
unset CrossTalkShr
unset ReadoutShr
unset DaqRecvShr
unset GateExtractorShr
PPFX_DIR="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/minerva/EXTERNAL/EXTERNAL_${release}/ppfx/${CMTCONFIG}/workdir/ppfx"; export PPFX_DIR
PPFX_BOOST_INCLUDE_DIR="/cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lcg/external/LCGCMT/LCGCMT_61/LCG_Settings/../../../Boost/1.57.0_python2.7/x86_64-slc7-gcc49-opt/include/boost-1_57"; export PPFX_BOOST_INCLUDE_DIR
unset MCReweightShr
if test -f /cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPolicy/scripts/StripPath.sh; then
  . /cvmfs/minerva.opensciencegrid.org/minerva2x2/products/releases/${release}/lhcb/GAUDI/GAUDI_v22r4b_lcgcmake/Gaudi/GaudiPolicy/scripts/StripPath.sh
fi