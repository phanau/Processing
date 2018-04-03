// this sample uses a custom shader to mix two movies with time-varying transparency 
// displaying them in three different "windows" (actually just 3 textured objects imaged
// at diferent positions in one viewport). The 3 objects have different texture coordinates
// so they get their textures from different regions of the input texture movies.
// The transparency mixture varies differently for each "window".
// For speed, the entire movies are cached in memory.
// Processing seems to have problems reliably reporting "available" on movie frames
// in the setup() function, so we compare consecutive frames to avoid caching a frame > once.

import processing.video.*;

ArrayList<PImage> mFrames1;
int mFrameCounter1 = 0;

ArrayList<PImage> mFrames2;
int mFrameCounter2 = 0;

PShape can, can1, can2, can3;
float angle;

PShader texShader;

int mTime;

boolean sameFrame(PImage f1, PImage f2) {
  for (int x=0; x<f1.width; x++)
    for (int y=0; y<f1.height; y++)
      if (f1.get(x,y) != f2.get(x,y)) {
        println("difference at: " + x + "," + y);
        return false;
      }
  return true;
}

ArrayList<PImage> cacheMovie(Movie m) {
  ArrayList<PImage> frames = new ArrayList<PImage>(10);
  m.play();
  int dupFrames = 0;
  while (dupFrames < 20) {
    if (m.available()) {
      m.read();
      PImage frame = m.get();
      PImage prevFrame = frames.size()>0 ? frames.get(frames.size()-1) : null;
      if (prevFrame == null || !sameFrame(frame, prevFrame)) {
        frames.add(frame);
        dupFrames = 0;
        println("new frame1: " + frames.size());
      }
      else {
        dupFrames++;
        println("duplicate frame!");
      }
    }
  }
  return frames;
}

void setup() {
  size(1280, 1000, P3D);

  // get the first of two texture movies
  mFrames1 = cacheMovie(new Movie(this, "AfternoonSky-20fps-High.MOV"));
  println("Movie1: " + mFrames1.size());
  
  // get the second of two texture movies
  mFrames2 = cacheMovie(new Movie(this, "IMG_8030.m4v"));
  println("Movie2: " + mFrames2.size());

  // create the flat sheet geometries we'll texture
  can1 = createSheet(200, 900, 0, 0.33);
  can2 = createSheet(200, 900, 0.33, 0.67);
  can3 = createSheet(200, 900, 0.67, 1);

  // load the custom pixel shader that mixes two textures
  texShader = loadShader("texfrag.glsl"); 
  
  // initialize timer for frame time display
  mTime = millis();
  
  // set (approximate) frame rate
  frameRate(20);
}

void draw() {
  
  // compute time since last start of frame (mTime)
  int t = millis();
  int dt = t - mTime;
  mTime = t;      // remember new last start of frame
  println("frame time: " + dt);
    
  // clear the frame
  background(0);
  
  // update the texture image contribution from movie1
  texShader.set("texture1", mFrames1.get(mFrameCounter1++));
  if (mFrameCounter1 >= mFrames1.size())
    mFrameCounter1 = 0;
    
  // update the texture image contribution from movie2
  texShader.set("texture2", mFrames2.get(mFrameCounter2++));
  if (mFrameCounter2 >= mFrames2.size())
    mFrameCounter2 = 0;
    
  // update the transparency mixture variable for can1
  // in an interactive version this would come from the touch sensor --
  // here we just compute it from the can rotation angle, which changes over time 
  texShader.set("alpha2", 0.5*(1.0+sin(angle)));
  
  // set the shader for this frame
  shader(texShader);
    
  // draw the frame, positioning the two objects appropriately
  translate(width/6, height/2);
  shape(can1);
  
  // update the transparency mixture variable for can2
  texShader.set("alpha2", 0.5*(1.0+sin(2*angle)));
        
  translate(width/3, 0);
  shape(can2);
  
  // update the transparency mixture variable for can3
  texShader.set("alpha2", 0.5*(1.0+sin(3*angle)));

  translate(width/3, 0);
  shape(can3);
  
  // update the can rotation angle for the next frame
  angle -= 0.01;    // radians
  
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
