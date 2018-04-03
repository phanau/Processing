/* Fixed problem when displaying on different sized windows
   Changed how the program gets color from the camera
   Don't use vidScale anymore, map cam to screen instead
   Crop cam image to always be in the correct aspect ratio
*/

Car[] cars = new Car[750];
import processing.video.*;

Capture cam;

void setup() {  // The "factory"
//fullScreen();
//size(displayWidth, displayHeight);
size(1280,960);
//size(1200,300);
//size(900,900);

String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 160, 120);  // If no cam list, make a default with this size
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, Capture.list()[6]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    cam.start();
  }
  
 for(int i=0; i<cars.length; i++) {
   cars[i] = new Car(random(width),0, width/570+random(15), random(30,100));  // make not arbitrary so it always displays reliably
 }
background(0);
noStroke();
}

void captureEvent(Capture video) {
  video.read();
}


void draw() {
  float alpha = map(mouseX, 0, width, 0, 3);
  fill(255, alpha);
  rect(0, 0, width, height);
  int divisor = int(map(mouseY, 0, height, 1, 40));
  
  // Calculate width and height of camera region to be mapped to the screen to avoid distortion
  int camH, camW;
  if (width*cam.height > cam.width*height) {  // if the window aspect ratio is wider than the camera
    camW = cam.width;
    camH = height*cam.width/width;
  }
  else {                                      // if the window aspect ratio is taller than the camera (or same)
    camW = cam.height*width/height;
    camH = cam.height;
  }
  //println("C:" + cam.width + "," + cam.height + "  c:" + camW + "," + camH + "  W:" + width + "," + height);
  
  for(int i=0; i<cars.length; i++) {
    cars[i].drive(i/divisor); 
    cars[i].display(camW, camH);
  }
}

  void mousePressed() {
    if (mousePressed) { 
      saveFrame("#####.png"); }
  }