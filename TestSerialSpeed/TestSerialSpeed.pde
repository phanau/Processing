
import processing.serial.*;
 
Serial myPort;

void setup() {
  size(400,400);
  
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 230400);
  
  // monitor size of available serial data
  int prev = myPort.available();
  for (int i=0; ; i++) {
    int curr = myPort.available();
    int T = millis();
    int delta = curr-prev;
    if (delta != 0){
      print("i="); print(i); print("  T="); print(T); print("  B="); print(curr); print("  dB=");println(delta);
    }
    prev = curr;
  }
  
}


