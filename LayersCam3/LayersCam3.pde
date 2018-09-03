// Show layered videos inside masks
  
import processing.video.*;

// helper function to disguise unfortunate fact that Processing filter() function is fussy about presence of param
void myFilter(PImage image, int kind, float param) {
  switch(kind) {
    case THRESHOLD:
    case POSTERIZE:
    case BLUR:
      image.filter(kind, param);
      break;
    case GRAY:
    case OPAQUE:
    case INVERT:
      image.filter(kind);
      break;
    case ERODE:
    case DILATE:
      for (int i=0; i<param; i++)    // interpret param as how many times to do it
        image.filter(kind);
    default:
      break;
  }
}

interface Source {      // Defines external appearance of any object that implements this interface
                        // Makes it so program "doesn't care" what kind of media is used 
                           // because it'll return any media as a PImage. Media become interchangable!
  boolean available();  // Available, true/false. ("Tell me if you have the next frame available.")
  PImage get();         // Returns current frame as a PImage for ANY media you put in (image, camera, video)
  void loop();          // Start going, keep going from start af the end (i.e. with video)
  void pause();         // Stop getting new images -- freeze frame a video... And option that might be useful.
}

// class: defines a class of objects...
// object: a collection of data and functions that operate on that data. A specific instance of a class
// the template from which you make objects of a type

class Filter {
  int mKind;
  float mParam;
  
  public Filter(int kind) {
    mKind = kind;  mParam = 0;
  }
  public Filter(int kind, float param) {
    mKind = kind;  mParam = param;
  }
  
  public int kind() { return mKind; }
  public float param() { return mParam; }
  
  public void apply(PImage image) {
    myFilter(image, mKind, mParam);
  }
}

// a Source with one or more filters applied to it - 
// this is an abstract base class that should never be instantiated
class FilteredSource implements Source {
  Filter[] filters;
  
  protected FilteredSource() { 
    filters = new Filter[0];
  }
  
  void addFilter(Filter filter) {
    filters = (Filter[]) append(filters, filter);
  }
  
  void applyFilters(PImage image) {
    for (Filter f : filters)
      f.apply(image);
  }
  
  // required implementations of Source interface -- overridden in derived physical classes
  boolean available() { return false; }
  PImage get() { return null; }
  void loop() { }
  void pause() { }
}

// a FilteredSource that sources a fixed PImage
class ImageSource extends FilteredSource {   
  PImage mImage;   // member data (local to this class)

  public ImageSource(String path) {  // "Constructor" of class image source
    mImage = loadImage(path);
  }
  
  public ImageSource filter(int kind) {
    addFilter(new Filter(kind, 0));
    return this;
  }
  
  public ImageSource filter(int kind, float param) {
    addFilter(new Filter(kind, param));
    return this;
  }
  
  // Same four functions as defined up above for interface, implemented for this particular source
  public boolean available() { return true; }    // always available
  public PImage get() {    // apply the filter stack to the image and return the result
    PImage frame = mImage.copy();
    applyFilters(frame);
    return frame; 
  }
  public void loop() {}    // nothing to do
  public void pause() {}   // nothing to do
}
  
//-----------------------------------------
// Implementation for camera
class CameraSource extends FilteredSource {
  Capture mCamera;
  PImage mFrame;
  boolean mbFilter;
  int mFilter;
  float mParam;
  
  public CameraSource(Capture camera) {
    mCamera = camera;
    mFrame = null;
    mbFilter = false;
  }
  
  public CameraSource filter(int kind) {
    addFilter(new Filter(kind, 0));
    return this;
  }
  
  public CameraSource filter(int kind, float param) {
    addFilter(new Filter(kind, param));
    return this;
  }
  
  public boolean available() {
    return mCamera.available();
  }
  
  public PImage get() {
    if (available()) {
      mCamera.read();
      mFrame = mCamera.get();
      applyFilters(mFrame);
    }
    return mFrame;   // returns current frame
  }
  
  public void loop() {  // Start capturing the images from the camera
    mCamera.start();
  }
  
  public void pause() { // Stop capturing the images from the camera
    mCamera.stop();
  }
}

