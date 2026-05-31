winState = require("win-state")
loseState = require("lose-state")
pauseState = require("pause-state")

s = {}

local loaded = false

function s.load(inpEnv, forceReload)
   if not loaded or forceReload then

      loaded = true
      env = inpEnv
      grid = env.grid
      colors = env.colors

      cursorImage = love.graphics.newImage("src/assets/mirino.png", {dpiscale=2})
      ballImage = love.graphics.newImage("src/assets/goccia-bw.png", {dpiscale=3})
      splatSound = love.audio.newSource("src/assets/music/TRUESplatsound.mp3", "static")
      
      balls = {}

      -- One meter is 32px in physics engine
      meter = 32
      love.physics.setMeter(meter)

      -- Create a world for each grid column
      fallColumns = {}
      for i=1,gridDim do
	 local speedup = 0.5
	 table.insert(fallColumns, love.physics.newWorld(0, 9.81*meter*speedup, true))
      end

      
      -- timer data
      ballSpawnElapsedTime = 0
      -- time in seconds after which a new ball spawns
      ballSpawnThreshold = 0.3
      ballSpeedupFactor = 1.1
      ballSpeedupElapsedTime = 0
      ballSpeedupThreshold = 1
      
      positiveScoreFactor = 50
      lowScorePenaltyFactor = 50
      highScorePenaltyFactor = 100
      gameSeconds = 30
      currentScore = 0

      pauseButtonPressed = false
      pauseButton = Button.new("Pause", 400, 550, 200, 50)
      pauseButton:registerCallback(function (self)
	    pauseButtonPressed = true
      end)
      
      editButtonPressed = false
      editButton = Button.new("Edit", 200, 550, 200, 50)
      editButton:registerCallback(function (self)
	    editButtonPressed = true
      end)
            
      editButton:registerCallback(function (self)
	    editState.load({colors=config.colors})
	    currentState = editState
	    balls = {}
      end)

      buttons = {pauseButton, editButton}
   end
end

function s.mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      for _,button in pairs(buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
      
      for k,ball in pairs(balls) do
	 if x >= ball:getX()-25 and x <= ball:getX()+25 and
	    y >= ball:getY()-25 and y <= ball:getY()+25 then
	    
	    selected = grid:selectCell(x,y,ball.color)
	    splatSound:play()
	    -- change the score
	    if selected then
	       i,j = grid:getCellFromCoordinates(x,y)
	       -- first case: a cell with a reference color
	       if grid.referenceCells[i][j] then
		  if grid.referenceCells[i][j] == balls[k].color and grid.available[i][j] then
		     currentScore = currentScore + positiveScoreFactor
		     grid.available[i][j] = false
		  elseif grid.referenceCells[i][j] ~= balls[k].color then
		     currentScore = currentScore - highScorePenaltyFactor
		  end
	       else
		  -- otherwise: an empty cell was clicked
		  currentScore = currentScore - lowScorePenaltyFactor
	       end
	    end
	    
	    balls[k] = nil
	 end
      end
   end
end

function s.update(dt)
  -- if pauseButtonPressed then
  --    love.mouse.setVisible(true)
  --    pauseState.load{balls=balls}
  --    return pauseState
  -- else
      love.mouse.setVisible(false)

      for _,column in pairs(fallColumns) do
	 column:update(dt)
      end

      -- generate a ball
      gameSeconds = gameSeconds - love.timer.getDelta()
      ballSpawnElapsedTime = ballSpawnElapsedTime + love.timer.getDelta()
      ballSpeedupElapsedTime = ballSpeedupElapsedTime + love.timer.getDelta()
      
      if gameSeconds <= 0 then
	 if hasWon() then
	    s.unload()
	    return winState
	 else
	    s.unload()
	    return loseState
	 end
      end
      
      if ballSpawnElapsedTime >= ballSpawnThreshold then
	 column = math.random(1,#fallColumns)
	 table.insert(balls, generateBall(fallColumns[column],
					  (column-1)*50+gridXOffset,
					  gridYOffset-60,
					  colors,
					  ballImage))
	 ballSpawnElapsedTime = 0
      end

      if ballSpeedupElapsedTime >= ballSpeedupThreshold then
	 ballSpeedupElapsedTime = 0
	 for _,column in pairs(fallColumns) do
	    local gx, gy = column:getGravity() 
	    column:setGravity(gx, gy*ballSpeedupFactor)
	 end
      end
      
      return s
   --end
end

function s.draw()
   -- Draw image on mouse cursor
   love.graphics.clear()
   love.graphics.draw(cursorImage, love.mouse.getX()-cursorImage:getHeight()/2, love.mouse.getY()-cursorImage:getWidth()/2)
   
   -- Draw the circle.
   for _,ball in pairs(balls) do
      ball:draw()
   end

   drawCenteredText(350, 30, 100, 50, "SCORE: " .. tostring(currentScore))
   drawCenteredText(500, 30, 100, 50, "TIME: " .. tostring(math.floor(gameSeconds)))
end

function s.unload()
   mainMusic:stop()
end

function hasWon()
   maxPoints = 0
   for i=1,grid.width do
      for j=1,grid.height do
	 if grid.referenceCells[i][j] then
	    maxPoints = maxPoints + 1
	 end
      end
   end
   maxPoints = maxPoints * positiveScoreFactor
   return currentScore >= maxPoints*0.9
end

function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text, color)
   love.graphics.push("all")
   if color then
      love.graphics.setColor(color.r, color.g, color.b, color.a)
   else
      love.graphics.setColor(0,0,0)
   end
   local font       = love.graphics.getFont()
   local textWidth  = font:getWidth(text)
   local textHeight = font:getHeight()
   love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
   love.graphics.pop()
end


return s
