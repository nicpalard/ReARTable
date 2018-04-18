public class ExtendedStickerCluster extends StickerCluster {
  // This is used to check if the cluster has already been detected has a premanent cluster
  private boolean isPermanent;
  
  private static final float MAX_DIST = 5;
  
  ExtendedStickerCluster() {
    super();
    this.isPermanent = false;
  }
  
  ExtendedStickerCluster(StickerCluster cluster) {
    this.isPermanent = false;
  }
  
  @Override
  public boolean equals(Object other) {
    if(other == null) return false;
    if(other == this) return true;
    if (!(other instanceof ExtendedStickerCluster) || !(other instanceof StickerCluster)) return false;
    ExtendedStickerCluster cluster = (ExtendedStickerCluster) other;
    
    if(this.size() != cluster.size()) return false;
    float dist = this.center.dist(cluster.center);
    if(dist > MAX_DIST) return false;
    
    // Does not contain the same things
    int[] candidateFoundIDs = new int[5];
    for (TrackedElement e : this) {
      candidateFoundIDs[e.attachedValue]++;
    }
    int[] foundIDs = new int[5];
    for (TrackedElement e : cluster) {
      foundIDs[e.attachedValue]++;
    }
    for(int i = 0 ; i < 5 ; i++) { 
      if (candidateFoundIDs[i] != foundIDs[i]) {
        return false;
      }
   }
   return true;
  }
}
