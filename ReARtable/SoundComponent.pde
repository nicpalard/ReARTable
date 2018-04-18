public abstract class SoundComponent {
  
  protected ExtendedStickerCluster m_exCluster;
  
  SoundComponent(ExtendedStickerCluster exCluster) {
     m_exCluster = exCluster; 
  }
  
  abstract void play();
  abstract void pause();
  abstract void show();
  
  ExtendedStickerCluster getCluster() {
    return m_exCluster;
  }
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
  void pause() {
    
  }
  
  void show() {
    fill(255, 255, 0);
    rect(m_exCluster.m_cluster.center.x, m_exCluster.m_cluster.center.y, 30, 30);
  }
}

public class DrumBeat extends SoundComponent {
  
  private int m_beatSpeed = 1;
  
  DrumBeat(ExtendedStickerCluster exCluster) {
    super(exCluster);
  }
  
  DrumBeat(ExtendedStickerCluster exCluster, int beatSpeed) {
   super(exCluster);
   m_beatSpeed = beatSpeed; 
  }
  
  void play() {
    sonicPi.sendOsc("/beat02/start", new Object[] {m_beatSpeed});
  }
  
  void pause() {
    sonicPi.sendOsc("/beat02/stop", new Object[] {m_beatSpeed});
  }
  
  void show() {
    fill(0, 255, 0);
    rect(m_exCluster.m_cluster.center.x, m_exCluster.m_cluster.center.y, 30, 30);
  }
}
