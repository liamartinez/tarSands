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


