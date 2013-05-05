/* @pjs preload="map.png"; */
/* @pjs preload="tsmmlogo.png"; */
/* @pjs preload="tswhatis.png"; */


PImage movementMap;
PImage tsmmlogo; 
PImage tswhatis;
int curCity, lastCity; 
int cur;
boolean clicked = false;

MercatorMap mercatorMap;
Sidebar sidebar; 
VScrollbar Vslider;
float newPos; 
int regionTotalNum;

int numRegions = 5; 
Region [] regions = new Region [numRegions];
String[] regionNames = {
  "Western Canada", "Eastern Canada", "Western USA", "Eastern USA", "Europe"
}; 
Button [] buttons = new Button [numRegions]; 

String curTitle = ""; 

//colors
color yellow = #FFC906; 
color red = #ED1C24;
color orange =#7E2966;
color purple = #7E2966;
color brown = #827561;
color[] colors = {
  yellow, red, orange, purple, brown
};

color TSblack = #151515; 
color TSSorange = #F58434;
color white = color (255); 

String currentRegion; 

//positions
int offset = 200; //todo
int regionsX = 100; 
int regionsY = 200; 
int mapBorder = 700; //hack to distinguish between map/ buttons

//sizes
int scrollWidth = 15; 
int rectW = 300; 
int rectH = 50; 
int rectHDetail = 80; 

void setup() {
  frameRate (40); 
  smooth(); 

  for (int i = 0; i< regions.length;i++) {
    regions[i] = new Region();
    regions[i].name = regionNames[i];
    buttons[i] = new Button (regionNames[i]);
  } 

  //buttons positions
  buttons[0].set (700, 10, 150, 35); 
  buttons[1].set (700, 10 + 1*35, 150, 35); 
  buttons[2].set (700, 10 + 2*35, 150, 35); 
  buttons[3].set (700 + 150, 10, 150, 35); 
  buttons[4].set (700 + 150, 10 + 1*35, 150, 35); 

  movementMap   = loadImage("map.png");
  tsmmlogo = loadImage ("tsmmlogo.png"); 
  tswhatis = loadImage ("tswhatis.png"); 
  size (1000, 500); 
  mercatorMap = new MercatorMap(900, 392, 60.9304, -3.5134, -171.5625, 14.0625);
  //-171.5625,-3.5134,14.0625,60.9304
  //last one, second one, first one, third one
  sidebar = new Sidebar(); 

  // Scrollbar/slider colors
  color scrEdgdeCol = color(0, 0, 0);
  color scrBgCol    = color(100, 100, 100);
  color sliderColor = color(0, 150, 200);
  color scrHoverCol = color(100, 200, 200);
  color scrPressCol = color(100, 255, 255);
  Vslider = new VScrollbar(width - scrollWidth, regionsY, scrollWidth, height - regionsY, 1, scrEdgdeCol, scrBgCol, sliderColor, scrHoverCol, scrPressCol);
  Vslider.setValue (0); 

  loadCSV("MovementMapData - Sheet1 (5).csv");

  // set the rect sizes after the csv has been loaded
  for (int i = 0; i< regions.length;i++) {
    for (int j = 0; j < regions[i].orgList.size(); j++) {
      Org o = (Org) regions[i].orgList.get(j); 
      o.setRectSize( rectW, rectH, rectHDetail, scrollWidth); //
    }
  }
}


