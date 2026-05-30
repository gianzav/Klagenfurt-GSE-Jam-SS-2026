Ball = {}
Ball.__index = Ball

function Ball.new(color, x, y, radius)
   -- color given as table {r,g,b,a}
    local self = setmetatable({}, Ball)
    self.x = x
    self.y = y
    self.radius = radius
    self.color = color
    return self
end


function Ball:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a) -- Light gray color
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Ball:isClicked(mx, my)
    return mx >= self.x and mx <= (self.x + self.width) and my >= self.y and my <= (self.y + self.height)
end

function Ball:getWidth()
   return self.radius*2
end

function Ball:getHeight()
   return self.radius*2
end

function Ball:getDimensions()
   return {self:getHeight(), self:getWidth()}
end
