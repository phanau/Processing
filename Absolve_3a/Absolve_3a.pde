// Show layered videos inside masks
  
import processing.video.*;

class Layer {
  Movie mMovie;       // the Movie for this Layer
  float mRotation;    // optional rotation applied when drawing this Layer (in radians)
  PImage mMask;       // the mask image for this Layer
  PImage mFrame;      // current frame of mMovie
  
  // constructor: creates a Layer with the given Movie, rotation (in degrees) and mask image
  public Layer(Movie movie, float rotationDegrees, PImage mask) {
    mMovie = movie;        // remember a reference to the Movie for this Layer
    mRotation = radians(rotationDegrees);    // save the rotation angle in radians
    mMask = mask;          // remember a reference to the mask image for this Layer (may be null, meaning no mask)
    if (mMask != null)     // if there is a mask image ...
      mMask.resize(width, height);   // resize it to match the display window size
  }
  
  // give access to this Layer's Movie so caller can call other functions to play it, loop forever, pause, etc.
  public Movie movie() { return mMovie; }
  
  // draw this Layer to the display window
  public void draw() {
    
    // if a new frame of this Layer's Movie is available, get it and make it ready to show ...
    if (mMovie.available()) {
      mMovie.read();
      mFrame = mMovie.get();
      mFrame.resize(width, height);  // resize the frame to match the display window 
      if (mMask != null)
        mFrame.mask(mMask);          // if this Layer has a mask, apply it to the current frame
    }
    
    if (mFrame == null)
      return;                      // nothing to draw yet
    
    // draw the current frame to the window, applying a rotation if requested for this Layer
    if (mRotation != 0.0) {
      // optionally rotate this masked video frame layer as we draw it
      translate(width, height);
      rotate(mRotation);
    }
    image(mFrame, 0,0);    // draw this Layer to the window
    resetMatrix();
  }
  
};

// declare all our Layers
Layer[] layers = new Layer[2];

void setup() {
  size(1152, 648);
  frameRate(30);
  
  // create and initialize all the Layers with their respective Movies, rotations, and mask images
  layers[0] = new Layer(new Movie(this, "RiverCloseup.mp4"), 180.0, null);
  layers[1] = new Layer(new Movie(this, "RiverCloseup.mp4"), 0.0, loadImage("ABSOLVE_BW.png"));

  // start all the Layers playing in "loop" mode
  for (Layer l : layers)
    l.movie().loop();
}


void draw() {
  // draw all the Layers to the screen
  for (Layer l : layers)
    l.draw();
}


// examples of some possible user inputs - pressing the mouse (or trackpad) over the window 
// either pauses or slows down the ABSOLVE layer

void mousePressed() {
  //layers[1].movie().pause();    // pause the layer1 Movie
  layers[1].movie().speed(0.1);   // slow down the layer1 Movie to 1/10 speed
}

void mouseReleased() {
  //layers[1].movie().loop();    // resume the layer1 Movie in "loop" mode
  layers[1].movie().speed(1.0);  // resume playing the layer1 Movie at full speed
}

void keyPressed() {
  println("pressed " + int(key) + " " + keyCode);
}

void keyTyped() {
  println("typed " + int(key) + " " + keyCode);
}

void keyReleased() {
  println("released " + int(key) + " " + keyCode);
}