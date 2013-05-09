
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

PVector locationWA;

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
  mapLegend = loadImage ("map_transparent_wcolor.png");
  
  temp = loadImage ("FPO_map1_1000x385.png"); 
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
      //o.setColor (colors[colorCount]); //lia
      o.setColor (regions[i].IDcolor); 
      zero = !zero; 
    }
  }

  cur = 0; 
  currentRegion = regions[cur].name;      
  regions[cur].setIsCurrent(true);
  buttons[cur].setIsCurrent(true);
  
  locationWA = new PVector (width/2, height/2); 
}


void draw() {
  background (0); 
mapLegend.loadPixels();
  //map
  pushMatrix();
  translate (-offset, offsetY); 
  image (movementMap, 0, 0);  
  image (mapLegend, 0, 0);  

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
  
  ellipse (locationWA.x, locationWA.y, 30, 30); 
}

void mousePressed() {
  if (mouseY > mapBorder && mouseX < width-rectW)  markCurrent();
  if (mouseY < mapBorder && mouseX < width-rectW) markButton();       

  regions[cur].checkClicks(); //toggle detail/ no detail
  
  //println ("mouseX: " + mouseX + " mouseY: " + mouseY);
  int orgLinked = regions[cur].checkLogos();
  //if (orgLinked != -1) goToLink(orgLinked);   
  
    color thisC = mapLegend.get (mouseX + offset, mouseY - offsetY); 
    for (int i = 0; i < regID.length; i++) {
        if (thisC > (regID[i] - 100000) && thisC <( regID[i] + 100000)) {
      println ("match: " + regions[i].name);
    }
    }
}

void mouseScrolled() {
  //newPos += mouseScroll*10; 
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