//-----------------------------------------
// Implementation for movies
class MovieSource extends FilteredSource {
  Movie mMovie;      // the Movie for this source
  PImage mFrame;     // current frame of the movie
  boolean mbFilter;
  int mFilter;
  float mParam;
  
  public MovieSource(Movie movie) { // Structure to be given a movie title/source later
    mMovie = movie;
    mFrame = null;
  }
  
  public MovieSource filter(int kind) {
    addFilter(new Filter(kind, 0));
    return this;
  }
  
  public MovieSource filter(int kind, float param) {
    addFilter(new Filter(kind, param));
    return this;
  }
  
  public boolean available() {  // "Is the next frame available?"
    return mMovie.available();
  }
  
  public PImage get() {
    if (available()) {
      mMovie.read();
      mFrame = mMovie.get();    // gets the next frame
      applyFilters(mFrame);
    }
    return mFrame;              // returns the frame
  }
  
  public void loop() {          // loop the movie
      mMovie.loop();
  }
  
  public void pause() {   // Could be used for interactivity:
                            // (i.e. press 1 to pause layer 1, press 2 to pause layer 2, etc.)
      mMovie.pause();
  }
}

//-----------------------------------------
// define the interface for all Layers (do these things for anything used as a layer)
interface Layer {
  void loop();
  void pause();
  void draw();
} //<>//

// a TextLayer that can change after it's created, and wanders around, bouncing off the sides of the frame
class TextLayer implements Layer {
  String mText;
  float mSize, mX, mY;   // size and position (upper lefthand corner)
  float mDx, mDy;        // instantaneous velocity vector
  boolean mActive;       // turned on and off by loop and pause calls
  color mColor;          // text color
  PFont mFont;           // text font

  public TextLayer(String text) {
    mText = text;  mSize = 24;  mX = 0;  mY = 0;
    mDx = 0;  mDy = 0;        // by default, don't wander unless/until "volocity(...)" function is called
    mActive = false;
    mColor = color(255,255,255);
    mFont = loadFont("SansSerif-150.vlw");   // "default" font if other font isn't set
  }

  public void loop() {
    mActive = true;
  }

  public void pause() {
    mActive = false;
  }

  public TextLayer string(String text) {
    mText = text;
    return this;
  }

  public TextLayer font(String fontName) {
    mFont = loadFont(fontName);
    return this;
  }

  public TextLayer size(int size) {
    mSize = size;
    return this;
  }

  public TextLayer position(float x, float y) {
    mX = x;  mY = y;
    return this;
  }

  public TextLayer textColor(color c) {
    mColor = c;
    return this;
  }

  public TextLayer velocity(float dx, float dy) {    // dx,dy are the initial velocity vector in pixels/frame
    mDx = dx;  mDy = dy;
    return this;
  }

  public void draw() {
    pushStyle();
    textAlign(LEFT, TOP);
    if(mFont != null)
      textFont(mFont);
    textSize(mSize);
    if (mActive) {
      mX += mDx;
      if (mX < 0) {
        mX = -mX;    // bounce off left side
        mDx = -mDx;
      }
      float right = mX+textWidth(mText);
      if (right > width) {
        mDx = -mDx;
      }
      mY += mDy;
      if (mY < 0) {
        mY = -mY;    // bounce off top
        mDy = -mDy;
      }
      float bottom = mY+textAscent()+textDescent();
      if (bottom > height) {
        mDy = -mDy;
      }
    }
    fill(mColor);
    text(mText, mX, mY);
    popStyle();
  }
} //<>//

// implement a type of Layer that uses a Source optionally masked by another Source
class SourceLayer implements Layer {
  Source mMovie;       // the Source (like an Image, Movie, or Capture) for this Layer
  float mRotation;     // optional rotation applied when drawing this Layer (in radians)
  float mTheta;        // optional rotation speed (in radians)
  Source mMask;        // the mask Source for this Layer
  PImage mFrame;       // current frame of mMovie
  PImage mMaskImage;   // window-sized mask image 
  boolean mFlipH, mFlipV;   // flip Layer horizontally and/or vertically
  float mAlpha;        // transparency of this Layer
  
