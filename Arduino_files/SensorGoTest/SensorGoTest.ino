// Includes the Servo library
#include <Servo.h>.
// Defines Tirg and Echo pins of the Ultrasonic Sensor
const int trigPin = 10;
const int echoPin = 11;
// Variables for the duration and the distance
long duration;
unsigned char distance;
Servo myServo; // Creates a servo object for controlling the servo motor

void setup() {
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  Serial.begin(9600);
  myServo.attach(12); // Defines on which pin is the servo motor attached
  myServo.write(150);
  
}

void loop() {
  // rotates the servo motor from 15 to 165 degrees
  for (unsigned char i = 15; i <= 165; i++) {
    // myServo.write(i);
    delay(30);
    distance = calculateDistance();// Calls a function for calculating the distance measured by the Ultrasonic sensor for each degree

    unsigned char buf[3] = {255, i, distance};
    
    //byte buf[3] = {255, 255, 255};
    Serial.write(buf, 3);
  }
  // Repeats the previous lines from 165 to 15 degrees
  for (unsigned char i = 165; i > 15; i--) {
    //myServo.write(i);
    delay(30);
    distance = calculateDistance();

    byte buf[3] = {255, i, distance};
    Serial.write(buf, 3);
  }
}
// Function for calculating the distance measured by the Ultrasonic sensor
int calculateDistance() {

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH); // Reads the echoPin, returns the sound wave travel time in microseconds
  distance = duration * 0.034 / 2;
  return distance;
}
