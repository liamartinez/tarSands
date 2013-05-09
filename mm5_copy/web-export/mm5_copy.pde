
/* @pjs preload="tswhatis.png", "FPO_map1_1000x385.png", "map.png", "tsmmlogo.png"; */
/* @pjs font="Helvetica.ttf"; @pjs pauseOnBlur="true"; */

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
PImage mapLegend;
int curCity, lastCity; 
int cur = 0;
boolean clicked = false;

MercatorMap mercatorMap;
VScrollbar Vslider;
float newPos; 
int regionTotalNum, scrollOffset;

int numRegions = 5; 
Region [] regions = new Region [numRegions];
String[] regionNames = {
  "Western Canada", "Eastern Canada", "Western USA", "Eastern USA", "Europe"
}; 
String[] regionNamesAb = {
  "W. Canada", "E. Canada", "W. USA", "E. USA", "Europe"
}; 
Button [] buttons = new Button [numRegions]; 

String curTitle = ""; 

color [] colors = { #16422E, #06534A };
color[] regID = { color (12, 72, 58), color (56, 123, 43), color (0, 154, 102), color (153, 202, 60), color (110, 182, 211) };
color TSgrey = #808080; 
color TSblack = #141414;
color TSdarkgrey = color (50);
color TSorange = #FF8530;
color white = color (255); 

PFont font, fontBold;

String currentRegion; 
boolean fromMap = false; 
boolean canScroll = false; 

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
int rectHDetail = 240; 

void setup() {
  frameRate (40); 
  smooth(); 

  font = createFont("Helvetica", 32);
  fontBold = createFont("Helvetica Bold", 32);

  int colorCount = 0; 
  for (int i = 0; i< regions.length;i++) {
    regions[i] = new Region();
    regions[i].name = regionNames[i];
    regions[i].IDcolor = regID[i];
    buttons[i] = new Button (regionNamesAb[i]);
    
    buttons[i].setColor( colors[colorCount]);
    regions[i].regColor = colors[colorCount];
    colorCount++; 
    if (colorCount >= colors.length ) colorCount = 0; 
  } 
   

  //buttons positions
  buttons[0].set (12, 5, 150, 40); 
  buttons[1].set (154, 5, 290, 40); 
  buttons[2].set (294, 5, 428, 40); 
  buttons[3].set (433, 5, 569, 40); 
  buttons[4].set (572, 5, 710, 40); 


  movementMap   = loadImage("map.png");
  //mapLegend = loadImage ("map_transparent_wcolor.png");
  
  //temp = loadImage ("FPO_map1_1000x385.png"); 
  size (1000, 385); 
  mercatorMap = new MercatorMap(900, 392, 60.9304, -3.5134, -171.5625, 14.0625);
  //-171.5625,-3.5134,14.0625,60.9304
  //last one, second one, first one, third one
  
  // Scrollbar/slider colors
  color scrEdgdeCol = color(0, 0, 0);
  color scrBgCol    = color(100, 100, 100);
  color sliderColor = color(0, 150, 200);
  color scrHoverCol = color(100, 200, 200);
  color scrPressCol = color(100, 255, 255);
  Vslider = new VScrollbar(width - scrollWidth, regionsY, scrollWidth, height - regionsY, 1, TSblack, TSblack, TSdarkgrey, TSdarkgrey, TSdarkgrey);
  Vslider.setValue (0); 

  loadCSV("MovementMapData - Revised Copy of Partner Data - pulled into map.tsv");
  boolean zero = true; 
  // set the rect sizes after the csv has been loaded
  for (int i = 0; i< regions.length;i++) {
    
    for (int j = 0; j < regions[i].orgList.size(); j++) {
      Org o = (Org) regions[i].orgList.get(j); 
      o.setRectSize( rectW, rectH, rectHDetail, scrollWidth); //
      o.regIDcolor = regions[i].IDcolor;
      o.setCoords();
      if (zero) colorCount = 0; 
      else colorCount = 1; 
      o.setColor (colors[colorCount]); //lia
      //o.setColor (regions[i].IDcolor); 
      zero = !zero; 
    }
  }

  cur = 0; 
  currentRegion = regions[cur].name;      
  regions[cur].setIsCurrent(true);
  buttons[cur].setIsCurrent(true);
  
  //mapLegend.loadPixels();
}


void draw() {
  background (0); 

  //map
  pushMatrix();
  translate (-offset, offsetY); 
  image (movementMap, 0, 0);  
  //image (mapLegend, 0, 0);  

  //ellipses
  for (int i = 0; i < regions.length; i++) {
    for (int j = 0; j < regions[i].orgList.size(); j++) {
      regions[i].displayCities();
    }
  }

  popMatrix();

  //sidebar and slider

  pushMatrix(); 
  scrollOffset = -((regionTotalNum*rectH)-height+rectHDetail);
  if (canScroll) newPos= map (Vslider.value(), 0, 1, 0, scrollOffset); 
  else newPos = 0; 
  regions[cur].setOffset(regionsY, newPos); //enables click functionality after translate
  translate (regionsX, newPos + regionsY); 
  //if (clicked) showCurRegion();
  showCurRegion();
  popMatrix(); 

  if (regionTotalNum > 4) { //todo
    canScroll = true; 
    Vslider.display();
  } 
  else {
    Vslider.setValue(0);
    canScroll = false; 
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
  textFont (font, 15);
  text ("Select a region to find out more about our network.", 10, height - 7); 

  //title
  pushMatrix(); 
  translate (722, 5); 
  //if (clicked) drawTitleText (regions[cur].name.toUpperCase()); 
  drawTitleText (regions[cur].name.toUpperCase()); 
  //else drawTitleText(""); 
  popMatrix();

  //if (keyPressed) image (temp, 0, 0);
  //to chage mouse pointer to hand when over a logo
  if (regions[cur].checkHover()) cursor (HAND); 
  else cursor (ARROW); 
}

void mousePressed() {
  if (mouseY > mapBorder && mouseX < width-rectW)  markCurrent();
  if (mouseY < mapBorder && mouseX < width-rectW) markButton();       

  regions[cur].checkClicks(); //toggle detail/ no detail
  
  //println ("mouseX: " + mouseX + " mouseY: " + mouseY);
  int orgLinked = regions[cur].checkLogos();
  if (orgLinked != -1) goToLink(orgLinked);   
  
  /*
    color thisC = mapLegend.get (mouseX + offset, mouseY - offsetY); 
    for (int i = 0; i < regID.length; i++) {
        if (thisC > (regID[i] - 100000) && thisC <( regID[i] + 100000)) {
      println ("match: " + regions[i].name);
    }
    }
    */
}

void mouseScrolled() {
  newPos += mouseScroll*10; 
  newPos = constrain (newPos, scrollOffset, 0); 
  Vslider.setValue (map (newPos, 0, scrollOffset, 0, 1 ));
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
      cur = i;
    } 
    else {
      regions[i].setIsCurrent(false);
    }
  }
  clicked = true;
  currentRegion = regions[cur].name;      
  regions[cur].setIsCurrent(true);   
  //regions[i].loc = 0; 
  regions[cur].totalHeight = 0;
  //regions[cur].yPos = -500;
  fromMap = false; 
}

