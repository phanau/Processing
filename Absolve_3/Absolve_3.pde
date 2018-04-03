// Show layered videos inside masks
  
import processing.video.*;

class Layer {
  Movie mMovie;
  float mRotation;    // radians
  PImage mMask;
  PImage mFrame;      // current frame of mMovie
  
  public Layer(Movie movie, float rotationDegrees, PImage mask) {
    mMovie = movie;
    mRotation = radians(rotationDegrees);
    mMask = mask;
    if (mMask != null)
      mMask.resize(width, height);   // resize to match display window 
  }
  
  public void loop() { mMovie.loop(); }
  public void play() { mMovie.play(); }
  
  // this function can be called asynchronously from movieEvent - possibly right in the middle of a call to draw()
  public void nextFrame(Movie m) {
    if (mMovie == m) {     // if this is =our= movie ...
      m.read();            // read the next frame of the Movie 
      mFrame = m.get();    // ... and copy it into our mFrame PImage
    }
  }
  
  public void draw() {
    if (mFrame == null) //<>//
      return;    // no frame to draw yet
    PImage lFrame = mFrame;        // make a local copy of the ref in case onMovieEvent is called during this call
    lFrame.resize(width, height);  // resize the frame to match the display window 
    if (mMask != null)
      lFrame.mask(mMask);          // if this Layer has a mask, apply it to the current frame
    if (mRotation != 0.0) {
      // optionally rotate this masked video frame layer as we draw it
      translate(width, height);
      rotate(mRotation);
    }
    image(lFrame, 0,0);    // draw this Layer to the window
    resetMatrix();
  }
  
};

String PATH1 = "RiverCloseup.mp4";   // this video is upside-down for some reason
String PATH2 = PATH1;
//String PATH2 = "MercerPainting.mov";

Layer layer1, layer2;

void setup() {
  size(1152, 648);
  frameRate(20);
  
  layer1 = new Layer(new Movie(this, PATH1), 180.0, null);
  layer1.loop();
  layer2 = new Layer(new Movie(this, PATH2), 0.0, loadImage("ABSOLVE_BW.png"));
  layer2.loop();
}


// Called every time a new frame is available to read
void movieEvent(Movie m) {
  layer1.nextFrame(m);      // checks if movie of Layer1 is the subject of this call, and if so handles it
  layer2.nextFrame(m);      // ... etc.
}


void draw() {
  layer1.draw();
  layer2.draw();
}