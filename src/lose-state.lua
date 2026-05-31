require("button")
require("select-level-state")

LoseState = {}
LoseState.__index = LoseState

function LoseState.new(env)
   local self = setmetatable({}, LoseState)
   self.loaded = false
   self.env = env
   return self
end

function LoseState:load(inpEnv, forceReload)
   if not self.loaded or forceReload then
      self.lossSound = love.audio.newSource("src/assets/music/Loss_Jingle.mp3", "static")
      self.endingImage = love.graphics.newImage("src/assets/ResultScreen.png", {dpiscale=0.75})

      self.retryButtonPressed = false
      local retryButton = Button.new("Retry", 350, 350, 100, 50)
      retryButton:registerCallback(function (button)
	    self.retryButtonPressed = true
      end)
      self.buttons = {retryButton}
   end
end

function LoseState:mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      for _,button in pairs(self.buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
   end
end

function LoseState:update(dt)
   if self.retryButtonPressed then
      local state = SelectLevelState.new(self.env)
      state:load()
      return state
   end
      
   return self
end

function LoseState:draw()
   love.graphics.clear(1,1,1)
   love.graphics.draw(self.endingImage)
   drawCenteredText(350, 200, 50, 100, "YOU LOSE :(")
   
   for _,button in pairs(self.buttons) do
      button:draw()
   end
end

function LoseState:unload()
end
