Engine = {}

-- Graphics scaling values
Engine._scaleFactorX = 1
Engine._scaleFactorY = 1

-- Input controller list for management
Engine._inputControllers = {}

-- Debug functionality
Engine.debugConfig = {
    showOverlay = false,
    showColliders = false,
    originCrosshairRadius = 0,
    highlightCollisions = false
}

-- FPS limiter
Engine._fpsMinDt = 1 / 60
Engine._fpsNextTime = love.timer.getTime()
Engine._fpsCurrentTime = Engine._fpsNextTime

-- Room/gamestate management
Engine._currentRoom = nil

--[[
    Updates elements necessary for game-engine functionality.
]]--
function Engine:update()
    -- Prepare FPS limiting
    self._fpsNextTime = self._fpsNextTime + self._fpsMinDt

    -- Update controllers
    for k, inputController in pairs(Engine._inputControllers) do
        inputController:_update()
    end

    -- Handle currently-active room logic
    Engine._currentRoom:_updateRoom()
end

--[[
    Draws various elements necessary for game-engine functionality.
]]--
function Engine:draw()
    -- Scale graphics to window size (based on game resolution)
    love.graphics.scale(Engine._scaleFactorX, Engine._scaleFactorY)

    -- Draw currently-active room graphics
    Engine._currentRoom:_drawRoom()

    -- Draw debug overlay
    if Engine.debugConfig.showOverlay then
        -- Display which gamestate is active
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("State: " .. Engine:getCurrentRoomName(), 4,
            love.graphics.getHeight() - 16)
        
        -- Display FPS
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(tostring(love.timer.getFPS()), 4, 0)
    end

    -- Cap FPS
    self._fpsCurrentTime = love.timer.getTime()
    if self._fpsNextTime <= self._fpsCurrentTime then
        self._fpsNextTime = self._fpsCurrentTime
    else
        love.timer.sleep(self._fpsNextTime - self._fpsCurrentTime)
    end
end

--[[
    Fowards a Love event handler down to the currently-active room.
]]--
function Engine:forwardEvent(event, data)
    -- Nothing to forward if active room doesn't have this event
    if type(Engine._currentRoom[event]) == Const.LUA_TYPE.NIL then return end
    
    -- Forward event
    data = data or {}
    Engine._currentRoom[event](Engine._currentRoom, unpack(data))
end

--[[
    Enables various debugging overlay elements.
]]--
function Engine:enableDebugMode(options)
    -- Check arguments
    options = options or {}

    -- Set option defaults
    Engine.debugConfig.showOverlay = options.showOverlay or
        Engine.debugConfig.showOverlay
    Engine.debugConfig.showColliders = options.showColliders or
        Engine.debugConfig.showColliders
    Engine.debugConfig.originCrosshairRadius = options.originCrosshairRadius or
        Engine.debugConfig.originCrosshairRadius
    Engine.debugConfig.highlightCollisions = options.highlightCollisions or
        Engine.debugConfig.highlightCollisions

    -- Save debug option settings
    Engine.debugConfig = options
end

--[[
    Changes the base resolution of the game.
]]--
function Engine:setBaseResolution(resX, resY)
    Engine._scaleFactorX = love.graphics.getWidth() / resX
    Engine._scaleFactorY = love.graphics.getHeight() / resY
end

--[[
    Limits the maximum FPS that the game can run at.
]]--
function Engine:setMaxFps(fps)
    Engine._fpsMinDt = 1 / fps
end

--[[
    Changes the currently-active game state.
]]--
function Engine:changeRoom(room)
    -- Clean up the room we're about to leave
    local prevRoom = nil
    if type(Engine._currentRoom) ~= Const.LUA_TYPE.NIL then
        Engine._currentRoom:_destroy()
        prevRoom = Engine._currentRoom
    end

    -- Force garbage collection
    collectgarbage()

    -- Switch to new room
    Engine._currentRoom = room
    if type(Engine._currentRoom.load) ~= Const.LUA_TYPE.NIL then
        Engine._currentRoom:load(prevRoom)
    end
end

--[[
    Returns the name of the currently-active room.
]]--
function Engine:getCurrentRoomName()
    return Engine._currentRoom:_getName()
end

function Engine:checkCollision(colliderA, colliderB)
    collisionOccurred = false
    
    if colliderA.shape == Const.COLLIDER_SHAPE.RECTANGLE and colliderB.shape == Const.COLLIDER_SHAPE.RECTANGLE then
        -- Both colliders are rectangles
        if colliderA.x < colliderB.x + colliderB.width and
            colliderA.x + colliderA.width > colliderB.x and
            colliderA.y < colliderB.y + colliderB.height and
            colliderA.y + colliderA.height > colliderB.y then
            collisionOccurred = true
        end
    elseif colliderA.shape == Const.COLLIDER_SHAPE.CIRCLE and colliderB.shape == Const.COLLIDER_SHAPE.CIRCLE then
        -- Both colliders are circles
        local dX = colliderA.x - colliderB.x
        local dY = colliderA.y - colliderB.y
        collisionOccurred = (math.sqrt(dX * dX + dY * dY) <
            (colliderA.radius + colliderB.radius))
    else
        -- One collider is a rectangle and the other is a circle
        if colliderA.shape == Const.COLLIDER_SHAPE.CIRCLE then
            colliderA, colliderB = colliderB, colliderA
        end
        local rect = colliderA
        local circle = colliderB
        
        local testX = circle.x
        local testY = circle.y
        
        -- Find closest edge
        if circle.x < rect.x then
            testX = rect.x
        elseif circle.x > rect.x + rect.width then
            testX = rect.x + rect.width
        end
        if circle.y < rect.y then
            testY = rect.y
        elseif circle.y > rect.y + rect.height then
            testY = rect.y + rect.height
        end
        
        -- Calculate distances based on closest edges
        local distX = circle.x - testX
        local distY = circle.y - testY
        local distance = math.sqrt((distX * distX) + (distY * distY))
        
        -- Collision check
        collisionOccurred = (distance <= circle.radius)
    end
    
    if collisionOccurred then
        colliderA.isColliding = true
        colliderB.isColliding = true
    end
    
    -- Return whether a collision happened
    return collisionOccurred
end
