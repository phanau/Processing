
import processing.serial.*;
 
Serial myPort;

void setup() {
  size(400,400);
  
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 230400);
}

void draw() {
  // monitor size of available serial data
  int prevA = myPort.available();
  int prevT = millis();
  for (int i=0; ; i++) {
    int currA = myPort.available();
    int currT = millis();
    int deltaA = currA-prevA;
    int deltaT = currT-prevT;
    if (deltaA != 0 && deltaT != 0){
      int rate = deltaA*1000/deltaT;
      print("i="); print(i); print("  T="); print(currT); print(  "  dT="); print(deltaT); print("  Avail="); print(currA); print("  dAvail="); print(deltaA); print("  B/sec="); println(rate);
      prevA = currA;
      prevT = currT;
    }
  }
  
}



