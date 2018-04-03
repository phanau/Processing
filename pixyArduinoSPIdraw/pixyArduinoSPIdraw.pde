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

void setup()
{
  size(768,600, P3D);
  pg = createGraphics(width,height);
  
  colors = new color[4];
  colors[1] = color(255, 0, 0);
  colors[2] = color(0, 255, 0);
  colors[3] = color(0, 0, 255);
  
  frameRate(60);  // slow down for testing
  
  // Open whatever port is the one you're using.
  String portName = Serial.list()[3]; //change to match your port
  println(portName);
  myPort = new Serial(this, portName, 230400);
  myPort.clear();   
}
 
void draw()
{ 

  String msg = " ";
  while (myPort.available() > 0) {
    msg = myPort.readStringUntil('\n');
    if (msg != null) {
      //print(msg);
      break;
    }
  }

  if (msg == null)
    return;
      
  String[] tokens = split(msg, ' ');
    
  pg.beginDraw();
  
  switch(state) {
    
    case WAITING_FOR_D:
      if (tokens[0].equals("D")) {
        count = int(tokens[1]);
        pg.clear();
        state = State.PROCESSING_B;
      }
      break;
    case PROCESSING_B:
      if (tokens[0].equals("B") && tokens.length == 6) {
        // parse and draw one block
        int sig = int(tokens[1]);
        float x = float(tokens[2])*scale;
        float y = float(tokens[3])*scale;
        float w = float(tokens[4])*scale;
        float h = float(tokens[5])*scale;
        pg.fill(colors[sig]);    // signature
        pg.ellipse(x, y, w, h);
      }
      else
      {
        state = State.WAITING_FOR_D;
      }
      break;
    default:
      println("error: bad State");
      break;
  }
  
  pg.endDraw();
   
  background(0);  // clear the display
  image(pg,0,0);
  
}
