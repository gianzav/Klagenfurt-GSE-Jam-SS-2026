s = {}

function s.load(env)
   -- instructions that are run once when entering the state
   env = env          -- data shared by previous state
end

function s.mousepressed(x, y, button, istouch, presses)
end

end

function s.update(dt)
   -- update executed at each frame
   -- MUST return the next state, wether itself or the next one
end

function s.draw()
end

function s.unload()
   -- instructions that are run when leaving the state
end

return s
