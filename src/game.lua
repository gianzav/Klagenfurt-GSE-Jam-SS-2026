require("button")
require("grid")
require("ball")

function love.load()
   -- General config
   canvasWidth, canvasHeight = 800, 600
   -- canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
   -- love.graphics.setCanvas()

   love.graphics.setBackgroundColor(1,1,1)
   love.window.setMode(800, 600, {resizable=false, vsync=0, minwidth=800, minheight=600})
   gridDim = 8
   cellSize = 50 -- Width and height of cells.
   gridWidth, gridHeigth = 8,8
   gridPixelWidth, gridPixelHeight = gridWidth*cellSize, gridHeigth*cellSize   
   gridXOffset, gridYOffset = canvasWidth/2-gridPixelWidth/2, canvasHeight/2-gridPixelHeight/2



   -- color buttons for edit mode
   
   grid = Grid.new(gridXOffset, gridYOffset, 8, 8, 50)
   ball = Ball.new({r=1, g=1, b=1, a=1}, 50, 50, 16)

   cursorImage = love.graphics.newImage("src/assets/mirino.png", {dpiscale=2})
   love.mouse.setVisible(false)

   -- One meter is 32px in physics engine
   meter = 32
   love.physics.setMeter(meter)

   -- Create a world for each grid column
   fallColumns = {}
   for i=1,gridDim do
      local speedup = 0.5
      table.insert(fallColumns, love.physics.newWorld(0, 9.81*meter*speedup, true))
   end
   
   balls = {}
   colors = {
      {r=1, g=0, b=0, a=1}, -- red
      {r=0, g=1, b=0, a=1}, -- green
      {r=0, g=0, b=1, a=1}, -- red
   }

   -- timer data
   timeElapsed = 0
   time = 0
   lastTime = 0
   -- time in seconds after which a new ball spawns
   ballSpawnThreshold = 1


   -- gameMode may be one of {"play", "pause", "edit"}
   gameMode = "edit"
   -- Game objects

   -- Buttons
   saveButton = Button.new("Save", 0,   550, 200, 50)
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
   white = {r=1,g=1,b=1,a=1}
   editingColor = white
   colorButtons = {}
end

function love.update(dt)
   if gameMode == "play" then
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
      
   -- Mouse cursor should be visible in edit mode
   elseif gameMode == "edit" then
      love.mouse.setVisible(true)
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
	       
	       grid:selectCell(x,y,ball.color)
	       balls[k] = nil
	    end
	 end
      elseif gameMode == "edit" then
	 print("ciao")
      end
   end
end


function love.draw()
   editButton:draw()
   playButton:draw()
   saveButton:draw()
   
   grid:draw()
   
   -- Draw the circle.
   for _,ball in pairs(balls) do
     ball:draw()
   end

   if gameMode == "play" then
      -- Draw image on mouse cursor
      love.graphics.draw(cursorImage, love.mouse.getX()-cursorImage:getHeight()/2, love.mouse.getY()-cursorImage:getWidth()/2)
   end
end
