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
  assert(type(event) == Type.STRING,
    "Argument \"event\" must be of type: "..Type.STRING)

  if type(Engine._currentRoom[event]) == Type.NIL then return end

  data = data or {}
  assert(type(data) == Type.TABLE,
    "Argument \"data\" must be of type: "..Type.TABLE)

  Engine._currentRoom[event](Engine._currentRoom, unpack(data))
end

--[[
  Enables various debugging overlay elements.
]]--
function Engine:enableDebugMode(options)
  options = options or {}
  assert(type(options) == Type.TABLE,
    "Argument \"options\" must be of type: "..Type.TABLE)

  for option, v in pairs(options) do
    if option ~= "showOverlay" and
      option ~= "showColliders" and
      option ~= "originCrosshairRadius" then
      error("Option \""..option.."\" is not a valid option")
    end
  end

  options.showOverlay = options.showOverlay or false
  options.showColliders = options.showColliders or false
  options.originCrosshairRadius = options.originCrosshairRadius or 0

  assert(options.originCrosshairRadius >= 0,
    "Argument \"originCrosshairRadius\" must be at least 0")

  assert(type(options.showOverlay) == Type.BOOLEAN,
    "Option \"showOverlay\" must be of type: "..Type.BOOLEAN)
  assert(type(options.showColliders) == Type.BOOLEAN,
    "Option \"showColliders\" must be of type: "..Type.BOOLEAN)
  assert(type(options.originCrosshairRadius) == Type.NUMBER,
    "Option \"originCrosshairRadius\" must be of type: "..Type.NUMBER)

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
  assert(type(room) == Type.TABLE,
    "Argument \"room\" must be of type: "..Type.TABLE)

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
