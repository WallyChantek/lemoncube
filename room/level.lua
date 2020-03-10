level = Room:new("Level")

function level:load(prevRoom)
  -- Load resources.
  self.imgPlayer = love.graphics.newImage(res.sprite.girlIdle)
  self.imgPlayerFlash = love.graphics.newImage(res.sprite.girlFlash)
  
  -- Initialize objects.
  self.player = Entity:new(128, 128, "default", "player")
  self.player:addCollider("hitbox", {
    offsetX = -8,
    offsetY = -16,
    relativity = Option.RELATIVE_ORIGIN
  })
  
  self.player:addAnimation("flash", self.imgPlayerFlash, 18, 34, {
    duration = 20,
    shouldLoop = true,
    direction = Option.ANIM_NORMAL,
    offsetX = -7,
    offsetY = -34,
    actionPoints = {
      { x = 00, y = 01 },
      { x = 02, y = 03 },
      { x = 04, y = 05 },
      { x = 06, y = 07 },
      { x = 08, y = 09 }
    }
  })
  -- player:addAnimation("idle", imgPlayer, 18, 34)
  self.player:scale(3, 3)
end

function level:update()
  if controllers[1]:isBeingHeld("up") then
    self.player:moveY(-3)
  elseif controllers[1]:isBeingHeld("down") then
    self.player:moveY(3)
  end
  
  if controllers[1]:isBeingHeld("left") then
    self.player:moveX(-3)
  elseif controllers[1]:isBeingHeld("right") then
    self.player:moveX(3)
  end

  if controllers[1]:wasPressed("fire3") then self.player:flipHorizontally() end
  if controllers[1]:wasPressed("fire5") then self.player:flipVertically() end
  if controllers[1]:isBeingHeld("fire1") then self.player:rotate(-1) end
  if controllers[1]:isBeingHeld("fire6") then self.player:rotate(1) end
  if controllers[1]:isBeingHeld("fire4") then self.player:scale(0.1, 0.1) end
  if controllers[1]:isBeingHeld("fire2") then self.player:scale(-0.1, -0.1) end
end

function level:keypressed(key, scancode, isrepeat)
  -- print("Kbrd: " .. key .. " | " .. scancode)
end

function level:joystickaxis(joystick, axis, value)
  if math.abs(value) > 0.5 then
    print("Axis: " .. axis .. " | " .. value)
  end
end

function level:joystickhat(joystick, hat, direction)
  print("Hat : " .. hat .. " | " .. direction)
end
