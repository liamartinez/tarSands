class Region {
  ArrayList orgList; 
  String name;
  boolean isCurrent; 

  int totalHeight;
  float offset; 

  Region() {
    orgList = new ArrayList();
  } 

  boolean isOverAnOrg() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.isInside (mouseX, mouseY)) {
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
      } 
      else {
        Org u  = (Org) orgList.get(i-1); 
        totalHeight += u.rectHeight;
      } 
      o.drawRect(totalHeight);
    }
  }

  void checkClicks() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      o.isDetail = false;
      if (o.clickedRect(offset)) {
        o.isDetail = true;
      }
    }
  }

  void setOffset(float offset_) {
    offset = offset_;
  }

  void setIsCurrent(boolean is) {
    isCurrent = is; 
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      o.isDetail = false;
    }
  }
}

