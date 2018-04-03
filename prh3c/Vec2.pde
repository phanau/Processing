
public class Vec2 {
  public float mx, my;
  
  Vec2(float x, float y) {
    mx = x; my = y;
  }
  Vec2(Vec2 v) {
    mx = v.mx; my = v.my;
  }
  Vec2 add(Vec2 v) {
    return new Vec2(mx+v.mx, my+v.my);
  }
  Vec2 sub(Vec2 v) {
    return new Vec2(mx-v.mx, my-v.my);
  }
  Vec2 mult(float s) {
    return new Vec2(mx*s, my*s);
  }
  float dot(Vec2 v) {
    return (mx*v.mx + my*v.my);
  }
  float magn() {
    return sqrt(magn2());
  }
  float magn2() {
    return this.dot(this);
  }
  Vec2 norm() {
    return new Vec2(this.mult(1.0/this.magn()));
  }
}