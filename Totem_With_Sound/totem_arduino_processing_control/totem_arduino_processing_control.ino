#include <Servo.h>

class MotorDriver
{
    int enablePin, forwardsPin, backwardsPin;
  public:
    MotorDriver(int _enable, int _forwards, int _backwards) {
      enablePin = _enable;
      forwardsPin = _forwards;
      backwardsPin = _backwards;
      pinMode(enablePin, OUTPUT);
      pinMode(forwardsPin, OUTPUT);
      pinMode(backwardsPin, OUTPUT);
    }

    void goForwards(int Speed) {
      digitalWrite(forwardsPin, HIGH);
      digitalWrite(backwardsPin, LOW);
      analogWrite(enablePin, Speed);
    }

    void goBackwards(int Speed) {
      digitalWrite(forwardsPin, LOW);
      digitalWrite(backwardsPin, HIGH);
      analogWrite(enablePin, Speed);
    }

    void STOP() {
      digitalWrite(forwardsPin, LOW);
      digitalWrite(backwardsPin, LOW);
      analogWrite(enablePin, 0);
    }
};

static const int n = 3; //number of servo motors
static const int bytes = 4; //number of servo motors


Servo servo[n];  // create servo object to control a servo

MotorDriver arm(5, 6, 7);
MotorDriver body(11, 12, 13);

void setup()
{
  servo[0].attach(3); // pan
  servo[1].attach(9); // tilt 1
  servo[2].attach(10); // tilt 2, mirrored


  servo[0].write(70);
  servo[1].write(90);
  servo[2].write(mirrorServo(90));
  delay(1000);

  Serial.begin(115200);
}

void loop()
{
  // Totem head control
  int value[bytes];
  // digitalWrite(13, LOW);
  //if (Serial.available()) {
  if (Serial.find("x")) {
    //digitalWrite(13, HIGH);
    for (int i = 0; i < bytes; i++) {
      value[i] = Serial.parseInt();
    }
    servo[0].write(value[0]);
    servo[1].write(value[1]);
    servo[2].write(mirrorServo(value[1]));

    //arm
    if (value[2] == 0) {
      arm.STOP();
    }
    else if (value[2] > 0) {
      arm.goForwards(value[2]);
    }
    else if (value[2] < 0) {
      arm.goBackwards(abs(value[2]));
    }


    //value[3]; //body

    if (value[3] == 0) {
      body.STOP();
    }
    else if (value[3] > 0) {
      body.goForwards(value[3]);
    }
    else if (value[3] < 0) {
      body.goBackwards(abs(value[3]));
    }
  }
}

int mirrorServo(int servoVal) {
  int mirroredServoVal = 180;
  mirroredServoVal -= servoVal;
  return mirroredServoVal;
}


