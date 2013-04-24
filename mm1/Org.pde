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
   
    if (input[5] != "") {
     City thisCity2 = new City(); 
     thisCity2.lat = float(input[7]); 
     thisCity2.lng = float(input[6]); 
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
  int   area = 5; 

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


