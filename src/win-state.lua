s = {}

function s.load()
   winSound = love.audio.newSource("src/assets/music/VictorySound.mp3", "static")
   winSound:play()
   endingImage = love.graphics.newImage("src/assets/ResultScreen.png", {dpiscale=0.75})
end

function s.mousepressed(x, y, button, istouch, presses)
end

function s.update(dt)
end

function s.draw()
   love.graphics.clear(1,1,1)
   love.graphics.draw(endingImage)
   drawCenteredText(350, 200, 50, 100, "YOU WIN. CONGRATS")
end

function s.unload()
end

return s
