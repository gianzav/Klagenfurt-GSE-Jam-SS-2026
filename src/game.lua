require("button")
require("grid")
require("ball")

function love.load()
   -- General config
   canvasWidth, canvasHeight = 800, 600
   canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
   love.graphics.setCanvas()
  
   gridDim = 8
   cellSize = 50 -- Width and height of cells.
   gridWidth, gridHeigth = 8,8
   gridPixelWidth, gridPixelHeight = gridWidth*cellSize, gridHeigth*cellSize   
   gridXOffset, gridYOffset = canvasWidth/2-gridPixelWidth/2, canvasHeight/2-gridPixelHeight/2

   -- Game objects
   saveButton = Button.new("Save", 100, 100, 200, 50)
   saveButton:registerCallback(function (self) self.label = "Saved!" end)
   grid = Grid.new(gridXOffset, gridYOffset, 8, 8, 50)
   ball = Ball.new({r=1, g=1, b=1, a=1}, 50, 50, 16)
end

function love.mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      if saveButton:isClicked(x, y) then
	 saveButton:runCallbacks()
      end

      grid:selectCell(x,y)
   end
end

function love.draw()
   saveButton:draw()
   grid:draw()
   ball:draw()
end
