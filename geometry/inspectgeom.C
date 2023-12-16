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

typedef std::vector<TGeoNode*> GeoPath;

std::vector<GeoPath> FindNodes(TGeoNode* base_node, const char* regexp)
{
  TPRegexp pregexp(regexp);

  const auto inner = [&](const auto& self,
                         TGeoNode* node,
                         const GeoPath& path2parent)
    -> std::vector<GeoPath> {
    std::vector<GeoPath> result;
    GeoPath path2me = path2parent;
    path2me.push_back(node);
    // check this node
    if (pregexp.MatchB(node->GetName()))
      result.push_back(path2me);
    // check its daughters
    for (size_t i = 0; i < node->GetNdaughters(); ++i) {
      TGeoNode* daughter = node->GetDaughter(i);
      std::vector<GeoPath> paths = self(self, daughter, path2me);
      for (const GeoPath& p : paths)
        result.push_back(p);
    }
    return result;
  };

  return inner(inner, base_node, {});
}

std::array<double, 3> GetGlobalPos(const char* regexp)
{
  TGeoNode* root_node = gGeoManager->GetNode(0);
  std::vector<GeoPath> paths = FindNodes(root_node, regexp);
  assert(paths.size() == 1);
  const GeoPath& path = paths[0];

  double local[3] = {0., 0., 0.};
  double master[3];
  for (int i = path.size()-1; i >= 0; --i) {
    TGeoNode* node = path[i];
    TGeoMatrix* mat = node->GetMatrix();
    mat->LocalToMaster(local, master);
    std::copy(master, master+3, local);
  }

  std::array<double, 3> result = {master[0], master[1], master[2]};
  return result;
}
