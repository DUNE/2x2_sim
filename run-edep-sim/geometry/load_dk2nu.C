// Use cmake to build NuSoftHEP/dk2nu w/o GENIE or TBB
// Then symlink the .pcm to sit next to the .so
{
  gSystem->Load("dk2nu/lib/libdk2nuTree.so");
}
