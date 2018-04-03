// Video inside text
// Plays a video behind a PNG with transparent letters  
  
import processing.video.*;

String PATH = "RiverCloseup.mp4";   // The translate and rotate are because 
                                    // this video is upside-down for some reason
Movie movie1, movie2;  // declare both in one line
PImage frame1, frame2; // current frame of movie1 and movie2
PImage mask1;  // text image in B+W... stencil

void setup() {
  size(1152, 648);
  frameRate(60);

  movie1 = new Movie(this, PATH);  // creates Movie object from movie file in data foler
  movie1.loop();     // play over and over
  movie2 = new Movie(this, PATH);
  movie2.loop();  
  //mov.speed(5);
  movie1.volume(0);   // 0 = mute   (not seeming to work...)
                      // To get sound, must be drawing from movie, not frame by frame
  
  // Resize and place text image 
  mask1 = loadImage("ABSOLVE_BW.png");  // Call
  mask1.resize(1152, 648);   // Resize to match phone camera size


}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();             // advances movie to the next frame on EVERY movie that's running
  if (m == movie1)    // checks if movie1 has advanced, and if so
    frame1 = m.get();   // returns current frame of movie1
  if (m == movie2)
    frame2 = m.get();   // returns current frame of movie2
}

void draw() {
  // Turns video right side up
  translate(width, height);
  rotate(PI);
  
  // Background video, whole
  if (frame1 != null)      // check to make sure a frame is available
    image(frame1, 0, 0, 1152, 648);   // if so, draw frame (like an image)  
  resetMatrix();  // undoes the translate and rotate and sets it back to default
  
  // video in text/mask
  if (frame2 != null)
  {
    frame2.resize(1152, 648);
    if (frame2.width == mask1.width && frame2.height == mask1.height)
    {
      frame2.mask(mask1);
      image(frame2, 0, 0, 1152, 648);   // draw's frame half size in top left (optionl)
    }
    else
    {
      // display sizes of frame2 and mask1
      fill(0);
      String s =  String.format("frame2 (%d,%d)   mask(%d,%d)", frame2.width, frame2.height, mask1.width, mask1.height);
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