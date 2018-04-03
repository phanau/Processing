

void setup() {
  size(1280,960);
  clear();
}

void draw() {
  int mX = mouseX;
  int mY = mouseY;
  
  clear();
  dot(mX, mY, 50, 50);
}

void dot(int x, int y, int w, int h) {
  fill(255,255,0,255);  // rgba
  ellipse(x, y, w, h);
}