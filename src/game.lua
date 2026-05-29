function love.load()
   canvas = love.graphics.newCanvas(800, 600)

   -- Rectangle is drawn to the canvas with the regular/default alpha blend mode ("alphamultiply").
   love.graphics.setCanvas(canvas)
   love.graphics.clear(0, 0, 0, 0)
   love.graphics.setBlendMode("alpha")
   love.graphics.setColor(1, 0, 0, .5)
   love.graphics.rectangle("fill", 0,0, 50,50)
   love.graphics.setCanvas()
end

function drawGrid()
   local cellSize  = 50 -- Width and height of cells.
   local gridHorizSize = cellSize*8
   local gridVertSize = cellSize*8
   local gridLines = {}

   -- Draw cells
   for i = 0,7 do
      for j = 0,7 do
	 love.graphics.draw(canvas, i*cellSize,j*cellSize)
      end
   end
   
   -- Vertical lines.
   for x = cellSize, cellSize*8, cellSize do
      local line = {x, 0, x, gridVertSize}
      table.insert(gridLines, line)
   end
   
   -- Horizontal lines.
   for y = cellSize, cellSize*8, cellSize do
      local line = {0, y, gridHorizSize, y}
      table.insert(gridLines, line)
   end

   -- Draw cell lines
   love.graphics.setLineWidth(2)

   for i, line in ipairs(gridLines) do
      love.graphics.line(line)
   end
end

function love.draw()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(1, 1, 1, 1)
    drawGrid()
end
