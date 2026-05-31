PauseState = {}
PauseState.__index = PauseState

function PauseState.new(env)
   self = setmetatable({}, PauseState)
   self.loaded = false
   self.balls = env.balls
   self.playState = env.playState
   self.editState = env.editState
   return self
end

function PauseState:load(env, forceReload)
   -- instructions that are run once when entering the stat
   if not self.loaded or forceReload then
      self.balls = env.balls
      self.playButtonPressed = false
      self.playButton = Button.new("Play", 400, 550, 200, 50)
      self.playButton:registerCallback(function (button)
	    self.playButtonPressed = true
      end)

      self.editButtonPressed = false
      self.editButton = Button.new("Edit", 200, 550, 200, 50)
      self.editButton:registerCallback(function (button)
	    self.editButtonPressed = true
      end)

      self.buttons = {self.playButton, self.editButton}
   end
end

function PauseState:mousepressed(x, y, button, istouch, presses)
   if button == 1 then
      for _,button in pairs(self.buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
   end
end


function PauseState:update(dt)
   -- update executed at each frame
   -- MUST return the next state, wether itself or the next one
   if self.playButtonPressed then
      self.playButtonPressed = false
      debug.debug()
      return self.playState
   end
   if self.editButtonPressed then
      self.editButtonPressed = false
      return self.editState
   end
   
   return self
end

function PauseState:draw()
   -- Draw the circle.
   for _,ball in pairs(self.balls) do
      ball:draw()
   end

   for _,button in pairs(self.buttons) do
      button:draw()
   end
end

function PauseState:unload()
   -- instructions that are run when leaving the state
end
