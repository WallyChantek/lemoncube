Animation = {}
Animation.__index = Animation

--[[
  Constructor
]]--
function Animation:new(image, width, height, options)
  local o = {}
  setmetatable(o, Animation)

  -- Argument checking
  assert(type(image) == TYPE_USERDATA,
    "Argument \"image\" must be of type: "..TYPE_USERDATA)
  assert(type(width) == TYPE_NUMBER,
    "Argument \"width\" must be of type: "..TYPE_NUMBER)
  assert(type(height) == TYPE_NUMBER,
    "Argument \"height\" must be of type: "..TYPE_NUMBER)
  
  -- Options validation checking
  options = options or {}
  assert(type(options) == TYPE_TABLE,
    "Argument \"options\" must be of type: "..TYPE_TABLE)
  for option, v in pairs(options) do
    if option ~= "duration" and
      option ~= "shouldLoop" and
      option ~= "cycles" and
      option ~= "loopPoint" and
      option ~= "direction" and
      option ~= "offsetX" and
      option ~= "offsetY" and
      option ~= "actionPoints" then
      error("Option \""..option.."\" is not a valid option")
    end
  end
  
  -- Configuration
  o._duration = options.duration or 10
  o._shouldLoop = options.shouldLoop or false
  o._cycles = options.cycles or 1
  o._loopPoint = options.loopPoint or 1
  o._isReversed = options.direction == ANIM_REVERSE or
    options.direction == ANIM_ALTERNATE_REVERSE
  o._shouldAlternate = options.direction == ANIM_ALTERNATE or
    options.direction == ANIM_ALTERNATE_REVERSE
  o._offsetX = options.offsetX or 0
  o._offsetY = options.offsetY or 0
  o._actionPoints = options.actionPoints or {}
  
  -- Options checking
  local direction = options.direction or 0
  assert(type(o._duration) == TYPE_NUMBER,
    "Option \"duration\" must be of type: "..TYPE_NUMBER)
  assert(type(o._shouldLoop) == TYPE_BOOLEAN,
    "Option \"shouldLoop\" must be of type: "..TYPE_BOOLEAN)
  assert(type(o._cycles) == TYPE_NUMBER,
    "Option \"cycles\" must be of type: "..TYPE_NUMBER)
  assert(type(o._loopPoint) == TYPE_NUMBER,
    "Option \"loopPoint\" must be of type: "..TYPE_NUMBER)
  assert(type(direction) == TYPE_NUMBER,
    "Option \"direction\" must use a valid constant value")
  assert(type(o._offsetX) == TYPE_NUMBER,
    "Option \"offsetX\" must be of type: "..TYPE_NUMBER)
  assert(type(o._offsetY) == TYPE_NUMBER,
    "Option \"offsetY\" must be of type: "..TYPE_NUMBER)
  assert(type(o._actionPoints) == TYPE_TABLE,
    "Option \"actionPoints\" must be of type: "..TYPE_TABLE)
  
  -- Data checking
  assert(width > 0,
    "Argument \"width\" must be at least 1")
  assert(height > 0,
    "Argument \"height\" must be at least 1")
  assert(o._duration > 0,
    "Option \"_duration\" must be at least 1")
  assert(o._cycles >= 1,
    "Option \"cycles\" must be at least 1")
  assert(o._loopPoint >= 1,
    "Option \"loopPoint\" must be at least 1")
  assert(direction >= ANIM_NORMAL and direction <= ANIM_ALTERNATE_REVERSE,
    "Option \"direction\" must use a valid constant value")
  
  -- Internal values
  o._currentFrame = 1
  o._frameTimer = o._duration
  o._remainingCycles = o._cycles
  o._paused = false
  
  -- Generate clipping rectangles
  o._img = image
  o._quads = {}
  -- Insert frames based on playback type
  if not o._isReversed then
    for y = 0, image:getHeight() - height, height do
      for x = 0, image:getWidth() - width, width do
        table.insert(o._quads, love.graphics.newQuad(x, y, width, height,
          image:getDimensions()))
      end
    end
  else
    for y = image:getHeight() - height, 0, -height do
      for x = image:getWidth() - width, 0, -width do
        table.insert(o._quads, love.graphics.newQuad(x, y, width, height,
          image:getDimensions()))
      end
    end
  end

  -- Validate action point data
  if #o._actionPoints > 0 then
    assert(#o._actionPoints == #o._quads,
      "Option \"actionPoint\" must match number of frames in animation")

    -- Reverse action point data if necessary
    if o._isReversed then
      reverseArray(o._actionPoints)
    end
  else
    -- If no action point data is supplied, just default everything to 0,0
    for i = 1, #o._quads, 1 do
      table.insert(o._actionPoints, { x=0, y=0 })
    end
  end

  -- Insert additional frames if set to ping-pong (reverse) at end
  if o._shouldAlternate then
    for i = #o._quads - 1, o._loopPoint + 1, -1 do
      table.insert(o._quads, o._quads[i])
      table.insert(o._actionPoints, o._actionPoints[i])
    end
  end

  return o
