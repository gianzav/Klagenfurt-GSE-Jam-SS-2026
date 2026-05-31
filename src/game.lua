require("button")
require("grid")
require("ball")
require("edit-state")
require("play-state")
require("select-level-state")

function love.load()
   -- General config
   env = {
      gridDim = 8,
      cellSize = 50, -- Width and height of cells.
      gridWidth = 8,
      gridHeigth = 8,
      backgroundImage = love.graphics.newImage("src/assets/canva.png", {dpiscale=0.75}),
      font = love.graphics.newFont("src/assets/fonts/Undak-KVA3y.otf", 24),
      mainMusic = love.audio.newSource("src/assets/music/Elves (1).mp3", "static"),
      windowWidth = 800,
      windowHeight = 600,
      colors =  {
	 {r=1, g=0, b=0, a=1}, -- red
	 {r=0, g=1, b=0, a=1}, -- green
	 {r=0, g=0, b=1, a=1}, -- red
	 {r=1, g=1, b=0, a=1}, -- yellow
      }
   }

   env["gridPixelWidth"] = env.gridWidth*env.cellSize
   env["gridPixelHeight"] = env.gridHeigth*env.cellSize   
   env["gridXOffset"] = env.windowWidth/2-env.gridPixelWidth/2
   env["gridYOffset"] = env.windowHeight/2-env.gridPixelHeight/2
   env["grid"] = Grid.new(env.gridXOffset, env.gridYOffset, 8, 8, 50)

   love.graphics.setBackgroundColor(1,1,1)
   love.window.setMode(env.windowWidth, env.windowHeight, {resizable=false, vsync=0, minwidth=env.windowWidth, minheight=env.windowHeight})
   
   love.graphics.setFont(env.font)
   env.mainMusic:setLooping(true)
   env.mainMusic:play()
   love.mouse.setVisible(true)

   --grid = Grid.loadFromFile("src/assets/layout-1.grid")
   -- currentState may be one of {"play", "pause", "edit", "win", "lose"}
   env["selectLevelState"] = SelectLevelState.new(env)
   env["editState"] = EditState.new(env)
   env["playState"] = PlayState.new(env)
   -- env.editState:load{playState = env.playState}
   env.selectLevelState:load()
   currentState = env.selectLevelState
end

function love.update(dt)
   currentState = currentState:update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
   currentState:mousepressed(x, y, button, istouch, presses)
end

function love.draw()
   -- static images
   love.graphics.draw(env.backgroundImage)
   -- env.grid:draw()
   currentState:draw()
end
