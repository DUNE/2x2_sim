// NOTE: .L inspectgeom.C first!

// void RecursiveInvisible(TGeoVolume *vol, Int_t transp);
// void RecursiveVisible(TGeoVolume *vol);
// void RecursiveTransparency(TGeoVolume *vol, Int_t transp);

void eve_display(const char* geomfile)
{
  // gROOT->ProcessLine(".L inspectgeom.C");

  TEveManager::Create();

  // gGeoManager = gEve->GetGeometry(geomfile);
  TGeoManager::Import(geomfile);
  gGeoManager->SetTopVisible(true);
  gGeoManager->DefaultColors();
  // gGeoManager->SetVisLevel(30);
  RecursiveTransparency(gGeoManager->GetTopVolume(), 10);

  // Print the list of volumes in the geometry
  // geom->GetListOfVolumes()->Print();

  TGeoVolume *volume = NULL;
  TObjArray *volumes = gGeoManager->GetListOfVolumes();
  Int_t nvolumes = volumes->GetEntries();
  for ( int i = 0; i < nvolumes; i++ ) {
    volume = (TGeoVolume*)volumes->At(i);
    volume->SetVisContainers(kTRUE);

    // Remove MINERvA fibers...
    if (TString(volume->GetMaterial()->GetName()).Contains("DetectorPlanelvFiber")) volume->SetInvisible();
  }

  auto* node = new TEveGeoTopNode(gGeoManager, gGeoManager->GetTopVolume()->GetNode(0));
  node->SetVisLevel(30);
  gEve->AddGlobalElement(node);

  auto l = new TEveLine(2);
  l->SetPoint(0, 0, 0, 20);
  l->SetPoint(1, 100, 200, 200);
  l->SetLineWidth(2);
  l->SetLineColor(kRed);
  gEve->AddElement(l);

  auto* cathode = gGeoManager->FindVolumeFast("volLArCathode");
  if (cathode) {
    cathode->SetTransparency(0);
  }

  gEve->FullRedraw3D(true);

  TGLViewer* v = gEve->GetDefaultGLViewer();
  // 0 - no clip, 1 - clip plane, 2 - clip box
  // v->GetClipSet()->SetClipType(TGLClip::EType(0));
  v->GetClipSet()->SetClipType(TGLClip::kClipNone);
  v->RefreshPadEditor(v);
  // v->CurrentCamera().RotateRad(-.7, 0.5);

  v->DoDraw();
}

// void RecursiveInvisible(TGeoVolume *vol) {
//   vol->InvisibleAll();
//   Int_t nd = vol->GetNdaughters();
//   for (Int_t i=0; i<nd; i++) {
//     RecursiveInvisible(vol->GetNode(i)->GetVolume());
//   }
// }

// void RecursiveVisible(TGeoVolume *vol) {
//   vol->InvisibleAll(false);
//   Int_t nd = vol->GetNdaughters();
//   for (Int_t i=0; i<nd; i++) {
//     RecursiveVisible(vol->GetNode(i)->GetVolume());
//   }
// }

// void RecursiveTransparency(TGeoVolume *vol, Int_t transp) {
//   vol->SetTransparency(transp);
//   vol->SetVisibility(true);
//   Int_t nd = vol->GetNdaughters();
//   for (Int_t i=0; i<nd; i++) {
//     RecursiveTransparency(vol->GetNode(i)->GetVolume(), transp);
//   }
// }