  // constructor: creates a Layer with the given Movie, rotation (in degrees) and mask image
  public SourceLayer(Source movie) {
    mMovie = movie;        // remember a reference to the Movie for this Layer
    mRotation = 0;         // rotation angle in radians
    mTheta = 0.0;          // by default, no dynamic rotation
    mMask = null;          // reference to the Mask Source for this Layer (initially null, meaning no mask)
    mAlpha = 1.0;          // default is opaque
  }
  
  // start the Layer playing in "loop" mode
  public void loop() {
    mMovie.loop();
    if (mMask != null)
      mMask.loop();
  }
  
  public void pause() {
    mMovie.pause();
    if (mMask != null)
      mMask.pause();
  }
  
  public SourceLayer mask(Source mask) {
    mMask = mask;          // remember a reference to the Mask for this Layer
    return this;
  }
  
  public SourceLayer rotation(float rotationDegrees) {
    mRotation = radians(rotationDegrees);    // save the rotation angle in radians
    return this;
  }
  
  public SourceLayer rotationSpeed(float theta) {
    mTheta = radians(theta);    // given in degrees, saved in radians
    return this;                // allows operations on the Layer to be daisy-chained
  }
  
  public SourceLayer flip(boolean h, boolean v) {
    mFlipH = h;  mFlipV = v;
    return this;
  }
  
  public SourceLayer transparency(float alpha) {
    mAlpha = alpha;
    return this;
  }
    
  // draw this Layer to the display window
  public void draw() {
    
    // if a new frame of this Layer's Movie is available, get it and make it ready to show ...
    if (mMovie.available()) {
      mFrame = mMovie.get();
      if (mFrame != null && mFrame.width > 0 && mFrame.height > 0)
        mFrame.resize(width, height);  // resize the frame to match the display window 
    }
    
    // if this Layer has a mask, get its current frame
    if (mMask != null) {
      if (mMask.available()) {
        mMaskImage = mMask.get();    // may be null if mask image isn't ready
        if (mMaskImage != null && mMaskImage.width > 0 && mMaskImage.height > 0) {
          mMaskImage.resize(width, height);
        }
      }
    }
    
    if (mFrame == null)
      return;                      // nothing to draw yet
        
    // if either frame or mask has changed, apply the mask to the frame
    PImage maskedFrame = mFrame;
    if (mFrame != null && mFrame.width > 0 && mFrame.height > 0 && 
        mMaskImage != null && mMaskImage.width > 0 && mMaskImage.height > 0)
      maskedFrame.mask(mMaskImage);  

    // draw the current frame to the window, applying a rotation if requested for this Layer -
    // rotation is around the middle of the Layer and the middle of the screen
    pushStyle();
    pushMatrix();
    translate(width/2, height/2);
    mRotation += mTheta;        // apply rotation increment (optional, default is 0)
    rotate(mRotation);
    scale(mFlipH?-1.0:1.0, mFlipV?-1.0:1.0);
    tint(1.0, mAlpha);
    image(maskedFrame, -width/2,-height/2, width, height);    // draw this Layer to the window
    popMatrix();
    popStyle();
  }
 
}

// declare all our Layers and input camera
Layer[] layers = new Layer[100];  // # = max number of layers. Doesn't have to match how many are actually used.

// unique file prefix for this run of the program
String guid;

// time of last frame (for frame time display)
int mTime;

