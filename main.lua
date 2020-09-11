-- Stardust game framework
require("lib.stardust.autoload")

-- Rooms
require("room.menu")
require("room.level")

function love.load()
    love.graphics.setLineStyle("rough")
    love.graphics.setDefaultFilter("nearest", "nearest")
    Engine:setBaseResolution(320, 240)
    Engine:enableDebugMode({
        showOverlay = true,
        showColliders = true,
        originCrosshairRadius = 8,
        highlightCollisions = true
    })

    path_res_img = "res/img/"
    res = {
        sprite = {
            girlIdle = path_res_img .. "girl.png",
            girlFlash = path_res_img .. "girl_flash.png",
            bullet = path_res_img .. "bullet.png"
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
    controllers[1]:setInput("up",    Const.INPUT_SOURCE.KB, "w")
    controllers[1]:setInput("down",  Const.INPUT_SOURCE.KB, "s")
    controllers[1]:setInput("left",  Const.INPUT_SOURCE.KB, "a")
    controllers[1]:setInput("right", Const.INPUT_SOURCE.KB, "d")
    controllers[1]:setInput("fire1", Const.INPUT_SOURCE.KB, "j")
    controllers[1]:setInput("fire2", Const.INPUT_SOURCE.KB, "k")
    controllers[1]:setInput("fire3", Const.INPUT_SOURCE.KB, "u")
    controllers[1]:setInput("fire4", Const.INPUT_SOURCE.KB, "i")
    controllers[1]:setInput("fire5", Const.INPUT_SOURCE.KB, "o")
    controllers[1]:setInput("fire6", Const.INPUT_SOURCE.KB, "l")
    
    Engine:changeRoom(menu)
end

function love.update()
    Engine:update()
end

function love.draw()
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
