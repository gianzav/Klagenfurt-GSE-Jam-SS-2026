Ball = {}
Ball.__index = Ball

function Ball.new(color, radius, body, sprite)
   -- color given as table {r,g,b,a}. sprite is optional
    local self = setmetatable({}, Ball)
    self.radius = radius
    self.color = color
    self.body = body
    self.sprite = sprite
    return self
end


function Ball:draw()
   love.graphics.push("all")
   if self.sprite then
      love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a) -- Light gray color
      love.graphics.draw(self.sprite, self:getX()-self.sprite:getWidth()/2, self:getY()-self.sprite:getHeight()/2)
   else
      love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a) -- Light gray color
      love.graphics.circle("fill", self:getX(), self:getY(), self.radius)
   end
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


function generateBall(world, x, y, colors, sprite)
   local ballRadius = 25
   
   -- Create a Body for the circle
   body = love.physics.newBody(world, x+ballRadius, y, "dynamic")
   
   -- Attatch a shape to the body.
   circle_shape = love.physics.newCircleShape(0,0,25)
   
   -- Create fixture between body and shape
   fixture = love.physics.newFixture(body, circle_shape)

   -- Calculate the mass of the body based on attatched shapes.
   -- This gives realistic simulations.
   body:setMassData(circle_shape:computeMass( 1 ))
   randomColor = math.random(1, #colors)
   ball = Ball.new(colors[randomColor], 25, body, sprite)
   return ball
end
