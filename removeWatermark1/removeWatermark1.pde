// align two frames from NY Phil archive and remove watermarks

PImage img, img1, img2;

// find the UL corner of the gray background in image
PImage findULcorner(PImage img) {
  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {
      color c = img.get(x,y);
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      if (r > 180 && g > 180 && b > 180) {
        println("["+x+","+y+"] "+r+","+g+","+b);
        return img.get(x,y,img.width-x,img.height-y);
      }
    }
  }
  return null;
}

boolean isWatermark(color c) {
  color wmk = #737473;
  return (Math.abs(red(c)-red(wmk)) + Math.abs(green(c)-green(wmk)) + Math.abs(blue(c)-blue(wmk)) < 10);
}

boolean isWatermarkNear(PImage img, int x, int y) {
  for (int dy=-1; dy<2; dy++) {
    for (int dx=-1; dx<2; dx++) {
      if (isWatermark(img.get(x+dx,y+dy)))
        return true;
    }
  }
  return false;
}

PImage mergeImages(PImage img1, PImage img2) {
  PImage img = img1.copy();
  int w = Math.min(img1.width, img2.width);
  int h = Math.min(img1.height, img2.height);
  //println("merge: w=" + w + ", h=" + h);
  for (int y=0; y<h; y++) {
    for (int x=0; x<w; x++) {
      if (isWatermarkNear(img1,x,y)) {
        img.set(x,y, img2.get(x,y));
        //println("merge: x="+x + ", y=" + y);
      }
    }
  }
  return img;
}


void setup() {
  size(1280,720);
  colorMode(RGB, 255);
  
  // read the two images
  String path1 = "image1.png";
  String path2 = "image2.png";
  PImage im1 = loadImage(path1);
  img1 = findULcorner(im1);
  PImage im2 = loadImage(path2);
  img2 = findULcorner(im2);
  
  // construct an image that merges img1 and img2 to remove watermark of known color
  img = mergeImages(img1, img2);
  
  // save result
  img.save("result.jpg");
}

int seconds() {
  return millis()/1000;
}

void draw() {
  background(0);
  
  if (seconds()%3 == 0)
    image(img1,0,0);
  else
  if (seconds()%3 == 1)
    image(img2,0,0);
  else
    image(img,0,0);    

}
