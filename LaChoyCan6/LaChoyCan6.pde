// this sample uses a custom shader to mix two movies with time-varying transparency 
// displaying them in three different "windows" (actually just 3 textured objects imaged
// at diferent positions in one viewport). The 3 objects have different texture coordinates
// so they get their textures from different regions of the input texture movies.
// The transparency mixture varies differently for each "window".

import processing.video.*;

Movie mMovie1;
PImage mFrame1;
Movie mMovie2;
PImage mFrame2;
float mAlpha2;

PShape can, can1, can2, can3;
float angle;

PShader texShader;

int mTime;

void setup() {
  size(1280, 1000, P3D);

  // get the first of two texture movies
  mMovie1 = new Movie(this, "AfternoonSky-20fps-High.MOV");
  mMovie1.loop();

  // get the second of two texture movies
  mMovie2 = new Movie(this, "RiverCloseup.mp4");
  mMovie2.loop();

  // create the flat sheet geometries we'll texture
  can1 = createSheet(200, 900, 0, 0.33);
  can2 = createSheet(200, 900, 0.33, 0.67);
  can3 = createSheet(200, 900, 0.67, 1);

  // load the custom pixel shader that mixes two textures
  texShader = loadShader("texfrag.glsl"); 
  
  // initialize timer for frame time display
  mTime = millis();
}

void draw() {
  background(0);
  
  // update the texture image contribution from movie1
  if (mMovie1.available()) {
    mMovie1.read();
    mFrame1 = mMovie1.get();
  }
  texShader.set("texture1", mFrame1);
  
  // update the texture image contribution from movie2
  if (mMovie2.available()) {
    mMovie2.read();
    mFrame2 = mMovie2.get();
  }
  texShader.set("texture2", mFrame2);
  
  // update the transparency mixture variable for can1
  // in an interactive version this would come from the touch sensor --
  // here we just compute it from the can rotation angle, which changes over time 
  texShader.set("alpha2", abs(sin(angle)));
  
  // set the shader for this frame
  shader(texShader);
    
  // draw the frame, positioning the two objects appropriately
  translate(width/6, height/2);
  shape(can1);
  
  // update the transparency mixture variable for can2
  texShader.set("alpha2", abs(sin(2*angle)));
        
  translate(width/3, 0);
  shape(can2);
  
  // update the transparency mixture variable for can3
  texShader.set("alpha2", abs(sin(3*angle)));

  translate(width/3, 0);
  shape(can3);
  
  // update the can rotation angle for the next frame
  angle -= 0.01;    // radians
  
  // post frame time
  int t = millis();
  int dt = t - mTime;
  mTime = t;
  println("frame time: " + dt);
}

PShape createSheet(float r, float h, float s1, float s2) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  //sh.texture(tex);
  sh.normal(0, 0, 1);
  sh.vertex(-r, -h/2, 0, s1, 0);
  sh.vertex(-r, +h/2, 0, s1, 1);
  sh.vertex(r, -h/2, 0, s2, 0);
  sh.vertex(r, +h/2, 0, s2, 1);
  sh.endShape();
  return sh;
}