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

  ArrayList cities; 
  color myColor; 
  float circleS; 
  float rate; 
  boolean isCurrent; 
  String name; 
  String description; 
  String fileName; 
  String cityName;
  
  Org() {
    cities = new ArrayList();
    myColor = colors[int(random(colors.length))]; 
    circleS = int(random(5, 15)); 
    rate = random (circleS, circleS+20); 
    isCurrent = false; 
  }



  void fromCSV(String[] input) {
    name = input[0]; 
    cityName = input[1];
    description = input[10];
    /*
    if (input[10].length() == 0) {
      description = "description"; 
    } else {
      description = input[10];
    }
      */
    //fileName = input[9];

    //if there is not another city - todo clean
    City thisCity = new City(); 
    thisCity.lat = float(input[3]); 
    thisCity.lng = float(input[2]); 
    thisCity.setCoords(); 
    cities.add (thisCity); 

    /*
    if (input[5] != null) {
     City thisCity2 = new City(); 
     thisCity2.lat = float(input[7]); 
     thisCity2.lng = float(input[6]); 
     cities.add (thisCity2); 
     }
     */
  } 

  void display() {

    for (int i = 0; i < cities.size(); i++) {
      City c = (City) cities.get(i);
      if (isOverACity()) {
        fill (255);
      } 
      else {
        fill (myColor, 175);
      }
      noStroke(); 
      circleS = circleS + cos( frameCount/ rate);
      ellipse (c.location.x, c.location.y, circleS, circleS);
      ellipse (c.location.x, c.location.y, 5, 5);
    }
  }

  boolean isOverACity() {
    for (int i = 0; i < cities.size(); i++) {
      City c = (City) cities.get(i);
      if (c.isInside (mouseX, mouseY)) 
        return true;
    }
    return false;
  }
}

class City {
  float lat, lng; 
  PVector location; 
  int   area = 10; 

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

