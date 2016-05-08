CameraFrame camFeed;

void settings() {
  // create window and setup a simple coordinate system
  size(500, 500);
}

void setup() {
  // Screen location
  surface.setLocation(200, 200);

  camFeed = new CameraFrame(this, 320, 240, "camera feed" );

  startUDP();
  resetServos();

  frameRate(120);
}

void draw() {
  background(150);

  drawSensorValues();
  drawCoordinateSystem();

  if (remoteFound) {
    if (doRampage && (camFeed.iSeeFace || doSpin)) {
      //doSpin = spin();
      camFeed.lastFaceTime = millis();
      stopMotors();
    } else if (doRampage) {
      if (millis() > camFeed.lastFaceTime + 1000) {
        servoGoTo(90, 40);
      }
      rampage();
    } else if (mousePressed) {
      calculateXY();
    } else {
      stopMotors();
    }

    if (millis() > lastSend + timeBetweenSends) {
      sendData();
    }
  }
}

// send zero when program exits
void exit() {
  val[0] = 0;
  val[1] = 0;
  sendData();
  super.exit();
}