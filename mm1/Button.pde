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
    color FG; 
    stroke (white);
    if (isCurrent) {
      BG = white; 
      FG = TSblack; 
    } 
    else {
      BG = TSblack; 
      FG = white; 
    }
    fill (BG); 
    rect (xLoc, yLoc, w, h); 
    textSize (18); 
    fill (FG); 
    text (regionName, xLoc + 10, yLoc + 22);
    noStroke();
  }

  boolean setRegion () {
    if (mouseX > xLoc && mouseX < xLoc + w && mouseY > yLoc && mouseY < yLoc + h) {
      isCurrent = true; 
      return true;
    } 
    else {
      isCurrent = false; 
      return false;
    }
  }
}

