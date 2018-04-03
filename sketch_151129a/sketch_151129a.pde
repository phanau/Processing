
import processing.video.*;
Movie movie1, movie2;
PImage frame1, frame2;
PImage mask;  // not used in this code... for later w/ B+W letters image

void setup() {
  size(1280, 720);
  movie1 = new Movie(this, "sample2.mov");  // creates Movie object from movie file in data foler
  //movie1.loop();   
  movie1.play();
  movie2 = new Movie(this, "sample3.mov");
  movie2.play();
}

void draw() {   // draw runs in its loop separately from movieEvent...
   // checks to make sure draw is ready to display what is "returned" in movieEvent below
  if (frame1 != null)      // check to make sure a frame is available
    image(frame1, 0, 0);   // if so, draw frame (like an image)
  if (frame2 != null)
    image(frame2, 0, 0, 640, 360);   // draw's frame half size in top left (optionl)
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();             // advances movie to the next frame on EVERY movie that's running
  if (m == movie1)    // checks if movie1 has advanced, and if so
    frame1 = m.get();   // returns current frame of movie1
  if (m == movie2)
    frame2 = m.get();   // returns current frame of movie2
}


// make text mask in B+W, not transparent
// subtract/blend based on blue/(color) channel... white contains all colors