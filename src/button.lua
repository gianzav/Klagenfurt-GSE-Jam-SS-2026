Button = {}
Button.__index = Button

function Button.new(label, x, y, width, height, backgroundColor)
    local self = setmetatable({}, Button)
    self.label = label
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.callbacks = {}

    if backgroundColor then
       self.backgroundColor = backgroundColor
    else
       self.backgroundColor = {r=0.8, g=0.8, b=0.9, a=1} -- gray by default
    end
    
    return self
end

function Button:draw()
   love.graphics.push("all")
   bg = self.backgroundColor
   love.graphics.setColor(bg.r, bg.g, bg.b, bg.a) -- Light gray color
   love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
   
   if self.label then
      love.graphics.setColor(0, 0, 0) -- Black color for text
      love.graphics.printf(self.label, self.x, self.y + (self.height / 4), self.width, "center")
   end
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
