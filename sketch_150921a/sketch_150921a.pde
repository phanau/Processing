int x = 0;
int y = 0;
void setup(){
  size(700,700);
  frameRate(15);
}

void draw(){
  background(mouseX,mouseY,mouseY);  // BG color changes w/ mouse position
  noStroke();
       
// Red loop
  for (x = 0; x < height+50; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width+50; y=y+50) {  // increments and places more circles down
      fill(random(200,255),random(60),random(60),random(100,255));
    ellipse(x+25,y+25,50,50);
    }  
  }
  
// Orange loop
  for (x = 0; x < height-100; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width-100; y=y+50) {  // increments and places more circles down
      fill(random(180,255),random(100,155),random(10),random(20,255));
    ellipse(x+75,y+75,50,50);
    }
  }
 
// Yellow loop
  for (x = 0; x < height-200; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width-200; y=y+50) {  // increments and places more circles down
      fill(random(210,255),random(210,255),random(30),random(30,255));
    ellipse(x+125,y+125,50,50);
    }
  }


// Green loop
  for (x = 0; x < height-300; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width-300; y=y+50) {  // increments and places more circles down
      fill(random(60),255,random(60),random(30,255));
    ellipse(x+175,y+175,50,50);
    }
  }
  
// Blue loop
  for (x = 0; x < height-400; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width-400; y=y+50) {  // increments and places more circles down
      fill(random(10),random(20),random(220,255),random(30,255));
    ellipse(x+225,y+225,50,50);
    }
  }

// Purple loop
    for (x = 0; x < height-500; x=x+50) {  // last part increments and places more circles across
    for(y = 0; y < width-500; y=y+50) {  // increments and places more circles down
      fill(random(180,220),random(10),random(220,255),random(30,255));
    ellipse(x+275,y+275,50,50);
    }
  }
  

// Opacity overlay
  if(mousePressed){
    for (x = 0; x < height+50; x=x+50) {  // last part increments and places more circles across
      for(y = 0; y < width+50; y=y+50) {  // increments and places more circles down
        fill(random(255),random(255),random(255),random(0,200));
      ellipse(x,y,50,50);
      }
    }  
  }

}