void draw() {
  background (0); 

  //map
  pushMatrix();
  translate (-offset, 150); 

  image (movementMap, 0, 0);  
  pushMatrix(); 
  scale (.5); 
  image (tsmmlogo, offset+230, -290); 
  image (tswhatis, offset+530, -290); 
  popMatrix(); 

  //ellipses
  for (int i = 0; i < regions.length; i++) {
    for (int j = 0; j < regions[i].orgList.size(); j++) {
      regions[i].displayCities();
    }
  }

  popMatrix();

  //sidebar and slider

  sidebar.display(); 
  pushMatrix(); 
  newPos= map (Vslider.value(), 0, 1, 0, -(regionTotalNum*50-height)); 
  regions[cur].setOffset(regionsY, newPos); //enables click functionality after translate
  translate (regionsX, newPos + regionsY); 
  if (clicked) showCurRegion();
  popMatrix(); 

  if (regionTotalNum > 6) { //todo
  Vslider.display(); 
  } else {
    Vslider.setValue(0); 
  }
  Vslider.update();
  
  //menu
  fill (TSblack); 
  rect (700, 0, width - regionsX, regionsY); 
  for (int i = 0; i < regions.length; i++) {
    buttons[i].display();
  }

  //title
  pushMatrix(); 
  translate (700, 150); 
  if (clicked) drawTitleText (regions[cur].name); 
  else drawTitleText(""); 
  popMatrix();
}

void mousePressed() {
  if (mouseX < mapBorder)  markCurrent();
  if (mouseX > mapBorder && mouseY < 150) markButton();       

  for (int i = 0; i < regions.length; i++) {
    regions[i].checkClicks();
  }
}

void mouseScrolled() {
  //newPos += mouseScroll*10; 
  newPos = constrain (newPos, -(regionTotalNum*50-height), 0); 
  Vslider.setValue (map (newPos, 0, -(regionTotalNum*50-height), 0, 1 ));
}


boolean isOverAnOrg() {
  for (int j = 0; j < regions.length; j++) {
    if (regions[j].isOverAnOrg()) {
      return true;
    }
  }
  return false;
}


void markButton() {
  for (int i = 0; i < regions.length; i++) {
    if (buttons[i].setRegion()) {
      currentRegion = regions[i].name;      
      regions[i].setIsCurrent(true);
      cur = i;
    } 
    else {
      regions[i].setIsCurrent(false);
    }
  }
  clicked = true;
}


void markCurrent() {
  if (isOverAnOrg()) {
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].isOverAnOrg()) {
        currentRegion = regions[i].name;      
        regions[i].setIsCurrent(true);
        cur = i;
      } 
      else {
        regions[i].setIsCurrent(false);
      }
    }
  }
  clicked = true;
}

void showCurRegion() {
  regions[cur].displayOrgs(); 
  regionTotalNum = regions[cur].orgList.size();
}

void drawTitleText (String title_) {
  stroke (255); 
  fill (255); 
  rect (0, 0, 200, 50);  
  fill (0); 
  text (title_, 10, 22); 
  noStroke();
}

void loadCSV(String fileName) {
  String [] file = loadStrings(fileName); 
  //println ("file length: " + file.length); 
  for (int i = 1; i < file.length; i++) {
    Org o = new Org(); 
    o.fromCSV(file[i].split(","));
    for (int j = 0; j < regions.length; j++) {
      if (o.region.contains(regions[j].name)) {
        //println ("this city: " + o.city + " is in region " + o.region); 
        regions[j].orgList.add (o);
        //println (regions[j].name +  " is this size " + regions[j].orgList.size());
      }
    }
  }
  for (int i = 0; i < regions.length; i++) {
    //println (regions[i].name + " " + regions[i].orgList.size());
  }
}

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

/**
 * Utility class to convert between geo-locations and Cartesian screen coordinates.
 * Can be used with a bounding box defining the map section.
 *
 * (c) 2011 Till Nagel, tillnagel.com
 */
public class MercatorMap {
  
  public static final float DEFAULT_TOP_LATITUDE = 80;
  public static final float DEFAULT_BOTTOM_LATITUDE = -80;
  public static final float DEFAULT_LEFT_LONGITUDE = -180;
  public static final float DEFAULT_RIGHT_LONGITUDE = 180;
  
  /** Horizontal dimension of this map, in pixels. */
  protected float mapScreenWidth;
  /** Vertical dimension of this map, in pixels. */
  protected float mapScreenHeight;

