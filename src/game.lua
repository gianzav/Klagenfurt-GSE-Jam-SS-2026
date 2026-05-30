require("button")
require("grid")
require("ball")
Talkies = require("talkies")


config = {
   windowWidth = 800,
   windowHeight = 600,
   colors =  {
      {r=1, g=0, b=0, a=1}, -- red
      {r=0, g=1, b=0, a=1}, -- green
      {r=0, g=0, b=1, a=1}, -- red
   }
}

function love.load()
   -- General config

   love.graphics.setBackgroundColor(1,1,1)
   love.window.setMode(config.windowWidth, config.windowHeight, {resizable=false, vsync=0, minwidth=800, minheight=600})
   gridDim = 8
   cellSize = 50 -- Width and height of cells.
   gridWidth, gridHeigth = 8,8
   gridPixelWidth, gridPixelHeight = gridWidth*cellSize, gridHeigth*cellSize   
   gridXOffset, gridYOffset = config.windowWidth/2-gridPixelWidth/2, config.windowHeight/2-gridPixelHeight/2

   grid = Grid.new(gridXOffset, gridYOffset, 8, 8, 50)
   
   cursorImage = love.graphics.newImage("src/assets/mirino.png", {dpiscale=2})
   love.mouse.setVisible(true)

   -- One meter is 32px in physics engine
   meter = 32
   love.physics.setMeter(meter)

   -- Create a world for each grid column
   fallColumns = {}
   for i=1,gridDim do
      local speedup = 0.5
      table.insert(fallColumns, love.physics.newWorld(0, 9.81*meter*speedup, true))
   end
   
   colors = config.colors
   balls = {}
   -- timer data
   timeElapsed = 0
   time = 0
   lastTime = 0
   -- time in seconds after which a new ball spawns
   ballSpawnThreshold = 1

   -- gameMode may be one of {"play", "pause", "edit", "delete"}
   gameMode = "edit"
   -- Game objects

   -- Buttons
   saveButton = Button.new("Save", 0,   550, 200, 50)
   saveButton:registerCallback(function (self)
	 grid:saveToFile(os.date("%d-%m-%Y-%H-%M") .. ".grid")
   end)
   
   editButton = Button.new("Edit", 200, 550, 200, 50)
   playButton = Button.new("Play", 400, 550, 200, 50)
   playButton:registerCallback(function (self)
	 if gameMode ~= "play" then
	    gameMode = "play"
	    self.label = "Pause"
	 else
	    gameMode = "pause"
	    self.label = "Play"
	 end
   end)

   editButton:registerCallback(function (self)
	 gameMode = "edit"
	 balls = {}
   end)

   buttons = {saveButton, editButton, playButton}
   
   -- colorButtons for edit mode
   editingColor = nil
   colorButtons = {}
   deleteButton = Button.new("clear", 50, 50, 50, 50, {r=0.9,g=0.9,b=0.9,a=1})
   deleteButton:registerCallback(function (self)
	 gameMode = "delete"
   end)
   
   for i,color in pairs(colors) do
      b = Button.new(nil, 50, (i+1)*50, 50, 50, color) -- colored buttons
      b:registerCallback(function (self)
	    editingColor = color
      end)
      table.insert(colorButtons, b)
   end

   currentScore = 0
   
end

function love.update(dt)
   if gameMode ~= "play" then
      love.mouse.setVisible(true)
   end
   
   if gameMode == "play" then
      love.mouse.setVisible(false)
      
      for _,column in pairs(fallColumns) do
	 column:update(dt)
      end

      -- generate a ball
      time = love.timer.getTime()
      
      if lastTime then
	 timeElapsed = timeElapsed + (time - lastTime)
      else
	 timeElapsed = 0
      end
      
      if timeElapsed >= ballSpawnThreshold then
	 column = math.random(1,#fallColumns)
	 table.insert(balls, generateBall(fallColumns[column],
					  (column-1)*50+gridXOffset,
					  gridYOffset-60,
					  colors))
	 timeElapsed = 0
      end

      lastTime = time
      
   end
end


function love.mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      for _,button in pairs(buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end

      if gameMode == "play" then
	 for k,ball in pairs(balls) do
	    if x >= ball:getX()-25 and x <= ball:getX()+25 and
	       y >= ball:getY()-25 and y <= ball:getY()+25 then
	       
	       selected = grid:selectCell(x,y,ball.color)

	       -- change the score
	       if selected then
		  i,j = grid:getCellFromCoordinates(x,y)
		  -- first case: a cell with a reference color
		  if grid.referenceCells[i][j] then
		     if grid.referenceCells[i][j]== balls[k].color then
			currentScore = currentScore + 50
		     else
			currentScore = currentScore - 100
		     end
		  else
		     -- otherwise: an empty cell was clicked
		     currentScore = currentScore - 50
		  end
	       end
	       
	       balls[k] = nil
	    end
	 end
      elseif gameMode == "edit" or gameMode == "delete" then
	 for _,button in pairs(colorButtons) do
	    if button:isClicked(x,y) then
	       button:runCallbacks()
	    end
	 end

	 if deleteButton:isClicked(x,y) then
	    deleteButton:runCallbacks()
	 end
	 
	 if gameMode == "delete" then
	    grid:deleteReferenceCell(x,y)
	 else
	    grid:addReferenceCell(x,y,editingColor)
	 end
	 
	 if saveButton:isClicked(x,y) then
	    saveButton:runCallbacks()
	 end
      end
   end
end

function love.draw()
   for _,button in pairs(buttons) do
      button:draw()
   end

   if gameMode == "edit" or gameMode == "delete" then
      for _,button in pairs(colorButtons) do
	 button:draw()
      end

      deleteButton:draw()
   end
   
   grid:draw()
   
   -- Draw the circle.
   for _,ball in pairs(balls) do
      ball:draw()
   end   


   if gameMode == "play" then
      -- Draw image on mouse cursor
      love.graphics.draw(cursorImage, love.mouse.getX()-cursorImage:getHeight()/2, love.mouse.getY()-cursorImage:getWidth()/2)      
   end

   --if gameMode == "play" or gameMode == "pause" then

   --end
   
   drawCenteredText(350, 30, 100, 50, "SCORE: " .. tostring(currentScore))
end

function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
   love.graphics.push("all")
   love.graphics.setColor(0,0,0)
   local font       = love.graphics.getFont()
   local textWidth  = font:getWidth(text)
   local textHeight = font:getHeight()
   love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
   love.graphics.pop()
end
