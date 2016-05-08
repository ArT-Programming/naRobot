static final int medianCount = 3;
static final int sensorCount = 5;
int medianDistance[] = new int[sensorCount];
int distanceArray[][] = new int[sensorCount][medianCount];
int distanceThreshold = 120;
int currentReading = 0;