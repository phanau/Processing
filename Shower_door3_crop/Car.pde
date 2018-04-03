
class Car {  // Make same name as the file
  float x;  // x pos, y pos, color
  float y;
  float l;
  float h;
 
  // function with same name as class: constructor. Function is called when "new car" calls function
  // Similar to setup: only called once
  Car(float carx, float cary, float carLength, float carHeight) {  // Receives variables, stores them in these properties
    x = carx;
    y = cary;
    l = carLength;
    h = carHeight;
  }
  
 // Like draw
 void drive(int speed) {
   y = y + speed;
   if (y >= height+h)
   {
     y = -h;
   }
 }
 
 void display(int camW, int camH) {
   color c = cam.get(int(map(width-x,0,width-1,cam.width/2-camW/2,cam.width/2+camW/2-1)), int(map(y,0,height-1,cam.height/2-camH/2,cam.height/2+camH/2-1)));
                                   // centers cropped camera
                                   // -1 because 0-159, not 1-160
   float alpha = map(mouseX, 0, width, 0, 1);
   fill(c);
   ellipse(x, y, l, h);
   
   fill(0,alpha);
   rect(0,0,width,height);
   
   //rectMode(CENTER);
   //rect(x, y, l, h);
   //rectMode(CORNER);
 }
}