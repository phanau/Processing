



private dot mdots[];
private int ndots = 0;

void setup() {
  size(1280,960); //<>//
  clear();
  mdots = new dot[1000];
}

void draw() {
  clear(); //<>//
  for (dot d : mdots) {
    if (d != null)
      d.update();
  }
  fill(255,255,255);
  text(ndots, 20,20);
}

void mousePressed() {
  int dx = 0; while (dx == 0) { dx = int(random(-10,10)); }
  int dy = 0; while (dy == 0) { dy = int(random(-10,10)); }
  mdots[ndots++] = new dot(mouseX, mouseY, dx, dy, int(random(5,50)), color(random(255), random(255), random(255))); //<>//
}