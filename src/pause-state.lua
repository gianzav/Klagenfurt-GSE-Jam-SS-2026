s = {}

function s.load(env)
   -- instructions that are run once when entering the state
   
   env = env
   balls = env.balls
end

function s.mousepressed(x, y, button, istouch, presses)
end


function s.update(dt)
   -- update executed at each frame
   -- MUST return the next state, wether itself or the next one
   return s
end

function s.draw()
   -- Draw the circle.
   for _,ball in pairs(balls) do
      ball:draw()
   end   
end

function s.unload()
   -- instructions that are run when leaving the state
end

return s
