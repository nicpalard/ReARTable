public class ExtendedStickerCluster {
  
  public boolean isPermanent;
  
  // This is used to check if the cluster has already been detected has a premanent cluster
  private StickerCluster m_cluster;
  private int[] m_objects;
  
  private int m_frameCount;
  private static final float MAX_DIST = 5;
  
  ExtendedStickerCluster(StickerCluster cluster) {
    isPermanent = false;
    m_frameCount = 1;
    m_cluster = cluster;
    
    m_objects = new int[5];
    for (TrackedElement e : m_cluster) {
      m_objects[e.attachedValue]++;
    }
  }
  
  public int frameCountUp() {
    return m_frameCount++;
  }
  
  public int frameCountDown() {
    return m_frameCount--;
  }
  
  public void setFrameCount(int newFrameCount) {
    m_frameCount = newFrameCount;
  }
  
  public int getFrameCount() {
    return m_frameCount;
  }
  
  public int[] getObjects() {
    return this.m_objects;
  }
  
  public StickerCluster getCluster() {
    return this.m_cluster;
  }
  
  @Override
  public boolean equals(Object other) {
    if(other == null) return false;
    if(other == this) return true;
    if (!(other instanceof ExtendedStickerCluster || other instanceof StickerCluster)) return false;
    
    StickerCluster cluster;
    ExtendedStickerCluster extendedStickerCluster;
    int[] objects;
    
    if (other instanceof ExtendedStickerCluster) {
      extendedStickerCluster = (ExtendedStickerCluster) other;
      cluster = extendedStickerCluster.getCluster();
      objects = extendedStickerCluster.getObjects();
    } 
    else {
      cluster = (StickerCluster) other;
      objects = new int[5];
      for (TrackedElement e : cluster) {
        objects[e.attachedValue]++;
      }
    }
    
    if(m_cluster.size() != cluster.size()) return false;
    float dist = m_cluster.center.dist(cluster.center);
    if(dist > MAX_DIST) return false;
    
    for(int i = 0 ; i < 5 ; i++) { 
      if (this.m_objects[i] != objects[i]) {
        return false;
      }
   }
   return true;
  }
}
