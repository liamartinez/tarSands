
class Org {

  float circleS; 
  float rate; 
  boolean isCurrent; 
  int   area = 40; 
  boolean isFirst = false; 

  color myColor; 
  String name; 
  String description; 
  String fileName; 
  String link; 
  float lat, lng; 
  PVector location; 
  String city; 
  String region; 
  PImage logo; 

  int rectHeight, rectHeightDeet, defHeight;
  int rectWidth, scrollW;
  float yPos; 

  boolean isDetail = false;
  boolean oldIsDetail;

  Org() {
    myColor = colors[int(random(colors.length))]; 
    circleS = int(random(5, 15)); 
    rate = random (circleS, circleS+20); 
    isCurrent = false;
  }

  void fromCSV(String[] input) {
    name = input[0]; 
    description = input[7];
    fileName = input[6];
    logo = loadImage (fileName); 
    link = input [8]; 

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

  void drawRect(float yPos_) {
    int sw, sw2; 
    float nameX, nameY; 
    yPos = yPos_; 
    fill (myColor); 
    if (isDetail) {
      rectHeight = rectHeightDeet; 
      sw = 20;
      sw2 = 2;
      if (!isFirst) yPos += 5;
    } 
    else {
      rectHeight = defHeight;
      sw = 2; 
      sw2 = sw;
    }
    rect (width-rectWidth - scrollW, yPos, rectWidth, rectHeight); 
    fill (TSblack); 
    textFont (font, 15);
    rectMode (CORNER); 
    textLeading(17); 
    text (name, width-rectWidth-scrollW + 10, 8+ yPos, 150, rectHeight);
    stroke (TSblack);
    strokeWeight (sw);  
    line (width-rectWidth - scrollW, yPos + rectHeight, width-rectWidth - scrollW + rectWidth, yPos + rectHeight);
    strokeWeight (sw2);
    line (width-rectWidth - scrollW, yPos, width-rectWidth - scrollW + rectWidth, yPos);
    noStroke(); 

    if (isDetail) {
      rectMode (CORNER); 
      textFont (font, 12); 
      textLeading (14); 
      text (description, width-rectWidth-scrollW + 10, 55 + yPos, rectWidth - 130, rectHeight/2); 
      nameX = width - 60;
      nameY = yPos + rectHeight - 20;
      //text (link, nameX, nameY - 30); 
    } else {
      nameX = width - 115;
      nameY = yPos + rectHeight - 10;
    }
    
      textAlign (RIGHT); 
      textFont (font, 12);
      text (city, nameX, nameY); 
      textAlign (LEFT); 
      image (logo, width - 105, yPos + 10);
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
    if (dist (x+offset, y-offsetY, location.x, location.y) < area) {
      return true;
    } 
    else {
      return false;
    }
  }
}

