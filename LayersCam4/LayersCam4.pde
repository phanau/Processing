// Show layered videos inside masks
  
import processing.video.*;

// from https://processing.org/examples/edgedetection.html
// implementation of a custom edge-finding filter
float[][] kernel = {{ -1, -1, -1}, 
                    { -1,  9, -1}, 
                    { -1, -1, -1}};

PImage EdgeFilterGray(PImage img) {
  img.loadPixels();
  // Create an opaque image of the same size as the original
  PImage edgeImg = createImage(img.width, img.height, RGB);
  // Loop through every pixel in the image.
  for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*img.width + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(img.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*img.width + x] = color(sum, sum, sum);
    }
  }
  // State that there are changes to edgeImg.pixels[]
  edgeImg.updatePixels();
  return edgeImg;
}

PImage EdgeFilterColor(PImage img) {
  img.loadPixels();
  // Create an opaque image of the same size as the original
  PImage edgeImg = createImage(img.width, img.height, RGB);
  // Loop through every pixel in the image.
  for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
      float sumR = 0; // Kernel sum for this pixel
      float sumG = 0; // Kernel sum for this pixel
      float sumB = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*img.width + (x + kx);
          // Multiply adjacent pixels based on the kernel values
          sumR += kernel[ky+1][kx+1] * red(img.pixels[pos]);
          sumG += kernel[ky+1][kx+1] * green(img.pixels[pos]);
          sumB += kernel[ky+1][kx+1] * blue(img.pixels[pos]);
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*img.width + x] = color(sumR, sumG, sumB);
    }
  }
  // State that there are changes to edgeImg.pixels[]
  edgeImg.updatePixels();
  return edgeImg;
}

