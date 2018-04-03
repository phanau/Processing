// Video inside text
// Plays a video behind a PNG with transparent letters  
  
import processing.video.*;

String PATH1 = "RiverCloseup.mp4";   // The translate and rotate are because 
                                    // this video is upside-down for some reason
String PATH2 = PATH1;
//String PATH2 = "MercerPainting.mov";

Movie movie1, movie2;  // declare both in one line
PImage frame1, frame2; // current frame of movie1 and movie2
PImage mask1;  // text image in B+W... stencil

void setup() {
  size(1152, 648);
  
  frameRate(20);

  movie1 = new Movie(this, PATH1);  // creates Movie object from movie file in data foler
  movie1.loop();     // play over and over
  movie2 = new Movie(this, PATH2);
  movie2.loop();  
  //mov.speed(5);
  movie1.volume(0);   // 0 = mute   (not seeming to work...)
                      // To get sound, must be drawing from movie, not frame by frame
  
  mask1 = loadImage("ABSOLVE_BW.png");  // load the mask image
  mask1.resize(width, height);   // Resize to match display window size
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();             // advances movie to the next frame on EVERY movie that's running
  if (m == movie1)      // checks if movie1 is the subject of this call, and if so
    frame1 = m.get();   // saves current frame of movie1 in PImage frame1
  if (m == movie2) {    // same for movie2 ...
    frame2 = m.get();   // saves current frame of movie2 in PImage frame2
  }
}

void draw() {
  // make local copies of references to frame1 and frame2 so that we'll hold onto those frames
  // even if movieEvent() call happens while we're drawing
  PImage lFrame1 = frame1;
  PImage lFrame2 = frame2;
  
  // Turns video right side up
  translate(width, height);
  rotate(PI);
  
  // Background video, whole
  if (lFrame1 != null)      // check to make sure a frame is available
    image(lFrame1, 0, 0, width, height);   // if so, draw frame (like an image)  
  resetMatrix();  // undoes the translate and rotate and sets it back to default
  
  // video in text/mask
  if (lFrame2 != null)
  {
    lFrame2.resize(width, height);  // resize frame2 to match the mask image and screen
    if (lFrame2.width == mask1.width && lFrame2.height == mask1.height)
    {
      lFrame2.mask(mask1);    // load the alpha (transparency) channel of frame2 with the blue channel of the mask image
      image(lFrame2, 0, 0, width, height);  // draw the masked frame2 image over the frame1 background
    }
    else
    {
      // display sizes of frame2 and mask1 to help debug things
      fill(0);
      String s =  String.format("frame1(%d,%d)  frame2(%d,%d)  mask(%d,%d)", 
        lFrame1.width, lFrame1.height, lFrame2.width, lFrame2.height, mask1.width, mask1.height);
      text(s, 20,20);
    }
  }
  
}


// make text mask in B+W, not transparent
// subtract/blend based on blue/(color) channel... white contains all colors




/*

void draw() {   // draw runs in its loop separately from movieEvent...
   // checks to make sure draw is ready to display what is "returned" in movieEvent below
  if (frame1 != null)      // check to make sure a frame is available
    image(frame1, 0, 0);   // if so, draw frame (like an image)
  if (frame2 != null)
    image(frame2, 0, 0, 640, 360);   // draw's frame half size in top left (optionl)
}

*/