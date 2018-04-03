// Experiment in Illegibility: Connected to Midi
  // The text: See text document inside of data folder
  
// Turn knobs/dials to max value before starting


/*  Change log:

  For efficiency: Moved font array and text array into global (and setup). Declared variables in global so they're shared 
  in setup and draw when needed. (document and joinLines are local in setup because they're only used there.)
  Too expensive to declare every time in the draw loop.
  
  Now so efficient I had to increase the speed range to slow it down!
      Alpha: 255 alpha at this speed it WAY too powerful, wipes things out 'til they can't be seen.

  Changed index to wordIndex
  Added fontIndex to iterate through font list (at speed independent of word change speed)
  
  Moved text wrap around check to main draw part (rather than at the end)
  
  Moved textFont calls around so the ascenders and descenders work with whatever window size

  Maybe reconsider use of Wingdings?

*/


// Global variables  
 
import themidibus.*;
float cc[] = new float[256];
MidiBus myBus;

int wordIndex = 0;
int fontIndex = 0;
String[] words;
PFont[] fonts;
int timer = 1000; // Gives the first word a head start so it can be seen the first time through.


void setup() {
  //fullScreen();
  //size(1270,500);
  frameRate(30);  // To limit
  size(500,500);
  textAlign(CENTER, CENTER);
  background(255);
  noStroke();
  //frameRate(30);  // Set to above 60 (or 30 for vid) when you want it to go faster than one change each frame (frameCount can't be fractional)
  
  // Setting up midi controller
  MidiBus.list();  // Shows controllers in the console
  myBus = new MidiBus(this, "SLIDER/KNOB","CTRL");  // input and output
  
  for (int i = 0; i < cc.length; i++) {
    cc[i] = 127;
  }
  
  // Create array of words from a text file
  String[] document = loadStrings("Tao.txt");   // Calls the text file from your data folder and loads it (by line breaks) into an array.
  String joinLines = join(document, " ");   // joins together what would otherwise be each line in a different spot in an array into one long string
  words = split(joinLines, " ");   // splits paragraph (long single string) at spaces (" ") into different cells


  // Array of font names
  String[] fontNames = {"Monaco-500.vlw", "OCRAStd-500.vlw", "Impact-500.vlw", "Helvetica-500.vlw", "Palatino-Roman-500.vlw",
                      "Wingdings2-500.vlw", "SynchroLET-500.vlw"};

  // Array of actual fonts, loaded using names in array above
  fonts = new PFont[fontNames.length];   // Make its size match the # of fonts

  // Loads all the fonts into the array
  for (int i = 0; i < fontNames.length; i++) {
    fonts[i] = loadFont(fontNames[i]);
  }  
}
  
  
void draw() {
  
// ORGANIZATION?:
  // Should we keep these midi controls together here, put the controls where they are implemented (i.e. speed below w/ speed setting), or make objects?

// --------------------
// ALPHA CONTROL: for fade  
  float alphaControl = map(cc[16],0,127,0,100);  // reduced from 255 to 100 because of faster refresh rate
  fill(255,alphaControl);  // fills screen-sized rectangle (below) with white w/ opacity determined by midi
  rect(0,0,width,height);
// --------------------
// SPEED CONTROL: how often to change the word (if (frameCount % speed == 0...)) 
  int speedControl = round(map(cc[17],0,127,500,10));  // Shouldn't be float b/c % 0
// --------------------
// TEXT BOX SIZE CONTROL: how much of the screen text should take up (in box)
  float boxSizeControl = map(cc[18],0,127,0.1,1);
// --------------------
// MAX SIZE CONTROL: changing the biggest font sizes to match b/w short and long words
      // The fraction of the screen height to allow the font to be (if short word)
  float fontSizeControl = map(cc[19],0,127,0.1,1);
// --------------------
// FONT SELECTION
  int fontSpeedControl = round(map(cc[20],0,127,500,10)); 
// --------------------


  // Put dyslexic scrambler in function/object because it's messy.
          // Could set scramble strength in a scramble class
  // Only make functions/objects for things that are long and have a lot of data... 
          // Easy ones (speed, box size, etc) can stay here.
  
  //PFont font = loadFont("Monaco-500.vlw");
  fill(0);
  
  // Change font every f'th frame
  if (frameCount % fontSpeedControl == 0) {
    fontIndex++;  // move to next font
    
    // Restart font array
    if(fontIndex == fonts.length)
      fontIndex = 0;     
  }
  
  // CHANGE BY frameCount
  if (frameCount % speedControl == 0) {     // every n'th frame
    float fontSize = 100;   // arbitrary, just for calculating correct size below
    textFont(fonts[fontIndex], fontSize);   // Tell the computer that size for the following calculations
    float maxSizeW = fontSize/textWidth(words[wordIndex]) * (width*boxSizeControl);
    float maxSizeH = fontSize/(textDescent()+textAscent()) * (height*boxSizeControl);
  
    fontSize = (min(maxSizeW, maxSizeH));   // Reset fontSize to be the smaller of the two possible maximums for height and width
    fontSize = min(fontSize, fontSizeControl*height*boxSizeControl);
    textSize(fontSize);
    
    text(words[wordIndex], width/2, (height/2)-50);  // Draws text in middle of window.
    wordIndex ++;  // advance one word
    
    // Check if it's time to restart text from beginning
    if(wordIndex == words.length)
      wordIndex = 0;  
  }
  
  /*  // CHANGE BY TIME                         
  if (millis() - timer >= 500)   // use millis() and a timer to change the word every [# of milliseconds]
  {
    index ++;
    timer = millis();  // helps keep track of how much time has passed since last change
  }  */

   
  // Show how much time has ellapsed
      // Clean up with white background box
      // Call this function only when a button is pressed
  textSize(18);
  text(millis()/1000 + " seconds have passed since the start", 250,50); 
  text("you are in frame: " + frameCount,250,85);
   
}

                       // midi #  (ex:) knob #    # from knob, mapped to be b/w 0 and 1
  void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  println("Frame rate:"+frameRate);
  //this.value = value;       // "this" refers (in Porcessing) to variables in the global space if this function is in the global space
  //this.number = number;     // Took these out b/c not reliable (mixed tutorials badly)
  //cc[number] = map(value, 0, 127, 0, 1);
  cc[number] = value;  // saves the midi output # to be converted later for what we need
}

boolean pauseToggle = true;

void keyPressed() {
   if (key == 'p' || key == 'P') {  // PAUSE
     if (pauseToggle) { noLoop(); pauseToggle = false; }
     else { loop(); pauseToggle = true; }
  }
  
   if (key == 'r' || key == 'R') {  // RESTART
     wordIndex = 0; }
  
}