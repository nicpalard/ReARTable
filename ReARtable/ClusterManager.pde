import fr.inria.papart.multitouch.detection.*;
import fr.inria.papart.multitouch.tracking.*;
import tech.lity.rea.colorconverter.ColorConverter;

public class ClusterManager extends PaperScreen {
  
  private CalibratedStickerTracker m_stickerTracker;
  private final String m_format = "A4";
  private final float m_formatHeight = 297;
  private final float m_formatWidth = 210;
  private final int m_stickerSize = 15;
  private final int m_clusterSize = 55;
  
  private final int MINIMUM_FRAME_VALIDITY = 15;
  private final int FRAME_TEST_RANGE = 30;
  
  private ArrayList<ExtendedStickerCluster> m_trackedClusters;
  
   void setup() {
     m_stickerTracker = new CalibratedStickerTracker(this, m_stickerSize);
     m_trackedClusters = new ArrayList<ExtendedStickerCluster>();
   }
   
   void settings() {
    setDrawingSize(m_formatHeight, m_formatWidth);
    loadMarkerBoard(Papart.markerFolder + m_format + "-default.svg", m_formatHeight, m_formatWidth);
    setDrawOnPaper();     
    setQuality(4.0f);
   }
   
   void drawOnPaper() {
     clear();
     ArrayList<TrackedElement> trackedElements = m_stickerTracker.findColor(millis());
     if(DEBUG) { displayStickers(trackedElements); }
     
     ArrayList<StickerCluster> clusters = StickerCluster.createZoneCluster(trackedElements, m_clusterSize);
     if(DEBUG) { displayAllClusters(clusters, color(0, 0, 0)); }
     
     checkClusters(clusters);
     for (SoundComponent s : sounds) {
        displayCluster(s.getCluster().getCluster(), color(0, 255, 0)); 
     }
     
   }
   
   void checkClusters(ArrayList<StickerCluster> currentClusters) {
     for (StickerCluster cluster : currentClusters) {
       // Search if the found cluster is currently tracked i.e there are informations on it.
       int idx = findCluster(cluster, m_trackedClusters);
       if (idx != -1) { // Found it
         // Update the frame count (used to check if it is here for enough time to be a sound component)
         ExtendedStickerCluster exCluster = m_trackedClusters.get(idx);
         exCluster.frameCountUp();
         // Check if it is enough to be a sound component
         if (exCluster.getFrameCount() >= MINIMUM_FRAME_VALIDITY && (frameCount % FRAME_TEST_RANGE) == 0) {
           // If it is enough, create the associated sound component
           if (!exCluster.isPermanent) {
             createSoundComponent(exCluster);
             exCluster.isPermanent = true;
           }
         }
       }
       else {
         if (cluster.size() >= 4) {
           m_trackedClusters.add(new ExtendedStickerCluster(cluster));
         }
       }
     }
     if (frameCount % FRAME_TEST_RANGE == 0) {
       // Every X frames, reset the tracked cluster array to avoid bad detection due to stacking
       // We keep permanent cluster because it means that it is associated to a sound
       for (int i = 0 ; i < m_trackedClusters.size() ; i++) {
         if (!m_trackedClusters.get(i).isPermanent) {
           m_trackedClusters.remove(i);
         }
       }
     }
   }
   
   int findCluster(Object cluster, ArrayList<ExtendedStickerCluster> trackedClusters) {
     int idx = -1;
     for (ExtendedStickerCluster tCluster : trackedClusters) { 
       idx++;
       if (tCluster.equals(cluster)) {
         return idx;
       }
     }
     return -1;
   }
   
   void displayStickers(ArrayList<TrackedElement> stickers) {
     noStroke();
     for (TrackedElement sticker : stickers) {
       if (sticker.attachedValue == 1) { //red
         fill(255, 0, 0);
         } 
       else if (sticker.attachedValue == 2) { //blue
         fill(0, 0, 255);
       } 
       else {
         fill(255, 255, 0);
       }
       PVector pos = sticker.getPosition();
       ellipse(pos.x, pos.y, m_stickerSize, m_stickerSize);
       
       if(DEBUG) {
         fill(255);
         stroke(0);
         text(Integer.toString(sticker.attachedValue), pos.x, pos.y, 10);
       }
     }
   }
   
   void displayCluster(StickerCluster cluster, color c) {
     stroke(c);
     strokeWeight(1.3);
     fill(255);
     ellipse(cluster.center.x, cluster.center.y, 5, 5);
     noFill();
     ellipse(cluster.center.x, cluster.center.y, 55, 55);
   }
   
  void displayAllClusters(ArrayList<StickerCluster> clusters, color c) {
    for (StickerCluster cluster : clusters) {
      displayCluster(cluster, c);
    }
  }

  void createSoundComponent(ExtendedStickerCluster cluster) {
    // TODO : Create different sounds depending on the composition of the cluster (accessible via cluster.m_objects)
    SoundComponent s = new Beat(cluster, 1);
    SoundComponent b = new DrumBeat(cluster, 1);
    s.play();
    b.play();
    sounds.add(s);
    sounds.add(b);
  }
  
  void deleteSoundComponent() {
    
  }
}
