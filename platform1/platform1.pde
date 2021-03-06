// for storing and referencing animation frames for the player character
PImage thomas;
PImage chris;
PImage cursor;
Boolean StartScreen;
PImage startButton;

// we use this to track how far the camera has scrolled left or right
float cameraOffsetX;

Thomas theThomas = new Thomas();
WorldOne LevelOne = new WorldOne();
WorldTwo LevelTwo = new WorldTwo();
Keyboard theKeyboard = new Keyboard();
Chris theChris = new Chris();
Player currentPlayer = theThomas;
World currentLevel = LevelOne;

PFont font;
PFont title;

// we use these for keeping track of how long player has played
int levelStartTimeSec, levelCurrentTimeSec;
/////////''/
// by adding this to the player's y velocity every frame, we get gravity
final float GRAVITY_POWER = 0.5; // try making it higher or lower!

void setup() { // called automatically when the program starts
  size(1000,721); // how large the window/screen is for the level

  font = loadFont("CenturyGothic-24.vlw");
  title = loadFont("CenturyGothic-72.vlw");

  thomas = loadImage("thomas.png");
  chris = loadImage("chris.png");
  cursor = loadImage("cursor.png");
  
  StartScreen = true;
  startButton = loadImage("startbutton.png"); 
  startButton.resize(0,50);

  cameraOffsetX = 0.0;
  frameRate(24); // this means draw() will be called 24 times per second

  resetLevel(); // sets up player, level level, and timer
}

void resetLevel() {
  // multiple levels could be supported by copying in a different start grid
  
  theThomas.reset(); // reset everything about the player
    
  if (currentLevel == LevelOne){
    LevelOne.reload(); // reset world map
  }else {
    if (currentLevel == LevelTwo && levelWonThomas() && levelWonChris()){
      currentLevel = LevelOne;
      theThomas.reset();
    }else{
      theChris.reset();
      LevelTwo.reload();
    }
  }
  
  // reset timer in corner
  levelCurrentTimeSec = levelStartTimeSec = millis()/1000; // dividing by 1000 to turn milliseconds into seconds
}

void nextLevel(){
  currentLevel = LevelTwo;
  resetLevel();
}

void switchPlayer(){ //changes the control of the player chronologically
  if (currentPlayer == theThomas && currentLevel == LevelTwo){
    currentPlayer = theChris;
  }else if (currentPlayer == theChris){
    currentPlayer = theThomas;
  }
}

Boolean levelWonThomas() { // checks whether player has gotten to white rectangle
  PVector centerOfPlayer;
  // (remember that "position" is keeping track of bottom center of player)
  centerOfPlayer = new PVector(theThomas.position.x, theThomas.position.y-thomas.height/2);

  return (currentLevel.worldSquareAt(centerOfPlayer)==5);
}

Boolean levelWonChris() { // checks whether player has gotten to white rectangle
  PVector centerOfPlayer;
  // (remember that "position" is keeping track of bottom center of player)
  centerOfPlayer = new PVector(theChris.position.x, theChris.position.y-chris.height/2);

  return (currentLevel.worldSquareAt(centerOfPlayer)==6);
}

Boolean levelLost(){ // checks whether player(s) has fallen in the cracks aka died
  return currentLevel.deathSquare(theThomas.position) || currentLevel.deathSquare(theChris.position); 
}

/*
Boolean levelLostThomas(){ // checks whether player has fallen in the cracks aka died
  PVector bottomOfPlayer;
  bottomOfPlayer = new PVector(theThomas.position.x, theThomas.position.y-thomas.height);
  return theWorld.deathSquare(theThomas.position); 
}

Boolean levelLostChris(){ // checks whether player has fallen in the cracks aka died
  PVector bottomOfPlayer;
  bottomOfPlayer = new PVector(theChris.position.x, theChris.position.y-chris.height);
  return theWorld.deathSquare(theChris.position); 
}
*/

void outlinedText(String sayThis, float atX, float atY) {
  textFont(font); // use the font we loaded
  fill(0); // white for the upcoming text, drawn in each direction to make outline
  text(sayThis, atX-1, atY);
  text(sayThis, atX+1, atY);
  text(sayThis, atX, atY-1);
  text(sayThis, atX, atY+1);
  fill(255); // white for this next text, in the middle
  text(sayThis, atX, atY);
}

void titleText(String titlename, float atX, float atY){
  textFont(title);
  fill(255);
  text(titlename, atX, atY);  
}

