
class Org {

  float circleS; 
  float rate; 
  float amplitude, period; 
  boolean isCurrent; 
  int   area; 
  boolean isFirst = false; //for animation
  boolean isLast = false; //for animation

  color myColor; 
  String name; 
  String description; 
  String fileName; 
  String link; 
  float lat, lng; 
  PVector location, randLoc; 
  String city; 
  String region; 
  PImage logo; 

  int rectHeight, newHeight, rectHeightDeet, defHeight;
  int rectWidth, scrollW;
  float yPos, newPos; 
  float logoLocX, logoLocY; 
  float linkLocX, linkLocY; 

  boolean isDetail = false;
  boolean oldIsDetail;

  Org() {
    myColor = colors[int(random(colors.length))]; 
    circleS = random (15, 30); 
    area = (int)circleS/2; 
    rate = random (3); 
    amplitude = random (.095); 
    period = random (60, 160); 
    isCurrent = false;
    logoLocX = width - 105;
    logoLocY =  (int)yPos + 10;
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
      fill (TSorange, 30);
    } 
    else {
      fill (myColor, 70);
    }
    noStroke(); 
    //circleS = circleS + amplitude * cos(TWO_PI * frameCount / period); //for individual pulsing
    ellipse (randLoc.x, randLoc.y, circleS, circleS);
    //ellipse (randLoc.x, randLoc.y, 5, 5);
  }

  void setRectSize (int width_, int defHeight_, int heightDeet_, int scrollW_) {
    rectWidth =  width_; 
    defHeight = defHeight_; 
    rectHeightDeet = heightDeet_; 
    scrollW = scrollW_;
  }

  void setColor (color c) {
    myColor = c;
  }

  void drawRect(float newPos_) {
    int sw, sw2; 
    float nameX = 0; 
    float nameY = 0; 
    newPos = newPos_;
    //yPos = yPos_; 
    float easing = 0.09;
    float dx = newPos - yPos;

    if (abs(dx) > 1) {
      yPos += dx * easing;
    }
    
    if (isDetail) {
      newHeight = rectHeightDeet;
      //rectHeight = rectHeightDeet; 
      //sw = 20;
      // sw2 = 2;
      //  if (!isFirst) yPos += 5;
    } 
    else {
      newHeight = defHeight;
      // rectHeight = defHeight;
      // sw = 2; 
      //sw2 = sw;
    }

    float easeHeight = .09;
    boolean go; 
    float sx = newHeight - rectHeight;

    if (abs(sx) > 1) {
      rectHeight += sx * easeHeight;
      go = false;
    } else {
      go = true; 
    }

    if (isLast) {
      fill (TSblack); 
      rect (width-rectWidth - scrollW, yPos + rectHeight, rectWidth, rectHeightDeet);//this rectangle acts as a BG
    } else {
      fill (myColor); 
      rect (width-rectWidth - scrollW, yPos, rectWidth, rectHeightDeet); 
    }
     fill (myColor); 
    rect (width-rectWidth - scrollW, yPos, rectWidth, rectHeight); 
    fill (white); 
    textFont (fontBold, 15);
    rectMode (CORNER); 
    textLeading(17); 
    int orgNameX = width-rectWidth-scrollW + 10;
    text (name,orgNameX , 8+ yPos, 150, rectHeight);
    stroke (TSblack);
    //strokeWeight (sw);  
    //line (width-rectWidth - scrollW, yPos + rectHeight, width-rectWidth - scrollW + rectWidth, yPos + rectHeight);
    //strokeWeight (sw2);
    //line (width-rectWidth - scrollW, yPos, width-rectWidth - scrollW + rectWidth, yPos);
    noStroke(); 

    if (isDetail) {
      if (go) {
      nameX = width - 60;
      nameY = yPos + rectHeight - 20;
      }
      //text (link, nameX, nameY - 30);
    } 
    else {
      if (go) {
      nameX = width - 115;
      nameY = yPos + rectHeight - 10;
      }
    }
      rectMode (CORNER); 
      textFont (font, 12); 
      textLeading (14); 
      text (description, width-rectWidth-scrollW + 10, 55 + yPos, rectWidth - 130, rectHeight- 60); 
    textAlign (RIGHT); 
    textFont (font, 12);
    text (city, nameX, nameY); 
    textAlign (LEFT); 
    logoLocY =  (int)yPos + 10;
    logoLocX = width - 105;
    image (logo, logoLocX, logoLocY);
    linkLocX = orgNameX; 
    linkLocY = nameY; 
    textFont (fontBold, 10); 
    text ("WEBSITE", linkLocX, linkLocY); 
  }

  boolean clickedRect (float offsetY_, float offset_) {
    float clickOffset = offset_; 
    float clickOffsetY = offsetY_; 
    if (mouseX > (width-rectWidth)  && mouseX < (width-scrollW-logo.width)  && mouseY > yPos + clickOffset + clickOffsetY && mouseY < (yPos + rectHeight)+ clickOffset + clickOffsetY - rectHeight/3) {
      return true;
    } 
    return false;
  }
  
    boolean clickedLogo (float offsetY_, float offset_) {
        float clickOffset = offset_; 
    float clickOffsetY = offsetY_; 
    
    /*
    if (mouseX > logoLocX &&  mouseY > logoLocY + clickOffsetY + clickOffset && mouseY < logoLocY + logo.height + clickOffset + clickOffsetY) {
      return true;
    }  */

    if (mouseX > linkLocX &&  mouseX < linkLocX + 100 && mouseY > linkLocY - 15 + clickOffsetY + clickOffset && mouseY < linkLocY  + clickOffset + clickOffsetY) {
      return true; 
    }
    return false;
  }


  void setCoords() {   
    location = mercatorMap.getScreenLocation(new PVector(lat, lng));
    makeLocation();
  }

  void makeLocation() {
    PVector newLoc; 
    randLoc = new PVector (int(random (location.x - 35, location.x + 35)), int(random (location.y - 35, location.y + 35))); 
    movementMap.loadPixels(); 
    randLoc.x = constrain (randLoc.x, 0, movementMap.width-1); 
    randLoc.y = constrain (randLoc.y, 0, movementMap.height-1); 
    color thisColor = movementMap.pixels[int(randLoc.x+movementMap.width*randLoc.y)]; 
    if (brightness (thisColor) < 5)  {
      return;
    } 
    else {
      makeLocation();
    }
  }

  boolean isInside (int x, int y) {
    if (dist (x+offset, y-offsetY, randLoc.x, randLoc.y) < area) {
      return true;
    } 
    else {
      return false;
    }
  }

}

