// this sample uses a custom shader to mix two movies with time-varying transparency 

import processing.video.*;

Movie mMovie1;
PImage mFrame1;
Movie mMovie2;
PImage mFrame2;
float mAlpha2;

PShape can;
float angle;

PShader texShader;

int mTime;

void setup() {
  size(640, 900, P3D);

  // get the first of two texture movies
  mMovie1 = new Movie(this, "AfternoonSky-20fps-High.MOV");
  mMovie1.loop();

  // get the second of two texture movies
  mMovie2 = new Movie(this, "RiverCloseup.mp4");
  mMovie2.loop();

  // create the can or flat sheet geometry we'll texture
  can = createCan(200, 600, 64);
  //can = createSheet(200, 600);
  
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
  
  // update the transparency mixture variable
  // in an interactive version this would come from the touch sensor --
  // here we just compute it from the can rotation angle, which changes over time 
  texShader.set("alpha2", abs(sin(angle)));
  
  // set the shader for this frame
  shader(texShader);
    
  // draw the frame
  translate(width/2, height/2);
  rotateY(angle);
  shape(can);
  
  // update the can rotation angle for the next frame
  angle -= 0.01;    // radians
  
  // post frame time
  int t = millis();
  int dt = t - mTime;
  mTime = t;
  println("frame time: " + dt);
}

PShape createCan(float r, float h, int detail) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  //sh.texture(tex);
  for (int i = 0; i <= detail; i++) {
    float angle = TWO_PI / detail;
    float x = sin(i * angle);
    float z = cos(i * angle);
    float u = float(i) / detail;
    sh.normal(x, 0, z);
    sh.vertex(x * r, -h/2, z * r, u, 0);
    sh.vertex(x * r, +h/2, z * r, u, 1);
  }
  sh.endShape();
  return sh;
}

PShape createSheet(float r, float h) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  //sh.texture(tex);
  sh.normal(0, 0, 1);
  sh.vertex(-2*r, -h/2, 0, 0, 0);
  sh.vertex(-2*r, +h/2, 0, 0, 1);
  sh.vertex(+2*r, -h/2, 0, 1, 0);
  sh.vertex(+2*r, +h/2, 0, 1, 1);
  sh.endShape();
  return sh;
}