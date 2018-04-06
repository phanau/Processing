// Set up libraries
import processing.video.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
color colors[];
enum State { WAITING_FOR_D, PROCESSING_B }

State state = State.WAITING_FOR_D;
int count = 0;

float scale = 3.0;

PGraphics pg;

long loopTime;

void setup()
{
  size(768,600, P3D);
  pg = createGraphics(width,height);
  
  colors = new color[5];
  colors[1] = color(255, 0, 0);
  colors[2] = color(0, 255, 0);
  colors[3] = color(0, 0, 255);
  colors[4] = color(255, 255, 0);
  
  frameRate(50);  // match PixyCam frame rate
  
  // Open whatever port is the one you're using.
  String portName = Serial.list()[3]; //change to match your port
  println(portName);
  myPort = new Serial(this, portName, 230400);
  myPort.clear();  
  
  loopTime = System.currentTimeMillis();
}
 
void draw()
{ 
  String msg = "";

  // get input message, if any is available
  while (myPort.available() > 0) {
    msg = myPort.readStringUntil('\n');
    if (msg != null) {
      break;
    }
  }

  if (msg.length() == 0) {
    println("no msg");
    return;
  }
   
  print(msg);
  
  // split the message into tokens separated by spaces
  String[] tokens = split(msg, ' ');
    
  pg.beginDraw();
  
  for (int tix = 0; tix < tokens.length;) {
    
      if (tokens[tix].equals("D")) {
        tix++;
        count = int(tokens[tix]);
        pg.clear();
        state = State.PROCESSING_B;
      }
      else
      if (tokens[tix].equals("B")) {
        // parse and draw one block
        int sig = int(tokens[tix+1]);
        float x = float(tokens[tix+2])*scale;
        float y = float(tokens[tix+3])*scale;
        float w = float(tokens[tix+4])*scale;
        float h = float(tokens[tix+5])*scale;
        tix += 6;
        pg.fill(colors[sig]);    // signature
        pg.ellipse(x, y, w, h);
      }
      else 
      if (tokens[tix].equals("E")) {
        myPort.write("E");  // send ACK to Arduino
        tix++;
      }
      else
        tix++;
    
  }
  
  pg.endDraw();
    
  long now = System.currentTimeMillis();

  background(0);  // clear the display
  image(pg,0,0);

  text(now - loopTime, 20, 50);
  loopTime = now;

}
