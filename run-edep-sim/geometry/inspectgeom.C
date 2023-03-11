void RecursiveInvisible(TGeoVolume *vol);
void RecursiveVisible(TGeoVolume *vol);
void RecursiveTransparency(TGeoVolume *vol, Int_t transp);

void inspectgeom(std::string filename) {
  TGeoManager::Import(filename.c_str());
  // TBrowser *b = new TBrowser();
  TGeoManager *geom = gGeoManager;
  geom->SetTopVisible(true);
  geom->DefaultColors();
  geom->SetVisLevel(30);

  // Print the list of volumes in the geometry
  // geom->GetListOfVolumes()->Print();

  // // Set to 50% transparency
  RecursiveTransparency(geom->GetTopVolume(), 30);

  TGeoVolume *volume = NULL;
  TObjArray *volumes = geom->GetListOfVolumes();
  Int_t nvolumes = volumes->GetEntries();
  for ( int i = 0; i < nvolumes; i++ ) {    
    volume = (TGeoVolume*)volumes->At(i);
    volume->SetVisContainers(kTRUE);

    // Remove MINERvA fibers...
    if (TString(volume->GetMaterial()->GetName()).Contains("DetectorPlanelvFiber")) volume->SetInvisible();
  }
  
  // Top volume is called World
  geom->GetTopVolume()->Draw("ogl");
}

void RecursiveInvisible(TGeoVolume *vol) {
  vol->InvisibleAll();
  Int_t nd = vol->GetNdaughters();
  for (Int_t i=0; i<nd; i++) {
    RecursiveInvisible(vol->GetNode(i)->GetVolume());
  }
}

void RecursiveVisible(TGeoVolume *vol) {
  vol->InvisibleAll(false);
  Int_t nd = vol->GetNdaughters();
  for (Int_t i=0; i<nd; i++) {
    RecursiveVisible(vol->GetNode(i)->GetVolume());
  }
}

void RecursiveTransparency(TGeoVolume *vol, Int_t transp) {
  vol->SetTransparency(transp);
  vol->SetVisibility(true);
  Int_t nd = vol->GetNdaughters();
  for (Int_t i=0; i<nd; i++) {
    RecursiveTransparency(vol->GetNode(i)->GetVolume(), transp);
  }
}

// compute the global y position of the damn argoncube
double FindTheOffset(std::vector<int> daughterIdxs, const char* expectedName)
{
  TGeoNode* node = gGeoManager->GetNode(0);
  double sums[3] = {0, 0, 0};
  double offset = node->GetMatrix()->GetTranslation()[1];

  for (auto i : daughterIdxs) {
    node = node->GetDaughter(i);
    // offset += node->GetMatrix()->GetTranslation()[1];
    auto trans = node->GetMatrix()->GetTranslation();
    std::cout << trans[0] << " " << trans[1] << " " << trans[2] << std::endl;
    sums[0] += trans[0]; sums[1] += trans[1]; sums[2] += trans[2];
  }

  std::cout << "Expected " << expectedName << "; found " << node->GetName() << std::endl;;
  std::cout << "sums: " << sums[0] << " " << sums[1] << " " << sums[2] << std::endl;
  return offset;
}

// load JustThe2x2.gdml first
double FindTheOffsetForJustThe2x2()
{
  return FindTheOffset({0, 0}, "volArgonCube_PV");
}

// load Merged2x2MINERvA_withRock_zincEdit_onlyActiveLArSens_v3.gdml
double FindTheOffsetForTheWholeThing()
{
  return FindTheOffset({0, 0, 0, 3, 0, 0, 0, 0}, "volArgonCube_PV");
}

// load JustThe2x2.gdml first
double FindTheOffsetForJustThe2x2Active()
{
  return FindTheOffset({0, 0, 1}, "volArgonCubeActive_PV");
}

// load Merged2x2MINERvA_withRock_zincEdit_onlyActiveLArSens_v3.gdml
double FindTheOffsetForTheWholeThingActive()
{
  return FindTheOffset({0, 0, 0, 3, 0, 0, 0, 0, 1}, "volArgonCubeActive_PV");
}

// load JustThe2x2.gdml first
double FindTheOffsetForJustThe2x2ActiveCathode()
{
  return FindTheOffset({0, 0, 1, 0, 0, 1, 0}, "volLArCathode_PV");
}
