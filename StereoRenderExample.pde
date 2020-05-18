// Stereo 3D Render Demonstration Example
// Written by Andy Modla in the Processing language (Java based)
// Example 3D photo of Yellow Daylily by Andy Modla
// Photo Copyright 2020 Andy Modla All rights reserved
// Photo for private use only, no commercial use
// Processing Foundation https://www.processing.org
//
// Anaglyph conversion algorithms derived from Stereo Photo Maker HTML5 
// stereo5.js (version 0.5) presentation script.
// http://stereo.jpn.org/eng/stphmkr/
//
// This code is an example of P3D buffer code using
// createGraphics() and createShape()
//
// This code should work in both Java and Android modes without any changes.
// Runs on ROKiT 3D Pro (Android) phone with glasses free display screen
// With Android app I use a Bluetooth keyboard for key control of the demo.
//

boolean ANDROID = false;
boolean ROKIT3D = false;

int H = 1080;
int W = 2160;
StereoRender render;

// index for left and right image arrays
public static final int L = 0;
public static final int R = 1;

PImage[] photo = new PImage[2];
float SCALE = 342;  // at 1080
float MIN_SCALE = 174;
float MAX_SCALE = 806;
float HHAB_SCALE = 254;
float AB_SCALE = 174;
float scale;

boolean initial = true;
volatile int lastKey = 0;
volatile int lastKeyCode;
public static final boolean DEBUG = false;
public static final int SHIFT = 4;  // pixel increment for movement

// screen boundaries for click zone use
int iX;
int iY;

volatile float xdelta = 0; 
volatile float ydelta = 0;

int FCOUNTER = 90; // frame counter
int fCounter = FCOUNTER;
int parallax = 0;

///////////////////////////////////////////////////////////

void settings() {
  if (ANDROID) {
    size(displayWidth, displayHeight, P3D);
    fullScreen();
  } else {
    size(W, H, P3D);
  }
  smooth();

  // set information click zone boundaries
  iX = displayWidth/8;
  iY = displayHeight/8;

  // set scale factor based on calibration at 1080 screen height
  float mag = height/1080;
  SCALE = mag*SCALE;
  MIN_SCALE = mag* MIN_SCALE;
  MAX_SCALE = mag * MAX_SCALE;
  scale = SCALE;
}

void setup() {
  background(128);
  orientation(LANDSCAPE); 

  fill(0);
  textSize(96);
  textAlign(CENTER);
  text("3D Stereo Render Demo", width/2, height/2);
  text("Written by Andy Modla", width/2, height/2+ iY);
  if (DEBUG) println("screen width="+ width + " height="+height);
}

void draw() {
  if (initial) {
    initial = false;
    photo[L] = loadImage("DSC_8162-8164-2editlogo_l.JPG");
    photo[R] = loadImage("DSC_8162-8164-2editlogo_r.JPG");
    if (DEBUG) println("photo "+photo[L].width+ "x"+photo[L].height);
    render = new StereoRender();
    if (ROKIT3D) {
      render.setMode(StereoRender.COLINTERLACE);
    }
    render.setPhoto(photo); // set L/R photo pair to display
    return;
  }
  keyUpdate();

  background(128);

  render.draw(scale, xdelta, ydelta, parallax);
}

////////////////////////////////////////////////////////////////////
