menu = Room:new("Main Menu")

function menu:load(prevRoom)
end

function menu:update()
  if controllers[1]:wasPressed("fire1") then Engine:changeRoom(level) end
end

function menu:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Press start to play!", 100, 120)
end

function menu:keypressed(key, scancode, isrepeat)
end