void setup() {    // Customize this and the draw loop by adding my own media
  size(1280, 720);
  //size(640, 480);
  frameRate(30); //<>//
  colorMode(RGB, 1.0);
  
  // generate a unique folder identifier in case we save any frames by concatenating year-month-day-hour-minute-second start time of program
  guid = String.valueOf(year())+"-"+String.valueOf(month())+"-"+String.valueOf(day())+"-"+String.valueOf(hour())+";"+String.valueOf(minute())+";"+String.valueOf(second());

  // create and initialize all the Layers with their respective Movies, rotations, and mask images
  int indx = 0;
  
  // NOTES
  // The layers stack back to front (like code, not like photoshop!)
  //"layers[indx++]" means adding this layer into "index'th" spot in the array, then increment so the next goes in the next spot
  // a SourceLayer uses a source, like a photo/movie/gif in the data folder
  
  // a simple Layer that just displays a static image
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png"));
  
  // a Layer that just displays a static image with some filtering
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png").filter(GRAY).filter(BLUR,4));
  
  // a simple Layer that plays a Movie (that is upside down for some reason)
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180); // rotates around center of layer and window
  
  // another simple Movie layer
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "AfternoonSky-20fps-High.mov"))).transparency(0.5f);
  
  // a simple Layer consisting of the default camera (here, flipped horizontally to act like a mirror)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).flip(true,false); // flip(horizontal,vertical)
  
  // a Layer consisting of a camera, flipped horizontally to act like a mirror, and run through several filters
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(DILATE,2).filter(ERODE,2).filter(POSTERIZE,4)).flip(true,false); // flip(horizontal,vertical)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(DILATE,4).filter(ERODE,4).filter(POSTERIZE,2).filter(GRAY)).flip(true,false); // flip(horizontal,vertical)
  layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(POSTERIZE,2).filter(GRAY).filter(DILATE,4).filter(ERODE,4)).flip(true,false); // flip(horizontal,vertical)

  // a Layer that shows a static image masked by another static image; the "rotation" call on the end causes it to be displayed rotated 30 degrees
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new ImageSource("ABSOLVE_BW.png")).rotation(30);
  
  // a Layer that shows a static image masked by another static image
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new ImageSource("ABSOLVE_BW.png"));

  // a Layer that shows a static image; the call on the end causes it to be displayed 25% transparent
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).transparency(0.25);
  
  // a Layer that shows a Movie masked by a static image; the "setRotationSpeed" call on the end causes this Layer to rotate slowly CW
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new ImageSource("ABSOLVE_BW.png")).rotationSpeed(1.0);
  
  // a Layer that shows a static image masked by a Movie
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  
  // a Layer that shows a static image masked by the camera
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new CameraSource(new Capture(this, width, height)));

  // a Layer that shows a Movie masked by a camera that has been run through one or more filters
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4")).filter(POSTERIZE,4)).mask(new CameraSource(new Capture(this, width, height)).filter(THRESHOLD,0.5)).flip(true,false);
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new CameraSource(new Capture(this, width, height)).filter(GRAY).filter(POSTERIZE,4)).flip(true,false);

  // a Layer that shows the camera masked by a static image that has some filters applied to it
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new CameraSource(new Capture(this, width, height)).filter(GRAY).filter(POSTERIZE,4)).flip(true,false);
  
  // a Layer that shows the camera masked by a static image; the "rotationSpeed" call on the end causes this Layer to rotate slowly CCW
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).mask(new ImageSource("jupiter1.png")).rotationSpeed(-1.0);
  
  // a Layer that shows the camera masked by a Movie
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4")));

  // a Layer that uses another Movie as the mask for a Movie (several different combinations)
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "MercerPainting.mov"))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "MercerPainting.mov"))).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180);
  
  // a Layer that displays some text that can wander around and bounce off the sides of the frame and be changed in other ways after creation
  //layers[indx++] = new TextLayer("And this is some wandering text.").font("ACaslonPro-Bold-150.vlw").position(100, 100).size(32).textColor(color(1,0.5,0,1.0)).velocity(2, 1);
  //layers[indx++] = new TextLayer("some more text.").font("ACaslonPro-Bold-150.vlw").position(300, 100).size(32).textColor(color(0.5,0,1.0,1)).velocity(2, -1);
  //layers[indx++] = new TextLayer("This is some fixed text.").position(100, 200);

 
  // start all the Layers playing in "loop" mode
  for (Layer l : layers)
    if (l != null)  // ignore unused layer array entries.
      l.loop();
  
  // initialize timer for frame time display
  mTime = millis();
}


void draw() {
  // draw all the Layers to the screen
  clear();
  for (Layer l : layers)
    if (l != null)  // ignore unused layer array entries.
      l.draw();
 
  // if user presses the 's' key, save the current frame to a file
  if (keyPressed && key=='s')
    saveFrame("saveFrame"+guid+"/frame-#####.tif");
    
  // post frame time
  int t = millis();
  int dt = t - mTime;
  mTime = t;
  println("frame time: " + dt);

}
