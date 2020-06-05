float g = 300;
float floor = 100;
float dx = 10;
float length = 600;
int segments = int(length / dx);
float[] h = new float[segments];
float[] uh = new float[segments];
float[] hm = new float[segments];
float[] uhm = new float[segments];
PVector start = new PVector(-800, -600) ;

PShape platform;
PShape chest;
PShape flag;
PShape shark;

void setup() {
  size(1000, 1000, P3D);
  camera = new Camera();
  platform = loadShape("Platform_TopMiddle.obj");
  chest = loadShape("chest.obj");
  flag = loadShape("Flag.obj");
  shark = loadShape("Shark.obj");
  for (int i = 0; i < segments; i++) {
    h[i] = 350 - 2*i ;
    uh[i] = 0 ;
    uhm[i] = 0 ;
    hm[i] = 0 ;
  }
}

void update(float dt) {
  for (int i=0; i<segments-1; i++) {
    hm[i] = (h[i]+h[i+1])/2.0 - (dt/2.0)*(uh[i+1]-uh[i])/dx;

    uhm[i] = (uh[i]+uh[i+1])/2.0 - (dt/2.0)*(
      sqr(uh[i+1])/h[i+1] + .5*g*sqr(h[i+1]) - 
      sqr(uh[i])/h[i] - .5*g*sqr(h[i]))/dx;
  }

  float damp = 3;
  for (int i=0; i<segments-2; i++) {
    h[i+1] -= dt*(uhm[i+1]-uhm[i])/dx;
    uh[i+1] -= dt*(damp*uh[i+1] + sqr(uhm[i+1])/hm[i+1] +
      .5*g*sqr(hm[i+1]) - sqr(uhm[i])/hm[i] - .5*g*sqr(hm[i]))/dx;
  }

  h[0] = h[1];
  h[segments-1] = h[segments-2];
  uh[segments-1] = -uh[segments-2] * 0.2;
  uh[0] = -uh[1]*0.2;
}

float sqr(float num) {
  return pow(num, 2);
}

void draw() {
  background(215, 215, 255);
  for (int i = 0; i < 5000; i++) {
    update(0.000005);
  }
  pushMatrix();
  rotate(PI);
  for (int i=0; i<segments-1; i++) {
    noStroke() ;
    fill(50, 100, 200);

    //Draw front
    beginShape(QUADS);
    vertex(start.x + (i*dx), start.y+h[i], 0) ;
    vertex(start.x + (i+1)*dx, start.y+h[i+1], 0) ;
    vertex(start.x+(i+1)*dx, start.y, 0) ;
    vertex(start.x + (i*dx), start.y, 0) ;
    endShape();

    // Draw top
    int zWater = -790;
    int offest = 0;
    beginShape(QUADS);
    vertex(-offest + start.x + (i*dx), start.y+h[i], 0) ;
    vertex(offest + start.x + (i+1)*dx, start.y+h[i+1], 0) ;
    vertex(offest + start.x+(i+1)*dx, start.y+h[i+1], zWater) ;
    vertex(-offest + start.x + (i*dx), start.y+h[i], zWater) ;
    endShape();

    // Draw back
    beginShape(QUADS);
    vertex(start.x + (i*dx), start.y+h[i], zWater) ;
    vertex(start.x + (i+1)*dx, start.y+h[i+1], zWater) ;
    vertex(start.x+(i+1)*dx, start.y, zWater) ;
    vertex(start.x + (i*dx), start.y, zWater) ;
    endShape();
  }
  popMatrix();
  camera.Update(1/frameRate);
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));

  pushMatrix();
  rotate(PI);
  translate(40, -350, -400);
  scale(250);
  shape(platform);
  popMatrix();

  pushMatrix();
  rotate(PI);
  translate(-1050, -350, -400);
  scale(250);
  shape(platform);
  popMatrix();

  pushMatrix();
  rotate(PI);
  rotateY(PI);
  translate(500, -600, 500);
  scale(40);
  shape(chest);
  popMatrix();

  pushMatrix();
  rotate(PI);
  translate(-1000, -200, -300);
  scale(150);
  shape(flag);
  popMatrix();
  
  pushMatrix();
  translate(800, -1*((h[6] + h[8] + h[10])/3)+700, -300);
  rotate(PI);
  rotateY(PI/2);
  rotateX(-PI/4);
  scale(30);
  shape(shark);
  popMatrix();

  pushMatrix();
  fill(0, 0, 0);
  translate(0, 900, -225);
  box(6000, 600, 300);
  popMatrix();
}

void addWater() {
  for (int i = 0; i < segments/3; i++) {
    int pos = segments/3 - i;
    if (h[pos] < 400) {
      h[pos] += i*2 ;
    }
  }
}

void removeWater() {
  for (int i = 0; i < segments/3; i++) {
    int pos = segments/3 - i;
    if (h[pos] > 100) {
      h[pos] -= i*2 ;
    }
  }
}

void keyPressed() {
  if (keyPressed && key == 'h' || key == 'H') addWater();
  if (keyPressed && key == 'j' || key == 'J') removeWater();
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
}
