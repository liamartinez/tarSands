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
int rectHDetail = 150; 

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

  loadCSV("MovementMapData - Partner Data - pulled into map.tsv");

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

