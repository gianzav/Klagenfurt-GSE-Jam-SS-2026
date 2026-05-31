require("button")
require("grid")
-- require("play-state")

SelectLevelState = {}
SelectLevelState.__index = SelectLevelState

function SelectLevelState.new(env)
   self = setmetatable({}, SelectLevelState)
   self.loaded = false
   self.env = env
   return self
end


function SelectLevelState:load(env, forceReload)
   if not self.loaded or forceReload then
      local levelsdir = "src/assets/"
      levels = {
	 house = Grid.loadFromFile(levelsdir .. "house.grid"),
	 glass = Grid.loadFromFile(levelsdir .. "glass.grid"),
	 snake = Grid.loadFromFile(levelsdir .. "snake.grid"),
	 smile = Grid.loadFromFile(levelsdir .. "smile.grid"),
	 flower = Grid.loadFromFile(levelsdir .. "flower.grid")
      }

      self.gridSelected = nil
      self.levelButtons = {}
      local i = 1 
      for name,grid in pairs(levels) do
	 local button = Button.new(name, 350, i*70, 100, 50)
	 button:registerCallback(function (button)
	       self.gridSelected = grid
	 end)
	 table.insert(self.levelButtons, button)
	 i = i + 1
      end
   end
end

function SelectLevelState:update(dt)
   if self.gridSelected then
      local playState = PlayState.new(self.env)
      playState:load{grid=self.gridSelected}
      return playState
   end
   
   return self
end

function SelectLevelState:mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      for _,button in pairs(self.levelButtons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
   end
end

function SelectLevelState:draw()
   for _,button in pairs(self.levelButtons) do
      button:draw()
   end
end

function SelectLevelState:unload()
end
