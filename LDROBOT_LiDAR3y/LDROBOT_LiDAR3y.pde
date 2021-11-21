
import processing.serial.*;
 
Serial myPort;

// This is a simple program for reading and plotting data from the LD-19 LiDAR.
// Serial data appears to be added to the input buffer in blocks of 250 bytes.
// If we try to process everything we get way behind, so we discard excess data from
// the input buffer after processing each packet and then try to re-sync to the
// stream next time.

public class Packet {
  public int mSpeed;
  public float mStartAngle;
  public float mEndAngle;
  public int[] mDistances;
  public int[] mConfidences;
  public int mChecksumByte;
  public int mTimestamp;
  public int mComputedChecksum;
};

boolean TRACE = false;

void setup() {
  size(400,400);

  // List all the available serial ports
  printArray(Serial.list());
  
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 230400);
}

void draw() { 
  //println("begin Draw"); 
  
  int avail = myPort.available();
  final int TARGET = 100;    // target amount of buffered data
  if (avail < TARGET) {
    if (TRACE) { print(" D:"); print(avail); print("<"); print(TARGET); print(" "); }
    return;
  }
 
  // get a packet
  FindSync();
  Packet p = GetPacket();
  
  // simple progress indicator xor full dump
  boolean simple = true;
  if (simple)
    print("*");
  else
    DumpPacket(p);
  
  // periodically clear the screen
  if (frameCount % 200 == 0) {
    background(204);
  }
  
  DrawReticle();  
  PlotPacket(p);
    
  // make sure we don't get too far behind 
  final int BEHIND = 500;  // this much is too much backlog
  avail = myPort.available();
  if (avail > BEHIND) {
    if (TRACE) { print(" B:"); print(avail); print(">"); print(BEHIND); print(" "); }
    while(myPort.available() > BEHIND)
      myPort.read();
  }
 
  //println();println("end Draw");
}

// draw a reticle
void DrawReticle() {
  strokeWeight(1);
  stroke(0x04000000);
  noFill();
  line(width/2,0,width/2,height);
  line(0,height/2,width,height/2);
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  ellipse(width/2,height/2,width/2, height/2);
  ellipse(width/2,height/2,width/4, height/4);
  ellipse(width/2,height/2,width/8, height/8);
  ellipse(width/2,height/2,3*width/8, 3*height/8);
}

// discard data until we read a SYNC byte - return count of discarded bytes
int WaitForSyncByte() {
  // discard and count data bytes while waiting for a start of packet sync character
  boolean sync = false;
  int count = 0;
  do {
    while (myPort.available() < 1);  // wait for valid data
    sync = (myPort.read() == (byte)0x54);  // test for sync byte
    if (!sync) count++;
  } while (!sync);
  return count; 
}

void FindSync() {
  // since we may start reading data in the middle of a packet, and we may encounter what
  // appears to be a sync character anywhere within a data packet, we have to make sure we're
  // actually "in sync" by looking for several sync characters the right distance apart.
  // currently, all packets have 12 data points, so there are 46 bytes between real sync bytes:
  //  46 bytes = 12 data points @ 3 bytes each + 10 bytes of other data and the CRC

  // discard data until we get two SYNC bytes the right distance apart in the stream
  int delta = 0;
  do {
    delta = WaitForSyncByte();
  } while (delta != 46);  // (delta != 0 && delta != 46);
    
}

int unsignedInt(byte low, byte high) {
    int uLow = low&0xff;
    int uHigh = high&0xff;
    int a = uLow + 256*uHigh;
    return a;
}

// get one packet of data assuming we've just read a SYNC byte
Packet GetPacket() {
  Packet p = new Packet();
  
  // get packet data length byte
  while (myPort.available() < 1);
  int dataLength = myPort.read(); 
  int numPoints = dataLength & (byte)0x1F;  // LS 5 bits
  int packetLen = numPoints*3 + 8;  // NOT counting Start, DataLen, and Checksum
  
  // wait for the rest of the packet data
  while (myPort.available() < packetLen+1)
  { 
    if (TRACE) { print(" G:"); print(myPort.available()); print("<"); print(packetLen+1); print(" "); } 
    delay(10); 
  }

  // put the packet data including Start and DataLen bytes but NOT Checksum into a byte array
  byte[] data = new byte[packetLen+2];
  data[0] = 0x54;    // Sync byte
  data[1] = (byte)dataLength;
  
  for (int i=2; i<packetLen+2; i++) {
    while (myPort.available() < 1);
    data[i] = (byte)myPort.read();
  }

  // get checksum
  while (myPort.available() < 1);
  p.mChecksumByte = myPort.read();

  // compute the checksum of the packet up to but NOT including the checksum byte
  p.mComputedChecksum = CalCRC8(data);
  
  // get Radar Speed
  p.mSpeed = unsignedInt(data[2],data[3]);

  // get Start Angle
  p.mStartAngle = unsignedInt(data[4],data[5])/100.0;
    
  // create data arrays
  p.mDistances = new int[numPoints];
  p.mConfidences = new int[numPoints];
  
  // get the data points
  for (int i=0; i<numPoints; i++) {
    p.mDistances[i] = unsignedInt(data[3*i+6],data[3*i+7]);
    //p.mDistances[i] = (int)p.mStartAngle*5; // uncomment this to test graphics
    p.mConfidences[i] = unsignedInt(data[3*i+8],(byte)0);
  }
  
  // get End Angle
  p.mEndAngle = unsignedInt(data[3*numPoints+6],data[3*numPoints+7])/100.0;
 
  // get Timestamp
  p.mTimestamp = unsignedInt(data[3*numPoints+8],data[3*numPoints+9]);
  
  return p;
}

