// a simple test program for LIDAR on Arduino
// read bytes from the LIDAR on Serial1 and echo them to the serial monitor on Serial(0)
// start a new output line whenever we see what looks like a start packet byte followed by a length (12)


import processing.serial.*;
 
Serial myPort;

void setup() {
  size(200,200);

  // List all the available serial ports
  printArray(Serial.list());
  
  // Open the first port that works at the rate you want:
  for (int i=0; i<Serial.list().length; i++) {
    if ((myPort = new Serial(this, Serial.list()[13], 230400))!=null){
      println("using Port["+i+"]");
      return;
    }
  }
}

char hex[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

void printHex(int b) {
    int hi = (b>>4)&0xF;
    int lo = b&0xF;
    print(hex[hi]); print(hex[lo]);
}

int packetCount = 0;

void draw() {
  // drain the backup
  while (myPort.available() > 100)
    myPort.read();
  
  // search for and echo the next sync byte
  while (myPort.read() != 0x54);
  println(); print('['); print(myPort.available()); print(']');
  printHex(0x54);
  
  // read and echo the rest of the packet
  if (myPort.available() >= 46) {
    for (int i=0; i<46; i++) {
      printHex(myPort.read());
    }
  }
}
