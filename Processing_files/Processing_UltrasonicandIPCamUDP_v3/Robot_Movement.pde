boolean doSpin = false;
long startSpinTime = 0;
boolean doRampage = false;
byte spinDirection = 1;
long lastDirectionTime = 0;
int allowNewTurnDirectionAfter = 6000;
byte rampageSpeed = -70;

void stopMotors() {
  val[0] = 0;
  val[1] = 0;
}

boolean spin() {
  if (!doSpin) {
    randomDirection();
    startSpinTime = millis();
  }
  if (millis() < startSpinTime + 5000) {
    val[1] = byte(50 * spinDirection);
    val[0] = 0;
    return true;
  }
  return false; //continue
}

void calculateDirection() {
  if (millis() > lastDirectionTime + allowNewTurnDirectionAfter) {
    if (medianDistance[0] != 0 && medianDistance[0] < medianDistance[sensorCount-1]) {
      spinDirection = 1;
    } else if (medianDistance[sensorCount-1] != 0 && medianDistance[sensorCount-1] < medianDistance[0]) {
      spinDirection = -1;
    } else {
      randomDirection();
    }
    /*
    if(medianDistance[] < 40){
     soun a lot!
     }
     */
  }
}

void randomDirection() {
  spinDirection = byte(random(2));
  if (spinDirection == 0) spinDirection = -1;
  lastDirectionTime = millis();
}

void rampage() {
  val[0] = rampageSpeed;
  val[1] = 0;
  for (int i = 0; i < medianDistance.length; i++) {
    if (medianDistance[i] != 0 && medianDistance[i] < distanceThreshold) {
      calculateDirection();
      val[0] = 0;
      val[1] = byte(60*spinDirection);
    }
  }
}