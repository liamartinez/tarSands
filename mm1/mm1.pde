/* @pjs preload="map.png"; */
/* @pjs preload="tsmmlogo.png"; */
/* @pjs preload="tswhatis.png"; */


PImage movementMap;
PImage tsmmlogo; 
PImage tswhatis;
int curCity, lastCity; 

MercatorMap mercatorMap;
Sidebar sidebar; 

ArrayList orgList;

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

void setup() {
  frameRate (40); 
  orgList = new ArrayList(); 
  movementMap   = loadImage("map.png");
  tsmmlogo = loadImage ("tsmmlogo.png"); 
  tswhatis = loadImage ("tswhatis.png"); 
  size (1000, 392); //manual entry 
  mercatorMap = new MercatorMap(900, 392, 60.9304, -3.5134, -171.5625, 14.0625);
  //-171.5625,-3.5134,14.0625,60.9304
  //last one, second one, first one, third one
  sidebar = new Sidebar(); 

  loadCSV("MovementMapData - Sheet1.csv");
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
  for (int i = 0; i < orgList.size(); i++) {
    Org o = (Org) orgList.get(i); 
    o.display();
  }

  popMatrix();

  //sidebar
  markCurrent();
  sidebar.display(); 
  showCurOrgs();
}

boolean isOverAnOrg() {
  for (int i = 0; i < orgList.size(); i++) {
    Org o = (Org) orgList.get(i); 
    if (o.isOverACity()) {
      return true;
    }
  }
  return false;
}

void markCurrent() {
  if (isOverAnOrg()) {
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.isOverACity()) {
        o.isCurrent = true;
      } 
      else {
        o.isCurrent = false;
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
   if (o.isOverACity()) {
   curCityName = o.cityName; 
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

  void showCurOrgs() {
    int count = 0; 
    String curCityName = ""; 
    for (int i = 0; i < orgList.size(); i++) {
      Org o = (Org) orgList.get(i); 
      if (o.isCurrent) {
        curCityName = o.cityName; 
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


  void loadCSV(String fileName) {
    String [] file = loadStrings(fileName); 
    for (int i = 1; i < file.length; i++) {
      Org o = new Org(); 
      o.fromCSV(file[i].split(","));
      orgList.add (o);
    }
  }