  /** Northern border of this map, in degrees. */
  protected float topLatitude;
  /** Southern border of this map, in degrees. */
  protected float bottomLatitude;
  /** Western border of this map, in degrees. */
  protected float leftLongitude;
  /** Eastern border of this map, in degrees. */
  protected float rightLongitude;

  private float topLatitudeRelative;
  private float bottomLatitudeRelative;
  private float leftLongitudeRadians;
  private float rightLongitudeRadians;

  public MercatorMap(float mapScreenWidth, float mapScreenHeight) {
    this(mapScreenWidth, mapScreenHeight, DEFAULT_TOP_LATITUDE, DEFAULT_BOTTOM_LATITUDE, DEFAULT_LEFT_LONGITUDE, DEFAULT_RIGHT_LONGITUDE);
  }
  
  /**
   * Creates a new MercatorMap with dimensions and bounding box to convert between geo-locations and screen coordinates.
   *
   * @param mapScreenWidth Horizontal dimension of this map, in pixels.
   * @param mapScreenHeight Vertical dimension of this map, in pixels.
   * @param topLatitude Northern border of this map, in degrees.
   * @param bottomLatitude Southern border of this map, in degrees.
   * @param leftLongitude Western border of this map, in degrees.
   * @param rightLongitude Eastern border of this map, in degrees.
   */
  public MercatorMap(float mapScreenWidth, float mapScreenHeight, float topLatitude, float bottomLatitude, float leftLongitude, float rightLongitude) {
    this.mapScreenWidth = mapScreenWidth;
    this.mapScreenHeight = mapScreenHeight;
    this.topLatitude = topLatitude;
    this.bottomLatitude = bottomLatitude;
    this.leftLongitude = leftLongitude;
    this.rightLongitude = rightLongitude;

    this.topLatitudeRelative = getScreenYRelative(topLatitude);
    this.bottomLatitudeRelative = getScreenYRelative(bottomLatitude);
    this.leftLongitudeRadians = getRadians(leftLongitude);
    this.rightLongitudeRadians = getRadians(rightLongitude);
  }

  /**
   * Projects the geo location to Cartesian coordinates, using the Mercator projection.
   *
   * @param geoLocation Geo location with (latitude, longitude) in degrees.
   * @returns The screen coordinates with (x, y).
   */
  public PVector getScreenLocation(PVector geoLocation) {
    float latitudeInDegrees = geoLocation.x;
    float longitudeInDegrees = geoLocation.y;

    return new PVector(getScreenX(longitudeInDegrees), getScreenY(latitudeInDegrees));
  }

  private float getScreenYRelative(float latitudeInDegrees) {
    return log(tan(latitudeInDegrees / 360f * PI + PI / 4));
  }

  protected float getScreenY(float latitudeInDegrees) {
    return mapScreenHeight * (getScreenYRelative(latitudeInDegrees) - topLatitudeRelative) / (bottomLatitudeRelative - topLatitudeRelative);
  }
  
  private float getRadians(float deg) {
    return deg * PI / 180;
  }

  protected float getScreenX(float longitudeInDegrees) {
    float longitudeInRadians = getRadians(longitudeInDegrees);
    return mapScreenWidth * (longitudeInRadians - leftLongitudeRadians) / (rightLongitudeRadians - leftLongitudeRadians);
  }
}


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
    description = input[8];

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

class Region {
  ArrayList orgList; 
  String name;
  boolean isCurrent; 

  int totalHeight;
  float offset, offsetY; //offset from one of the regions growing larger, and offset from translating down

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
      if (o.clickedRect(offsetY, offset)) {
        o.isDetail = true;
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
      o.isDetail = false;
    }
  }
}

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
class Sidebar {
  
  int w = offset + 100; 
  int h = height; 
 // Org[] sortedList = new Org[orgList.length]; 
  
  Sidebar () {
  }
  
  void display() {
    fill (TSblack); 
    rect (width-w, 0, w, h); 
    
  }
  
}
/*

size
logos
description
preloading

2 cities in the same region

fix org size

make the menu a box so it can detect where the mouse is and draw a neat rect below it

*/

