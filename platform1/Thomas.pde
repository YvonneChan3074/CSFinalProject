class Thomas extends Player {
  
  final float JUMP_POWER = 13.0; // how hard the player jolts upward on jump
  final float RUN_SPEED = 5.0; // force of player movement on ground, in pixels/cycle
  final float AIR_RUN_SPEED = 2.0; // like run speed, but used for control while in the air
  final float SLOWDOWN_PERC = 0.6; // friction from the ground. multiplied by the x speed each frame.
  final float AIR_SLOWDOWN_PERC = 0.85; // resistance in the air, otherwise air control enables crazy speeds
  final float RUN_ANIMATION_DELAY = 3; // how many game cycles pass between animation updates?
  final float TRIVIAL_SPEED = 1.0; // if under this speed, the player is drawn as standing still
  
  Thomas() { // constructor, gets called automatically when the Thomas instance is created
    super();
  }
  
  void checkForFalling() {
    // If we're standing on an empty tile or end tile, we're not standing on anything. Fall!
    if(currentLevel.worldSquareAt(position)==World.TILE_EMPTY ||
       //currentLevel.worldSquareAt(position)==World.TILE_START_THOMAS||
       currentLevel.worldSquareAt(position)==WorldTwo.TILE_END_THOMAS){
       isOnGround=false;
    }
    
    if(isOnGround==false) { // not on ground?    
      if(currentLevel.worldSquareAt(position)== World.TILE_SOLID) { // landed on solid square?
        isOnGround = true;
        position.y = currentLevel.topOfSquare(position);
        velocity.y = 0.0;
      } else { // fall
        velocity.y += GRAVITY_POWER;
      }
    }
  }
  
  void checkForWallBumping() {
    int thomasWidth = thomas.width; // think of image size of player standing as the player's physical size
    int thomasHeight = thomas.height;
    int wallProbeDistance = int(thomasWidth*0.5);
    
    /* Because of how we draw the player, "position" is the center of the feet/bottom
     * To detect and handle wall/ceiling collisions, we create 5 additional positions:
     * leftSideHigh - left of center, at shoulder/head level
     * leftSideLow - left of center, at shin level
     * rightSideHigh - right of center, at shoulder/head level
     * rightSideLow - right of center, at shin level
     * topSide - horizontal center, at tip of head
     * These 6 points - 5 plus the original at the bottom/center - are all that we need
     * to check in order to make sure the player can't move through blocks in the world.
     * This works because the block sizes (World.GRID_UNIT_SIZE) aren't small enough to
     * fit between the cracks of those collision points checked.
     */
    
    // used as probes to detect running into walls, ceiling
    PVector leftSideHigh,rightSideHigh,leftSideLow,rightSideLow,topSide;
     leftSideHigh = new PVector();
     rightSideHigh = new PVector();
     leftSideLow = new PVector();
     rightSideLow = new PVector();
     topSide = new PVector();
 
     // update wall probes
     leftSideHigh.x = leftSideLow.x = position.x - wallProbeDistance; // left edge of player
     rightSideHigh.x = rightSideLow.x = position.x + wallProbeDistance; // right edge of player
     leftSideLow.y = rightSideLow.y = position.y-0.2*thomasHeight; // shin high
     leftSideHigh.y = rightSideHigh.y = position.y-0.8*thomasHeight; // shoulder high
 
     topSide.x = position.x; // center of player
     topSide.y = position.y-thomasHeight; // top of guy
 
    // the following conditionals just check for collisions with each bump probe
    // depending upon which probe has collided, we push the player back the opposite direction
    
  
    if( currentLevel.worldSquareAt(topSide)==World.TILE_SOLID) {
      if(currentLevel.worldSquareAt(position)==World.TILE_SOLID) {
        position.sub(velocity);
        velocity.x=0.0;
        velocity.y=0.0;
      } else {
        position.y = currentLevel.bottomOfSquare(topSide)+thomasHeight;
        if(velocity.y < 0) {
          velocity.y = 0.0;
        }
      }
    }
    
    if( currentLevel.worldSquareAt(leftSideLow)==World.TILE_SOLID) {
      position.x = currentLevel.rightOfSquare(leftSideLow)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(leftSideHigh)==World.TILE_SOLID) {
      position.x = currentLevel.rightOfSquare(leftSideHigh)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(rightSideLow)==World.TILE_SOLID) {
      position.x = currentLevel.leftOfSquare(rightSideLow)-wallProbeDistance;
      if(velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(rightSideHigh)==World.TILE_SOLID) {
      position.x = currentLevel.leftOfSquare(rightSideHigh)-wallProbeDistance;
      if(velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
  }
  
  /* modified version when it kept returning nullPointerException
  
  if( currentLevel.worldSquareAt(leftSideLow)==World.TILE_SOLID ||
        (currentLevel.worldSpotX(leftSideLow) == currentLevel.worldSpotX(theChris.rightSideLow)) &&
        (currentLevel.worldSpotY(leftSideLow) == currentLevel.worldSpotY(theChris.rightSideLow))){
      position.x = currentLevel.rightOfSquare(leftSideLow)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(leftSideHigh)==World.TILE_SOLID ||
        (currentLevel.worldSpotX(leftSideHigh) == currentLevel.worldSpotX(theChris.rightSideHigh)) &&
        (currentLevel.worldSpotY(leftSideHigh) == currentLevel.worldSpotY(theChris.rightSideHigh))){
      position.x = currentLevel.rightOfSquare(leftSideHigh)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(rightSideLow)==World.TILE_SOLID ||
        (currentLevel.worldSpotX(rightSideLow) == currentLevel.worldSpotX(theChris.leftSideLow)) &&
        (currentLevel.worldSpotY(rightSideLow) == currentLevel.worldSpotY(theChris.leftSideLow))){
      position.x = currentLevel.leftOfSquare(rightSideLow)-wallProbeDistance;
      if(velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
   
    if( currentLevel.worldSquareAt(rightSideHigh)==World.TILE_SOLID||
        (currentLevel.worldSpotX(rightSideHigh) == currentLevel.worldSpotX(theChris.leftSideHigh)) &&
        (currentLevel.worldSpotY(rightSideHigh) == currentLevel.worldSpotY(theChris.leftSideHigh))){
      position.x = currentLevel.leftOfSquare(rightSideHigh)-wallProbeDistance;
      if(velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
    */

  void inputCheck() {
    // keyboard flags are set by keyPressed/keyReleased in the main .pde
    
    float speedHere = (isOnGround ? RUN_SPEED : AIR_RUN_SPEED);
    float frictionHere = (isOnGround ? SLOWDOWN_PERC : AIR_SLOWDOWN_PERC);
    
    if(theKeyboard.holdingLeft) {
      velocity.x -= speedHere;
    } else if(theKeyboard.holdingRight) {
      velocity.x += speedHere;
    } 
    velocity.x *= frictionHere; // causes player to constantly lose speed
    
    if(isOnGround) { // player can only jump if currently on the ground
      if(theKeyboard.holdingSpace || theKeyboard.holdingUp) { // either up arrow or space bar cause the player to jump
        velocity.y = -JUMP_POWER; // adjust vertical speed
        isOnGround = false; // mark that the player has left the ground, i.e.cannot jump again for now
      }
    }
  }

  void draw() {
    int thomasWidth = thomas.width;
    int thomasHeight = thomas.height;
    //image(thomas, xToBegin(currentLevel.start_Grid), yToBegin(currentLevel.start_Grid));
    
    if(velocity.x<-TRIVIAL_SPEED) {
      facingRight = false;
    } else if(velocity.x>TRIVIAL_SPEED) {
      facingRight = true;
    }
    
    pushMatrix(); // lets us compound/accumulate translate/scale/rotate calls, then undo them all at once
    translate(position.x,position.y);
    if(facingRight==false) {
      scale(-1,1); // flip horizontally by scaling horizontally by -100%
    }
    translate(-thomasWidth/2,-thomasHeight); // drawing images centered on character's feet
    image(thomas, 0, 0);
    popMatrix(); // undoes all translate/scale/rotate calls since the pushMatrix earlier in this function
  }
}