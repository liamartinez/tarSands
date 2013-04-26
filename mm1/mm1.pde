/* @pjs preload="map.png"; */
/* @pjs preload="tsmmlogo.png"; */
/* @pjs preload="tswhatis.png"; */


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
  newPos += mouseScroll*10; 
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

