
void setup() {
  size(400,400);
  //noSmooth();
  strokeWeight(5);
}

float angle=0;

void draw() {
  //background(0x04FFFFFF);
  fill(0x3FFFFFF);
  rect(0,0,width,height);
  
  translate(width/2, height/2);
  rotate(angle);
  scale(0.5, 0.5);
  angle += 0.01;
  point(120, 80);
  point(130, 90);
  point(140, 100);
  point(140, 80);
  point(120, 100);
  point(-120, -90);
}
