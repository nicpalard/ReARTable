public abstract class SoundComponent {
  
  protected ExtendedStickerCluster m_exCluster;
  protected boolean m_isPlaying = false;
  
  SoundComponent(ExtendedStickerCluster exCluster) {
    m_exCluster = exCluster; 
  }
  
  abstract void play();
  abstract void pause();
  abstract void update();
  
  void toggle() {
    if (m_isPlaying) {
      pause();
    } 
    else {
      play();
    }   
  }
  
  ExtendedStickerCluster getCluster() {
    return m_exCluster;
  }

  @Override
  public boolean equals(Object other) {
    if (!(other instanceof SoundComponent)) return false;
    SoundComponent otherSc = (SoundComponent) other;
    return this.m_exCluster.equals(otherSc.m_exCluster);
  }
}


public class Beat extends SoundComponent {
  
  private float m_beatSpeed = 1;
  private float m_amplitude = 0.1;
  
  Beat(ExtendedStickerCluster exCluster) {
    super(exCluster);
  }
  
  Beat(ExtendedStickerCluster exCluster, int beatSpeed) {
   super(exCluster);
   m_beatSpeed = beatSpeed; 
  }
  
  void play() {
    m_isPlaying = true;
    sonicPi.sendOsc("/beat01/start", new Object[] {m_beatSpeed, m_amplitude});
  }
  void pause() {
    m_isPlaying = false;
    sonicPi.sendOsc("/beat01/stop");
  }
  
  void update() {
    sonicPi.sendOsc("beat01/update", new Object[] {m_beatSpeed, m_amplitude});
  }
  
  void updateAmplitude(float amplitude) {
    this.m_amplitude = amplitude;
    update();
  }
  
  void updateSpeed(float speed) {
    this.m_beatSpeed = speed;
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
    sonicPi.sendOsc("/beat02/stop");
  }
  
  void update() {
    sonicPi.sendOsc("beat01/update", new Object[] {m_beatSpeed});
  }
}
