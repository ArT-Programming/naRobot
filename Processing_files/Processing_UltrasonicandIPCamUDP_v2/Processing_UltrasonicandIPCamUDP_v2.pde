
void setup() {
  // create window and setup a simple coordinate system
  size(500, 500);
  startCamera("http://192.168.0.153:8080/video");
  startUDP();
  resetServos();
}

void draw() {
  background(150);

  drawCamera();
  boolean faceDetected = findFaces();

  drawSensorValues();
  drawCoordinateSystem();

  if (remoteFound) {
    if (doRampage && (faceDetected || doSpin)) {
      //doSpin = spin();
      lastFaceTime = millis();
      stopMotors();
    } else if (doRampage) {
      if (millis() > lastFaceTime + 1000) {
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