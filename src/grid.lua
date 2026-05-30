Grid = {}
Grid.__index = Grid

function Grid.new(x, y, width, height, cellSize)
   -- width and height given in terms of number of cells
   local self = setmetatable({}, Grid)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.cellSize = cellSize
   
   -- Initialize grid with zeroes for 'unclicked' cells
   self.grid = {}
   for i = 1,height do
      self.grid[i] = {}
      for j = 1,width do
	 self.grid[i][j] = 0
      end
   end
   
   return self
end


function Grid:draw()
   local gridLines = {}
   love.graphics.setCanvas()
   love.graphics.push()
   love.graphics.translate(self.x, self.y)
   love.graphics.clear(1, 1, 1, 1)

   love.graphics.setBlendMode("alpha")
         
   -- Put cells on canvas
   for i = 1,8 do
      for j = 1,8 do
	 if self.grid[i][j] == 1 then
	    love.graphics.setColor(1, 1, 1, .5)
	 else
	    love.graphics.setColor(1, 0, 0, .5)
	 end
	 love.graphics.rectangle("fill", (i-1)*self.cellSize, (j-1)*self.cellSize, self.cellSize, self.cellSize)
      end
   end

   love.graphics.setColor(0, 0, 0, 1) -- black lines

   pixelWidth = self.cellSize * self.width
   pixelHeight = self.cellSize * self.height
   -- Vertical grid lines.
   table.insert(gridLines, {0, 0, 0, pixelHeight})
   for x = self.cellSize, pixelHeight, self.cellSize do
      local line = {x, 0, x, pixelHeight}
      table.insert(gridLines, line)
   end
   
   -- Horizontal lines.
   table.insert(gridLines, {0, 0, pixelWidth, 0})
   for y = self.cellSize, pixelWidth, self.cellSize do
      local line = {0, y, pixelWidth, y}
      table.insert(gridLines, line)
   end

   -- Draw cell lines
   love.graphics.setLineWidth(2)

   for i, line in ipairs(gridLines) do
      love.graphics.line(line)
   end
   
   -- love.graphics.draw(canvas, 0, 0)
   love.graphics.pop() -- restore previous coordinate system
end


function Grid:selectCell(x,y)
   local squareX = math.floor((x-self.x) / self.cellSize) + 1
   local squareY = math.floor((y-self.y) / self.cellSize) + 1
   if squareX >= 1 and squareX <= self.height and
      squareY >= 1 and squareY <= self.width then
      self.grid[squareX][squareY] = 1
   end
end
