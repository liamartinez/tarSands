
class Org {

  float circleS; 
  float rate; 
  boolean isCurrent; 
  int   area = 5; 

  color myColor; 
  String name; 
  String description; 
  String fileName; 
  float lat, lng; 
  PVector location; 
  String city; 
  String region; 
  
  int rectHeight = 30;
  int rectWidth = offset + 100;
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
  
    
  void drawRect(int yPos_) {
      yPos = yPos_; 
      fill (myColor); 
      if (isDetail) {
        rectHeight = 60; 
      } else {
        rectHeight = 30;
      }
      rect (width-rectWidth, yPos, rectWidth, rectHeight); 
      fill (255); 
      text (name, width-sidebar.w + 10, 10 + yPos);
  }
  
  boolean clickedRect (float offset_) {
    float clickOffset = offset_; 
    if (mousePressed && mouseX > (width-rectWidth)  && mouseX < (width-rectWidth + rectWidth)  && mouseY > yPos + clickOffset && mouseY < (yPos + rectHeight)+ clickOffset) {
      return true; 
    } 
    return false;
  }


  void setCoords() {   
    location = mercatorMap.getScreenLocation(new PVector(lat, lng));
  }

  boolean isInside (int x, int y) {
    if (dist (x+offset, y, location.x, location.y) < area) {
      return true;
    } 
    else {
      return false;
    }
  }
}

