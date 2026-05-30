Ball = {}
Ball.__index = Ball

function Ball.new(color, radius, body)
   -- color given as table {r,g,b,a}
    local self = setmetatable({}, Ball)
    self.radius = radius
    self.color = color
    self.body = body
    return self
end


function Ball:draw()
   love.graphics.push()
   love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a) -- Light gray color
   love.graphics.circle("fill", self:getX(), self:getY(), self.radius)
   love.graphics.pop()
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

function Ball:getX()
   return self.body:getX()
end

function Ball:getY()
   return self.body:getY()
end
