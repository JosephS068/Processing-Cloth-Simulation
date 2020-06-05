float g = 300;
float floor = 100;
float dx = 10;
float dz = dx ;
float xlength = 100;
int segments = int(xlength / dx);
float[][] h = new float[segments][segments];
float[][] uh = new float[segments][segments];
float[][] hm = new float[segments][segments];
float[][] mh = new float[segments][segments];
float[][] uhm = new float[segments][segments];
float[][] vh = new float[segments][segments];
float[][] vhm = new float[segments][segments];
PVector start = new PVector(-800, -600) ;

// Environment Collision
PVector floorTranslations = new PVector(100, 800, 100);
int[] floorDimensions = {10000, 300, 10000};

void setup(){
  size(1000, 1000, P3D);
  camera = new Camera();
  for(int i = 0 ; i < segments; i++){
    for(int j = 0 ; j <segments; j++){
     h[i][j] = 350 - i*4 ;
     vh[i][j] = 0 ;
     uh[i][j] = 0 ;
     hm[i][j] = 0 ;
     vhm[i][j] = 0 ;
     uhm[i][j] = 0 ;
     mh[i][j] = 0 ;
    }
  }
}

void updateMidPoint(float dt, int i, int j){
  hm[i][j] = (h[i][j]+h[i+1][j])/2.0 - (dt/2.0)*((uh[i+1][j]-uh[i][j])/dx + (vh[i][j+1]-vh[i][j])/dz);
  uhm[i][j] = (uh[i][j]+uh[i+1][j])/2.0 - (dt/2.0)*(sqr(uh[i+1][j])/h[i+1][j] + .5*g*sqr(h[i+1][j]) - sqr(uh[i][j])/h[i][j] - .5*g*sqr(h[i][j]))/dx;
  vhm[i][j] = (vh[i][j]+vh[i][j+1])/2.0 - (dt/2.0)*(sqr(vh[i][j+1])/h[i][j+1] + .5*g*sqr(h[i][j+1]) - sqr(vh[i][j])/h[i][j] - .5*g*sqr(h[i][j]))/dz;
}

void update(float dt, int i, int j) {
  println(hm[i][j]) ;
  float damp = 3;
  h[i+1][j] -= dt*((uhm[i+1][j]-uhm[i][j])/dx + (vhm[i][j+1]-vhm[i][j])/dz);
  uh[i+1][j] -= dt*(damp*uh[i+1][j] + sqr(uhm[i+1][j])/hm[i+1][j] + .5*g*sqr(hm[i+1][j]) - sqr(uhm[i][j])/hm[i][j] - .5*g*sqr(hm[i][j]))/dx;
  vh[i][j+1] -= dt*(damp*vh[i][j+1] + sqr(vhm[i][j+1])/hm[i][j+1] + .5*g*sqr(hm[i][j+1]) - sqr(vhm[i][j])/hm[i][j] - .5*g*sqr(hm[i][j]))/dz;
  
  //h[0] = h[1];
  //h[segments-1] = h[segments-2];
  //uh[segments-1] = -uh[segments-2] * 0.2;
  //uh[0] = -uh[1]*0.2;
}

void updatePos(float dt){
  for(int i = 0 ; i < segments-1; i++){
    for(int j = 0 ; j < segments-1; j++){
      updateMidPoint(dt, i, j) ;
    }
  }
  for(int i = 0 ; i < segments-2; i++){
    for(int j = 0 ; j < segments-2; j++){
      update(dt, i, j) ;
    }
  }
  h[0][0] = h[1][1] ;
  h[segments-1][0] = h[segments-2][0] ;
  h[segments-1][segments-1] = h[segments-2][segments-2] ;
  h[0][segments-1] = h[0][segments-2] ;
  uh[0][0] = uh[1][1] ;
  uh[segments-1][0] = uh[segments-2][0] ;
  uh[segments-1][segments-1] = uh[segments-2][segments-2] ;
  uh[0][segments-1] = uh[0][segments-2] ;
  vh[0][0] = vh[1][1] ;
  vh[segments-1][0] = vh[segments-2][0] ;
  vh[segments-1][segments-1] = vh[segments-2][segments-2] ;
  vh[0][segments-1] = vh[0][segments-2] ;
}

float sqr(float num) {
  return pow(num, 2);
}

void draw(){
  background(0, 0, 0) ;
  lights();  
  noStroke() ;
  noFill() ;
  drawEnv();
  
  for(int i = 0 ; i < 100 ; i++){
    updatePos(0.000005);
  }
  rotate(PI);
  for(int i=0; i<segments-1; i++) {
    for(int j = 0 ; j < segments-1; j++){
      noStroke() ;
      fill(255, 255, 255);
      beginShape(QUADS);
      vertex(start.x + (i*dx), start.y+h[i][j], start.z + (j*dz)) ;
      vertex(start.x + (i+1)*dx, start.y+h[i+1][j], start.z + (j*dz)) ;
      vertex(start.x+(i+1)*dx, start.y+h[i+1][j+1], start.z + (j+1)*dz) ;
      vertex(start.x + (i*dx), start.y+h[i][j+1], start.z + (j+1)*dz) ;
      endShape(); 
    }
  }
  
  camera.Update(1/frameRate) ;
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));
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
}

void keyPressed() {
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
}
