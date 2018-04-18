public abstract class SoundComponent {
  
  public ExtendedStickerCluster m_exCluster;
  
  SoundComponent(ExtendedStickerCluster exCluster) {
     m_exCluster = exCluster; 
  }
  
  abstract void play();
  abstract void show();
}


public class Beat extends SoundComponent {
  
  private int m_beatSpeed = 1;
  
  Beat(ExtendedStickerCluster exCluster) {
    super(exCluster);
  }
  
  Beat(ExtendedStickerCluster exCluster, int beatSpeed) {
   super(exCluster);
   m_beatSpeed = beatSpeed; 
  }
  
  void play() {
    sonicPi.sendOsc("/beat01", new Object[] {m_beatSpeed});
  }
  
  void show() {
    fill(255, 255, 0);
    rect(m_exCluster.m_cluster.center.x, m_exCluster.m_cluster.center.y, 30, 30);
  }
}
