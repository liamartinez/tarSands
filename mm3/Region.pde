class Region {
  ArrayList orgList; 
  String name;
  boolean isCurrent; 

  int totalHeight;
  float offset, offsetY; //offset from one of the regions growing larger, and offset from translating down

  float loc; 

  Region() {
    orgList = new ArrayList();
  } 

  boolean isOverAnOrg() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.isInside (mouseX, mouseY) && mousePressed) {
        return true;
      }
    }
    return false;
  }

  void displayCities() {
    for (int i = orgList.size()-1; i > -1; i--) {
      Org o = (Org) orgList.get(i); 
      o.display( 5 * i);
    }
  }

  void displayOrgs() {  
    
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (i == 0) {
        totalHeight = 0;
        o.isFirst = true; 
      } 
      else {
        Org u  = (Org) orgList.get(i-1); 
        totalHeight += u.rectHeight;
      } 
      
      /*
      float easing = 0.05;
       if (i == 0) println ("TH " + i + " " + totalHeight); 
      float dx = totalHeight - 0;
       if (i == 0) println ("dx " + i + " " + dx + " loc: " + loc); 
      if (abs(dx) > 1) {
        totalHeight += dx * easing;
        if (i == 0) println ("loc " + i + " " + loc); 
      }
      */
      o.drawRect(totalHeight);
    }
  }

  void checkClicks() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      o.isDetail = false;
      if (o.clickedRect(offsetY, offset)) {
        o.isDetail = !o.oldIsDetail; 
        o.oldIsDetail = o.isDetail; 
      }
    }
  }

  void setOffset(float offsetY_, float offset_) {
    offset = offset_;
    offsetY = offsetY_;
  }

  void setIsCurrent(boolean is) {
    isCurrent = is; 
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      //o.isDetail = false;
    }
  }
}

