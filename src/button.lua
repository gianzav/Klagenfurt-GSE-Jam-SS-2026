Button = {}
Button.__index = Button

function Button.new(label, x, y, width, height)
    local self = setmetatable({}, Button)
    self.label = label
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.callbacks = {}
    return self
end

function Button:draw()
   love.graphics.push("all")
   love.graphics.setColor(0.8, 0.8, 0.8) -- Light gray color
   love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
   love.graphics.setColor(0, 0, 0) -- Black color for text
   love.graphics.printf(self.label, self.x, self.y + (self.height / 4), self.width, "center")
   love.graphics.pop()
end

function Button:isClicked(mx, my)
    return mx >= self.x and mx <= (self.x + self.width) and my >= self.y and my <= (self.y + self.height)
end

function Button:registerCallback(callback)
   -- Add a callback to be run when the mouse is clicked
   table.insert(self.callbacks, callback)
end

function Button:runCallbacks()
   for k,callback in pairs(self.callbacks) do
      callback(self)
   end
end
