// Show layered videos inside masks
  
import processing.video.*;

interface Source {
  boolean available();
  PImage get();
  void loop();
  void pause();
}

class ImageSource implements Source {
  PImage mImage;
  public ImageSource(String path) {
    mImage = loadImage(path);
  }
  public boolean available() { return true; }
  public PImage get() { return mImage; }
  public void loop() {}
  public void pause() {}
}
  
class CameraSource implements Source {
  Capture mCamera;
  PImage mFrame;
  
  public CameraSource(Capture camera) {
    mCamera = camera;
    mFrame = null;
  }
  
  public boolean available() {
    return mCamera.available();
  }
  
  public PImage get() {
    if (available()) {
      mCamera.read();
      mFrame = mCamera.get();
    }
    return mFrame;
  }
  
  public void loop() {
    // Start capturing the images from the camera
    mCamera.start();
  }
  
  public void pause() {
    // Stop capturing the images from the camera
    mCamera.stop();
  }
}

class MovieSource implements Source {
  Movie mMovie;      // the Movie for this Mask
  PImage mFrame;
  
  public MovieSource(Movie movie) {
    mMovie = movie;
    mFrame = null;
  }
  
  public boolean available() {
    return mMovie.available();
  }
  
  public PImage get() {
    if (available()) {
      mMovie.read();
      mFrame = mMovie.get();
    }
    return mFrame;
  }
  
  public void loop() {
      mMovie.loop();
  }
  
  public void pause() {
      mMovie.pause();
  }
}

// define the interface for all Layers
interface Layer {
  void loop();
  void pause();
  void draw();
}

// a simple text Layer
class TextLayer implements Layer {
  String mText;
  float mSize, mX, mY;
  public TextLayer(String text, int size, float x, float y)
  {
    mText = text;  mSize = size;  mX = x;  mY = y;
  } //<>//
  
  public void loop() {
    // nothing to do unless text changes with time ...
  }
  
  public void pause() {
  }
  
  public void draw() {
    textSize(mSize);
    text(mText, mX, mY);
  }
}

// a TextLayer that can change after it's created, and wanders around, bouncing off the sides of the frame
class ComplexTextLayer extends TextLayer {
  float mDx, mDy;    // instantaneous velocity vector
  boolean mActive;   // turned on and off by loop and pause calls
  color mColor;      // text color
  
  public ComplexTextLayer(String text) {
    super(text, 24, 0, 0);    // by default, create a base Text object of size 24 at position (0,0)
    mDx = 0;  mDy = 0;        // by default, don't wander unless/until "wander(...)" function is called
    mActive = false;
    mColor = color(255,255,255);
  }
  
  public void loop() {
    mActive = true;
  }
  
  public void pause() {
    mActive = false;
  }
  
  public ComplexTextLayer string(String text) {
    mText = text;
    return this;
  }
  
  public ComplexTextLayer size(int size) {
    mSize = size;
    return this;
  }
  
  public ComplexTextLayer position(float x, float y) {
    mX = x;  mY = y;
    return this;
  }
  
  public ComplexTextLayer textColor(color c) {
    mColor = c;
    return this;
  }
  
  public ComplexTextLayer velocity(float dx, float dy) {    // dx,dy are the initial velocity vector in pixels/frame
    mDx = dx;  mDy = dy;
    return this;
  }
      
  public void draw() {
    textAlign(LEFT, TOP);
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
        mDy = -mDy; //<>//
      }
      float bottom = mY+textAscent()+textDescent();
      if (bottom > height) {
        mDy = -mDy;
      }
    }
    fill(mColor);
    text(mText, mX, mY);
  }
}

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
    mMask = null;          // reference to the Mask for this Layer (initially null, meaning no mask)
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
    pushMatrix();
    translate(width/2, height/2);
    mRotation += mTheta;        // apply rotation increment (optional, default is 0)
    rotate(mRotation);
    scale(mFlipH?-1.0:1.0, mFlipV?-1.0:1.0);
    tint(1.0, mAlpha);
    image(maskedFrame, -width/2,-height/2, width, height);    // draw this Layer to the window
    tint(1.0, 1.0);
    popMatrix();
  }
 
}

// declare all our Layers and input camera
Layer[] layers = new Layer[10];

void setup() {
  size(1280, 720);
  frameRate(30); //<>//
  colorMode(RGB, 1.0);    // all colors and transparencies are in RGBA format with range 0.0-1.0
  
  // create and initialize all the Layers with their respective Movies, rotations, and mask images
  int indx = 0;
  
  // a simple Layer that plays a Movie (that is upside down for some reason)
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180);
  
  // a simple Layer consisting of the default camera (here, flipped horizontally to act like a mirror)
  layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).flip(true,false);
  
  // a Layer that shows a static image masked by another static image; the calls on the end cause it to be displayed rotated 30 degrees and 50% transparent
  layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new ImageSource("ABSOLVE_BW.png")).rotation(30).transparency(0.5);
  
  // a Layer that shows a Movie masked by a static image; the "rotationSpeed" call on the end causes this Layer to rotate slowly CW
  layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new ImageSource("ABSOLVE_BW.png")).rotationSpeed(1.0);
  
  // a Layer that shows a static image masked by a Movie
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  
  // a Layer that shows a static image masked by the camera
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new CameraSource(new Capture(this, width, height)));
  
  // a Layer that shows the camera masked by a static image; the "rotationSpeed" call on the end causes this Layer to rotate slowly CCW
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).mask(new ImageSource("jupiter1.png")).rotationSpeed(-1.0);
  
  // a Layer that shows the camera masked by a Movie
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4")));

  // a Layer that uses another Movie as the mask for a Movie (several different combinations)
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "MercerPainting.mov"))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "MercerPainting.mov"))).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180);

  // a simple Layer that displays some static unchanging text
  //layers[indx++] = new TextLayer("Hello, this is some text.", 32, 100, 100);
  
  // a Layer that displays some text that can wander around and bounce off the sides of the frame and be changed in other ways after creation
  layers[indx++] = new ComplexTextLayer("And this is some wandering text.").position(100, 100).size(32).textColor(color(1,0.5,0,1.0)).velocity(2, 1);
  
  // start all the Layers playing in "loop" mode
  for (Layer l : layers)
    if (l != null)
      l.loop();
}


void draw() {
  // draw all the Layers to the screen
  clear();
  for (Layer l : layers)
    if (l != null)
      l.draw();
      
  if (keyPressed && key=='s')
    saveFrame("saveFrame/frame-#####.jpg");
}