import oscP5.*;
import netP5.*;

class SonicPiController {
  
  private NetAddress m_sonicPi;
  private OscP5 m_osc;
  
  SonicPiController() {
    this("127.0.0.1", 4559, 8000);
  }
  
  SonicPiController(String sonicIp, int sonicPort, int OSCPort) {
    m_osc = new OscP5(this, OSCPort);
    m_sonicPi = new NetAddress(sonicIp, sonicPort);
  }
  
  public void sendOsc(String root, Object[] params) {
    OscMessage message = new OscMessage(root, params);
    m_osc.send(message, m_sonicPi);
    if(DEBUG) { println("Sending `" + message + "` to SonicPi"); }
  }
  
  public void sendStop(String root) {
    sendOsc(root + "/stop", new Object[] {true});
  }
  
  public void sendBeat(int speed) {
    sendOsc("/beat01", new Object[] {speed}); 
  }
}
