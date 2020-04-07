//images
PImage sky, soil, cabbage, ghDown, ghIdle, ghLeft, ghRight, life, soldier, title, gameOver, resHovered, resNormal, startHovered, startNormal;
//game state
final int GAME_START = 0;
final int GAME_RUN = 1;
final int GAME_OVER = 2;
int gameState = GAME_START;
//button range
final int BUTTON_TOP = 360;
final int BUTTON_BOTTOM = 420;
final int BUTTON_LEFT = 248;
final int BUTTON_RIGHT = 392;
//key
boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
//general
final float blockSize = 80.0;
int timeNow, timeLast;
int frameBegin, frameLast, frameDiff;
//soldier
float soldierX = 0.0;
float soldierY = floor(random(2, 6)) * blockSize;
float soldierSpeed = 2.0;
//groundHog
float ghX = 4.0 * blockSize;
float ghY = 1.0 * blockSize;
//cabbage
float cabbageX = floor(random(0, 8)) * blockSize;
float cabbageY = floor(random(2, 6)) * blockSize;
//life
int lifeCount = 2;

void setup() {
  size(640, 480, P2D);
  //loading image
  sky = loadImage("img/bg.jpg"); 
  soil = loadImage("img/soil.png"); 
  cabbage = loadImage("img/cabbage.png"); 
  ghDown = loadImage("img/groundhogDown.png"); 
  ghIdle = loadImage("img/groundhogIdle.png"); 
  ghLeft = loadImage("img/groundhogLeft.png"); 
  ghRight = loadImage("img/groundhogRight.png");
  life = loadImage("img/life.png"); 
  soldier = loadImage("img/soldier.png"); 
  title = loadImage("img/title.jpg"); 
  gameOver = loadImage("img/gameover.jpg");
  resHovered = loadImage("img/restartHovered.png");
  resNormal = loadImage("img/restartNormal.png");
  startHovered = loadImage("img/startHovered.png");
  startNormal = loadImage("img/startNormal.png");
}

void draw() {
  switch(gameState){ //there are three stages - START, RUN and OVER.
    case GAME_START:
      image(title, 0, 0); //show START background.
      image(startNormal, 248, 360); //show normal button.
      if(mouseX > BUTTON_LEFT && mouseX < BUTTON_RIGHT && mouseY > BUTTON_TOP && mouseY < BUTTON_BOTTOM){
        image(startHovered, 248, 360); //if mouse is over the button then show Hovered button.
        if(mousePressed){gameState = GAME_RUN;} //detect if mouse click and switch to RUN.
      }
      break;
    
    case GAME_RUN: // there are five item should be drawn in RUN stage.
      drawBG(); //background involve sky, soil, sun and grass.
      drawLife(); //draw life by life count.
      drawCabbage(); //draw cabbage and detect collision with groundhog.
      drawSoldier(); //draw soldier and detect collision with groundhog.
      drawGH(); //using key pressed and framecount to control groundhog. 
      
      if(lifeCount == 0){gameState = GAME_OVER;} // if life count down to zero then game is over.
      break;
      
    case GAME_OVER:
      image(gameOver, 0, 0);
      image(resNormal, 248, 360);
      if(mouseX > BUTTON_LEFT && mouseX < BUTTON_RIGHT && mouseY > BUTTON_TOP && mouseY < BUTTON_BOTTOM){
        image(resHovered, 248, 360);
        if(mousePressed){
          gameState = GAME_RUN;
          //initial all data.
          ghX = 4 * blockSize;
          ghY = 1 * blockSize;
          soldierX = 0.0;
          soldierY = floor(random(2, 6)) * blockSize;
          cabbageX = floor(random(0, 8)) * blockSize;
          cabbageY = floor(random(2, 6)) * blockSize;
          lifeCount = 2;
        }
      }
      break;
  }
}

void drawBG(){
  //sky
  background(sky);
  //soil
  image(soil, 0, 160, width, 320);
  //grass
  noStroke();
  fill(124, 204, 25);
  rectMode(CORNER);
  rect(0, 145, width, 15);
  //sun
  noStroke();
  fill(255, 255, 0);
  ellipse(width-50, 50, 130, 130);
  noStroke();
  fill(253, 184, 19);
  ellipse(width-50, 50, 120, 120);
}

void drawLife(){
  //draw different number and position of life.
  for(int i = 0; i < lifeCount; ++i){
    image(life, i * (life.width+20)+10, 10);
  }
}

void drawCabbage(){
  image(cabbage, cabbageX, cabbageY);
  //detect collision between cabbage and groundhog.
  if( cabbageX < (ghX + blockSize) && (cabbageX + blockSize) > ghX && cabbageY < (ghY + blockSize) && (cabbageY + blockSize) > ghY ){
    cabbageX = width;
    cabbageY = height;
    lifeCount++; //earn life.
  }
}

void drawSoldier(){
  image(soldier, soldierX, soldierY);
  soldierX += soldierSpeed;
  //detect if soldier is out of boundary.
  if(soldierX > width){soldierX = -soldier.width;}
  //detect collision between soldier and grounhog.
  if( soldierX < (ghX + blockSize) && (soldierX + blockSize) > ghX && soldierY < (ghY + blockSize) && (soldierY + blockSize) > ghY ){
    lifeCount--; //lose life.
    //initial groundhog's position and moving state.
    ghX = 4 * blockSize;
    ghY = 1 * blockSize;
    downPressed = false;
    leftPressed = false;
    rightPressed = false;
  }
}

void drawGH(){ 
  //control grounghold via framenumber
  frameBegin = frameLast; //record the beginning frame number
  frameDiff = frameCount - frameBegin; //calculate frame difference between start and now. frameDiff must >= 1.
  
  if (downPressed) {
    // divide a block into 14 sections, start counting frame numbers when key pressed and moving one section each frame.
    if(frameDiff < 15){image(ghDown, ghX, ghY += (blockSize / 14.0));}
    else{downPressed = false;} //after 15 frames, groundhog move one block and turn to IDLE.
  }
  else if (leftPressed) {
    if(frameDiff < 15){image(ghLeft, ghX -= (blockSize / 14.0), ghY);}
    else{leftPressed = false;} 
  }
  else if (rightPressed) {
    if(frameDiff < 15){image(ghRight, ghX += (blockSize / 14.0), ghY);}
    else{rightPressed = false;}
  } 
  else{
    frameLast = frameCount; //update the new beginning frame only when IDLE
    image(ghIdle, ghX, ghY);
  }
  
  //boundary detection
  if(ghX + blockSize > width){ //detect right boundary.
    ghX = width - blockSize;
    rightPressed = false; //if touch boundary, release key to avoid continue moving. 
  }
  else if(ghX < 0){ //detect left boundary.
    ghX = 0;
    leftPressed = false;
  }
  else if(ghY + blockSize > height){ //detect down boundary.
    ghY = height - blockSize;
    downPressed = false;
  }
}

void keyPressed(){
  timeNow = millis(); //get latest time.
  
  if((timeNow - timeLast) >=  250){ //at least 250ms between two clicks.
    timeLast = timeNow; //update time record only when successful click. 
    if(key == CODED){
      switch (keyCode) {
        case DOWN:
          downPressed = true;
          break;
        case LEFT:
          leftPressed = true;
          break;
        case RIGHT:
          rightPressed = true;
          break;
      }
    }
  }
}
