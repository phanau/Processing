

void setup() {  // The "factory"
  //fullScreen();
  //size(displayWidth, displayHeight);
  size(1280,960);
  clear();
}

void draw() {
  int mX = mouseX;
  int mY = mouseY;
  
  dot(mX, mY, int(random(20,50)), int(random(40,60)));
}

void mousePressed() {
  clear();
}

void dot(int x, int y, int w, int h) {
  fill(random(200,255),random(255),random(255),random(255));
  ellipse(x, y, w, h);
}