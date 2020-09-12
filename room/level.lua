level = Room:new("Level")

function level:load()
    -- Load map
    self:loadMap(map_debug)
    
    -- Load resources.
    self.imgPlayer = res.sprite.girlIdle
    self.imgPlayerFlash = res.sprite.girlFlash
    
    self.myNum = 3
    
    -- Initialize objects.
    self.player = Entity:new(100, 50)
    self.player.MOVE_SPEED = 1
    self.player.GRAVITY = 0.1
    self.player.JUMP_STRENGTH = 4
    self.player.xSpeed = 0
    self.player.ySpeed = 0
    self.player.wasGrounded = false
    self.player.isGrounded = false
    
    self.player:addAnimation("standing", res.sprite.playerStanding, 16, 32, {
        offsetX = -8,
        offsetY = -32
    })
    
    self.player:addAnimation("walking", res.sprite.playerWalking, 16, 32, {
        offsetX = -8,
        offsetY = -32,
        frameDuration = 20,
        shouldLoop = true,
        direction = Const.ANIM_PLAYBACK.ALTERNATE,
        startingFrame = 2
    })
    
    self.player:addCollider("physbox", {
        width = 12, height = 28,
        offsetX = -6, offsetY = -28
    })
end

function level:update()
    -- Handle player control ---------------------------------------------------
    if gamepad:isBeingHeld("right") then
        self.player.xSpeed = self.player.MOVE_SPEED
        self.player:flipHorizontally(false)
    elseif gamepad:isBeingHeld("left") then
        self.player.xSpeed = -self.player.MOVE_SPEED
        self.player:flipHorizontally(true)
    else
        self.player.xSpeed = 0
    end
    
    local playerPhysbox = self.player:getCollider("physbox")
    
    -- Move player horizontally & check tilemap collisions
    self.player:moveX(self.player.xSpeed)
    for i, o in ipairs(level:getMapObstacles()) do
        if Engine:checkCollision(playerPhysbox, o) then
            if self.player.xSpeed > 0 then
                self.player:setX(o.x - (playerPhysbox.width/2))
            else
                self.player:setX(o.x + o.width + (playerPhysbox.width/2))
            end
            self.player.xSpeed = 0
        end
    end
    
    -- Move player vertically & check tilemap collisions
    self.player.ySpeed = self.player.ySpeed + self.player.GRAVITY
    self.player:moveY(self.player.ySpeed)
    for i, o in ipairs(level:getMapObstacles()) do
        if Engine:checkCollision(playerPhysbox, o) then
            if self.player.ySpeed > 0 then
                self.player:setY(o.y)
                self.player.isGrounded = true
            else
                self.player:setY(o.y + o.height + playerPhysbox.height)
            end
            self.player.ySpeed = 0
        end
    end
    
    for i, o in ipairs(level:getMapPlatforms()) do
        if Engine:checkCollision(playerPhysbox, o) then
            if self.player.ySpeed > 0 and
                (self.player:getY() - self.player.ySpeed - 1) < o.y then
                self.player:setY(o.y)
                self.player.isGrounded = true
                self.player.ySpeed = 0
            end
        end
    end
    
    -- Handle player jumping
    if self.player.isGrounded and gamepad:wasPressed("fire1") then
        self.player.ySpeed = -self.player.JUMP_STRENGTH
    end
    
    
    -- Set player's animations
    if self.player.xSpeed == 0 then
        self.player:changeAnimation("standing")
    else
        self.player:changeAnimation("walking")
    end
    
    self.player.wasGrounded = self.player.isGrounded
    self.player.isGrounded = false
end

function level:draw()
    
end

function level:keypressed(key, scancode, isrepeat)
    -- print("Kbrd: " .. key .. " | " .. scancode)
end

function level:joystickhat(joystick, hat, direction)
    -- print("Hat : " .. hat .. " | " .. direction)
end
