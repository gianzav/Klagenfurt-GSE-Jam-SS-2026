require("button")
require("grid")
require("ball")

-- currentState may be one of {"play", "pause", "edit", "win", "lose"}
playState = require("play-state")
editState = require("edit-state")

config = {
   windowWidth = 800,
   windowHeight = 600,
   colors =  {
      {r=1, g=0, b=0, a=1}, -- red
      {r=0, g=1, b=0, a=1}, -- green
      {r=0, g=0, b=1, a=1}, -- red
      {r=1, g=1, b=0, a=1}, -- yellow
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
   --grid = Grid.loadFromFile("src/assets/layout-1.grid")

   -- currentState may be one of {"play", "pause", "edit", "delete", "win", "lose"}
   editState.load{colors=config.colors, grid=grid}
   currentState = editState

   backgroundImage = love.graphics.newImage("src/assets/canva.png", {dpiscale=0.75})
   
   font = love.graphics.newFont("src/assets/fonts/Undak-KVA3y.otf", 24)
   love.graphics.setFont(font)

   mainMusic = love.audio.newSource("src/assets/music/Elves (1).mp3", "static")
   mainMusic:setLooping(true)
   mainMusic:play()
   love.mouse.setVisible(true)
end

function love.update(dt)
   currentState = currentState.update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
   currentState.mousepressed(x, y, button, istouch, presses)
end

function love.draw()
   -- static images
   love.graphics.draw(backgroundImage)
   grid:draw()
   currentState.draw()
end
