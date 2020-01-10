// remove IVY watermark from picture
// this is java code

class Rect {
  public int mX, mY, mW, mH;

  public Rect(int x, int y, int x2, int y2)
  { mX = x; mY = y; mW = x2-x; mH = y2-y; }
  
  public Rect scaled(float s)
  {
    Rect r = new Rect(0,0,0,0);
    r.mX = Math.round(mX*s); r.mY = Math.round(mY*s); r.mW = Math.round(mW*s); r.mH = Math.round(mH*s);
    return r;
  }
}

PImage img, result;

// remove the watermark wm from the image img ---
// assume the watermark was added by doing a transparency mix: img' = (1-alpha)*img + alpha*wm
// so, img = (img' - alpha*wm)/(1 - alpha)
PImage removeWatermark(PImage img, Rect imgRect, PImage wm, Rect wmRect, float alpha) {
  PImage result = img.copy();
  for (int y=0; y<imgRect.mH; y++) {
    for (int x=0; x<imgRect.mW; x++) {
      // get RGB of image pixel
      color imgC = img.get(imgRect.mX+x, imgRect.mY+y);
      float imgR = red(imgC);
      float imgG = green(imgC);
      float imgB = blue(imgC);
      // get RGB of watermark pixel
      color wmC = img.get(wmRect.mX+x, wmRect.mY+y);
      float wmR = red(wmC);
      float wmG = green(wmC);
      float wmB = blue(wmC);
      // compute image pixel with watermark removed
      float iwrR = (imgR-alpha*wmR)/(1-alpha);
      float iwrG = (imgG-alpha*wmG)/(1-alpha);
      float iwrB = (imgB-alpha*wmB)/(1-alpha);
      color iwrC = color(iwrR, iwrG, iwrB);
      result.set(imgRect.mX+x, imgRect.mY+y, iwrC);
    }
  }
  return result;
}


void setup() {
  size(1280,720);
  colorMode(RGB, 255);
  
  // read the source image
  img = loadImage("LEP.png");
  Rect imgR = new Rect(391,210, 847,715);  // ul, lr
  
  // read the watermark image
  PImage wm = loadImage("IVY.png");
  Rect wmR = new Rect(41,61, 354,373);  // ul, lr
  
  // scale the watermark image to match its size in the source image
  wm.resize(wm.width*imgR.mW/wmR.mW, wm.height*imgR.mH/wmR.mH);
  
  // make a new Rect describing the extents of the watermark in the scaled watermark image
  Rect wmRs = wmR.scaled((float)imgR.mW/(float)wmR.mW);
  
  // construct an image that removes the watermark image from the source image
  float alpha = 0.4f;
  result = removeWatermark(img, imgR, wm, wmRs, alpha);
  
  // save result
  result.save("result.jpg");
}

int seconds() {
  return millis()/1000;
}

void draw() {
  background(0);
  
  if (seconds()%3 == 0)
    image(img,0,0);
  else
    image(result,0,0);    

}
