void setup(){
  size(1000, 1000);
  generateBalls();
}

int threadCount = 2;
int springPerThread = 10;
Ball[] balls = new Ball[threadCount * springPerThread];
ArrayList<Spring> springs = new ArrayList<Spring>();

void generateBalls() {
  for(int i=0; i<balls.length; i++) {
    PVector pos = new PVector(200 + (i/springPerThread)* 200 + i * restLen, 200) ;
    PVector vel = new PVector(0, 0) ;
    PVector acc = new PVector(0 , 0) ;
    float mass = 2;
    balls[i] = new Ball(pos, vel, acc, mass);
  }
  
  for(int i=0; i<balls.length-1; i++) {
    if (i % springPerThread != springPerThread-1) {
      springs.add(new Spring(balls[i], balls[i+1]));
    }
  }
}

float roof = 0 ;
float floor = 900 ;
float restLen = 50 ;
float k = 10 ;
float kv = 15 ;
float radius = 10 ;
PVector gravity = new PVector(0, 13, 0) ;
PVector stringStart = new PVector(200, 200) ;


void update(float dt){    
  for(int i=0; i<springs.size(); i++) {
    calculateAccleration(springs.get(i).bottom, springs.get(i).top);
  }
  
  for (int i = 0 ; i < balls.length;i++) {
    if(i % springPerThread != 0){
      PVector dv = PVector.mult(PVector.add(gravity, balls[i].acc), dt) ; 
      balls[i].vel.add(dv) ;
      balls[i].pos.add(PVector.mult(balls[i].vel, dt)) ;  
    }
    if(balls[i].pos.y + radius > floor) {
        balls[i].pos.y = floor - radius;
        balls[i].vel.y = -0.2*balls[i].vel.y;
    }
    balls[i].acc = new PVector(0,0);
  }
}

void calculateAccleration(Ball ball2, Ball ball1) {
  PVector stringVector = PVector.sub(ball2.pos, ball1.pos) ;
  float stringLen = stringVector.mag() ;
  float currLen = stringLen - restLen ;
  
  stringVector.normalize() ;
  PVector stringVectorUnit = stringVector;
  
  float dampenForce = -kv* (ball2.vel.dot(stringVectorUnit) - ball1.vel.dot(stringVectorUnit));
  PVector dampForceVector  = PVector.mult(stringVectorUnit, dampenForce);
  PVector stringForce1 = stringVectorUnit.mult(-k*currLen) ;
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
  
  Spring (Ball top, Ball bottom) {
    this.top = top;
    this.bottom = bottom;
  } 
} 

void draw(){
  println(springs.size()) ;
  background(255, 255, 255) ;
  line(0, floor, 1000, floor);
  update(4/frameRate) ;
  fill(0, 0, 0) ; 
  for(int i=0; i<balls.length; i++) {
    if (i % springPerThread != 0) {
      pushMatrix() ;
      line(balls[i-1].pos.x, balls[i-1].pos.y, balls[i].pos.x, balls[i].pos.y) ;
      circle(balls[i].pos.x, balls[i].pos.y, radius) ;
      popMatrix() ;
    }
    else{
      pushMatrix() ;
      circle(balls[i].pos.x, balls[i].pos.y, radius) ;
      popMatrix() ;
    }
  }  
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));
}
