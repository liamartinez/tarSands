
class Org {

  float circleS; 
  float rate; 
  boolean isCurrent; 
  int   area = 40; 

  color myColor; 
  String name; 
  String description; 
  String fileName; 
  float lat, lng; 
  PVector location; 
  String city; 
  String region; 
  
  int rectHeight, rectHeightDeet, defHeight;
  int rectWidth, scrollW;
  int yPos; 
  
  boolean isDetail = false;

  Org() {
    myColor = colors[int(random(colors.length))]; 
    circleS = int(random(5, 15)); 
    rate = random (circleS, circleS+20); 
    isCurrent = false;
  }

  void fromCSV(String[] input) {
    name = input[0]; 
    //description = input[12];

    city = input[1]; 
    region = input[3]; 
    lat = float(input[5]); 
    lng = float(input[4]); 
    setCoords();
  } 

  void display(int circleSize) {
    if (isCurrent) {
      fill (255);
    } 
    else {
      fill (myColor, 175);
    }
    noStroke(); 
    //circleSize = circleSize + cos( frameCount/ rate); //for individual pulsing
    ellipse (location.x, location.y, circleSize, circleSize);
    ellipse (location.x, location.y, 5, 5);
  }
  
  void setRectSize (int width_, int defHeight_, int heightDeet_, int scrollW_) {
    rectWidth =  width_; 
    defHeight = defHeight_; 
    rectHeightDeet = heightDeet_; 
    scrollW = scrollW_; 
  }
    
  void drawRect(int yPos_) {
      yPos = yPos_; 
      fill (myColor); 
      if (isDetail) {
        rectHeight = rectHeightDeet; 
      } else {
        rectHeight = defHeight;
      }
      rect (width-rectWidth - scrollW, yPos, rectWidth, rectHeight); 
      fill (255); 
      textSize (13); 
      text (name, width-rectWidth-scrollW + 10, 20 + yPos);
  }
  
  boolean clickedRect (float offsetY_, float offset_) {
    float clickOffset = offset_; 
    float clickOffsetY = offsetY_; 
    if (mouseX > (width-rectWidth)  && mouseX < (width-scrollW)  && mouseY > yPos + clickOffset + clickOffsetY && mouseY < (yPos + rectHeight)+ clickOffset + clickOffsetY) {
      return true; 
    } 
    return false;
  }


  void setCoords() {   
    location = mercatorMap.getScreenLocation(new PVector(lat, lng));
  }

  boolean isInside (int x, int y) {
    if (dist (x+offset, y - 150, location.x, location.y) < area) {
      return true;
    } 
    else {
      return false;
    }
  }
}

