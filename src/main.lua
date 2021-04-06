-- Lemoncube game framework
require("lib.lemoncube.autoload")

-- Game objects
require("objects.player")

-- Maps
require('maps.map-debug')

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
        -- originCrosshairRadius = 8,
        highlightCollisions = true
    })

    local resImg = "res/img/"
    res = {
        sprite = {
            playerStanding = love.graphics.newImage(resImg .. "mia-stand.png"),
            playerWalking = love.graphics.newImage(resImg .. "mia-walk.png"),
            girlIdle = love.graphics.newImage(resImg .. "girl.png"),
            girlFlash = love.graphics.newImage(resImg .. "girl_flash.png"),
            tiles = love.graphics.newImage(resImg .. "tiles.png")
        },
        music = {
            dummy = "dummy"
        },
        sfx = {
            dummy = "dummy"
        }
    }

    gamepad = InputController:new()
    gamepad:setInput("up",    Const.INPUT_SOURCE.KB, "w")
    gamepad:setInput("down",  Const.INPUT_SOURCE.KB, "s")
    gamepad:setInput("left",  Const.INPUT_SOURCE.KB, "a")
    gamepad:setInput("right", Const.INPUT_SOURCE.KB, "d")
    gamepad:setInput("fire1", Const.INPUT_SOURCE.KB, "j")
    gamepad:setInput("fire2", Const.INPUT_SOURCE.KB, "k")
    gamepad:setInput("fire3", Const.INPUT_SOURCE.KB, "u")
    gamepad:setInput("fire4", Const.INPUT_SOURCE.KB, "i")
    gamepad:setInput("fire5", Const.INPUT_SOURCE.KB, "o")
    gamepad:setInput("fire6", Const.INPUT_SOURCE.KB, "l")
    
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
