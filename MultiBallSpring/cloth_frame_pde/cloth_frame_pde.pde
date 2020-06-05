int threadCount = 30;
int springPerThread = 30;
Ball[] balls = new Ball[threadCount * springPerThread];
ArrayList<Spring> springs = new ArrayList<Spring>();
PImage graf, disco, g1, g2, g3 ;
PShape glob, wall1, wall2, wall3 ;
float roof = 0 ;
float floor = 10000 ;
float restLen = 12 ;
float k = 40;
float kv = 30;
float radius = 10 ;
PVector gravity = new PVector(0, 1, 0) ;
PVector stringStart = new PVector(200, 200) ;
PVector vair = new PVector(0 , 0, 0) ;
float drag = 0.000005 ;
float angle = 0 ;

// Environment Collision
PVector floorTranslations = new PVector(100, 800, 100);
int[] floorDimensions = {10000, 300, 10000};

// Sphere Collisions
PVector sphereMovement = new PVector(0, 0, 0);
PVector sphereTranslations  = new PVector(150, 200, 200);
float sphereRadius = 50;

void setup(){
  size(1000, 1000, P3D);
  generateBalls();
  camera = new Camera();
  graf = loadImage("graffiti.jpg") ;
  disco = loadImage("discoball.jpg") ;
  g1 = loadImage("graff1.jpg") ;
  g2 = loadImage("graff2.jpg") ;
  g3 = loadImage("graff3.jpg") ;
  glob = createShape(SPHERE, sphereRadius) ;
  glob.setTexture(disco) ;
  glob.setStroke(0) ;
}

void generateBalls() {
  for(int i=0; i<balls.length; i++) {
    PVector pos = new PVector(100 + (i/springPerThread)* restLen, -10, (i%springPerThread)*restLen)  ;
    PVector vel = new PVector(0, 0, 0) ;
    PVector acc = new PVector(0 , 0, 0) ;
    float mass = 1;
    balls[i] = new Ball(pos, vel, acc, mass);
  }
  
  for(int i=0; i<balls.length-1; i++) {
    if (i % springPerThread != springPerThread-1) {
      springs.add(new Spring(balls[i], balls[i+1]));
    }
    int hoz = i + springPerThread ;
    if(hoz < balls.length){
      springs.add(new Spring(balls[i], balls[i+springPerThread]));
    }
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
    
    balls[i].acc = new PVector(0,0);  // Zero out vectors 
  }
  // Get acceleration for next time step
  for(int i=0; i<springs.size(); i++) {
    calculateAccleration(springs.get(i).bottom, springs.get(i).top);
  }
}

void midpointUpdate(float dt){
  for(int i=0; i<springs.size(); i++) {
    calculateAccleration(springs.get(i).bottom, springs.get(i).top);
  }
  
  for(int i = 0 ; i < balls.length; i++){
    int x = i / springPerThread ;
    if (vair.z > 100 || i % springPerThread != 0 || x% 4 != 0 ){
      applyDrag(i) ;
      PVector dv = PVector.mult(PVector.add(gravity, balls[i].acc), dt/2) ;
      balls[i].vel.add(dv) ;
    }
    balls[i].acc = new PVector(0,0);  // Zero out vectors
  }
  for(int i=0; i<springs.size(); i++) {
    calculateAccleration(springs.get(i).bottom, springs.get(i).top);
  }
  for(int i = 0 ; i < balls.length; i++){
    int x = i / springPerThread ;
    if (vair.z > 100 || i % springPerThread != 0 || x% 4 != 0 ){
      UpdatePosition(balls[i], dt) ;
      applyDrag(i) ;
      PVector dv = PVector.mult(PVector.add(gravity, balls[i].acc), dt/2) ;
      balls[i].vel.add(dv) ;
    }
    balls[i].acc = new PVector(0,0);  // Zero out vectors
  }
  
}

