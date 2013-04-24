class Org {

  ArrayList cities; 
  color myColor; 
  float circleS; 
  float rate; 
  boolean isCurrent; 
  String name; 
  String description; 
  String fileName; 
  //String cityName;
  String currentCity = "";
  
  Org() {
    cities = new ArrayList();
    myColor = colors[int(random(colors.length))]; 
    circleS = int(random(5, 15)); 
    rate = random (circleS, circleS+20); 
    isCurrent = false; 
  }



  void fromCSV(String[] input) {
    name = input[0]; 
    
    description = input[11];
    /*
    if (input[11].length() == 0) {
      description = "description"; 
    } else {
      description = input[11];
    }
      */
    //fileName = input[10];

    //if there is not another city - todo clean
    City thisCity = new City(); 
    thisCity.name = input[1]; 
    thisCity.lat = float(input[4]); 
    thisCity.lng = float(input[3]); 
    thisCity.setCoords(); 
    cities.add (thisCity); 
   
    if (input[5] != "") {
     City thisCity2 = new City(); 
     thisCity2.name = input[6];
     thisCity2.lat = float(input[8]); 
     thisCity2.lng = float(input[7]); 
     thisCity2.setCoords(); 
     cities.add (thisCity2); 
     }
     
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
      circleS = circleS + cos( frameCount/ rate); //for individual pulsing
      ellipse (c.location.x, c.location.y, circleS, circleS);
      ellipse (c.location.x, c.location.y, 5, 5);
    }
  }

  boolean isOverACity() {
    for (int i = 0; i < cities.size(); i++) {
      City c = (City) cities.get(i);
      if (c.isInside (mouseX, mouseY)) {
        currentCity = c.name; 
        return true;
      }
    }
   return false;
  }

}

class City {
  float lat, lng; 
  PVector location; 
  int   area = 5; 
  String name; 

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


