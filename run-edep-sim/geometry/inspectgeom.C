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
  geom->GetListOfVolumes()->Print();

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
