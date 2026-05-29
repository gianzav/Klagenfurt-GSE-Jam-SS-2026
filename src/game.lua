require("button")

function love.load()
   canvasWidth, canvasHeight = 800, 600
   canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
   love.graphics.setCanvas()
  
   gridDim = 8
   cellSize = 50 -- Width and height of cells.
   gridWidth, gridHeigth = cellSize*gridDim, cellSize*gridDim

   -- Initialize grid with zeroes for 'unclicked' cells
   grid = {}
   for i = 1,gridDim do
      grid[i] = {}
      for j = 1,gridDim do
	 grid[i][j] = 0
      end
   end

   gridXOffset, gridYOffset = canvasWidth/2-gridWidth/2, canvasHeight/2-gridHeigth/2
   saveButton = Button.new("Save", 100, 100, 200, 50)
end

function selectCell(x,y)
   local squareX = math.floor((x-gridXOffset) / cellSize) + 1
   local squareY = math.floor((y-gridYOffset) / cellSize) + 1
   if squareX >= 1 and squareX <= gridDim and
      squareY >= 1 and squareY <= gridDim then
      grid[squareX][squareY] = 1
   end
end

function love.mousepressed(x, y, button, istouch, presses)
   selectCell(x,y)

   if button == 1 and saveButton:isClicked(x, y) then
      print("Button clicked!")
   end
end

function drawGrid()
   local gridLines = {}
   love.graphics.setCanvas()
   love.graphics.push()
   love.graphics.translate(gridXOffset, gridYOffset)
   love.graphics.clear(1, 1, 1, 1)

   love.graphics.setBlendMode("alpha")
   
      
   -- Put cells on canvas
   for i = 1,8 do
      for j = 1,8 do
	 if grid[i][j] == 1 then
	    love.graphics.setColor(1, 1, 1, .5)
	 else
	    love.graphics.setColor(1, 0, 0, .5)
	 end
	 love.graphics.rectangle("fill", (i-1)*cellSize, (j-1)*cellSize, 50,50)
      end
   end

   
   love.graphics.setColor(0, 0, 0, 1) -- black lines
   
   -- Vertical grid lines.
   table.insert(gridLines, {0, 0, 0, gridHeigth})
   for x = cellSize, cellSize*gridDim, cellSize do
      local line = {x, 0, x, gridHeigth}
      table.insert(gridLines, line)
   end
   
   -- Horizontal lines.
   table.insert(gridLines, {0, 0, gridWidth, 0})
   for y = cellSize, cellSize*gridDim, cellSize do
      local line = {0, y, gridWidth, y}
      table.insert(gridLines, line)
   end

   -- Draw cell lines
   love.graphics.setLineWidth(2)

   for i, line in ipairs(gridLines) do
      love.graphics.line(line)
   end
   
   love.graphics.draw(canvas, 0, 0)
   love.graphics.pop() -- restore previous coordinate system
end

function love.draw()
   drawGrid()
   saveButton:draw()
end
