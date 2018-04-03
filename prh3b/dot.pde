
class dot {
  Vec2 mPos;      // position 
  Vec2 mVel;      // velocity
  float mdiam;       // diameter 
  color mcolor;      // color  
  
  public dot(Vec2 pos, Vec2 vel, float diam, color c) {
    mPos = pos; mVel = vel; mdiam=diam; mcolor=c; 
  }
  
  public void update(Vec2 c) {
    mVel = mVel.add(gravAccel(c));
    mPos = mPos.add(mVel);
    final float Ksquish = 1.0;
    if (mPos.mx < 0 || mPos.mx > 1280) 
      mVel.mx *= (-1.0 * Ksquish);
    if (mPos.my < 0 || mPos.my > 960) 
      mVel.my *= (-1.0 * Ksquish);
    fill(mcolor);  // rgba
    ellipse(mPos.mx, mPos.my, mdiam, mdiam);
  }
  
  float dist2(Vec2 p, Vec2 c) {
    return (c.sub(p)).magn2();
  }
  
  Vec2 gravAccel(Vec2 c) {
    Vec2 g = c.sub(mPos);
    float d2 = g.magn2();
    if (d2 < 100) return new Vec2(0,0);
    Vec2 dNorm = g.norm();
    final float Kgrav = 1000;
    return dNorm.mult(Kgrav/d2);
  }
    
  public float velocity() {
    return mVel.magn();
  }
}