void calculateAccleration(Ball ball2, Ball ball1) {
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

void UpdatePosition(Ball ball, float dt){  
  // Sphere detection
  PVector distance = PVector.sub(ball.pos, sphereTranslations);
  float length = distance.mag();
  
  // 0.5 added to reduce clipping
  if(length < sphereRadius + 1) {
    distance.normalize();
    PVector bounce = PVector.mult(distance, ball.vel.dot(distance));
    bounce.mult(1.5);
    ball.vel.sub(bounce);
    ball.pos.add(PVector.mult(distance, (sphereRadius + 1 - length)));
  }
  
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

class Ball {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  
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

void draw(){
  background(0, 0, 0) ;
  
  pushMatrix() ;
  textureMode(NORMAL);
  translate(-200, 500, -900) ;
  beginShape(TRIANGLE_STRIP);
  texture(g1);
  vertex(0, -2000, 0, 0) ;
  vertex(0, 0, 0, 1) ;
  vertex(2000, -2000, 1, 0) ;
  vertex(2000, 0, 1, 1) ;  
  endShape();
  popMatrix();
  
  pushMatrix() ;
  textureMode(NORMAL);
  rotateY(-PI/2);
  translate(-900, 500, -1800) ;
  beginShape(TRIANGLE_STRIP);
  texture(g2);
  vertex(0, -2000, 0, 0) ;
  vertex(0, 0, 0, 1) ;
  vertex(2000, -2000, 1, 0) ;
  vertex(2000, 0, 1, 1) ;
  endShape(CLOSE);
  popMatrix();
  
  pushMatrix() ;
  textureMode(NORMAL);
  rotateY(-PI) ;
  translate(-1800, 500, -1100) ;
  beginShape(TRIANGLE_STRIP);
  texture(g3);
  vertex(0, -2000, 0, 0) ;
  vertex(0, 0, 0, 1) ;
  vertex(2000, -2000, 1, 0) ;
  vertex(2000, 0, 1, 1) ;
  endShape(CLOSE);
  popMatrix();
  
  pushMatrix() ;
  fill(100, 100, 100);
  translate(floorTranslations.x, floorTranslations.y, floorTranslations.z) ;
  box(floorDimensions[0], floorDimensions[1], floorDimensions[2]) ; 
  popMatrix() ;
  
  // Update sphere location
  sphereTranslations.x += sphereMovement.x;
  sphereTranslations.y += sphereMovement.y;
  sphereTranslations.z += sphereMovement.z;
  
  pushMatrix() ;
  tint(255) ;
  translate(sphereTranslations.x, sphereTranslations.y, sphereTranslations.z) ;
  angle += 1 ;
  rotateY(radians(angle)) ;
  shape(glob) ;
  popMatrix() ;
  
  for(int i = 0 ;i < 100; i++){
    update(0.25/frameRate) ;
    // uncomment for mid point, using constant dt in midpoint because it might break because of rendering of walls.
    //midpointUpdate(0.04) ;
  }
  camera.Update(1/frameRate) ;
  fill(255, 255, 255) ;
  
  // texture the cloth    
  noStroke() ;
  noFill() ;
  int k = 0 ;
  textureMode(NORMAL);
  for(int i = 0 ; i < springPerThread - 1; i++){
    beginShape(TRIANGLE_STRIP);
    texture(graf) ;
    for(int j = 0 ; j < threadCount; j++){
      if (springs.get(k).exists){
        float u = map(j, 0, threadCount, 0, 1) ;
        float v1 = map(i, 0, springPerThread, 0, 1) ;
        float v2 = map(i+1, 0, springPerThread, 0, 1) ;
        vertex(balls[i + j*springPerThread].pos.x, balls[i + j*springPerThread].pos.y, balls[i + j*springPerThread].pos.z, u, v1) ;
        vertex(balls[i+1 + j*springPerThread].pos.x, balls[i+1 + j*springPerThread].pos.y, balls[i+1 + j*springPerThread].pos.z, u, v2) ;
      }
      
    }
    endShape() ;
  }
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));
}

void keyPressed() {
  if (keyCode == 32) vair.z += 10 ;
  if (keyPressed && key == 'n' || key == 'N') vair.z -= 10;
  if (keyPressed && key == 'y' || key == 'Y') sphereMovement.z = -4;
  if (keyPressed && key == 'h' || key == 'H') sphereMovement.z = 4;
  if (keyPressed && key == 'g' || key == 'G') sphereMovement.x = -4;
  if (keyPressed && key == 'j' || key == 'J') sphereMovement.x = 4;
  if (keyPressed && key == 't' || key == 'T') sphereMovement.y = -4;
  if (keyPressed && key == 'u' || key == 'U') sphereMovement.y = 4;
  camera.HandleKeyPressed();
}

void keyReleased() {
  if (key == 'n' || key == 'N') vair.z -= 10;
  if (key == 'y' || key == 'Y') sphereMovement.z = 0;
  if (key == 'h' || key == 'H') sphereMovement.z = 0;
  if (key == 'g' || key == 'G') sphereMovement.x = 0;
  if (key == 'j' || key == 'J') sphereMovement.x = 0;
  if (key == 't' || key == 'T') sphereMovement.y = 0;
  if (key == 'u' || key == 'U') sphereMovement.y = 0;
  camera.HandleKeyReleased();
}
