final int WIDTH = 1000;
final int HEIGHT = 560;

LightRay[] lazors = new LightRay[50];

void settings() {
  size(WIDTH, HEIGHT);
}

int activeMirrorCount = 4;
int mirrorCountStep = 2;

void setup() {
  frameRate(10);

  for (int i = 0; i < lazors.length; i++) {
    float x = 20 + i*(width-20)/lazors.length;
    float y = 20;
    lazors[i] = new LightRay(x, y, HALF_PI);
  }
}

void draw() {
  background(255);
  
  activeMirrorCount = constrain(activeMirrorCount,4,200);

  Mirror[] mirrors = new Mirror[activeMirrorCount];

  PVector[] corners = new PVector[mirrors.length + 1];
  for (int i = 0; i < corners.length; i++) {
    final float X_SCALAR = 500.0/corners.length, Y_SCALAR = 300.0/(X_SCALAR*X_SCALAR*corners.length*corners.length);
    float x = X_SCALAR * (i - (corners.length-1)/2.0);
    float y = Y_SCALAR * x*x;
    corners[i] = new PVector(width/2.0 + x, height - y);
  }
  for (int i = 0; i < mirrors.length; i++) {
    mirrors[i] = new Mirror(corners[i], corners[i+1]);
  }

  activeMirrorCount+=mirrorCountStep;
  if (activeMirrorCount > 200 || activeMirrorCount < 4) {
    
    mirrorCountStep *= -1;
    activeMirrorCount += mirrorCountStep;
  }

  for (LightRay l : lazors) {
    l.reflect(mirrors);
  }
  for (int i= 0; i < mirrors.length; i++) {
    mirrors[i].drawMe();
  }

  for (LightRay l : lazors) {
    l.drawMe(#FFEE00);
  }
  fill(0);
  textAlign(LEFT, BOTTOM);
  textSize(25);
  text("#Mirrors = " + (activeMirrorCount-mirrorCountStep), 0, height);
}

boolean running = true;
void keyPressed() {
  if (key == ' ') {
    if (running) {
      noLoop();
      running = false;
    } else {
      loop();
      running = true;
    }
  } else if (keyCode == UP) {
    activeMirrorCount += 2 - mirrorCountStep;
    redraw();
  } else if (keyCode == DOWN) {
    activeMirrorCount += -2 - mirrorCountStep;
    redraw();
  }
}
