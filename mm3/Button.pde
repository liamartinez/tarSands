class Button {

  int xLoc, yLoc, w, h; 
  String regionName; 
  boolean isCurrent = false;

  Button(String name_) {
    regionName = name_; 

  }
  
  void set (int xLoc_, int yLoc_, int w_, int h_) {
    xLoc = xLoc_; 
    yLoc = yLoc_; 
    w = w_; 
    h = h_;
  }


  void display() {
    color BG;
    color FG = TSblack; 
   // stroke (white);
    if (isCurrent) {
      BG = white; 
    } 
    else {
      BG = TSgrey; 
    }
    fill (BG); 
    rectMode (CORNERS);
    noStroke(); 
    rect (xLoc, yLoc, w, h); 
    rectMode (CORNER);
    textFont (font, 15); 
    fill (FG); 
    text (regionName.toUpperCase(), xLoc + 10, yLoc + 20);
    noStroke();
  }

  boolean setRegion () {
    if (mouseX > xLoc && mouseX <  w && mouseY > yLoc && mouseY < h) {
      isCurrent = true; 
      return true;
    } 
    else {
      isCurrent = false; 
      return false;
    }
  }
}

