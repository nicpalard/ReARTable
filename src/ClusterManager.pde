import fr.inria.papart.multitouch.detection.*;
import fr.inria.papart.multitouch.tracking.*;
import tech.lity.rea.colorconverter.ColorConverter;

import java.util.Map;
import java.util.AbstractMap;



public class ClusterManager extends PaperScreen {
  
  private CalibratedStickerTracker m_stickerTracker;
  private final String m_format = "A4";
  private final float m_formatHeight = 297;
  private final float m_formatWidth = 210;
  private final int m_stickerSize = 15;
  private final int m_clusterSize = 55;
  
  private final int MINIMUM_FRAME_VALIDITY = 1;
  private final int FRAME_TEST_RANGE = 30;
  
  private ArrayList<Map.Entry<StickerCluster, Integer>> m_currentClusters;
  
   void setup() {
     m_stickerTracker = new CalibratedStickerTracker(this, m_stickerSize);
     m_currentClusters = new ArrayList<Map.Entry<StickerCluster, Integer>>();
     //soundComponents = new ArrayList<StickerCluster>();
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
     displayAllClusters(soundComponents, color(0, 255, 0));
     
   }
   
   void checkClusters(ArrayList<StickerCluster> currentClusters) {
     
     for (StickerCluster cluster : currentClusters) {
       int idx = findCluster(cluster, m_currentClusters);
         if (idx != -1) {
           m_currentClusters.get(idx).setValue(m_currentClusters.get(idx).getValue()+1);
           PVector averageCenter = new PVector((m_currentClusters.get(idx).getKey().center.x + cluster.center.x) / 2, 
                                             (m_currentClusters.get(idx).getKey().center.y + cluster.center.y) / 2);
           m_currentClusters.get(idx).getKey().center = averageCenter;
           // Now that we found it, we should check if this cluster appeared during the last X frames.
           if (m_currentClusters.get(idx).getValue() >= MINIMUM_FRAME_VALIDITY && (frameCount % FRAME_TEST_RANGE) == 0) {
             // If it was there for the last X frames, we promote it to a sound component
             // TODO: Checking this everytime is really greedy, do a new class ExtendedStickerCluster with a boolean to check wether or not it has already been added as a permanent component.
             createSoundComponent(m_currentClusters.get(idx).getKey());
           }
         }
         else {
           //println("Adding new cluster");
           // This is a new cluster.
           if(cluster.size() == 4) { // If its size is too small, we do not add it to the global array
             m_currentClusters.add(new AbstractMap.SimpleEntry<StickerCluster, Integer>(cluster, 1));
           }
         }
     }
     if(frameCount % FRAME_TEST_RANGE == 0) { 
       m_currentClusters.clear();
     }
   }
   
   int findCluster(StickerCluster cluster, ArrayList<Map.Entry<StickerCluster, Integer>> currentClusters) {
     int idx = -1;
     for(Map.Entry<StickerCluster, Integer> entry : currentClusters) {
       idx++;
       if (equalsClusters(entry.getKey(), cluster)) {
         return idx;
       }
     }
     return -1; 
   }
   
   int findCluster(ArrayList<StickerCluster> clusters, StickerCluster cluster) {
     int idx =-1;
     for(StickerCluster entry : clusters) {
       idx++;
       if (equalsClusters(entry, cluster)) {
         return idx;
       }
     }
     return -1;
   }
   
   boolean equalsClusters (StickerCluster cluster1, StickerCluster cluster2) {
     // Not the same size 
     if(cluster1.size() != cluster2.size()) {
       return false;
     }
    
     // Too far away
     float dist = cluster1.center.dist(cluster2.center);
     if( dist > 10) {
       return false;
     }
     
     // Does not contain the same things
     int[] candidateFoundIDs = new int[5];
     for (TrackedElement e : cluster1) {
        candidateFoundIDs[e.attachedValue]++;
     }
     int[] foundIDs = new int[5];
     for (TrackedElement e : cluster2) {
        foundIDs[e.attachedValue]++;
     }
     
     for(int i = 0 ; i < 5 ; i++) { 
       if (candidateFoundIDs[i] != foundIDs[i]) {
         return false;
       }
     }
     return true;
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
    
    void createSoundComponent(StickerCluster cluster) {
      if (findCluster(soundComponents, cluster) >= 0) { // If the cluster is already detected as a sound component
        return;
      }
      soundComponents.add(cluster);
    }
}
