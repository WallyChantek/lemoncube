Engine = {}

-- Graphics scaling values
Engine._scaleFactorX = 1
Engine._scaleFactorY = 1

-- Input controller list for management
Engine._inputControllers = {}

-- Debug functionality
Engine.debugOptions = {}
Engine._debugger = nil

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
    inputController:update()
  end

  -- Handle currently-active room logic
  Engine._currentRoom:updateRoom()
end

--[[
  Draws various elements necessary for game-engine functionality.
]]--
function Engine:draw()
  -- Scale graphics to window size (based on game resolution)
  love.graphics.scale(Engine._scaleFactorX, Engine._scaleFactorY)

  -- Draw currently-active room graphics
  Engine._currentRoom:drawRoom()

  -- Draw debug overlay
  if type(Engine._debugger) ~= Type.NIL then
    Engine._debugger:draw()
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
  validate.typeString(event, "event")
  
  -- Nothing to forward if active room doesn't have this event
  if type(Engine._currentRoom[event]) == Type.NIL then return end
  
  -- Forward event
  data = data or {}
  validate.typeTable(data, "data")
  Engine._currentRoom[event](Engine._currentRoom, unpack(data))
end

--[[
  Enables various debugging overlay elements.
]]--
function Engine:enableDebugMode(options)
  -- Check arguments
  options = options or {}
  validate.typeTable(options, "options")

  -- Validate option names
  validate.optionNames(options, {
    "showOverlay",
    "showColliders",
    "originCrosshairRadius",
    "highlightCollisions"
  })

  -- Set option defaults
  options.showOverlay = options.showOverlay or false
  options.showColliders = options.showColliders or false
  options.originCrosshairRadius = options.originCrosshairRadius or 0
  options.highlightCollisions = options.highlightCollisions or false

  -- Check option types
  validate.typeBoolean(options.showOverlay, "showOverlay")
  validate.typeBoolean(options.showColliders, "showColliders")
  validate.typeNumber(options.originCrosshairRadius, "originCrosshairRadius")
  validate.typeBoolean(options.highlightCollisions, "highlightCollisions")
  
  -- Check option values
  validate.atLeast(options.originCrosshairRadius, "originCrosshairRadius", 0)

  -- Create debugger object & save option settings
  Engine._debugger = Debugger:new()
  Engine.debugOptions = options
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
  validate.typeTable(room, "room")

  -- Clean up the room we're about to leave
  local prevRoom = nil
  if type(Engine._currentRoom) ~= Type.NIL then
    Engine._currentRoom:leave()
    prevRoom = Engine._currentRoom
  end

  -- Force garbage collection
  collectgarbage()

  -- Switch to new room
  Engine._currentRoom = room
  if type(Engine._currentRoom.load) ~= Type.NIL then
    Engine._currentRoom:load(prevRoom)
  end
end

--[[
  Returns the name of the currently-active room.
]]--
function Engine:getCurrentRoomName()
  return Engine._currentRoom:getName()
end

function Engine:checkCollision(colliderA, colliderB)
  collisionOccurred = false
  
  if colliderA.shape == Option.RECTANGLE and colliderB.shape == Option.RECTANGLE then
    -- Both colliders are rectangles
    if colliderA.x < colliderB.x + colliderB.width and
      colliderA.x + colliderA.width > colliderB.x and
      colliderA.y < colliderB.y + colliderB.height and
      colliderA.y + colliderA.height > colliderB.y then
      collisionOccurred = true
    end
  elseif colliderA.shape == Option.CIRCLE and colliderB.shape == Option.CIRCLE then
    -- Both colliders are circles
    local dX = colliderA.x - colliderB.x
    local dY = colliderA.y - colliderB.y
    collisionOccurred = (math.sqrt(dX * dX + dY * dY) <
      (colliderA.radius + colliderB.radius))
  else
    -- One collider is a rectangle and the other is a circle
    if colliderA.shape == Option.CIRCLE then
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