end

--[[
  Processes the animation.
]]--
function Animation:animate(dt)
  if type(dt) ~= TYPE_NIL then
    assert(type(dt) == TYPE_NUMBER,
      "Argument dt must be of type: "..TYPE_NUMBER)
  end

  -- Don't animate if playback paused or there are no frames left to animate
  if self._paused or self._remainingCycles == 0 then
    return
  end
  
  -- Animate
  if self._frameTimer <= 0 then
    self._currentFrame = self._currentFrame + 1
    self._frameTimer = self._duration
  end

  if not dt then
    self._frameTimer = self._frameTimer - 1
  else
    self._frameTimer = self._frameTimer - (dt * #self._quads)
  end
  
  -- Loop (if necessary)
  if self._currentFrame > #self._quads then
    if self._shouldLoop then
      -- Reset if animation should loop indefinitely
      self._currentFrame = self._loopPoint
    else
      -- Otherwise, handle cycle-based looping
      self._remainingCycles = self._remainingCycles - 1
      
      if self._remainingCycles > 0 or self._shouldAlternate then
        self._currentFrame = self._loopPoint
      else
        self._currentFrame = #self._quads
      end
    end
  end
end

--[[
  Displays the current frame of the animation.
--]]
function Animation:draw(x, y, rotation, scaleX, scaleY)
  assert(type(x) == TYPE_NUMBER,
    "Argument \"x\" must be of type: "..TYPE_NUMBER)
  assert(type(y) == TYPE_NUMBER,
    "Argument \"y\" must be of type: "..TYPE_NUMBER)
  assert(type(rotation) == TYPE_NUMBER,
    "Argument \"rotation\" must be of type: "..TYPE_NUMBER)
  assert(type(scaleX) == TYPE_NUMBER,
    "Argument \"scaleX\" must be of type: "..TYPE_NUMBER)
  assert(type(scaleY) == TYPE_NUMBER,
    "Argument \"scaleY\" must be of type: "..TYPE_NUMBER)
  
  love.graphics.draw(self._img, self._quads[self._currentFrame],
    x + (self._offsetX * scaleX), y + (self._offsetY * scaleY), rotation,
    scaleX, scaleY)
end

--[[
  Returns the current frame number of the animation.
--]]
function Animation:getCurrentFrame()
  return self._currentFrame
end

--[[
  Returns whether the animation is currently animating, or if it's reached the
  end of its cycle. EXT: Looped animations will always return true.
]]--
function Animation:hasFinished()
  return self._remainingCycles ~= 0
end

--[[
  Freezes an active animation.
]]--
function Animation:pause()
  self._paused = true
end

--[[
  Restarts the animation from the beginning of its cycles.
]]--
function Animation:restart()
  self._currentFrame = 1
  self._frameTimer = self._duration
  self._remainingCycles = self._cycles
end

--[[
  Resumes a paused animation.
]]--
function Animation:resume()
  self._paused = false
end

--[[
  Returns the X-coordinate position of the current frame's action point.
]]--
function Animation:getActionPointX()
  return self._actionPoints[self._currentFrame].x
end

--[[
  Returns the Y-coordinate position of the current frame's action point.
]]--
function Animation:getActionPointY()
  return self._actionPoints[self._currentFrame].y
end
