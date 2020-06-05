int threadCount = 30;
int springPerThread = 30;
Ball[] balls = new Ball[threadCount * springPerThread];
ArrayList<Spring> springs = new ArrayList<Spring>();
ArrayList<Spring> extraSprings = new ArrayList<Spring>();
PImage graf ;
float roof = 0 ;
float floor = 10000 ;
float k = 50;
float kv = 30;
float radius = 10 ;
PVector gravity = new PVector(0, 1, 0) ;
PVector stringStart = new PVector(200, 200) ;
PVector vair = new PVector(0 , 0, 0) ;
float drag = 0.000008 ;
float restLen = 8 ;

// Environment Collision
PVector floorTranslations = new PVector(100, 800, 100);
int[] floorDimensions = {10000, 300, 10000};


void setup(){
  size(1000, 1000, P3D);
  generateBalls();
  camera = new Camera();
  graf = loadImage("graffiti.jpg") ;
}

void draw(){
  background(0, 0, 0) ;
  lights();  
  drawEnv();
  
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
    texture(graf) ;
    for(int j = 0 ; j < threadCount; j++){
      // get related balls
      Ball right = balls[i + j*springPerThread];
      Ball downRight = balls[i+1 + j*springPerThread];
      if (downRight.up != null && right.left != null) {
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
}

void drawEnv() {
  pushMatrix() ;
  fill(100, 100, 50);
  translate(floorTranslations.x, floorTranslations.y, floorTranslations.z) ;
  box(floorDimensions[0], floorDimensions[1], floorDimensions[2]) ; 
  popMatrix() ;
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
      Spring newSpring = new Spring(balls[i], balls[i+1], restLen);
      springs.add(newSpring);
      balls[i].down = newSpring;
      balls[i+1].up = newSpring;
    }
    int hoz = i + springPerThread ;
    if(hoz < balls.length){
      Spring newSpring = new Spring(balls[i], balls[i+springPerThread], restLen);
      springs.add(newSpring);
      balls[i].right = newSpring;
      balls[i+springPerThread].left = newSpring;
    }
  }
  
  for(int i=0; i<balls.length; i++) {
    addExtraSprings(balls[i]);
  }
}

void addExtraSprings(Ball ball) {
  if (ball.down != null && ball.down.bottom.down != null) {
    // go down twice for connection
    addExtraSpringLeft(ball.down.bottom.down.bottom, 1, ball);
    addExtraSpringRight(ball.down.bottom.down.bottom, 1, ball);
  }
}

float extraRestLen = sqrt((pow(2 * restLen, 2) * 2));
void addExtraSpringLeft(Ball ball, int leftMoves, Ball original) {
  if (ball.left != null && leftMoves < 2) {
    leftMoves++;
    addExtraSpringLeft(ball.left.top, leftMoves, original);
  }
  if(leftMoves == 2) {
    Spring newSpring = new Spring(ball, original, extraRestLen);
    extraSprings.add(newSpring);
  }
}

void addExtraSpringRight(Ball ball, int rightMoves, Ball original) {
  if (ball.right != null && rightMoves < 2) {
    rightMoves++;
    addExtraSpringRight(ball.right.bottom, rightMoves, original);
  }
  if(rightMoves == 2) {
    Spring newSpring = new Spring(ball, original, extraRestLen);
    extraSprings.add(newSpring);
  }
}

void update(float dt){
  for (int i = 0 ; i < balls.length;i++) {
    int x = i / springPerThread ;
    if (vair.z > 100 || i % springPerThread != 0 || x% 4 != 0 ){
      UpdatePosition(balls[i], dt);
      applyDrag(i) ;
      PVector dv = PVector.mult(PVector.add(gravity, balls[i].acc), dt) ;
      balls[i].vel.add(dv) ;
    }
    
    balls[i].acc = new PVector(0,0,0);  // Zero out vectors 
  }
  // Get acceleration for next time step
  for(int i=0; i<springs.size(); i++) {
    calculateAccleration(springs.get(i).bottom, springs.get(i).top, springs.get(i).restLength);
  }
  //calculate force for extra springs
  for(int i=0; i<extraSprings.size(); i++) {
    calculateAccleration(extraSprings.get(i).bottom, extraSprings.get(i).top, extraSprings.get(i).restLength);
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

void applyDrag(int ind){
  Ball cur = balls[ind] ;
  if (ind % springPerThread != springPerThread-1 && ind + springPerThread < balls.length){
    Ball upr = balls[ind + springPerThread] ;
    Ball upd = balls[ind + 1] ;
    PVector av = PVector.add(upr.vel, upd.vel) ;
    av.add(cur.vel) ;
    av.sub(vair) ;
    PVector pg = PVector.sub(upr.pos, cur.pos).cross(PVector.sub(upd.pos,cur.pos)) ;
    float area = pg.mag() ;
    float f = av.mag()*(av.dot(pg))/area ;
    PVector force = pg.mult(-drag*f/6) ;
    cur.acc.add(force) ;
    upr.acc.add(force) ;
    upd.acc.add(force) ;
  }
  
  if (ind % springPerThread != 0 && ind + springPerThread < balls.length){
    Ball upr = balls[ind + springPerThread] ;
    Ball upd = balls[ind + springPerThread - 1] ;
    PVector av = PVector.add(upr.vel, upd.vel) ;
    av.add(cur.vel) ;
    av.sub(vair) ;
    PVector pg = PVector.sub(upr.pos, cur.pos).cross(PVector.sub(upd.pos,cur.pos)) ;
    float area = pg.mag() ;
    float f = av.mag()*(av.dot(pg))/area ;
    PVector force = pg.mult(-drag*f/6) ;
    cur.acc.add(force) ;
    upr.acc.add(force) ;
    upd.acc.add(force) ;
  }
  
}

void calculateAccleration(Ball ball2, Ball ball1, float restLen) {
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
  float restLength;
  float maxForce;
  
  Spring (Ball top, Ball bottom, float restLength) {
    this.top = top;
    this.bottom = bottom;
    this.restLength = restLength;
    maxForce = 50.0;
  } 
} 

void keyPressed() {
  if (keyCode == 32) vair.z += 10 ;
  if (keyPressed && key == 'n' || key == 'N') vair.z -= 10;
  camera.HandleKeyPressed();
}

void keyReleased() {
  if (key == 'n' || key == 'N') vair.z -= 10;

  camera.HandleKeyReleased();
}
