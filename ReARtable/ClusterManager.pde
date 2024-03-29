import fr.inria.papart.multitouch.detection.*;
import fr.inria.papart.multitouch.tracking.*;
import tech.lity.rea.colorconverter.ColorConverter;

public class ClusterManager extends PaperScreen {
  
  private CalibratedStickerTracker m_stickerTracker;
  private final String m_format = "A4";
  private final float m_formatHeight = 297;
  private final float m_formatWidth = 210;
  private final int m_stickerSize = 15;
  private final float m_clusterSize = 27.5;
  
  private final int MINIMUM_FRAME_VALIDITY = 15;
  private final int FRAME_CHECK_INTERVAL = 5;
  private final float MAX_MODIFIER_RANGE = m_clusterSize + 30;
  
  private ArrayList<ExtendedStickerCluster> m_trackedClusters;
  
   void setup() {
     m_stickerTracker = new CalibratedStickerTracker(this, m_stickerSize);
     m_trackedClusters = new ArrayList<ExtendedStickerCluster>();
   }
   
   void settings() {
    setDrawingSize(m_formatHeight, m_formatWidth);
    loadMarkerBoard(Papart.markerFolder + m_format + "-default.svg", m_formatHeight, m_formatWidth);
    setDrawOnPaper();     
    setQuality(2.0f);
   }
   
   void drawOnPaper() {
     clear();
     ArrayList<TrackedElement> trackedElements = m_stickerTracker.findColor(millis());
     if(DEBUG) { displayStickers(trackedElements); }
     
     ArrayList<StickerCluster> clusters = StickerCluster.createZoneCluster(trackedElements, m_clusterSize);
     if(DEBUG) { displayAllClusters(clusters, color(0, 0, 0)); }
     
     if (frameCount % FRAME_CHECK_INTERVAL == 0) {
       lightCheckClusters(clusters);
       checkModifiers(clusters);
     }
     
     for (SoundComponent s : sounds) {
       displaySoundComponent(s);
       //displayCluster(s.getCluster().getCluster(), color(0, 255, 0)); 
     }
     
   }
   
   void checkModifiers(ArrayList<StickerCluster> clusters) {
     for (SoundComponent sc : sounds) {
       boolean sameModifier = false;
       TrackedElement modifier = null;
       TrackedElement currentModifier = sc.getModifier();
       for (StickerCluster cluster : clusters) {
         if (cluster.size() == 1) {
           if (currentModifier != null && cluster.center.dist(currentModifier.getPosition()) < 5) {
             println("Old modifier updated.");
             sameModifier = true;
             modifier = cluster.get(0);
           }
           else if(!sameModifier && modifier == null && cluster.center.dist(sc.getCluster().getCluster().center) < MAX_MODIFIER_RANGE) {
             println("Old modifier deleted, new modifier detected.");
             modifier = cluster.get(0);
           }
         }
       }
       sc.setModifier(modifier);
     }
   }
   
   // Every X frames do a lightCheck
   void lightCheckClusters(ArrayList<StickerCluster> clusters) {
     ArrayList<ExtendedStickerCluster> exClusterToRemove = new ArrayList<ExtendedStickerCluster>();
     // If there are trackedClusters
     if (!m_trackedClusters.isEmpty()) {
       // For each trackedCluster :
       //  1. Check if it is still tracked this frame
       //  2. If true, keep tracking it, if false remove it
       //  3. For all the other clusters (not tracked), create a trackedCluster that will be processed during the next check
       for(ExtendedStickerCluster exCluster : m_trackedClusters ) {
         int idx = -1;
         boolean isStillDetected = false;
         for (StickerCluster cluster : clusters) {
           idx++;
           if (exCluster.equals(cluster)) {
             clusters.remove(idx);
             if (!exCluster.isPermanent()) {
               if (exCluster.getFrameCount() < MINIMUM_FRAME_VALIDITY) {
                 println("frameCount up: " + exCluster.getFrameCount());
                 exCluster.frameCountUp();
               }
               else {
                 createSoundComponent(exCluster);
               }
             }
             isStillDetected = true;
             break;
           }
         }
         if (!isStillDetected) {
           if (exCluster.isPermanent()) {
             if (exCluster.getFrameCount() > 0) {
               exCluster.frameCountDown();
             }
             else {
               exClusterToRemove.add(exCluster);
               deleteSoundComponent(exCluster.getSound());
             }
           }
         }
       }
       for (ExtendedStickerCluster exCluster : exClusterToRemove) {
         m_trackedClusters.remove(exCluster);
       }
     }
     
     // After removing all the already tracked clusters, add the untracked one to the tracklist
     for (StickerCluster cluster : clusters) {
       if (cluster.size() >= 4) {
         m_trackedClusters.add(new ExtendedStickerCluster(cluster));
       }
     }
   }
   
   int findCluster(Object cluster, ArrayList<ExtendedStickerCluster> trackedClusters) {
     int idx = -1;
     for (ExtendedStickerCluster exCluster : trackedClusters) { 
       idx++;
       if (exCluster.equals(cluster)) {
         return idx;
       }
     }
     return -1;
   }
   
   void displaySticker(TrackedElement sticker) {
     if (sticker.attachedValue == 1) { // red
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
   
   void displayStickers(ArrayList<TrackedElement> stickers) {
     noStroke();
     for (TrackedElement sticker : stickers) {
       displaySticker(sticker);
     }
   }
   
   void displayCluster(StickerCluster cluster, color c) {
     stroke(c);
     strokeWeight(1.3);
     fill(255);
     ellipse(cluster.center.x, cluster.center.y, 5, 5);
     noFill();
     ellipse(cluster.center.x, cluster.center.y, m_clusterSize * 2, m_clusterSize * 2);
   }
   
  void displayAllClusters(ArrayList<StickerCluster> clusters, color c) {
    for (StickerCluster cluster : clusters) {
      displayCluster(cluster, c);
    }
  }

  void createSoundComponent(ExtendedStickerCluster cluster) {
    // TODO : Create different sounds depending on the composition of the cluster (accessible via cluster.getObjects())
    SoundComponent s = new Beat(cluster, 1);
    s.play();
    sounds.add(s);
    cluster.setSound(s);    
    /*
    SoundComponent b = new DrumBeat(cluster, 1);
    b.play();
    sounds.add(b);*/
  }
  
  void deleteSoundComponent(SoundComponent s) {
    s.pause();
    sounds.remove(s);
    s.getCluster().setSound(null);
  }
  
  void displaySoundComponent(SoundComponent s) {
    if (s.getModifier() != null) {
      displaySticker(s.getModifier());
    }
    displayCluster(s.getCluster().getCluster(), color(0, 255, 0));
  }
}
