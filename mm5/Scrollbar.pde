class VScrollbar

//from: http://forum.processing.org/topic/vertical-scrollbar
//slightly modified to work with js

{
  int barWidth, barHeight; // width and height of bar. NOTE: barWidth also used as slider button height.
  int Xpos, Ypos;          // upper-left position of bar
  float Spos, newSpos;     // y (upper) position of slider
  int SposMin, SposMax;    // max and min values of slider
  int loose;               // how loose/heavy
  boolean isOver;            // True if hovering over the scrollbar
  boolean locked;          // True if a mouse button is pressed while on the scrollbar
  color barOutlineCol;
  color barFillCol;
  color barHoverCol;
  color sliderFillCol;
  color sliderPressCol;

  VScrollbar (int X_start, int Y_start, int bar_width, int bar_height, int loosiness,
              color bar_outline, color bar_background, color slider_bg, color barHover, color slider_press) {
    barWidth = bar_width;
    barHeight = bar_height;
    Xpos = X_start;
    Ypos = Y_start;
    Spos = Ypos + barHeight/2 - barWidth/2; // center it initially
    newSpos = Spos;
    SposMin = Ypos;
    SposMax = Ypos + barHeight - barWidth;
    loose = loosiness;
    if (loose < 1) loose = 1;
    barOutlineCol  = bar_outline;
    barFillCol     = bar_background;
    sliderFillCol  = slider_bg;
    barHoverCol    = barHover;
    sliderPressCol = slider_press;
  }

  void update() {
    isOver = over();
    if(mousePressed && isOver) locked = true; else locked = false;

    if(locked) {
      newSpos = constrain(mouseY-barWidth/2, SposMin, SposMax);
    }
    if(abs(newSpos - Spos) > 0) {
      Spos = Spos + (newSpos-Spos)/loose;
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if(mouseX > Xpos && mouseX < Xpos+barWidth &&
    mouseY > Ypos && mouseY < Ypos+barHeight) {
      return true;
    } else {
      return false;
    }
  }
  
  void display() {
    stroke(barOutlineCol);
    fill(barFillCol);
    rect(Xpos, Ypos, barWidth, barHeight);
    if(isOver) {
      fill(barHoverCol);
    } 
    if (locked) {
      fill(sliderPressCol);
    }
    if (!isOver && !locked) {
      fill (sliderFillCol);
    }
    if (abs(Spos-newSpos)>0.1) fill (sliderPressCol);
    rect(Xpos, Spos, barWidth, barWidth);
  }

  float value() {
    // Convert slider position Spos to a value between 0 and 1
    return (Spos-Ypos) / (barHeight-barWidth);
  }
  
  void setValue(float value) {
    // convert a value (0 to 1) to slider position Spos
    if (value<0) value=0;
    if (value>1) value=1;
    Spos = Ypos + ((barHeight-barWidth)*value);
    newSpos = Spos;
  }
}
