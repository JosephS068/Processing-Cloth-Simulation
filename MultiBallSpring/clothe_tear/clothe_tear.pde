import ddf.minim.*;

AudioPlayer player;
Minim minim;

int threadCount = 25;
int springPerThread = 35;
Ball[] balls = new Ball[threadCount * springPerThread];
ArrayList<Spring> springs = new ArrayList<Spring>();
PImage horde ;
float roof = 0 ;
float floor = 10000 ;
float restLen = 8 ;
float k = 50;
float kv = 30;
float radius = 10 ;
PVector gravity = new PVector(0, 1, 0) ;
PVector stringStart = new PVector(200, 200) ;
PVector vair = new PVector(0 , 0, 0) ;
float drag = 0.000008 ;
float maxForce = 375.0;

// Environment Collision
PVector floorTranslations = new PVector(100, 800, 100);
int[] floorDimensions = {10000, 300, 10000};

// Sword Collisions
PVector swordMovement = new PVector(0, 0, 0);
PVector swordTranslations  = new PVector(0, 100, 125);
PShape sword;

// Background elements
int numSwords = 200;
float[] swordsX = new float[numSwords];
float[] swordsZ = new float[numSwords];
float[] swordsRotate = new float[numSwords];
int numRocks = 15;
PShape rock;
float[] rockX = new float[numRocks];
float[] rockZ = new float[numRocks];
float[] rockScales = new float[numRocks];

PImage ground;

void setup(){
  size(1000, 1000, P3D);
  minim = new Minim(this);
  player = minim.loadFile("graveyard.mp3", 1024);
  player.play();
  
  generateBalls();
  camera = new Camera();
  sword = loadShape("Sword_Golden.obj");
  horde = loadImage("horde.png") ;
  rock = loadShape("rock.obj");
  ground = loadImage("ground.jpeg");
  for(int i=0; i<numSwords; i++) {
    swordsX[i] = random(-4000, 4000);
    swordsZ[i] = random(-4000, 4000);
    swordsRotate[i] = random(2 * PI);
  }
  
  for(int i=0; i<numRocks; i++) {
    rockX[i] = random(-4000, 4000);
    rockZ[i] = random(-4000, 4000);
    rockScales[i] = random(110, 160);
  }
}

void draw(){
  background(0, 0, 0) ;
  lights();  
  drawEnv();
  
  // Sword sphere location
  swordTranslations.x += swordMovement.x;
  swordTranslations.y += swordMovement.y;
  swordTranslations.z += swordMovement.z;
  
  pushMatrix();
  translate(swordTranslations.x, swordTranslations.y, swordTranslations.z);
  rotateX(-PI/2);
  scale(50);
  shape(sword);
  popMatrix();
  
  for(int i = 0 ;i < 100; i++){
    update(0.1/frameRate) ;
  }
  camera.Update(1/frameRate) ;
  fill(255, 255, 255) ;
  
  // texture the cloth    
  noStroke() ;
  noFill() ;
  textureMode(NORMAL);
  for(int i = 0 ; i < springPerThread - 1; i++){
    beginShape(TRIANGLE_STRIP);
    texture(horde) ;
    for(int j = 0 ; j < threadCount; j++){
      // get related balls
      Ball right = balls[i + j*springPerThread];
      Ball downRight = balls[i+1 + j*springPerThread];
      if (downRight.up != null && right.left != null && downRight.up.exists && right.left.exists) {
        float u = map(j, 0, threadCount, 0, 1) ;
        float v1 = map(i, 0, springPerThread, 0, 1) ;
        float v2 = map(i+1, 0, springPerThread, 0, 1) ;
        vertex(right.pos.x, right.pos.y, right.pos.z, u, v1) ;
        vertex(downRight.pos.x, downRight.pos.y, downRight.pos.z, u, v2) ;
      }
    }
    endShape() ;
  }
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));
  
  swordCut();
}

void drawEnv() {
  // create sky
  pushMatrix();
  fill(68, 77, 120);
  translate(-5000, -5000, 5000);
  rect(0, 0, 10000, 10000);
  popMatrix();
  
  pushMatrix();
  fill(68, 77, 120);
  translate(-5000, -5000, -5000);
  rect(0, 0, 10000, 10000);
  popMatrix();
  
  pushMatrix();
  fill(68, 77, 120);
  translate(-5000, -5000, -5000);
  rotateX(PI/2);
  rect(0, 0, 10000, 10000);
  popMatrix();
  
  pushMatrix();
  fill(68, 77, 120);
  translate(-5000, -5000, 5000);
  rotateY(PI/2);
  rect(0, 0, 10000, 10000);
  popMatrix();
  
  pushMatrix();
  fill(68, 77, 120);
  translate(5000, -5000, 5000);
  rotateY(PI/2);
  rect(0, 0, 10000, 10000);
  popMatrix();
    
  pushMatrix() ;
  fill(100, 100, 50);
  translate(floorTranslations.x, floorTranslations.y, floorTranslations.z) ;
  box(floorDimensions[0], floorDimensions[1], floorDimensions[2]) ; 
  popMatrix() ;
  
  for(int i=0; i<numSwords; i++) {
    pushMatrix();
    rotateY(swordsRotate[i]);
    translate(swordsX[i], 475, swordsZ[i]);
    scale(50);
    rotateZ(.35);
    shape(sword);
    popMatrix();
  }
  for(int i=0; i<numRocks; i++) {
    pushMatrix();
    translate(rockX[i], 650, rockZ[i]);
    scale(rockScales[i]);
    rotateZ(PI);
    shape(rock);
    popMatrix();
  }
}

