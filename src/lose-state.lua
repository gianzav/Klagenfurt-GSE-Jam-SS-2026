LoseState = {}
LoseState.__index = LoseState

function LoseState.new(env)
   local self = setmetatable({}, LoseState)
   self.loaded = false
   return self
end

function LoseState:load(inpEnv, forceReload)
   if not self.loaded or forceReload then
      self.lossSound = love.audio.newSource("src/assets/music/Loss_Jingle.mp3", "static")
      self.endingImage = love.graphics.newImage("src/assets/ResultScreen.png", {dpiscale=0.75})
   end
end

function LoseState:mousepressed(x, y, button, istouch, presses)
end

function LoseState:update(dt)
   return self
end

function LoseState:draw()
   love.graphics.clear(1,1,1)
   love.graphics.draw(self.endingImage)
   drawCenteredText(350, 200, 50, 100, "YOU LOSE. SKILL ISSUE")
end

function LoseState:unload()
end