void markCurrent() {
  for (int i = 0; i < regions.length; i++) {
    if (regions[i].isOverAnOrg()) {
      cur = i;
    } 
    else {
      regions[i].setIsCurrent(false);
      buttons[i].setIsCurrent(false);
    }
  }
  currentRegion = regions[cur].name;      
  regions[cur].setIsCurrent(true);
  //regions[cur].setOneCurrent(regions[cur].getCurOrg());
  buttons[cur].setIsCurrent(true);
  regions[cur].totalHeight = 0; 
  clicked = true;
  fromMap = true; 
}

void showCurRegion() {
  /*
  if (!fromMap) regions[cur].displayOrgs();  
  else regions[cur].displayOneOrg(regions[cur].getCurOrg());  
  */
  regions[cur].displayOrgs(); 
  regionTotalNum = regions[cur].orgList.size();
}

void drawTitleText (String title_) {
  fill (regions[cur].regColor); 
  rect (0, 0, rectW, 35);  
  fill (white); 
  textFont (fontBold, 18); 
  text (title_, 10, 25); 
  noStroke();
}

void goToLink(int whichOrg) {
  Org o = (Org) regions[cur].orgList.get (whichOrg);
  link (o.link, "hi"); 
  
}
      
void loadCSV(String fileName) {
  String [] file = loadStrings(fileName); 
  for (int i = 1; i < file.length; i++) {
    Org o = new Org(); 
    o.fromCSV(file[i].split("\t"));
    for (int j = 0; j < regions.length; j++) {
      if (o.region.contains(regions[j].name)) {
        regions[j].orgList.add (o);
      }
    }
  }
}


class Button {

  int xLoc, yLoc, w, h; 
  String regionName; 
  boolean isCurrent = false;
  color buttonColor; 

  Button(String name_) {
    regionName = name_; 

  }
  
  void set (int xLoc_, int yLoc_, int w_, int h_) {
    xLoc = xLoc_; 
    yLoc = yLoc_; 
    w = w_; 
    h = h_;
  }

  void setColor(color c) {
    buttonColor = c; 
  }

