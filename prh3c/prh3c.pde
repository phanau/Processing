



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
  // for all active planets
  for (dot d : mdots) {
    if (d != null) {
      // treat cursor like a small planet
      d.update(new Vec2(mouseX, mouseY), 10);
      // update each planet for the gravitational effects of all others
      for (dot e : mdots) {          
        if (e != null && e != d)
          d.update(e.mPos, e.mdiam);
      }
      // update telemetry
      totalV += d.velocity();
    }
  }
  // draw telemetry: number of planets, total velocity (energy) of all planets
  fill(255,255,255);
  text(ndots, 20,20);
  text(totalV, 20,40);
}

void mousePressed() {
  float dx = random(-1,1);
  float dy = random(-1,1); 
  mdots[ndots++] = new dot(new Vec2(mouseX, mouseY), new Vec2(dx, dy), int(random(20,50)), color(random(255), random(255), random(255)));
}