static color[] colors = { #7F0000, #007F00, #00007F, #000000 };
static int colorIx = 0;

void PlotPacket(Packet p) {
  stroke(colors[colorIx]);
  colorIx++; if (colorIx == colors.length) colorIx = 0;
  
  float maxDistance = 2000.0;  // mm
  translate(width/2, height/2);
  //rotate(PI/2);    // rotate display to match sensor orientation
  scale((width/2)/maxDistance, (height/2)/maxDistance);
  strokeWeight(maxDistance/100);
  
  for (int i=0; i<p.mDistances.length; i++){
    float angle = GetAngle(p,i);
    int x = (int)(p.mDistances[i]*sin(angle*TWO_PI/360.0));
    int y = (int)(-p.mDistances[i]*cos(angle*TWO_PI/360.0));
    if (p.mConfidences[i] > 100 && angle > 0)
      point(x,y);
  }
  
}


void DumpPacket(Packet p) {
  println();println("==========================================");
  print ("available bytes: "); println(myPort.available());
  print ("ChecksumByte: "); print(p.mChecksumByte);
  print ("  ComputedChecksum: "); println(p.mComputedChecksum);
  print ("Radar Speed: "); println(p.mSpeed);
  print ("Start Angle: "); println(p.mStartAngle);
  print ("End Angle: "); println(p.mEndAngle);
  int numPoints = p.mDistances.length;
  print ("numPoints: "); println(numPoints);
  if (numPoints > 1) {
  for (int i=0; i<numPoints; i++) {
    print("distance: "); print(p.mDistances[i]);
    print("  angle: "); print(GetAngle(p,i));
    print("  confidence: "); println(p.mConfidences[i]);
  }
  print ("Timestamp: "); println(p.mTimestamp);
  }
}

// compute angle in degrees of ith point of Packet p
float GetAngle(Packet p, int i) {
    float step;
    int numPoints = p.mDistances.length;
    if(p.mEndAngle > p.mStartAngle)
      step = (p.mEndAngle - p.mStartAngle)/(numPoints - 1);
    else
      step = (p.mEndAngle + 360.0 - p.mStartAngle)/(numPoints - 1);
         
    float angle = (p.mStartAngle + step*i);
    if (step > 2.0) // bogus
       angle = -1;
    return angle;
}


private final static byte[] CrcTable = {
(byte)0x00, (byte)0x4d, (byte)0x9a, (byte)0xd7, (byte)0x79, (byte)0x34, (byte)0xe3, (byte)0xae, 
(byte)0xf2, (byte)0xbf, (byte)0x68, (byte)0x25, (byte)0x8b, (byte)0xc6, (byte)0x11, (byte)0x5c, 
(byte)0xa9, (byte)0xe4, (byte)0x33, (byte)0x7e, (byte)0xd0, (byte)0x9d, (byte)0x4a, (byte)0x07, 
(byte)0x5b, (byte)0x16, (byte)0xc1, (byte)0x8c, (byte)0x22, (byte)0x6f, (byte)0xb8, (byte)0xf5, 
(byte)0x1f, (byte)0x52, (byte)0x85, (byte)0xc8, (byte)0x66, (byte)0x2b, (byte)0xfc, (byte)0xb1, 
(byte)0xed, (byte)0xa0, (byte)0x77, (byte)0x3a, (byte)0x94, (byte)0xd9, (byte)0x0e, (byte)0x43, 
(byte)0xb6, (byte)0xfb, (byte)0x2c, (byte)0x61, (byte)0xcf, (byte)0x82, (byte)0x55, (byte)0x18, 
(byte)0x44, (byte)0x09, (byte)0xde, (byte)0x93, (byte)0x3d, (byte)0x70, (byte)0xa7, (byte)0xea, 
(byte)0x3e, (byte)0x73, (byte)0xa4, (byte)0xe9, (byte)0x47, (byte)0x0a, (byte)0xdd, (byte)0x90, 
(byte)0xcc, (byte)0x81, (byte)0x56, (byte)0x1b, (byte)0xb5, (byte)0xf8, (byte)0x2f, (byte)0x62, 
(byte)0x97, (byte)0xda, (byte)0x0d, (byte)0x40, (byte)0xee, (byte)0xa3, (byte)0x74, (byte)0x39, 
(byte)0x65, (byte)0x28, (byte)0xff, (byte)0xb2, (byte)0x1c, (byte)0x51, (byte)0x86, (byte)0xcb, 
(byte)0x21, (byte)0x6c, (byte)0xbb, (byte)0xf6, (byte)0x58, (byte)0x15, (byte)0xc2, (byte)0x8f, 
(byte)0xd3, (byte)0x9e, (byte)0x49, (byte)0x04, (byte)0xaa, (byte)0xe7, (byte)0x30, (byte)0x7d, 
(byte)0x88, (byte)0xc5, (byte)0x12, (byte)0x5f, (byte)0xf1, (byte)0xbc, (byte)0x6b, (byte)0x26, 
(byte)0x7a, (byte)0x37, (byte)0xe0, (byte)0xad, (byte)0x03, (byte)0x4e, (byte)0x99, (byte)0xd4, 
(byte)0x7c, (byte)0x31, (byte)0xe6, (byte)0xab, (byte)0x05, (byte)0x48, (byte)0x9f, (byte)0xd2, 
(byte)0x8e, (byte)0xc3, (byte)0x14, (byte)0x59, (byte)0xf7, (byte)0xba, (byte)0x6d, (byte)0x20,
(byte)0xd5, (byte)0x98, (byte)0x4f, (byte)0x02, (byte)0xac, (byte)0xe1, (byte)0x36, (byte)0x7b, 
(byte)0x27, (byte)0x6a, (byte)0xbd, (byte)0xf0, (byte)0x5e, (byte)0x13, (byte)0xc4, (byte)0x89, 
(byte)0x63, (byte)0x2e, (byte)0xf9, (byte)0xb4, (byte)0x1a, (byte)0x57, (byte)0x80, (byte)0xcd, 
(byte)0x91, (byte)0xdc, (byte)0x0b, (byte)0x46, (byte)0xe8, (byte)0xa5, (byte)0x72, (byte)0x3f, 
(byte)0xca, (byte)0x87, (byte)0x50, (byte)0x1d, (byte)0xb3, (byte)0xfe, (byte)0x29, (byte)0x64, 
(byte)0x38, (byte)0x75, (byte)0xa2, (byte)0xef, (byte)0x41, (byte)0x0c, (byte)0xdb, (byte)0x96, 
(byte)0x42, (byte)0x0f, (byte)0xd8, (byte)0x95, (byte)0x3b, (byte)0x76, (byte)0xa1, (byte)0xec, 
(byte)0xb0, (byte)0xfd, (byte)0x2a, (byte)0x67, (byte)0xc9, (byte)0x84, (byte)0x53, (byte)0x1e, 
(byte)0xeb, (byte)0xa6, (byte)0x71, (byte)0x3c, (byte)0x92, (byte)0xdf, (byte)0x08, (byte)0x45, 
(byte)0x19, (byte)0x54, (byte)0x83, (byte)0xce, (byte)0x60, (byte)0x2d, (byte)0xfa, (byte)0xb7, 
(byte)0x5d, (byte)0x10, (byte)0xc7, (byte)0x8a, (byte)0x24, (byte)0x69, (byte)0xbe, (byte)0xf3, 
(byte)0xaf, (byte)0xe2, (byte)0x35, (byte)0x78, (byte)0xd6, (byte)0x9b, (byte)0x4c, (byte)0x01, 
(byte)0xf4, (byte)0xb9, (byte)0x6e, (byte)0x23, (byte)0x8d, (byte)0xc0, (byte)0x17, (byte)0x5a, 
(byte)0x06, (byte)0x4b, (byte)0x9c, (byte)0xd1, (byte)0x7f, (byte)0x32, (byte)0xe5, (byte)0xa8
};


static int CalCRC8(byte[] p) {
  int crc = 0;
  for (int i = 0; i < p.length; i++) {
    crc = CrcTable[(crc ^ p[i]) & 0xFF] & 0xFF; 
  }
  return crc; 
}




