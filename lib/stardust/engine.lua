Engine = {}

Engine._scaleFactorX = 1
Engine._scaleFactorY = 1

Engine._inputControllers = {}
Engine._debugger = nil
Engine._supportedHandlers = {
  "joystickhat",
  "joystickaxis",
  "keypressed", -- TODO: Remove when we build our own menu stuff
}

-- FPS limiter
Engine._fpsMinDt = 1 / 60
Engine._fpsNextTime = love.timer.getTime()
Engine._fpsCurrentTime = Engine._fpsNextTime

-- Room/gamestate management
Engine._currentRoom = nil

-- Default Love configurations
love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest", "nearest")


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
  Engine:getRoom():updateCore()
end

--[[
  Draws various elements necessary for game-engine functionality.
]]--
function Engine:draw()
  love.graphics.scale(Engine._scaleFactorX, Engine._scaleFactorY)

  -- Draw currently-active room graphics
  Engine:getRoom():drawCore()

  -- Draw debug overlay
  if type(Engine._debugger) ~= TYPE_NIL then
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
  if type(Engine:getRoom()[event]) == TYPE_NIL then return end

  data = data or {}
  assert(type(event) == TYPE_STRING,
    "Argument \"event\" must be of type: "..TYPE_STRING)
  assert(type(data) == TYPE_TABLE,
    "Argument \"data\" must be of type: "..TYPE_TABLE)

  Engine:getRoom()[event](Engine:getRoom(), unpack(data))
end

--[[
  Enables various debugging overlay elements.
]]--
function Engine:enableDebugMode()
  Engine._debugger = Debugger:new()
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
  assert(type(room) == TYPE_TABLE,
    "Argument \"room\" must be of type: "..TYPE_TABLE)

  -- Clean up the room we're about to leave
  local prevRoom = nil
  if type(Engine._currentRoom) ~= TYPE_NIL then
    Engine._currentRoom:leave()
    prevRoom = Engine._currentRoom
  end

  -- Force garbage collection
  collectgarbage()

  -- Switch to new room
  Engine._currentRoom = room
  if type(Engine._currentRoom.load) ~= TYPE_NIL then
    Engine._currentRoom:load(prevRoom)
  end
end

function Engine:getRoom()
  return Engine._currentRoom
end
