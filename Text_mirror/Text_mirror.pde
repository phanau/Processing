/*
Play with camera in text
Live video in bold text to see self reflected in the words...
Make an array of PNGs w/ B+W words for use as masks... 
  Play with reversing if BG or foreground (+/- space) is from cam
    Meaning: "YOU ARE HERE" ---> "HERE" could put cam in BG
cycle through them over camera feed to look like a mirror that changes shape
*/

import processing.video.*;

Capture cam;

void setup() {
  //size(640, 480);
  size(1280, 720);   // play with how to get a bigger "mirror" (can I try a webcam?)
  //fullScreen();
  background(0);

  // request a Capture device that matches the target window
  cam = new Capture(this, width, height);
  if (cam == null) {
    println("can't find a camera. Bye!");
    exit();
  }
  
  // Start capturing the images from the camera
  cam.start();
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  
  // mirror and display the camera image
  scale(-1.0, 1.0);  // flip horizontally for mirror effect
  image(cam,-cam.width,0);
  
  // this is faster than the above if no fiddling with the image is needed
  //set(0, 0, cam);  
}