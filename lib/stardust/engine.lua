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
    "originCrosshairRadius"
  })

  -- Set option defaults
  options.showOverlay = options.showOverlay or false
  options.showColliders = options.showColliders or false
  options.originCrosshairRadius = options.originCrosshairRadius or 0

  -- Check option types
  validate.typeBoolean(options.showOverlay, "showOverlay")
  validate.typeBoolean(options.showColliders, "showColliders")
  validate.typeNumber(options.originCrosshairRadius, "originCrosshairRadius")
  
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
