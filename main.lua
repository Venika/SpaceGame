display.setStatusBar( display.HiddenStatusBar )

local physics = require("physics");
physics.start();
physics.setGravity(0,0);

local Enemy = require ("Enemy");
local soundTable=require("soundTable");


hs=0;
HP=5;
local countDownTimer
local startView
local drop
local tridrop
local controlBar
local p
local p1
local checkView
local cube


local fire={}
local move={}
local Main={}
local removeProjectile={}
local createShot={}
local startscreen={}
local removestartscreen={}
local Game={}
local time={}
local Gameover={}
local Check={}


function Main()
  startscreen()

end

function startscreen()
  background=display.newImage( "bg.jpg",display.contentCenterX, display.contentCenterY)
  background:scale(.64,.71)
  playBtn=display.newImage( "playBtn.png", display.contentCenterX, display.contentCenterY+50)
  playBtn:scale(.5,.5)
  playBtn:addEventListener('tap',removestartscreen)
  startView= display.newGroup(background,playBtn)
end

Main()

function removestartscreen:tap(e)
  transition.to(startView, {ime = 500, y = -display.contentHeight,
  onComplete = function() display.remove(startView)
  startView = null
  Game()
  time()

  hs=0
  HP=5
  end})
end


function time()

  secondsLeft = 3 * 60   -- 2 minutes * 60 seconds
     clockTime = display.newEmbossedText("Time: ", display.contentCenterX-100, 1, native.systemFontBold, 30)
     clockTime:setFillColor( .88,.26,.5)
     color =
    {
     highlight = {.80,.41,.79},
     shadow = {0,1,1}
    }
    clockTime:setEmbossColor( color );

  local clockText = display.newEmbossedText("03:00", display.contentCenterX-20, 1, native.systemFontBold, 30)
    clockText:setFillColor(.88,.26,.5)
    local color =
    {
     highlight = {.80,.41,.79},
     shadow = {0,1,1}
    }
    clockText:setEmbossColor( color );

  local function updateTime()
      -- decrement the number of seconds
      secondsLeft = secondsLeft - 1
      -- time is tracked in seconds.  We need to convert it to minutes and seconds
      local minutes = math.floor( secondsLeft / 60 )
      local seconds = secondsLeft % 60

      -- make it a string using string format.
      local timeDisplay = string.format( "%02d:%02d", minutes, seconds )
      clockText.text = timeDisplay

      if(timeDisplay=="00:00" and HP~=0) then
        timer.cancel( countDownTimer )
      --  physics.pause()
        check('win')
      --  Gameover()
        print("Game Over-win")

      end
  end
  -- run them timer
  countDownTimer = timer.performWithDelay( 1000, updateTime, secondsLeft )
end





function Game()
audio.play( soundTable["game"] );
    --sky
    sky=display.newImage( "sky.png",display.contentCenterX, display.contentCenterY)
    sky:scale(.64,.71)
	 --Control bar
	  controlBar = display.newRect (display.contentCenterX, display.contentHeight-65, display.contentWidth, 70);
	  controlBar:setFillColor(.88,.26,.5,0.5);
    controlBar.tag="cbar"

	  ---Score
	  local scoreText = display.newEmbossedText( "Hit:", 250, 0, native.systemFontBold, 30 );
	  scoreText:setFillColor(.88,.26,.5);

    local color =
	    {
	    	highlight = {.80,.41,.79},
	    	shadow = {0,1,1}
	    }
    scoreText:setEmbossColor( color );

	    ---Score
    local scores = display.newEmbossedText( hs, 300, 0, native.systemFontBold, 30 );
    scores:setFillColor(.88,.26,.5);
    local color =
	    {
	      highlight = {.80,.41,.79},
	      shadow = {0,1,1}
	    }
    scores:setEmbossColor( color );

	 -- Main Player
    cube = display.newCircle (display.contentCenterX, display.contentHeight-150, 15);
    cube:setFillColor(.88,.26,.5,0.9)
    physics.addBody (cube, "kinematic");
    cube.tag="cube"
		cube.isSensor=true;

    function move ( event )
	     if event.phase == "began" then
		       cube.markX = cube.x
	     elseif event.phase == "moved" then
	 	      local x = (event.x - event.xStart) + cube.markX
	 	       if (x <= 20 + cube.width/2) then
		           cube.x = 20+cube.width/2;
		       elseif (x >= display.contentWidth-20-cube.width/2) then
		           cube.x = display.contentWidth-20-cube.width/2;
		       else
		           cube.x = x;
		       end
	     end
     end --ends move
    controlBar:addEventListener("touch", move);



    -- Projectile
  local cnt = 0;
  function fire (event)
  --if (cnt < 3) then
        cnt = cnt+1;
	      local p = display.newCircle (cube.x, cube.y-16, 5);
	      p.anchorY = 1;
	      p:setFillColor(.71,.31,.52);
	      physics.addBody (p, "dynamic", {radius=5} );
	      p:applyForce(0, -0.4, p.x, p.y);
	      audio.play( soundTable["shootSound"] );

	   function removeProjectile (event)
      if (event.phase=="began") then
	   	   event.target:removeSelf();
         event.target=nil;
				 if (event.other.tag == "enemy") then
            	event.other.pp:hit();
              hs=hs+1;
              scores.text=hs;
         end
      end
    end  --ends Projectile
    p:addEventListener("collision", removeProjectile);
  end  --ends fire
  Runtime:addEventListener("tap", fire)


  function pentrain()

   local Pentagon = Enemy:new( {HP=3, fR=720, fT=700,  bT=700} );

    function Pentagon:spawn()
     self.shape = display.newPolygon(math.random(50,280), 50, { 0,-37, 37,-10, 23,34, -23,34, -37,-10 });
     self.shape.pp = self;
     self.shape.tag = "enemy";
     self.shape:setFillColor ( 1, 1, 0,0.9);
     physics.addBody(self.shape, "dynamic");
     self.shape:setLinearVelocity( 0, 20)
     self.shape.isSensor=true;
   end

   function Pentagon:shoot (interval)
     interval = interval or 1300;
       local function createShot(obj)
       local p1 = display.newRect (obj.shape.x, obj.shape.y+50,
                                  10,10);
       p1:setFillColor(1,0,0);
       p1.anchorY=0;
       p1.tag="Enembullets";
       physics.addBody (p1, "dynamic");
       p1:applyForce(0, 0.2, p1.x, p1.y);

       local function shotHandler (event)
         if (event.phase == "began") then
   	      event.target:removeSelf();
      	  event.target = nil;
         end
       end --ends shotHandler
       p1:addEventListener("collision", shotHandler);
      -- bullets=display.newGroup(p) --doesn't collide with player
     end --ends createshot
     self.timerRef = timer.performWithDelay(interval,	function (event) createShot(self) end, -1);

   end

    sq = Pentagon:new();
    sq:spawn();
    sq:shoot();

  end --ends pentrain
