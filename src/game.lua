require("button")
require("grid")
require("ball")

function love.load()
   -- General config
   canvasWidth, canvasHeight = 800, 600
   -- canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
   -- love.graphics.setCanvas()

   love.window.setMode(800, 600, {resizable=false, vsync=0, minwidth=800, minheight=600})
   gridDim = 8
   cellSize = 50 -- Width and height of cells.
   gridWidth, gridHeigth = 8,8
   gridPixelWidth, gridPixelHeight = gridWidth*cellSize, gridHeigth*cellSize   
   gridXOffset, gridYOffset = canvasWidth/2-gridPixelWidth/2, canvasHeight/2-gridPixelHeight/2

   -- Game objects
   saveButton = Button.new("Save", 10, 380, 200, 50)

   
   saveButton:registerCallback(function (self) self.label = "Saved!" end)
   
   grid = Grid.new(gridXOffset, gridYOffset, 8, 8, 50)
   ball = Ball.new({r=1, g=1, b=1, a=1}, 50, 50, 16)

   cursorImage = love.graphics.newImage("src/assets/elf192.192.png", {dpiscale=2})


   -- One meter is 32px in physics engine
   meter = 32
   love.physics.setMeter(meter)

   -- Create a world for each grid column
   fallColumns = {}
   for i=1,gridDim do
      local speedup = 0.5
      table.insert(fallColumns, love.physics.newWorld(0, 9.81*meter*speedup, true))
   end
   
   ballRadius = 25
   balls = {}
   colors = {
      {r=1, g=0, b=0, a=1}, -- red
      {r=0, g=1, b=0, a=1}, -- green
      {r=0, g=0, b=1, a=1}, -- red
   }
   
   for i=1,gridDim do
      -- Create a Body for the circle
      
      body = love.physics.newBody(fallColumns[i], (i-1)*50+gridXOffset+ballRadius, gridYOffset, "dynamic")
      
      -- Attatch a shape to the body.
      circle_shape = love.physics.newCircleShape(0,0,25)
      
      -- Create fixture between body and shape
      fixture = love.physics.newFixture(body, circle_shape)

      -- Calculate the mass of the body based on attatched shapes.
      -- This gives realistic simulations.
      body:setMassData(circle_shape:computeMass( 1 ))
      randomColor = math.random(1,#colors)
      ball = Ball.new(colors[randomColor], 25, body)
      table.insert(balls, ball)
   end
end

function love.update(dt)
   for _,column in pairs(fallColumns) do
      column:update(dt)
   end
end

function love.mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      if saveButton:isClicked(x, y) then
	 saveButton:runCallbacks()
      end

      for k,body in pairs(balls) do
	 if x >= body:getX()-25 and x <= body:getX()+25 and
	    y >= body:getY()-25 and y <= body:getY()+25 then
	    grid:selectCell(x,y)
	    balls[k] = nil
	 end
      end

      -- show elf on the clicked point
   end
end

function love.draw()
   saveButton:draw()
   grid:draw()
   -- ball:draw()

   -- Draw the circle.
   for _,ball in pairs(balls) do
      ball:draw()
   end
   
   -- Draw image on mouse cursor
   -- love.graphics.draw(cursorImage, love.mouse.getX()-cursorImage:getHeight()/2, love.mouse.getY()-cursorImage:getWidth()/2)
end
