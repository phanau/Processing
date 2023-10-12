import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;

import org.opencv.core.Point;

import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.CvType;

import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.highgui.HighGui;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;


OpenCV opencv;
ArrayList<Line> lines;

void erodeN(int n){
    for (int i=0; i<n; i++)
      opencv.erode();
}

//====================================================================

    Mat getCurrentMat(){
        if(opencv.getUseColor()){
          return opencv.matBGRA;
        } else{
          return opencv.matGray;
        }
    }
 
  ArrayList<Line> findLines(int threshold){
    ArrayList<Line> result = new ArrayList<Line>();
    
    Mat lineMat = new Mat();
    Imgproc.HoughLines(getCurrentMat(), lineMat, 1, PConstants.PI/180.0, threshold);
    //print("lineMat.width "); println(lineMat.width());
    //print("lineMat.height "); println(lineMat.height());
    //print("lineMat "); println(lineMat);
    for (int i = 0; i < lineMat.height(); i++) {
        double[] coords = lineMat.get(i, 0);    
        float rho = (float)coords[0]; float theta = (float)coords[1];
        print("rho="); print(rho); print("  theta="); println(theta);
        // theta += 0.1 * i;   // draw "fan" of lines around point
        double a = cos(theta); double b = sin(theta);
        double x0 = a*rho; double y0 = b*rho;
        int len = 10;
        Point pt1 = new Point(); pt1.x = (int)(x0 + len*(-b));  pt1.y = (int)(y0 + len*(a));
        Point pt2 = new Point(); pt2.x = (int)(x0 - len*(-b));  pt2.y = (int)(y0 - len*(a));
        result.add(new Line(pt1.x,pt1.y,pt2.x,pt2.y));
    }
    
    return result;
  }

  ArrayList<Line> findLinesP(int threshold, double minLineLength, double maxLineGap){
    ArrayList<Line> result = new ArrayList<Line>();
    
    Mat lineMat = new Mat();
    Imgproc.HoughLinesP(getCurrentMat(), lineMat, 1, PConstants.PI/180.0, threshold, minLineLength, maxLineGap);
    //print("lineMat.width "); println(lineMat.width());
    //print("lineMat.height "); println(lineMat.height());
    //print("lineMat "); println(lineMat);
    for (int i = 0; i < lineMat.height(); i++) {
        double[] coords = lineMat.get(i, 0);
        result.add(new Line(coords[0], coords[1], coords[2], coords[3]));
    }
    
    return result;
  }

//====================================================================

final int DUMPLINES = 3;

void setup() {
  size(796, 800);
}

float rotAngle = 0;

void draw() {
  
  // process latest frame
  PImage src = loadImage("test9.png");  // film_scan.jpg test1.png
  src.resize(0, 800);
  opencv = new OpenCV(this, src);
  
  // rotate the image by the current angle
  rotAngle += 0.5;
  
  Mat srcMat = getCurrentMat();
  //OpenCV.toCv(src, srcMat);
  
  Point center = new Point( srcMat.width()/2.0, srcMat.height()/2.0 );
  Mat rot_mat = Imgproc.getRotationMatrix2D( center, rotAngle, 1.0 );
  Mat rot_image_mat = new Mat();
  Imgproc.warpAffine( srcMat, rot_image_mat, rot_mat, srcMat.size() );

  //print(srcMat.width()); print(","); print(srcMat.height()); print(" "); println(srcMat);
  //print(rot_image_mat.width()); print(","); print(rot_image_mat.height()); print(" "); println(rot_image_mat);
  //print(rot_mat.width()); print(","); print(rot_mat.height()); print(" "); println(rot_mat);
  
  // restart OpenCV with rotated image
  PImage rotImage = new PImage(rot_image_mat.width(),rot_image_mat.height());
  opencv.toPImage(rot_image_mat, rotImage);
  //println(rotImage);
  opencv.loadImage(rotImage);
  
  // process the image for edge detection
  opencv.findCannyEdges(20, 75);

  // Find lines with Hough line detection
  // Arguments are: threshold, minLengthLength, maxLineGap
  //lines = findLines(40);
  lines = findLinesP(40, 10, 10);

  if ((DUMPLINES&1)!=0) {
    println(); print("lines:"); 
    if (lines != null)
        println(lines.size());
  }
  image(opencv.getOutput(), 0, 0);
  strokeWeight(3);
  stroke(0, 255, 255);

  for (Line line : lines) {
      line(line.start.x, line.start.y, line.end.x, line.end.y);
      if ((DUMPLINES&2)!=0) { 
        print(line.start.x); print(","); print(line.start.y); print("   \t"); 
        print(line.end.x); print(","); print(line.end.y); print("   \t");
        println(sqrt((line.start.x-line.end.x)*(line.start.x-line.end.x) + (line.start.y-line.end.y)*(line.start.y-line.end.y)));
      }
  }
}
