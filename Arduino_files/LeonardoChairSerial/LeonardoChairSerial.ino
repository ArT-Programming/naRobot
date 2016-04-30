#include <SoftwareSerial.h>

int frame[9];

SoftwareSerial ServoPort(10, 11);

unsigned long timeToDo = 0;
unsigned long timeout = 0;
boolean timedOut = true;
void setup()
{
  // Chair commands
  frame[0] = 74;
  frame[1] = 0;
  frame[2] = 0;
  frame[3] = 0;
  frame[4] = 0;
  frame[5] = 181;

  // Servo commands
  frame[6] = 90; // servo 1 == x, pan
  frame[7] = 40; // servo 2 == y, tilt

  // Open serial communications and wait for port to open:
  ServoPort.begin(115200);
  Serial.begin(115200);
  Serial1.begin(38400, SERIAL_8E1);

  disable();

  //pinMode(0, INPUT_PULLUP);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  enable();


}

void disable() {
  UCSR1B &= ~bit (TXEN1); //disable TX
}
void enable() {
  //enables both rx and tx, even though rx is enabled already
  UCSR1B = (1 << RXEN1) | (1 << TXEN1) | (1 << RXCIE1);
}

void loop() // run over and over
{
  if (Serial.available()) {
    frame[0] = Serial.read();
    frame[1] = Serial.read();
    frame[2] = Serial.read();
    frame[3] = Serial.read();
    frame[4] = Serial.read();
    frame[5] = Serial.read();
    frame[6] = Serial.read();
    frame[7] = Serial.read();
    timeout = millis() + 1000;
    timedOut = false;
  }
  //send servo coordinates
  for (int i = 6; i < 8; i++) {
    ServoPort.write(frame[i]);
  }

  if ( millis() >= timeout) {
    timedOut = true;
  }

  if (timedOut) {
    disable();
  } else {
    enable();
  }

  if (!timedOut && millis() >= timeToDo) {

    for (int i = 0; i < 6; i++) {
      Serial1.write(frame [i]);
    }
    Serial1.flush();

    delayMicroseconds(500);
    disable();

    delay(3);

    enable();

    timeToDo = millis() + 10;
  }

  while (Serial1.available()) {
    Serial.write(Serial1.read());
  }
}




