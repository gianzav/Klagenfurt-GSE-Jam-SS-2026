require("savetable")

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
   
   -- Initialize grid with white color for 'unclicked' cells
   self.grid = {}
   for i = 1,height do
      self.grid[i] = {}
      for j = 1,width do
	 self.grid[i][j] = {r=1,g=1,b=1,a=1}
      end
   end

   self.referenceCells = {}
   for i = 1,height do
      self.referenceCells[i] = {}
      for j = 1,width do
	 self.referenceCells[i][j] = nil
      end
   end

   -- Flag to know if the cell was colored during gameplay
   self.coloredByPlayer = {}
   for i = 1,height do
      self.coloredByPlayer[i] = {}
      for j = 1,width do
	 self.coloredByPlayer[i][j] = false
      end
   end
   
   return self
end


function Grid:draw()
   love.graphics.push("all")
   local gridLines = {}

   love.graphics.translate(self.x, self.y)
   love.graphics.setBlendMode("alpha")

   love.graphics.push("all")
   -- Put cells on canvas
   for i = 1,self.width do
      for j = 1,self.height do
	 color = self.grid[i][j]
	 reference = self.referenceCells[i][j]
	 
	 -- if the cell was colored
	 if self.coloredByPlayer[i][j] then
	    love.graphics.setColor(color.r, color.g, color.b)
	 elseif not self.coloredByPlayer[i][j] and reference then
	    love.graphics.setColor(reference.r, reference.g, reference.b, 0.5)
	 else
	    love.graphics.setColor(color.r, color.g, color.b)
	 end
	 love.graphics.rectangle("fill", (i-1)*self.cellSize, (j-1)*self.cellSize, self.cellSize, self.cellSize)
      end
   end
   
   love.graphics.pop()
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
   
   love.graphics.pop()
end


function Grid:selectCell(x,y,color)
   local squareX = math.floor((x-self.x) / self.cellSize) + 1
   local squareY = math.floor((y-self.y) / self.cellSize) + 1
   if squareX >= 1 and squareX <= self.height and
      squareY >= 1 and squareY <= self.width then
      self.coloredByPlayer[squareX][squareY] = true
      self.grid[squareX][squareY] = color
   end
end

function Grid:addReferenceCell(x,y,color)
   if color then
      local squareX = math.floor((x-self.x) / self.cellSize) + 1
      local squareY = math.floor((y-self.y) / self.cellSize) + 1
      if squareX >= 1 and squareX <= self.height and
	 squareY >= 1 and squareY <= self.width then
	 self.referenceCells[squareX][squareY] = color
      end
   end
end

function Grid:deleteReferenceCell(x,y)
   local squareX = math.floor((x-self.x) / self.cellSize) + 1
   local squareY = math.floor((y-self.y) / self.cellSize) + 1
   if squareX >= 1 and squareX <= self.height and
      squareY >= 1 and squareY <= self.width then
      
      self.referenceCells[squareX][squareY] = nil
      self.coloredByPlayer[squareX][squareY] = false
      self.grid[squareX][squareY] = {r=1,g=1,b=1,a=1}
   end
end

function Grid:saveToFile(filename)
   table.save(self, filename)
end

function Grid.loadFromFile(filename)
   loaded = table.load(filename)

   local g = Grid.new(loaded.x, loaded.y, loaded.width, loaded.height, loaded.cellSize)

   g.referenceCells = loaded.referenceCells
   return g
end

