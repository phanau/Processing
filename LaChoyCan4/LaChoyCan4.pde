// play a movie wrapped as a texture around a can.
// check for duplicate frames on successive draw() calls.

import processing.video.*;

Movie mMovie;
PShape can;
float angle;

PShader texShader;

PImage mPrevFrame = null;

int mDupCount = 0;

void setup() {
  size(640, 900, P3D);
  mMovie = new Movie(this, "AfternoonSky-20fps-High.MOV");
  mMovie.loop();
  can = createCan(200, 600, 64, null);
  texShader = loadShader("texfrag.glsl"); //, "texvert.glsl");
}

boolean sameFrame(PImage f1, PImage f2) {
  if (f1 == null || f2 == null)
    return false;
  for (int x=0; x<f1.width; x++)
    for (int y=0; y<f1.height; y++)
      if (f1.get(x,y) != f2.get(x,y))
        return false;
  return true;
}

void draw() {
  background(0);
    
  PImage mFrame = null;
  if (mMovie.available()) {
    mMovie.read();
    mFrame = mMovie.get();
  }
  
  // check for duplicate frames
  if (sameFrame(mFrame, mPrevFrame))
    println("duplicate frame!" + mDupCount++);
  else  
    mPrevFrame = mFrame;
  
  texShader.set("texture2", mFrame);
  shader(texShader);
    
  translate(width/2, height/2);
  rotateY(angle);
  shape(can);
  angle -= 0.01;
}

PShape createCan(float r, float h, int detail, PImage tex) {
  textureMode(NORMAL);
  PShape sh = createShape();
  sh.beginShape(QUAD_STRIP);
  sh.noStroke();
  sh.texture(tex);
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
