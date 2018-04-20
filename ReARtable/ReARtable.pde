import fr.inria.papart.procam.camera.*;
import fr.inria.papart.procam.display.*;
import fr.inria.papart.procam.*;
import tech.lity.rea.svgextended.*;
import org.bytedeco.javacpp.*;
import org.reflections.*;
import toxi.geom.*;
import org.openni.*;

import ddf.minim.analysis.FFT;
import ddf.minim.*;
import controlP5.*;

/* GLOBAL VARIABLES */
boolean DEBUG = false;
boolean PROJECTION = false;

Papart papart;
ARDisplay display;
Camera camera;
SonicPiController sonicPi;

ArrayList<SoundComponent> sounds;

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
  sounds = new ArrayList<SoundComponent>();
  sonicPi = new SonicPiController();
}

float amplitude = 0.1;
float speed = 1;

void draw() {
  manualCameraRendering();
  manualARRendering();
  for (SoundComponent sc : sounds) {
    if(sc instanceof Beat) {
      ((Beat) sc).updateAmplitude(amplitude);
      ((Beat) sc).updateSpeed(speed);
    }
  }
}

void mouseClicked() {
  for (SoundComponent sc : sounds) {
    sc.toggle();
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
  
  if (key == 'y') {
    speed += 0.1;
  }
  
  if (key == 't') {
    speed -= 0.1;
  }
  
  if (key == 'o') {
    amplitude += 0.05;
  }  
  
  if (key == 'l') {
    amplitude -= 0.05;
  }  
  
}
