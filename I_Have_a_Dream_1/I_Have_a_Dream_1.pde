import processing.video.*;


/*
 Make civil rights text videos --- Have them be revealed by MLK video (transparent)
   Separate by sentences... or meaningful chunks. Figure out timing.
   White words on black and vise versa? Different colors? 
  
 Use screen capture to make one into something that can be masked by the camera? Or by video?
 INTERACTIVE OR NOT?

Another version/experiment: Layer a text video/just the text running under a civil rights video masked by the camera


Make an array of relevant lines from MLK's speech, and up randomly... 
can I get them to fade back? Scatter randomly (position between sets of coordinates)

Fading: add semi-transparent background layers after each addition of a quote...
Smoothness: add a quote every five lines?
For (iterate one by one)
  Place a low-opacity layer down
  If (iteration number is divisible by 5/10/?)
         place a line at a random location

Have an array of hash tags too, lines from today
#BlackLivesMatter
#ICantBreathe  
#HandsUpDontShoot
#Ferguson

Play semi transparent MLK video over text...



Get live tweets with the hashtag?
*/

int speechIndex = 0;
int hashIndex = 0;
int cycleCounter = 0;

String[] lines;
String[] hashtagList;

PFont modernFont;
PFont MLK_font;

void setup() {
  
  size(1280,800);    // captured vid = 764 x 564
  //fullScreen(1);
  textAlign(CENTER);
  background(200);
  
  // MLK lines array
  String[] document = loadStrings("starting_lines.txt");
  String speech = join(document, "_"); // joins together what would otherwise be each line in a different spot in an array into one long string
  lines = split(speech, "_");   // splits paragraph (long single string) at underscores into diff cells
  
  // Modern hanshtags array
  String[] hashtagDoc = loadStrings("Modern_lines.txt");
  String list = join(hashtagDoc, "_"); // joins together what would otherwise be each line in a different spot in an array into one long string
  hashtagList = split(list, "_");   // splits paragraph (long single string) at underscores into diff cells
  
  modernFont = loadFont("AdobeGothicStd-Bold-80.vlw");
  MLK_font = loadFont("AmericanTypewriter-80.vlw");
}
  

void draw() {
  
  // Set frame rate
  // Could also be done in setup() and then again at the end of the if statement to restart at the end (in draw())
  float normFrameRate = 30;
  frameRate(normFrameRate); //Reset to normal framerate after restarting each time through  
  
  // Fading into BG
  if(cycleCounter%7 > 3)   // slow down fading of newly minted text
  {
    fill(255, 10);
    rect(0, 0, width, height);  
  }
  
  cycleCounter++;     
  if(cycleCounter%7 == 0)   // slow down the printing of speech text, every n'th frame
  {
  
    fill(0);  // Set text color to black
    textFont(MLK_font);
    textSize(random(10, 70));
    text(lines[speechIndex], random(150, 1200), random(60, 750));
    speechIndex++;
          
    // Restart speech from beginning.
    if(speechIndex == lines.length)   // When index reaches end of paragraph (length of array), start over
    {
      speechIndex = 0;
    }
  }                     
    
  if(cycleCounter%14 == 0)   // slow down the printing of hashtags, every n'th frame
  {
    fill(0);  // Set text color to black
    textFont(modernFont);
    textSize(random(10, 50));          
    text(hashtagList[hashIndex], random(150, 1200), random(60, 750));
    hashIndex++;
    
    // Restart hashtag list from beginning.
    if(hashIndex == hashtagList.length)   // When index reaches end of paragraph (length of array), start over
    {
      hashIndex = 0;
    }  
  }
  
  if (keyPressed) {
    if (key == 's')
      saveFrame("frames/#####.jpg");
  }
}