void generateBalls() {
  for(int i=0; i<balls.length; i++) {
    PVector pos = new PVector(100 + (i/springPerThread)* restLen, (i%springPerThread)*restLen, -10)  ;
    PVector vel = new PVector(0, 0, 0) ;
    PVector acc = new PVector(0 , 0, 0) ;
    float mass = 1;
    balls[i] = new Ball(pos, vel, acc, mass);
  }
  
  for(int i=0; i<balls.length-1; i++) {
    if (i % springPerThread != springPerThread-1) {
      Spring newSpring = new Spring(balls[i], balls[i+1]);
      springs.add(newSpring);
      balls[i].down = newSpring;
      balls[i+1].up = newSpring;
    }
    int hoz = i + springPerThread ;
    if(hoz < balls.length){
      Spring newSpring = new Spring(balls[i], balls[i+springPerThread]);
      springs.add(newSpring);
      balls[i].right = newSpring;
      balls[i+springPerThread].left = newSpring;
    }
  }
}

void update(float dt){
  for (int i = 0 ; i < balls.length;i++) {
    int x = i / springPerThread ;
    if (vair.z > 100 || i % springPerThread != 0 || x% 4 != 0 ){
      UpdatePosition(balls[i], dt);
      PVector dv = PVector.mult(PVector.add(gravity, balls[i].acc), dt) ;
      balls[i].vel.add(dv) ;
    }
    
    balls[i].acc = new PVector(0,0,0);  // Zero out vectors 
  }
  // Get acceleration for next time step
  for(int i=0; i<springs.size(); i++) {
    if(springs.get(i).exists) {
      boolean broken;
      broken = calculateAccleration(springs.get(i).bottom, springs.get(i).top);
      springs.get(i).exists = !broken;
    }
  }
}

void UpdatePosition(Ball ball, float dt){  
  // Floor Detection
  float floorPos = floorTranslations.y - (floorDimensions[1]/2) - 2;
  PVector possiblePostion = PVector.add(ball.pos, PVector.mult(ball.vel, dt));
  if(possiblePostion.y < floorPos) {
    ball.pos.add(PVector.mult(ball.vel, dt)) ;
  } else {
    ball.vel = new PVector(0, 0, 0);
    ball.acc = new PVector(0, 0, 0);
  }
}

boolean calculateAccleration(Ball ball2, Ball ball1) {
  PVector stringVector = PVector.sub(ball2.pos, ball1.pos) ;
  float stringLen = stringVector.mag() ;
  float currLen = stringLen - restLen ;
  
  stringVector.normalize() ;
  PVector stringVectorUnit = stringVector;
  PVector stringForce1 = new PVector(0, 0, 0) ;
  float dampenForce = -kv* (ball2.vel.dot(stringVectorUnit) - ball1.vel.dot(stringVectorUnit));
  PVector dampForceVector  = PVector.mult(stringVectorUnit, dampenForce);
  stringForce1 = stringVectorUnit.mult(-k*currLen) ;
  stringForce1.div(2*ball2.mass) ;
  dampForceVector.div(2*ball2.mass) ;
  ball2.acc.add(PVector.add(stringForce1, dampForceVector)) ;
  
  ball1.acc.sub(PVector.add(stringForce1, dampForceVector)) ;
  if (abs(stringForce1.mag()) > maxForce) {
    return true;
  } else {
    return false;
  }
}

class Ball {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  
  Spring up = null;
  Spring right = null;
  Spring left = null;
  Spring down = null;
  
  Ball (PVector pos, PVector vel, PVector acc, float mass) {
    this.pos = pos;
    this.vel = vel;
    this.acc = acc;
    this.mass = mass;
  } 
}

class Spring {
  Ball top;
  Ball bottom;
  boolean exists ;
  
  Spring (Ball top, Ball bottom) {
    this.top = top;
    this.bottom = bottom;
    exists = true ;
  } 
} 

void swordCut() {
  for(int i=0; i<springs.size(); i++) {
    float hitBoxXRight = swordTranslations.x + 10;
    float hitBoxXLeft = swordTranslations.x - 10;
    float hitBoxY = swordTranslations.y;
  
    Ball top = springs.get(i).top;
    Ball bottom = springs.get(i).bottom;
    if(top.pos.y > bottom.pos.y) {
      top = springs.get(i).bottom;
      bottom = springs.get(i).top;
    }

    if (top.pos.x < hitBoxXRight && top.pos.x > hitBoxXLeft
        && bottom.pos.x < hitBoxXRight && bottom.pos.x > hitBoxXLeft
        && top.pos.y < hitBoxY && bottom.pos.y > hitBoxY) {
          springs.get(i).exists = false;
    }
  }
}

void keyPressed() {
  if (keyCode == 32) vair.z += 10 ;
  if (keyPressed && key == 'n' || key == 'N') vair.z -= 10;
  if (keyPressed && key == 'g' || key == 'G') swordMovement.x = -6;
  if (keyPressed && key == 'j' || key == 'J') swordMovement.x = 6;
  if (keyPressed && key == 'y' || key == 'Y') swordMovement.y = -6;
  if (keyPressed && key == 'h' || key == 'h') swordMovement.y = 6;
  camera.HandleKeyPressed();
}

void keyReleased() {
  if (key == 'n' || key == 'N') vair.z -= 10;
  if (key == 'g' || key == 'G') swordMovement.x = 0;
  if (key == 'j' || key == 'J') swordMovement.x = 0;
  if (key == 'y' || key == 'Y') swordMovement.y = 0;
  if (key == 'h' || key == 'H') swordMovement.y = 0;

  camera.HandleKeyReleased();
}
