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

// AUDIO VIZU VARIABLES
Minim minim;
AudioInput input;
FFT fftLog;

// Setup params
color bgColor = color(0,0,0);

// Modifiable parameters
float spectrumScale = 2;
float STROKE_MAX = 10;
float STROKE_MIN = 2;
float strokeMultiplier = 1;
float audioThresh = .9;
float[] circles = new float[29];
float DECAY_RATE = 2;

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
  
  // AUDIO VISU TEST
  minim = new Minim(this);
  input = minim.getLineIn(minim.MONO, 2048);
  
  fftLog = new FFT( input.bufferSize(), input.sampleRate());
  fftLog.logAverages( 22, 3);
  
  noFill();
  ellipseMode(RADIUS);
}

void draw() {
  manualCameraRendering();
  manualARRendering();
  for (SoundComponent sc : sounds) {
    sc.show();
  }
}

void mouseClicked() {
  for (SoundComponent sc : sounds) {
    if (sc instanceof DrumBeat) {
        sc.pause(); 
    }
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
