void eve_display(const char* geomfile)
{
  TEveManager::Create();

  // gGeoManager = gEve->GetGeometry(geomfile);
  TGeoManager::Import(geomfile);
  gGeoManager->DefaultColors();

  auto* node = new TEveGeoTopNode(gGeoManager, gGeoManager->GetTopVolume()->GetNode(0));
  gEve->AddGlobalElement(node);

  gEve->FullRedraw3D(true);

  TGLViewer* v = gEve->GetDefaultGLViewer();
  // 0 - no clip, 1 - clip plane, 2 - clip box
  // v->GetClipSet()->SetClipType(TGLClip::EType(0));
  v->GetClipSet()->SetClipType(TGLClip::kClipNone);
  v->RefreshPadEditor(v);
  // v->CurrentCamera().RotateRad(-.7, 0.5);
  v->DoDraw();
}
