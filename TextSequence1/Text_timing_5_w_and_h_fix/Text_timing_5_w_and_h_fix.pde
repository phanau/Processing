// Experiment in Illegibility: Timing adjustments

/*    The text: This is what is in the text file in the data folder
We, the Global Studies Steering Committee, regret to inform you that after seven years of successful 
faculty development, student-focused programming, and contributions to faculty recruitment, retention, 
and diversity, the Provost and Dean of Faculty Patrick Spencer has unilaterally, and without consulting 
the Steering Committee or Global Studies Director, suspended the Global Studies Initiative for the 
2016-2017 academic year.  
*/


// Global variable(s)

int index = 0;   // Used near the end to count through the array and to know when to start over
int timer = 1000; // Gives the first word a head start so it can be seen the first time through.

//float alpha = map(mouseX,0,width, 0, 255);

void setup() {
  size(1270,500);       // Window size
  //size(500,500);        // For testing the textWidth constraint
  textAlign(CENTER);    // Centers the text on the coordinate where told to draw
  
  background(255);
  
}
  
  
void draw() {
  
  float alpha = map(mouseX,0,width, 0, 255);
  
  //background(255);  // Draws background again each time through draw to animate
  fill(255,alpha);
  rect(0,0,1270,500);

  
  // Create array of words from a text file
  String[] document = loadStrings("GSI_P_1.txt");   // Calls the text file from your data folder and loads it (by line breaks) into an array.
  String GSI = join(document, " ");   // joins together what would otherwise be each line in a different spot in an array into one long string
  String[] words = split(GSI, " ");   // splits paragraph (long single string) at spaces (" ") into different cells
    // Those last two steps are important especially if you have multiple paragraphs with line breaks.
    // This example code uses only one paragraph, but it's formatted for use with any text file.
  
  PFont font = loadFont("Monaco-150.vlw");
  
  fill(0);  // Set paragraph text color to black
  
  //textSize(150);   // Set font size  (remember to make this less than or equal to the size you set when creating the font)
  //float fontSize = map(mouseY,0,height, 150, 0);
  //textSize(fontSize);
  //textFont(font, fontSize);
  float fontSize = 150;       // 150 is a placeholder
  float maxSizeW = fontSize/textWidth(words[index]) * (width-20);         // maximum font size to fit in the frame width-wise with a bit of space
  float maxSizeH = fontSize/(textDescent()+textAscent() * (height-10));   // maximum font size to fit in the frame height-wise with a bit of space
          // Adapted from https://forum.processing.org/two/discussion/13105/how-to-make-a-string-of-any-length-fit-within-text-box
                 // See code at bottom in note for filling the screen
          // Make sure that space from top and bottom edge depends on ascenders and descenders + arbitrary space constant

  fontSize = (min(maxSizeW, maxSizeH));   // Reset fontSize to be the smaller of the two possible maximums for height and width
  textFont(font, fontSize); 

  // Draw Text
  text(words[index], width/2, (height/2)+30);  // Places text in middle of window.
  
  
  
  

  /*  // CHANGE BY TIME                         
  if (millis() - timer >= 500)   // use millis() and a timer to change the word every [# of milliseconds]
  {
    index ++;
    timer = millis();  // helps keep track of how much time has passed since last change
  }  */

  // CHANGE BY frameCount
  if (frameCount % 20 == 0)   // every nth frame
  {
    index ++;
    //timer = millis();  // helps keep track of how much time has passed since last change
  }
   
   
  // Show how much time has ellapsed
  textSize(18);
  text(millis()/1000 + " seconds have passed since the start", 250,50); 
  text("you are in frame: " + frameCount,250,85);

   
  // Restart paragraph from beginning.
  if(index == words.length)   // When index reaches the end of the text (length of array), start over
  {
    
            //frameRate(0.6);  // Adds a pause before restarting
    index = 0;       // Sets index back to 0 to start from the beginning of the text
  }  
}


/*  NOTES

*** = priority for digital humanities conference (end of internship)

Midi controller (0-128)
Hopefully not more than 8 controls

Sliders/Dials
  Speed
  Size
  Alpha
  Font (include Monaco as tribute to Heavy Industries)
  Grayscale or text vs background

Button pressed (boolean, 0 or 128)
  Restart from beginning (one-time reset)
  While pressed, make text red

Toggle (true/false, switches from on to off with each press)
   *** Pause
  Reverse black and white (immediate; priority over grayscale)
    Consider possible problems of what controls font color
    If above/below [threshold], turn to opposite 
  Disrupt linearity?
    Pull random words from array
    Later: scramble words (research how in arrays... arrays within arrays. String --> chars)
      Dyslexia vs. "bad spelling version" of a text... Look at common dyslexia and spelling mistakes


Additional thoughts:
  move? (change alignement or centering? Add noise/randomness to motion?)
  React to mouse 

  *** textWidth(str) calculates and returns the width of any character or text string. Use to keep words within bounds of the frame
  https://processing.org/reference/textWidth_.html
  
  Extended separate version: Make text fill window as much as possible:
  If maximum size for both width AND height (ascenders and descenders), then it will fill the screen as much as possible (keeping ratio)
    https://forum.processing.org/two/discussion/13105/how-to-make-a-string-of-any-length-fit-within-text-box
    
    EXAMPLE
      String str = "ABjgjhlkjlhlkhkl";
      // position and dimensions of the text-box
      int x =20;
      int y =20;
      int w = 200;
      int h = 60;
       
      void setup() {
        size(300, 150);
        // calculate minimum size to fit width
        float minSizeW = 12/textWidth(str) *w;
        // calculate minimum size to fit height
        float minSizeH = 12/(textDescent()+textAscent()) *h;
       
        textSize(min(minSizeW, minSizeH));
       
        noFill();
        rect(x, y, w, h);
       
        fill(0);
        text(str, x, y+h-textDescent());
      }

*/