
class dot {
  int mx, my;      // position 
  int mdx, mdy;    // velocity
  int mdiam;       // diameter 
  color mcolor;    // color  
  
  public dot(int x, int y, int dx, int dy, int diam, color c) {
    mx=x; my=y; mdx=dx; mdy=dy; mdiam=diam; mcolor=c; 
  }
  
  public void update() {
    mx += mdx;
    if (mx < 0 || mx > 1280) 
      mdx = -mdx;
    my += mdy;
    if (my < 0 || my > 960)
      mdy = -mdy;
    
    fill(mcolor);  // rgba
    ellipse(mx, my, mdiam, mdiam);
  }
}
  