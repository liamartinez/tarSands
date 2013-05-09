class Button {

  int xLoc, yLoc, w, h; 
  String regionName; 
  boolean isCurrent = false;
  color buttonColor; 

  Button(String name_) {
    regionName = name_; 

  }
  
  void set (int xLoc_, int yLoc_, int w_, int h_) {
    xLoc = xLoc_; 
    yLoc = yLoc_; 
    w = w_; 
    h = h_;
  }

  void setColor(color c) {
    buttonColor = c; 
  }

  void display() {
    color BG;
    color FG;
   // stroke (white);
    if (isCurrent) {
      BG = TSorange; 
      FG = TSblack; 
    } 
    else {
      BG = buttonColor; 
      FG = white; 
    }
    fill (BG); 
    rectMode (CORNERS);
    noStroke(); 
    rect (xLoc, yLoc, w, h); 
    rectMode (CORNER);
    textAlign (CENTER); 
    textFont (fontBold, 18); 
    fill (FG); 
    text (regionName.toUpperCase(), xLoc + 65, yLoc + 25);
    noStroke();
    textAlign (CORNER); 
  }

  boolean setRegion () {
    if (mouseX > xLoc && mouseX <  w && mouseY > yLoc && mouseY < h) {
      isCurrent = true; 
    } 
    else {
      isCurrent = false; 
    }
    return isCurrent;
  }
  
  void setIsCurrent (boolean is_) {
    isCurrent = is_; 
  }
  
}