  void display() {
    color BG;
    color FG;
   // stroke (white);
    if (isCurrent) {
      BG = TSorange; 
      FG = TSblack; 
    } 
    else {
      BG = buttonColor; 
      FG = white; 
    }
    fill (BG); 
    rectMode (CORNERS);
    noStroke(); 
    rect (xLoc, yLoc, w, h); 
    rectMode (CORNER);
    textAlign (CENTER); 
    textFont (fontBold, 18); 
    fill (FG); 
    text (regionName.toUpperCase(), xLoc + 65, yLoc + 25);
    noStroke();
    textAlign (CORNER); 
  }

  boolean setRegion () {
    if (mouseX > xLoc && mouseX <  w && mouseY > yLoc && mouseY < h) {
      isCurrent = true; 
    } 
    else {
      isCurrent = false; 
    }
    return isCurrent;
  }
  
  void setIsCurrent (boolean is_) {
    isCurrent = is_; 
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
  float amplitude, period; 
  boolean isCurrent; 
  int   area; 
  boolean isFirst = false; //for animation
  boolean isLast = false; //for animation

  color myColor; 
  color regIDcolor; 
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
  
  int spread, tryCount; 

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

    float easeHeight = 1.1;
    boolean go; 
    float sx = newHeight - rectHeight;

    if (abs(sx) > 1) {
      rectHeight += sx * easeHeight;
      go = false;
    } 
    else {
      go = true;
    }

    if (isLast) {
      fill (0); 
      rect (width-rectWidth - scrollW, yPos + rectHeight, rectWidth, rectHeightDeet);//this rectangle acts as a BG
    } 
    else {
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
    text (name, orgNameX, 8+ yPos, 150, rectHeight);
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
            rectMode (CORNER); 
    textFont (font, 12); 
    textLeading (14); 
    text (description, width-rectWidth-scrollW + 10, 55 + yPos, rectWidth - 130, rectHeight- 60); 
      }

      linkLocX = orgNameX; 
      linkLocY = nameY; 
      textFont (fontBold, 10); 
      text ("WEBSITE", linkLocX, linkLocY);
    } 
    else {
      if (go) {
        nameX = width - 115;
        nameY = yPos + rectHeight - 10;
      }
    }
    textAlign (RIGHT); 
    textFont (font, 12);
    text (city, nameX, nameY); 
    textAlign (LEFT); 
    logoLocY =  (int)yPos + 10;
    logoLocX = width - 105;
    image (logo, logoLocX, logoLocY);
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
    spread = 10;
    tryCount = 0; 
    makeLocation();
  }

  void makeLocation() {
    randLoc = new PVector (int(random (location.x - spread, location.x + spread)), int(random (location.y - spread, location.y + spread))); 
    //mapLegend.loadPixels(); 
    //randLoc = location; 
     /*
    randLoc.x = constrain (randLoc.x, 0, mapLegend.width-1); 
    randLoc.y = constrain (randLoc.y, 0, mapLegend.height-1); 
    
   
    //color thisColor = mapLegend.get (int(randLoc.x), int (randLoc.y)); 
    color thisColor = mapLegend.pixels [int(randLoc.x) + (int (randLoc.y) * mapLegend.width)]; 
    println (regIDcolor + " " + thisColor + " here: " + abs (regIDcolor - thisColor));    //color thisColor = 40;
    if (regIDcolor > (thisColor - 100000) && regIDcolor <( thisColor + 100000)) {
      //println ("yes match"); 
      return;
    } 
    else {
      spread +=10;
      
      if (tryCount < 10) {
        tryCount ++;
      } else {
        spread +=10;
        tryCount = 0; 
      }
      
      //println ("spread: " + spread); 
      if (spread > 100) return;
      
      
      makeLocation();
    }
    
    */
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

class Region {
  ArrayList orgList; 
  String name;
  boolean isCurrent; 
  int curOrg; 
  color regColor; 
  color IDcolor;
  
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
        curOrg = i; 
        return true;
      }
    }
    return false;
  }

  int getCurOrg() {
    return curOrg;
  }

  int checkLogos() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.clickedLogo (offsetY, offset) && mousePressed) {
        return i;
      }
    }
    return -1;
  }

  boolean checkHover() {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.clickedLogo (offsetY, offset)) {
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
      if (i == orgList.size() -1) o.isLast = true; 
      o.drawRect(totalHeight);
    }
  }

  void displayOneOrg(int whichOrg) {
    Org o = (Org) orgList.get(whichOrg); 
    totalHeight = 0;
    o.isFirst = true; 
    o.isLast = true;
    o.drawRect (totalHeight);
  }

  void setOneCurrent (int whichOrg) {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      o.isCurrent = false;
    }

    Org oh = (Org) orgList.get(whichOrg);
    oh.isCurrent = true;
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
      o.isCurrent = is; 
      o.yPos = -rectH;
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

