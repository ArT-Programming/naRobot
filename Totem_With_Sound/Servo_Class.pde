enum Status{ // different states
  sleep, wake, lookLeft, lookRight, nodYesUp, nodYesDown, nodNoLeft, nodNoRight, jitter
};

class Servo {
  int pos;
  long lastStepTime;

  public Servo(int _pos) {
    super();
    pos = _pos;
    MoveTo(pos);
  }
 
  void MoveTo(int _toPos) {
    pos = _toPos;
  }
  
  public boolean MoveTo(int _toPos, int _velocity) {
    // _toPos = map(_toPos, 0, 100, minimum, maximum);

    if (pos == _toPos) { 
      return true;
    }

    int timeBetweenSteps = 1000 / _velocity;

    if (millis() > lastStepTime + timeBetweenSteps) {
      if (pos > _toPos) { 
        pos--;
      } else if (pos < _toPos) { 
        pos++;
      }
      lastStepTime = millis();
    }

    if (pos == _toPos) { 
      return true;
    } else { 
      return false;
    }
  }
}