final int EDGEFILTERGRAY=-1;
final int EDGEFILTERCOLOR=-2;


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
      break;
    case EDGEFILTERGRAY:
      image.set(0,0,EdgeFilterGray(image));
      break;
    case EDGEFILTERCOLOR:
      image.set(0,0,EdgeFilterColor(image));
      break;      
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
  
  public MovieSource frameRate(float f) {
      mMovie.frameRate(f);
      return this;
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
  float mWidth;
  float mHeight;
  float mCenterX;
  float mCenterY;
  
  // constructor: creates a Layer with the given Movie, rotation (in degrees) and mask image
  public SourceLayer(Source movie) {
    mMovie = movie;        // remember a reference to the Movie for this Layer
    mRotation = 0;         // rotation angle in radians
    mTheta = 0.0;          // by default, no dynamic rotation
    mMask = null;          // reference to the Mask Source for this Layer (initially null, meaning no mask)
    mAlpha = 1.0;          // default is opaque
    mWidth = width;        // default is full window size
    mHeight = height;
    mCenterX = width/2;    // coordinates of the center of the viewport in the window
    mCenterY = height/2;
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
    
  public SourceLayer viewport(float x, float y, float w, float h) {
    mCenterX = x; mCenterY = y;
    mWidth = w; mHeight = h;
    return this;
  }
  
  // draw this Layer to the display window
  public void draw() {
    
    // if a new frame of this Layer's Movie is available, get it and make it ready to show ...
    if (mMovie.available()) {
      mFrame = mMovie.get();
      if (mFrame != null && mFrame.width > 0 && mFrame.height > 0)
        mFrame.resize(round(mWidth), round(mHeight));  // resize the frame to match the viewport 
    }
    
    // if this Layer has a mask, get its current frame
    if (mMask != null) {
      if (mMask.available()) {
        mMaskImage = mMask.get();    // may be null if mask image isn't ready
        if (mMaskImage != null && mMaskImage.width > 0 && mMaskImage.height > 0) {
          mMaskImage.resize(round(mWidth), round(mHeight));
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
    mRotation += mTheta;        // apply rotation increment (optional, default is 0)
    // rotate and flip viewport about its center
    // transforms are post-appended and points are post-multiplied,
    // so the last transform is applied first.
    translate(mCenterX, mCenterY);
    rotate(mRotation); 
    scale(mFlipH?-1.0:1.0, mFlipV?-1.0:1.0);
    translate(-mCenterX, -mCenterY);
    
    tint(1.0, mAlpha);
    imageMode(CENTER);
    image(maskedFrame, mCenterX, mCenterY, mWidth, mHeight);    // draw this Layer to the window
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
  //size(1920,1080);
  size(1280, 720);
  //size(640, 480);
  //frameRate(30); //<>//
  colorMode(RGB, 1.0);
  
  // generate a unique folder identifier in case we save any frames by concatenating year-month-day-hour-minute-second start time of program
  guid = String.valueOf(year())+"-"+String.valueOf(month())+"-"+String.valueOf(day())+"-"+String.valueOf(hour())+"-"+String.valueOf(minute())+"-"+String.valueOf(second());

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
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "AfternoonSky-20fps-High.mov"))).transparency(1.0f);
  
  // play multiple Movies in different viewports
  if (false) {
    layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180).viewport(width*0.5,height*0.5,width*0.8,height*0.8);
    layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "AfternoonSky-20fps-High.mov"))).rotation(-15).flip(false,true).viewport(width/2,height/2,width/2,height/2);
    layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "IMG_8030.m4v"))).viewport(width/4,height/4,width/4,height/4);
    layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "MVI_0115.mov"))).rotation(15).viewport(width*0.75,height/4,width/4,height/4);
    layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).flip(true,false).rotationSpeed(1).viewport(width*0.75,height*0.75,width/4,height/4);
  }
  
  // play a movie in an array of viewports
  if (false) {
    int n = 2;
    int m = 10/2;  // margin between viewports
    for (int i=0; i<n; i++){
      for (int j=0; j<n; j++) {
        layers[indx++] = (i==j) ?
            new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).rotation(180).viewport((i+0.5)*width/n,(j+0.5)*height/n,width/n-m,height/n-m) :
            new SourceLayer(new MovieSource(new Movie(this, "AfternoonSky-20fps-High.mov"))).viewport((i+0.5)*width/n,(j+0.5)*height/n,width/n-m,height/n-m) ;
      }
    }
  }
  
  // a simple Layer consisting of the default camera (here, flipped horizontally to act like a mirror) and in a rotating viewport
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).flip(true,false).rotationSpeed(0); // flip(horizontal,vertical)
  
  // the camera in an array of viewports
  if (true) {
    int n = 2;
    int m = 10/2;  // margin between viewports
    for (int i=0; i<n; i++){
      for (int j=0; j<n; j++) {
        layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).flip(true,false).viewport((i+0.5)*width/n,(j+0.5)*height/n,width/n-m,height/n-m);
      }
    }
  }
  
  // a Layer consisting of a camera, flipped horizontally to act like a mirror, and run through several filters
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(DILATE,2).filter(ERODE,2).filter(POSTERIZE,4)).flip(true,false); // flip(horizontal,vertical)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(DILATE,4).filter(ERODE,4).filter(POSTERIZE,2).filter(GRAY)).flip(true,false); // flip(horizontal,vertical)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(POSTERIZE,2).filter(GRAY).filter(DILATE,4).filter(ERODE,4)).flip(true,false); // flip(horizontal,vertical)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(POSTERIZE,4).filter(EDGEFILTERGRAY)).flip(true,false); // flip(horizontal,vertical)
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height)).filter(POSTERIZE,3).filter(EDGEFILTERCOLOR)).flip(true,false); // flip(horizontal,vertical)

  // a Layer that shows a static image masked by another static image
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new ImageSource("ABSOLVE_BW.png"));

  // a Layer that shows a static image masked by another static image; the "rotation" call on the end causes it to be displayed rotated 30 degrees
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new ImageSource("ABSOLVE_BW.png")).rotation(30);
  
  // a Layer that shows a static image; the call on the end causes it to be displayed 25% transparent
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).transparency(0.25);
  
  // a Layer that shows a Movie masked by a static image; the "setRotationSpeed" call on the end causes this Layer to rotate slowly CW
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new ImageSource("ABSOLVE_BW.png")).rotationSpeed(1.0);
  
  // a Layer that shows a static image masked by a Movie
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new MovieSource(new Movie(this, "MercerPainting.mov")));
  
  // a Layer that shows a static image masked by the camera
  //layers[indx++] = new SourceLayer(new ImageSource("jupiter1.png")).mask(new CameraSource(new Capture(this, width, height)));

  // a Layer that shows the camera masked by a static image
  //layers[indx++] = new SourceLayer(new CameraSource(new Capture(this, width, height))).mask(new ImageSource("jupiter1.png"));

  // a Layer that shows a Movie masked by a camera that has been run through one or more filters
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4")).filter(POSTERIZE,4)).mask(new CameraSource(new Capture(this, width, height)).filter(THRESHOLD,0.5)).flip(true,false);
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4"))).mask(new CameraSource(new Capture(this, width, height)).filter(GRAY).filter(POSTERIZE,4)).flip(true,false);

  // a Layer that shows a Movie that has been run through one or more filters
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4")).filter(POSTERIZE,4).filter(EDGEFILTERGRAY));
  //layers[indx++] = new SourceLayer(new MovieSource(new Movie(this, "RiverCloseup.mp4")).filter(POSTERIZE,4).filter(EDGEFILTERCOLOR));

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

