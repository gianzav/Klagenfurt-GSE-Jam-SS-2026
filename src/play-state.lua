require("button")
require("pause-state")
require("win-state")
require("lose-state")

PlayState = {}
PlayState.__index = PlayState


function PlayState.new(env)
   local self = setmetatable({}, PlayState)
   self.loaded = false

   self.env = env
   self.colors = env.colors
   self.gridXOffset = env.gridXOffset
   self.gridYOffset = env.gridYOffset
   self.mainMusic = env.mainMusic
   self.colors = env.colors
   self.gridDim = env.gridDim

   env["playState"] = self
   -- env["pauseState"] = PauseState.new(env)

   --self.pauseState = env.pauseState
   -- self.editState = env.editState

   return self
end

function PlayState:load(env, forceReload)
   if not self.loaded or forceReload then
      self.grid = env.grid
      self.loaded = true

      self.cursorImage = love.graphics.newImage("src/assets/mirino.png", {dpiscale=2})
      self.ballImage = love.graphics.newImage("src/assets/goccia-bw.png", {dpiscale=3})
      self.splatSound = love.audio.newSource("src/assets/music/TRUESplatsound.mp3", "static")
      
      self.balls = {}

      -- One meter is 32px in physics engine
      self.meter = 32
      love.physics.setMeter(self.meter)

      -- Create a world for each grid column
      self.fallColumns = {}
      for i=1,self.gridDim do
	 table.insert(self.fallColumns, love.physics.newWorld(0, 9.81*self.meter, true))
      end
      
      -- timer data
      self.ballSpawnElapsedTime = 0
      -- time in seconds after which a new ball spawns
      self.ballSpawnThreshold = 0.5
      self.ballSpeedupFactor = 1.05
      self.ballSpeedupElapsedTime = 0
      self.ballSpeedupThreshold = 1
      
      self.positiveScoreFactor = 50
      self.lowScorePenaltyFactor = 50
      self.highScorePenaltyFactor = 100
      self.gameSeconds = 3
      self.currentScore = 0
      
      -- self.pauseButtonPressed = false
      -- self.pauseButton = Button.new("Pause", 400, 550, 200, 50)
      -- self.pauseButton:registerCallback(function (button)
      -- 	    self.pauseButtonPressed = true
      -- end)
      
      --self.editButtonPressed = false
      --self.editButton = Button.new("Edit", 200, 550, 200, 50)
      --self.editButton:registerCallback(function (button)
      --	    self.editButtonPressed = true
      --end)
            
      --self.buttons = {self.editButton}
   end
end

function PlayState:mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      -- for _,button in pairs(self.buttons) do
      -- 	 if button:isClicked(x,y) then
      -- 	    button:runCallbacks()
      -- 	 end
      -- end
      
      for k,ball in pairs(self.balls) do
	 if x >= ball:getX()-25 and x <= ball:getX()+25 and
	    y >= ball:getY()-25 and y <= ball:getY()+25 then
	    
	    local selected = self.grid:selectCell(x,y,ball.color)
	    self.splatSound:play()
	    -- change the score
	    if selected then
	       local i,j = self.grid:getCellFromCoordinates(x,y)
	       -- first case: a cell with a reference color
	       if self.grid.referenceCells[i][j] then
		  if self.grid.referenceCells[i][j] == self.balls[k].color and self.grid.available[i][j] then
		     self.currentScore = self.currentScore + self.positiveScoreFactor
		     self.grid.available[i][j] = false
		  elseif self.grid.referenceCells[i][j] ~= self.balls[k].color then
		     self.currentScore = self.currentScore - self.highScorePenaltyFactor
		  end
	       else
		  -- otherwise: an empty cell was clicked
		  self.currentScore = self.currentScore - self.lowScorePenaltyFactor
	       end
	    end
	    
	    self.balls[k] = nil
	 end
      end
   end
end

function PlayState:update(dt)
   -- if self.pauseButtonPressed then
   --   self:unload()
   --   self.pauseState:load{balls=self.balls}
   --   return self.pauseState
   --if self.editButtonPressed then
   --   self:unload()
   --   return self.editState
   --else
      love.mouse.setVisible(false)

      for _,column in pairs(self.fallColumns) do
	 column:update(dt)
      end

      -- generate a ball
      self.gameSeconds = self.gameSeconds - love.timer.getDelta()
      self.ballSpawnElapsedTime = self.ballSpawnElapsedTime + love.timer.getDelta()
      self.ballSpeedupElapsedTime = self.ballSpeedupElapsedTime + love.timer.getDelta()
      
      if self.gameSeconds <= 0 then
	 if self:hasWon() then
	    self:unload()
	    local winState = WinState.new()
	    winState:load()
	    return winState
	 else
	    self:unload()
	    local loseState = LoseState.new(self.env)
	    loseState:load()
	    return loseState
	 end
      end
      
      if self.ballSpawnElapsedTime >= self.ballSpawnThreshold then
	 local column = math.random(1,#self.fallColumns)
	 table.insert(self.balls, generateBall(self.fallColumns[column],
					       (column-1)*50+self.gridXOffset,
					       self.gridYOffset-60,
					       self.colors,
					       self.ballImage))
	 self.ballSpawnElapsedTime = 0
      end

      if self.ballSpeedupElapsedTime >= self.ballSpeedupThreshold then
	 self.ballSpeedupElapsedTime = 0
	 for _,column in pairs(self.fallColumns) do
	    local gx, gy = column:getGravity() 
	    column:setGravity(gx, gy*self.ballSpeedupFactor)
	 end
      end
      
      return self
   --end
end

function PlayState:draw()
   self.grid:draw()
   -- Draw image on mouse cursor
   love.graphics.draw(self.cursorImage,
		      love.mouse.getX()-self.cursorImage:getHeight()/2,
		      love.mouse.getY()-self.cursorImage:getWidth()/2)
   
   -- Draw the circle.
   for _,ball in pairs(self.balls) do
      ball:draw()
   end

   --for _,button in pairs(self.buttons) do
   --   button:draw()
   --end
   
   drawCenteredText(350, 30, 100, 50, "SCORE: " .. tostring(self.currentScore))
   drawCenteredText(500, 30, 100, 50, "TIME: " .. tostring(math.floor(self.gameSeconds)))
end

function PlayState:unload()
   self.mainMusic:stop()
   love.mouse.setVisible(true)
end

function PlayState:hasWon()
   local maxPoints = 0
   for i=1,self.grid.width do
      for j=1,self.grid.height do
	 if self.grid.referenceCells[i][j] then
	    maxPoints = maxPoints + 1
	 end
      end
   end
   maxPoints = maxPoints * self.positiveScoreFactor
   return self.currentScore >= maxPoints*0.8
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
