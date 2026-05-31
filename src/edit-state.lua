require("button")

s = {}

loaded = false

function s.load(inpEnv, forceReload)
   if not loaded or forceReload then
      loaded = true
      env = inpEnv
      grid = env.grid
      
      deletionEnabled = false
      currentState = nil -- possible sub-state
      colors = env.colors
      -- colorButtons for edit mode
      editingColor = nil
      colorButtons = {}
      deleteButton = Button.new("clear", 50, 50, 50, 50, {r=0.9,g=0.9,b=0.9,a=1})
      deleteButton:registerCallback(function (self)
	    deletionEnabled = true
      end)
      
      for i,color in pairs(colors) do
	 b = Button.new(nil, 50, (i+1)*50, 50, 50, color) -- colored buttons
	 b:registerCallback(function (self)
	       editingColor = color
	       deletionEnabled = false
	 end)
	 table.insert(colorButtons, b)
      end


      saveButton = Button.new("Save", 200, 550, 200, 50)
      saveButton:registerCallback(function (self)
	    grid:saveToFile(os.date("%d-%m-%Y-%H-%M") .. ".grid")
      end)


      editButton = Button.new("Edit", 200, 550, 200, 50)
      playButton = Button.new("Play", 400, 550, 200, 50)
      

      editButton:registerCallback(function (self)
	    editState.load({colors=config.colors})
	    currentState = editState
	    balls = {}
      end)

      buttons = {saveButton, playButton}

      -- State transitions
      playButtonPressed = false
   end
end

function s.mousepressed(x, y, button, istouch, presses)
   for _,button in pairs(colorButtons) do
      if button:isClicked(x,y) then
	 button:runCallbacks()
      end
   end

   if deleteButton:isClicked(x,y) then
      deleteButton:runCallbacks()
   end
   
   if deletionEnabled then
      grid:deleteReferenceCell(x,y)
   else
      grid:addReferenceCell(x,y,editingColor)
   end
   
   if saveButton:isClicked(x,y) then
      saveButton:runCallbacks()
   end

   if button == 1 then
      for _,button in pairs(buttons) do
	 if button:isClicked(x,y) then
	    button:runCallbacks()
	 end
      end
   end

   if playButton:isClicked(x,y) then
      playButtonPressed = true
   end

end

function s.update(dt)
   if playButtonPressed then
      s.unload()
      playState.load(env)
      playButtonPressed = false
      return playState
   end
   
   return s
end

function s.draw()
   for _,button in pairs(colorButtons) do
      button:draw()
   end

   for _,button in pairs(buttons) do
      button:draw()
   end
   
   deleteButton:draw()
end

function s.unload()
end

return s
