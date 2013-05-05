/* @pjs preload="map.png"; */
/* @pjs preload="tsmmlogo.png"; */
/* @pjs preload="tswhatis.png", "FPO_map1_1000x385.png"; */
/* @pjs font="Myriad.ttf"; */

/* @pjs preload=
"equiterre.png",
"cycc.png",
"CANC.png",
"sierra-club.png",
"nrcm.png",
"BoldNebraskaLogo.png",
"nrdc.png",
"nrdc.png",
"350.png",
"EnergyActionCoalition.png",
"oil change international.png",
"NWF.png",
"ForestEthicsAdvocacy.png",
"pipeup.png",
"sierraprairie.png",
"UKTarSands.png",
"keepers of the athabasca.png",
"greenpeace.png",
"greenpeace.png",
"wcel.png",
"tankerfreeBC.png",
"raven.png",
"4worlds.png",
"LOS.png",
"TSFNE.png",
"sierra club BC.png",
"FOE.png",
"raincoast.png";
*/


PImage temp; 
PImage movementMap;
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
String[] regionNames = {"Western Canada", "Eastern Canada", "Western USA", "Eastern USA", "Europe"}; 
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

color TSgrey = #808080; 
color TSblack = #141414;
color TSdarkgrey = color (50);
color TSSorange = #F58434;
color white = color (255); 

PFont font;

String currentRegion; 

//positions
int offset = 180; //todo
int offsetY = 20; 
int regionsX = 37; 
int regionsY = 40; 
int mapBorder = 40; //hack to distinguish between map/ buttons

//sizes
int scrollWidth = 15; 
int rectW = 300; 
int rectH = 70; 
int rectHDetail = 180; 

void setup() {
  frameRate (40); 
  smooth(); 
  
  font = createFont("Oswald-Light", 32);
  
  for (int i = 0; i< regions.length;i++) {
    regions[i] = new Region();
    regions[i].name = regionNames[i];
    buttons[i] = new Button (regionNames[i]);
  } 

  //buttons positions
  buttons[0].set (12, 10, 150, 34); 
  buttons[1].set (154, 10, 290, 34); 
  buttons[2].set (294, 10, 428, 34); 
  buttons[3].set (433, 10, 569, 34); 
  buttons[4].set (572, 10, 710, 34); 

  movementMap   = loadImage("map.png");
  temp = loadImage ("FPO_map1_1000x385.png"); 
  size (1000, 385); 
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
  Vslider = new VScrollbar(width - scrollWidth, regionsY, scrollWidth, height - regionsY, 1, TSblack, TSblack, TSdarkgrey, TSdarkgrey, TSdarkgrey);
  Vslider.setValue (0); 

  loadCSV("MovementMapData - Partner Data - pulled into map (4).tsv");

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
  translate (-offset, offsetY); 
  image (movementMap, 0, 0);  

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
  noStroke(); 
  fill (TSblack); 
  rect (0, 0, width, 43);
  rect (0, 0, 10, height); 
  rect (0, 361, 720, 25);
  rect (710, 0, 10, height); 
  //rect (700, 0, width - regionsX, regionsY); 
  for (int i = 0; i < regions.length; i++) {
    buttons[i].display();
  }
  fill (255); 
  text ("Select a region to find out more about our network.", 10, height - 7); 

  //title
  pushMatrix(); 
  translate (722, 11); 
  if (clicked) drawTitleText (regions[cur].name.toUpperCase()); 
  else drawTitleText(""); 
  popMatrix();
  
  //if (keyPressed) image (temp, 0, 0); 
}

void mousePressed() {
  if (mouseY > mapBorder)  markCurrent();
  if (mouseY < mapBorder) markButton();       

  for (int i = 0; i < regions.length; i++) {
    regions[i].checkClicks();
  }
  //println ("mouseX: " + mouseX + " mouseY: " + mouseY); 
}

void mouseScrolled() {
  newPos += mouseScroll*10; 
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
       //regions[i].loc = 0; 
       regions[i].totalHeight = 0; 
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
        //regions[i].loc = 0; 
        regions[i].totalHeight = 0; 
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
  fill (255); 
  rect (0, 0, 141, 24);  
  fill (0); 
  text (title_, 10, 20); 
  noStroke();
}

void loadCSV(String fileName) {
  String [] file = loadStrings(fileName); 
  //println ("file length: " + file.length); 
  for (int i = 1; i < file.length; i++) {
    Org o = new Org(); 
    o.fromCSV(file[i].split("\t"));
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
    color FG = TSblack; 
   // stroke (white);
    if (isCurrent) {
      BG = white; 
    } 
    else {
      BG = TSgrey; 
    }
    fill (BG); 
    rectMode (CORNERS);
    noStroke(); 
    rect (xLoc, yLoc, w, h); 
    rectMode (CORNER);
    textFont (font, 15); 
    fill (FG); 
    text (regionName.toUpperCase(), xLoc + 10, yLoc + 20);
    noStroke();
  }

  boolean setRegion () {
    if (mouseX > xLoc && mouseX <  w && mouseY > yLoc && mouseY < h) {
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

easing

size
logos
description
preloading

2 cities in the same region

fix org size

make the menu a box so it can detect where the mouse is and draw a neat rect below it

*/

