import fr.inria.papart.procam.camera.*;
import fr.inria.papart.procam.display.*;
import fr.inria.papart.procam.*;
import tech.lity.rea.svgextended.*;
import org.bytedeco.javacpp.*;
import org.reflections.*;
import toxi.geom.*;
import org.openni.*;

/* GLOBAL VARIABLES */
boolean DEBUG = false;
boolean PROJECTION = false;

Papart papart;
ARDisplay display;
Camera camera;
SonicPiController sonicPi;

ArrayList<StickerCluster> soundComponents;

PFont fpsFont;

void settings() {
  if (PROJECTION) {
    fullScreen(P3D);
  } else {
    size(640, 480, P3D);
  }
}

void setup() {
  // Set PapARt mode
  papart = PROJECTION ? Papart.projection(this) : Papart.seeThrough(this);
  papart.startTracking();
  
  // Get display & camera to render AR & camera images
  display = papart.getARDisplay();
  camera = display.getCamera();
  display.manualMode();

  // Load every PaperScreen & TableScreen subclasses.
  papart.loadSketches();
  
  fpsFont = createFont("Verdana", 50);
  soundComponents = new ArrayList<StickerCluster>();
  sonicPi = new SonicPiController();
}

void draw() {
  manualCameraRendering();
  manualARRendering();
  if(soundComponents.size() > 0) {
    sonicPi.sendBeat(1);
  }
}

void manualCameraRendering() {
  display.drawScreens();
  
  if(camera != null) {
    PImage frame = camera.getPImage();
    if(frame != null) {
      image(camera.getPImage(), 0, 0);
    }
  }
}

/*
  Render AR elements on top of already rendered elements
*/
void manualARRendering() {
  // This line is needed to get what has already been rendered and not erase everything
  display.drawImage((PGraphicsOpenGL) g, display.render(), 0, 0, width, height);
  fill(255, 255, 0);
  if(DEBUG) {
    text(frameRate, 40, 40);
  }
}

void keyPressed() {
  if (key == 'd') {
    DEBUG = !DEBUG;
  }
}
