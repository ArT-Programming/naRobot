// All the network UDP stuff goes here
import hypermedia.net.*; //UDP library by Stephane Cousot

UDP udp;  // define the UDP object

String remoteIP = "192.168.0.198"; //Hardcoded FTW!
int remotePort = 8080;
boolean remoteFound = false; // only send to remote if we know where to send it to
int listenPort = 8080;

byte val[] = new byte[2]; // values to send
int timeBetweenSends = 10; // send every 10 ms (draw() is probably not that fast anyway, so just as often as we can)
long lastSend = 0; // last time send
long lastRecieved = 0;

void startUDP() {
  println("Setting up UDP listener on Port ", listenPort);
  //println("Sending to ", remoteIP, ":", remotePort);
  udp = new UDP( this, listenPort );
  udp.listen( true );
  println("Waiting for incomming UPD package...");
}

// send values as byte array via udp to the remote ip and port
void sendData() {
  lastSend = millis();
  byte[] b = {val[0], val[1], byte(servoVal[0]), byte(servoVal[1])};
  //println("Chair:" ,b[0],b[1], "\t\tServo:",b[2],b[3]);
  udp.send( b, remoteIP, remotePort );
}

// this port recieved data from ip with port
void receive( byte[] data, String ip, int port ) {  // <-- extended handler ... void receive( byte[] data ) is the default
  // we now know the remote ip and port to send to
  if (!remoteFound) {
    println("Remote found on ", ip, ":", port);
    remoteFound = true;
    remoteIP = ip;
    remotePort = port;
  }
  if (data.length == medianDistance.length) {
    for (int i = 0; i < medianDistance.length; i++) {
      distanceArray[i][currentReading] = data[i] & 0xFF;
      medianDistance[i] = getMedian(distanceArray[i]);
    }
  }
  currentReading++;
  currentReading = currentReading % medianCount;

  lastRecieved = millis();
}

int getMedian(int[] array) {
  IntList values = new IntList();
  for (int i = 0; i < array.length; i++) {
    values.append(array[i]);
  }
  values.sort();
  return values.get(array.length/2);
}