penrand=math.random(500,5000)
drop=timer.performWithDelay( penrand, pentrain, -1 )


function Trirain()
   ------------Triangle
 local Triangle = Enemy:new( {HP=1, bR=360, fT=500, bT=300});

    function Triangle:spawn()
    self.shape = display.newPolygon(math.random(25,280), self.yPos,
   			             {-20,-20,20,-20,0,20});

    self.shape.pp = self;
    self.shape.tag = "enemy";
    self.shape:setFillColor ( 0, 0, 1);
    physics.addBody(self.shape, "dynamic",  {shape={-20,-20,20,-20,0,20}});
    self.shape.isSensor=true;

    y_dist=self.yPos-cube.y
    x_dist=self.xPos-cube.x
    local V = 0.5;
     t = math.sqrt(x_dist^2 + y_dist^2)/V;
    local x_speed = x_dist/t
    local y_speed = y_dist/t

    transition.to(self.shape, {time=t, x=cube.x, y=cube.y,
    onComplete=function ()
      self.shape:removeSelf()
      self.shape=nil
    end});
  end

 function Triangle:shoot(interval)
  interval = interval or 1500;
  local function createShot(obj)  --enemy bullets
    p = display.newRect (obj.shape.x, obj.shape.y+50, 10,10);
    p:setFillColor(1,0,0);
    p.anchorY=0;
    p.tag="Enembullets";
    physics.addBody (p, "dynamic");
    p:applyForce(0, 0.5, p.x, p.y);


    py_dist=p.y-cube.y
    px_dist=p.x-cube.x
    local Vl = 0.1;
     t1 = math.sqrt(px_dist^2 + py_dist^2)/Vl;
    local px_speed = px_dist/t1
    local py_speed = py_dist/t1

    transition.to(p.shape, {time=t1, px=cube.x, py=cube.y});

    local function shotHandler (event)
      if (event.phase == "began") then
      event.target:removeSelf();
      event.target = nil;
      end
    end
    p:addEventListener("collision", shotHandler);
  end
  self.timerRef = timer.performWithDelay(10,
  function (event) createShot(self) end, 2);
end

   tr=Triangle:new();
   tr:spawn();
end
trirand=math.random(500,5000)
tridrop=timer.performWithDelay( trirand, Trirain, -1 )




function onCollision(event)
  if (event.phase=="began") then
    if(event.object1.tag=="cube" and event.object2.tag=="Enembullets" or event.object1.tag=="cube" and event.object2.tag=="enemy") then
    --  print("collide")
      HP=HP-1;
    --  print(HP)
      if (event.object2.tag=="enemy") then
        event.object2.pp:hit();
      end
      if (HP==0) then
        print( "Game over")
        check('lose')
        timer.pause( countDownTimer )

        --physics.pause()
      end
    end

  --  transition.cancel()
  end
end

Runtime:addEventListener("collision", onCollision)

function check(e)
  timer.cancel( drop )
  timer.cancel( tridrop )
  display.remove(sq)
  display.remove(tr)

    if(e == 'win') then
        checkView = display.newImage('win.png')
        checkView.x = display.contentWidth * 0.5
        checkView.y = display.contentHeight * 0.5
    else
        checkView = display.newImage('Lose.png')
        checkView.x = display.contentWidth * 0.5
        checkView.y = display.contentHeight * 0.5
    end

    checkView:addEventListener('tap', Gameover)
end


function Gameover()
audio.pause( soundTable["game"] );
  hs=0
  HP=5
--physics.stop()
--physics.pause()
 --display.remove(sq)
 --display.remove(tr)
--  p1:removeEventListener("collision", shotHandler);


  display.remove( checkView )
  display.remove( sky )
 display.remove(scores)
  controlBar:removeEventListener("touch", move)
  display.remove(cube)
  Runtime:removeEventListener("tap", fire)
  Runtime:removeEventListener("collision", onCollision)
  startscreen()
end
end
