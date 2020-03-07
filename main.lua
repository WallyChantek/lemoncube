-- Stardust game framework
require("lib.stardust.autoload")

-- Game states
require("room.room_menu")
require("room.room_level")

function love.load()
  Engine:setBaseResolution(320, 240)
  Engine:enableDebugMode()

  path_res_img = "res/img/"
  res = {
    sprite = {
      girlIdle = path_res_img .. "girl.png",
      girlFlash = path_res_img .. "girl_flash.png",
      block = path_res_img .. "block.png"
    },
    music = {
      dummy = "dummy"
    },
    sfx = {
      dummy = "dummy"
    }
  }

  controllers = {}
  controllers[1] = InputController:new()
  controllers[1]:setInput("up",    INPUT_KB, "w")
  controllers[1]:setInput("down",  INPUT_KB, "s")
  controllers[1]:setInput("left",  INPUT_KB, "a")
  controllers[1]:setInput("right", INPUT_KB, "d")
  controllers[1]:setInput("fire1", INPUT_KB, "j")
  controllers[1]:setInput("fire2", INPUT_KB, "k")
  controllers[1]:setInput("fire3", INPUT_KB, "u")
  controllers[1]:setInput("fire4", INPUT_KB, "i")
  
  Engine:changeRoom(menu)
end

function love.update(dt)
  -- Update systems
  Engine:update()
end

function love.draw()
  -- Draw systems
  Engine:draw()
end

function love.keypressed(key, scancode, isrepeat)
  if key == "f2" then
    -- Soft reset
    Engine:changeRoom(menu)
  elseif key == "escape" then
    -- Quit
    love.event.quit()
  end
  
  Engine:forwardEvent("keypressed", {key, scancode, isrepeat})
end

function love.joystickaxis(joystick, axis, value)
  Engine:forwardEvent("joystickaxis", {joystick, axis, value})
end

function love.joystickhat(joystick, hat, direction)
  Engine:forwardEvent("joystickhat", {joystick, hat, direction})
end
