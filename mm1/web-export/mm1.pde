/* @pjs preload="map.png"; */
/* @pjs preload="tsmmlogo.png"; */
/* @pjs preload="tswhatis.png"; */

boolean isJS = "true"; 

PImage movementMap;
PImage tsmmlogo; 
PImage tswhatis;
int curCity, lastCity; 
int cur; 

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

int offset = 200; //todo

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

String currentRegion; 

void setup() {
  frameRate (40); 
  for (int i = 0; i< regions.length;i++) {
    regions[i] = new Region();
    regions[i].name = regionNames[i];
  } 
  movementMap   = loadImage("map.png");
  tsmmlogo = loadImage ("tsmmlogo.png"); 
  tswhatis = loadImage ("tswhatis.png"); 
  size (1000, 392); //manual entry 
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
  Vslider = new VScrollbar(width - 15, 0, 15, height, 2, scrEdgdeCol, scrBgCol, sliderColor, scrHoverCol, scrPressCol);
  Vslider.setValue (0); 
  loadCSV("MovementMapData - Sheet1 (5).csv");
}


void draw() {
  //map
  pushMatrix();
  translate (-offset, 0); 

  image (movementMap, 0, 0);  
  pushMatrix(); 
  scale (.6); 
  image (tsmmlogo, offset+150, height - 50); 
  image (tswhatis, offset + 470, height + 40); 
  popMatrix(); 

  for (int i = 0; i < regions.length; i++) {
    for (int j = 0; j < regions[i].orgList.size(); j++) {
      regions[i].displayCities();
    }
  }

  popMatrix();

  //sidebar
  markCurrent();
  sidebar.display(); 
  pushMatrix(); 
  newPos= map (Vslider.value(), 0, 1, 0, -(regionTotalNum*30-height)); 
  regions[cur].setOffset(newPos);
  translate (0, newPos); 
  showCurRegion();
  popMatrix(); 

  Vslider.display(); 
  Vslider.update();
}

void mousePressed() {
    for (int i = 0; i < regions.length; i++) {
      regions[i].checkClicks();
    }
}

void mouseScrolled() {
  if (isJS) newPos += mouseScroll*10; 
  newPos = constrain (newPos, -(regionTotalNum*30-height), 0); 
  Vslider.setValue (map (newPos, 0, -(regionTotalNum*30-height), 0, 1 ));
}


boolean isOverAnOrg() {
  for (int j = 0; j < regions.length; j++) {
      if (regions[j].isOverAnOrg()) {
        return true;
      }
    }
  return false;
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
}


/*
  void showCurOrgs() {
 int count = 0; 
 String curCityName = ""; 
 for (int i = 0; i < orgList.size(); i++) {
 Org o = (Org) orgList.get(i); 
 if (o.isCurrent) {
 curCityName = o.city; 
 count ++; 
 fill (255); 
 text (o.name, width-sidebar.w + 10, 40 + (30 * count));   
 
 strokeWeight (3);
 stroke (TSSorange);  
 line (width-sidebar.w, 40, width - 10, 40);
 } 
 else {
 }
 }
 text (curCityName, width-sidebar.w + 10, 30);
 }
 */

void showCurRegion() {
  for (int i = 0; i < regions.length; i++) {
    if (regions[i].isCurrent) {
      regions[i].displayOrgs();
      regionTotalNum = regions[i].orgList.size();
    }
  }
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

