WinState = {}
WinState.__index = WinState

function WinState.new(env)
   local self = setmetatable({}, WinState)
   self.loaded = false
   return self
end

function WinState:load(env, forceReload)
   if not self.loaded or forceReload then
      self.winSound = love.audio.newSource("src/assets/music/VictorySound.mp3", "static")
      self.winSound:play()
      self.endingImage = love.graphics.newImage("src/assets/ResultScreen.png", {dpiscale=0.75})
   end
end

function WinState:mousepressed(x, y, button, istouch, presses)
end

function WinState:update(dt)
   return self
end

function WinState:draw()
   love.graphics.clear(1,1,1)
   love.graphics.draw(self.endingImage)
   drawCenteredText(350, 200, 50, 100, "YOU WIN. CONGRATS")
end

function WinState:unload()
end