int frameNumber=0;
boolean bMovieSaved = false;        // ... since last frame save
int movieNumber=0;

void draw() {
  // draw all the Layers to the screen
  clear();
  for (Layer l : layers)
    if (l != null)  // ignore unused layer array entries.
      l.draw();
 
  // if user presses the 's' key, save the current frame to a file
  if (keyPressed && key=='s') {
    saveFrame("saveFrame"+guid+"/frame-"+ ++frameNumber +".jpg");
    bMovieSaved = false;
  }
  
  // if user presses 'S', convert the current frame folder to a movie file
  if (keyPressed && key=='S') {
    generateMovie();
    bMovieSaved = true;
  }
  
  // post frame time
  int t = millis();
  int dt = t - mTime;
  mTime = t;
  println("frame time: " + dt);
}

// http://hamelot.io/visualization/using-ffmpeg-to-convert-a-set-of-images-into-a-video/
// ffmpeg -r 6 -i "saveFrame2018-9-3-10-54-44/frame-%d.jpg" "saveFrame2018-9-3-10-54-44/movie.mp4" 
void generateMovie()
{
  if (!bMovieSaved) {
    println("Making movie file >" , "/usr/local/bin/ffmpeg", "-r", "6", "-i", sketchPath("saveFrame"+guid+"/frame-%d.jpg"), sketchPath("saveFrame"+guid+"/movie"+movieNumber+".mp4") );
    ProcessBuilder pb = new ProcessBuilder(
        "/usr/local/bin/ffmpeg", "-r", "6", "-i", sketchPath("saveFrame"+guid+"/frame-%d.jpg"), sketchPath("saveFrame"+guid+"/movie"+movieNumber+".mp4"));
    //pb.directory(new File("saveFrame"+guid));
    println("working dir = " + pb.directory());
    File log = new File("log.txt");
    pb.redirectErrorStream(true);
    pb.redirectOutput(ProcessBuilder.Redirect.appendTo(log));
    try {
      Process process = pb.start();
      assert pb.redirectInput() == ProcessBuilder.Redirect.PIPE;
      assert pb.redirectOutput().file() == log;
      assert process.getInputStream().read() == -1;
      process.waitFor();
      println("done!");
      movieNumber++;
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
