level = Room:new("Level")

function level:load(prevRoom)
    -- Load resources.
    self.imgPlayer = love.graphics.newImage(res.sprite.girlIdle)
    self.imgPlayerFlash = love.graphics.newImage(res.sprite.girlFlash)
    self.imgBullet = love.graphics.newImage(res.sprite.bullet)
    
    self.myNum = 3
    
    -- Initialize objects.
    self.player = Entity:new(128, 128)
    self.player:addCollider("hitbox", {
        shape = Const.COLLIDER_SHAPE.RECTANGLE,
        width = 16, height = 16,
        offsetX = -8, offsetY = -16,
        relativity = Const.COLLIDER_POSITION.ORIGIN_POINT
    })
    self.player:addCollider("hurtbox1", {
        shape = Const.COLLIDER_SHAPE.RECTANGLE,
        width = 8, height = 8,
        offsetX = -4, offsetY = -4,
        relativity = Const.COLLIDER_POSITION.ACTION_POINT,
        relativeActionPoint = "head"
    })
    self.player:addCollider("hurtbox2", {
        shape = Const.COLLIDER_SHAPE.CIRCLE,
        radius = 8,
        offsetX = 0, offsetY = -17,
        relativity = Const.COLLIDER_POSITION.ACTION_POINT,
        relativeActionPoint = "above"
    })
    
    self.player:addAnimation("idle", self.imgPlayer, 18, 34, {
        offsetX = -7,
        offsetY = -34
    })
    self.player:addAnimation("flash", self.imgPlayerFlash, 18, 34, {
        frameDuration = 20,
        shouldLoop = true,
        direction = Const.ANIM_PLAYBACK.NORMAL,
        offsetX = -7,
        offsetY = -34,
        actionPoints = {
            head = {
                { x = 0, y = -28 },
                { x = 0, y = -28 },
                { x = 0, y = -28 },
                { x = 0, y = -28 },
                { x = 0, y = -28 }
            },
            above = {
                { x = 0, y = -30 },
                { x = 0, y = -30 },
                { x = 0, y = -30 },
                { x = 0, y = -30 },
                { x = 0, y = -30 }
            }
        }
    })
    self.player:changeAnimation("flash")
    self.player:setScale(2, 2)
    self.player.MOVE_SPEED = 1
    
    
    self.goomba1 = Entity:new(196, 169)
    self.goomba1:addCollider("hitbox", {
        shape = Const.COLLIDER_SHAPE.RECTANGLE,
        width = 16, height = 16,
        offsetX = -8, offsetY = -8
    })
    
    self.goomba2 = Entity:new(64, 64)
    self.goomba2:addCollider("hitbox", {
        shape = Const.COLLIDER_SHAPE.CIRCLE,
        radius = 16
    })
end

function level:update()
    if controllers[1]:isBeingHeld("up") then
        self.player:moveY(-self.player.MOVE_SPEED)
    elseif controllers[1]:isBeingHeld("down") then
        self.player:moveY(self.player.MOVE_SPEED)
    end
    
    if controllers[1]:isBeingHeld("left") then
        self.player:moveX(-self.player.MOVE_SPEED)
    elseif controllers[1]:isBeingHeld("right") then
        self.player:moveX(self.player.MOVE_SPEED)
    end

    if controllers[1]:wasPressed("fire3") then self.player:flipHorizontally() end
    if controllers[1]:wasPressed("fire5") then self.player:flipVertically() end
    if controllers[1]:isBeingHeld("fire1") then self.player:rotate(-1) end
    if controllers[1]:isBeingHeld("fire6") then self.player:rotate(1) end
    if controllers[1]:isBeingHeld("fire4") then self.player:scale(0.1, 0.1) end
    if controllers[1]:isBeingHeld("fire2") then self.player:scale(-0.1, -0.1) end
    
    -- if controllers[1]:isBeingHeld("fire4") then self.player:scaleHorizontally(0.1) end
    -- if controllers[1]:isBeingHeld("fire2") then self.player:scaleVertically(0.1) end
    
    for k, collider in pairs(self.player:getColliders()) do
        Engine:checkCollision(collider, self.goomba1:getCollider("hitbox"))
        Engine:checkCollision(collider, self.goomba2:getCollider("hitbox"))
    end
end

function level:draw()
    love.graphics.setColor(1, 1, 1, 1)
end

function level:keypressed(key, scancode, isrepeat)
    -- print("Kbrd: " .. key .. " | " .. scancode)
end

function level:joystickhat(joystick, hat, direction)
    print("Hat : " .. hat .. " | " .. direction)
end