void updateCameraPosition() {
  int rightEdge = World.GRID_UNITS_WIDE*World.GRID_UNIT_SIZE-width;
  // the left side of the camera view should never go right of the above number
  // think of it as "total width of the level world" (World.GRID_UNITS_WIDE*World.GRID_UNIT_SIZE)
  // minus "width of the screen/window" (width)
  if (currentPlayer == theThomas){
    cameraOffsetX = theThomas.position.x-width/2;
  }else if (currentPlayer == theChris){
    cameraOffsetX = theChris.position.x-width/2;
  }
  if (cameraOffsetX < 0) {
    cameraOffsetX = 0;
  }

  if (cameraOffsetX > rightEdge) {
    cameraOffsetX = rightEdge;
  }
}

void mouseClicked(){
  if (mouseX >= 300 && mouseX <= 300 + startButton.width 
      && mouseY >= 500 && mouseY <= 500 + startButton.height){
      StartScreen = false;
  }
}

void draw() { // called automatically, 24 times per second because of setup()'s call to frameRate(24)
  if (StartScreen){
    background(32,36,55);
    pushMatrix();
    rotate(PI/15.0);
    titleText("Thomas Was", 175, 120);
    rotate(-1*PI/15.0);
    titleText("Alone", 625,250);
    popMatrix();
    image(thomas,625,300);
    image(chris, 300,300 +thomas.height - chris.height);
    image(startButton, 300, 500);
    outlinedText("How to play:\nUse arrows to move.\nSpacebar to jump.\nQ to switch characters.", width/2 - 200, height-120);
  }else{
  pushMatrix(); // lets us easily undo the upcoming translate call
  translate(-cameraOffsetX, 0.0); // affects all upcoming graphics calls, until popMatrix

  updateCameraPosition();

  currentLevel.render();
    
  if (levelLost() == false){
    if (currentLevel == LevelOne && currentPlayer == theThomas){
      image(cursor, theThomas.position.x- 0.3*thomas.width, theThomas.position.y - 1.4*thomas.height);
      theThomas.inputCheck();
      theThomas.move();
      theThomas.draw();
    }else if (currentLevel == LevelTwo){
    if (currentPlayer == theThomas){
      image(cursor, theThomas.position.x- 0.3*thomas.width, theThomas.position.y - 1.4*thomas.height);
      theThomas.inputCheck();
      theThomas.move();
      
      }
    if (currentPlayer == theChris){
      image(cursor, theChris.position.x-0.3*chris.width, theChris.position.y - 1.5*chris.height);
      theChris.inputCheck();
      theChris.move();
      }
      theThomas.draw();
      theChris.draw();
    }
  }
  
  popMatrix(); // undoes the translate function from earlier in draw()
  
  if (currentLevel == LevelOne){
    textAlign(CENTER,TOP);
    outlinedText("Thomas was Alone. Wow. What a weird first thought to have.\nThomas knew of four things:\nthe whole 'alone' thing, portals,\nhis fantastic falling abilities, joyful jumping skills.", width/2, 10);
  }
  if (currentLevel == LevelTwo){
    textAlign(CENTER,TOP);
    outlinedText("But then Thomas met Chris.\nChris was quite fond of Thomas since he helped him reach new heights.\nThomas had made a new friend.\nHe was not alone anymore.", width/2, 10);
  }
  /*
  if (focused == false) { // does the window currently not have keyboard focus?
    textAlign(CENTER);
    outlinedText("Click this area to play.\n\nUse arrows to move.\nSpacebar to jump.\nQ to switch characters.", width/2, height-120);
  } else {
  */
    textAlign(RIGHT);
    if (levelWonThomas() == false && levelWonChris() == false &&
        levelLost() == false) { // stop updating timer after player finishes
      levelCurrentTimeSec = millis()/1000; // dividing by 1000 to turn milliseconds into seconds
    }
    int minutes = (levelCurrentTimeSec-levelStartTimeSec)/60;
    int seconds = (levelCurrentTimeSec-levelStartTimeSec)%60;
    if (seconds < 10) { // pad the "0" into the tens position
      outlinedText(minutes +":0"+seconds, width-8, height-10);
    } else {
      outlinedText(minutes +":"+seconds, width-8, height-10);
    }

    if (levelWonThomas() && currentLevel == LevelOne) {
      textAlign(CENTER);
      outlinedText("You have finished the level!\nPress N to go to the next Level!", width/2, height/2-12);
    }
    
    if (levelWonThomas() && levelWonChris() && currentLevel == LevelTwo) {
      textAlign(CENTER);
      outlinedText("Congratulations! You have finished the game!\nPress R to Reset and start over.", width/2, height/2-12);
    }
    
    if (levelLost()) {
      textAlign(CENTER);
      outlinedText("You have lost this level!\nPress R to Reset and try again.", width/2, height/2-12);
    }
  }
}

void keyPressed() {
  theKeyboard.pressKey(key, keyCode);
}

void keyReleased() {
  theKeyboard.releaseKey(key, keyCode);
}

void stop() { // automatically called when program exits.
  super.stop(); // tells program to continue doing its normal ending activity
}