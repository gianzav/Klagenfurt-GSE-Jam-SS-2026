require("button")

EditState = {}
EditState.__index = EditState

function EditState.new(env)
   local self = setmetatable({}, EditState)
   self.loaded = false
   self.grid = env.grid
   self.colors = env.colors
   self.playState = env.playState
   return self
end

function EditState:load(env, forceReload)
   if not self.loaded or forceReload then
      self.playState = env.playState
      self.loaded = true
      
      self.deletionEnabled = false
      
      -- colorButtons for edit mode
      self.editingColor = nil
      self.colorButtons = {}
      self.deleteButton = Button.new("clear", 50, 50, 50, 50, {r=0.9,g=0.9,b=0.9,a=1})
      self.deleteButton:registerCallback(function (buttonk)
	    self.deletionEnabled = true
      end)
      
      for i,color in pairs(self.colors) do
	 local b = Button.new(nil, 50, (i+1)*50, 50, 50, color) -- colored buttons
	 b:registerCallback(function (button)
	       self.editingColor = color
	       self.deletionEnabled = false
	 end)
	 table.insert(self.colorButtons, b)
      end

      self.saveButton = Button.new("Save", 200, 550, 200, 50)
      self.saveButton:registerCallback(function (self)
	    self.grid:saveToFile(os.date("%d-%m-%Y-%H-%M") .. ".grid")
      end)

      self.playButton = Button.new("Play", 400, 550, 200, 50)
      self.buttons = {self.saveButton, self.playButton}

      -- State transitions
      self.playButtonPressed = false
   end
end

function EditState:mousepressed(x, y, button, istouch, presses)
   for _,button in pairs(self.colorButtons) do
      if button:isClicked(x,y) then
	 button:runCallbacks()
      end
   end

   if self.deleteButton:isClicked(x,y) then
      self.deleteButton:runCallbacks()
   end
   
   if self.deletionEnabled then
      self.grid:deleteReferenceCell(x,y)
   else
      self.grid:addReferenceCell(x,y,self.editingColor)
   end
   
   if self.saveButton:isClicked(x,y) then
      self.saveButton:runCallbacks()
   end

   if button == 1 then
      for _,button in pairs(self.buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
   end

   if self.playButton:isClicked(x,y) then
      self.playButtonPressed = true
   end

end

function EditState:update(dt)
   if self.playButtonPressed then
      self:unload()
      self.playState:load(env)
      self.playButtonPressed = false
      return self.playState
   end
   
   return self
end

function EditState:draw()
   for _,button in pairs(self.colorButtons) do
      button:draw()
   end

   for _,button in pairs(self.buttons) do
      button:draw()
   end
   
   self.deleteButton:draw()
end

function EditState:unload()
end
