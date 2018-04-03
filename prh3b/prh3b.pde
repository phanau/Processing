



private dot mdots[];
private int ndots = 0;

void setup() {
  size(1280,960);
  clear();
  mdots = new dot[1000];
}

void draw() {
  clear();
  float totalV = 0;
  for (dot d : mdots) {
    if (d != null) {
      d.update(new Vec2(mouseX, mouseY));
      totalV += d.velocity();
    }
  }
  fill(255,255,255);
  text(ndots, 20,20);
  text(totalV, 20,40);
}

void mousePressed() {
  float dx = random(-10,10);
  float dy = random(-10,10); 
  mdots[ndots++] = new dot(new Vec2(mouseX, mouseY), new Vec2(dx, dy), int(random(5,50)), color(random(255), random(255), random(255)));
}