// All the interfaces and drawing functions go here

void drawSensorValues() {
  // draw threshold in red
  noStroke();
  fill(255, 0, 0, 100);
  rectMode(CORNERS);
  rect(0, height-2*distanceThreshold, width, height);

  // draw sensor values in blue
  stroke(0, 200, 255, 150);
  strokeWeight(50);
  strokeCap(SQUARE);
  int xOffset = width / (2*medianDistance.length);
  for (int i = 0; i < medianDistance.length; i++) {
    int x = (i * width / medianDistance.length) + xOffset;
    int y = 0;
    if (medianDistance[i] != 0)
      y = height - 2*medianDistance[i];
    line(x, height, x, y);
  }
}

void drawCoordinateSystem() {
  stroke(0);
  strokeWeight(3);
  ;
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
}