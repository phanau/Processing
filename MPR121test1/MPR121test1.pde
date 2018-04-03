// Set up libraries
import processing.video.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
    
void setup()
{
  size(750,580, P3D);
  
  // Open whatever port is the one you're using.
    String portName = Serial.list()[3]; //change to match your port
    println(portName);
    myPort = new Serial(this, portName, 9600);
    // Add in later: sync message, wait for Arduino to send a character
    myPort.readStringUntil('\n');         // read it and throw it away

}
 
void draw()
{ 
     if(myPort.available() > 0) // if --> one data point at a time in format "x:53\n"
     {  // If data is available,
        String val = myPort.readStringUntil('\n');         // read it and store it in val
        if(val != null)   
        {
          //print("input: "+val); //print it out in the console. 
          int[] nums = int(split(val, ' '));
          
          print("values:");
          for (int n : nums){
            print(n); print(", ");
          }
          println("");
        }
      }

}
