Animation = {}
Animation.__index = Animation

--[[
  Constructor
]]--
function Animation:new(image, width, height, options)
  local o = {}
  setmetatable(o, Animation)

  -- Check arguments
  options = options or {}
  validate.typeUserdata(image, "image")
  validate.typeNumber(width, "width")
  validate.typeNumber(height, "height")
  validate.typeTable(options, "options")
  
  -- Validate option names
  validate.optionNames(options, {
    "frameDuration",
    "shouldLoop",
    "cycles",
    "loopPoint",
    "direction",
    "offsetX",
    "offsetY",
    "actionPoints"
  })
  
  -- Set option defaults
  o._frameDuration = options.frameDuration or 10
  o._shouldLoop = options.shouldLoop or false
  o._cycles = options.cycles or 1
  o._loopPoint = options.loopPoint or 1
  o._isReversed = options.direction == Option.ANIM_REVERSE or
    options.direction == Option.ANIM_ALTERNATE_REVERSE
  o._shouldAlternate = options.direction == Option.ANIM_ALTERNATE or
    options.direction == Option.ANIM_ALTERNATE_REVERSE
  o._offsetX = options.offsetX or 0
  o._offsetY = options.offsetY or 0
  o._actionPoints = options.actionPoints or {}
  
  -- Check option types
  local direction = options.direction or 0
  validate.typeNumber(o._frameDuration, "frameDuration")
  validate.typeBoolean(o._shouldLoop, "shouldLoop")
  validate.typeNumber(o._cycles, "cycles")
  validate.typeNumber(o._loopPoint, "loopPoint")
  validate.typeNumber(direction, "direction")
  validate.typeNumber(o._offsetX, "offsetX")
  validate.typeNumber(o._offsetY, "offsetY")
  validate.typeTable(o._actionPoints, "actionPoints")
  
  -- Check option data
  validate.atLeast(width, "width", 1)
  validate.atLeast(height, "height", 1)
  validate.atLeast(o._frameDuration, "frameDuration", 1)
  validate.atLeast(o._cycles, "cycles", 1)
  validate.atLeast(o._loopPoint, "loopPoint", 1)
  validate.constant(direction, "direction", {
    Option.ANIM_NORMAL,
    Option.ANIM_REVERSE,
    Option.ANIM_ALTERNATE,
    Option.ANIM_ALTERNATE_REVERSE
  })
  
  -- Internal values needed for animation processing
  o._currentFrame = 1
  o._frameTimer = o._frameDuration
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
  if util.size(o._actionPoints) > 0 then
    for apName, apPairs in pairs(o._actionPoints) do
      -- Verify that number of action point pairs is correct
      validate.equals(util.size(apPairs), "apPairs", util.size(o._quads),
        " must match number of frames in animation")
      
      -- Iterate through each action point pair
      for k, apPair in pairs(apPairs) do
        -- Validate action point pair options
        validate.optionNames(apPair, {"x", "y"})
        
        -- Validation action point pair types
        validate.typeNumber(apPair.x, "x")
        validate.typeNumber(apPair.y, "y")
      end

      -- Reverse action point data if necessary
      if o._isReversed then
        util.reverseTable(apPairs)
      end
    end
  end

  -- Insert additional frames (and action points) if set to alternate
  if o._shouldAlternate then
    for i = util.size(o._quads) - 1, o._loopPoint + 1, -1 do
      table.insert(o._quads, o._quads[i])
      for actionPointName, actionPointPairs in pairs(o._actionPoints) do
        table.insert(actionPointPairs, actionPointPairs[i])
      end
    end
  end

  return o
end

--[[
  Processes the animation.
]]--
function Animation:animate()
  -- Don't animate if playback paused or there are no frames left to animate
  if self._paused or self._remainingCycles == 0 then
    return
  end
  
  -- Animate
  if self._frameTimer <= 0 then
    self._currentFrame = self._currentFrame + 1
    self._frameTimer = self._frameDuration
  end
  self._frameTimer = self._frameTimer - 1
  
  -- Loop (if necessary)
  if self._currentFrame > util.size(self._quads) then
    if self._shouldLoop then
      -- Reset if animation should loop indefinitely
      self._currentFrame = self._loopPoint
    else
      -- Otherwise, handle cycle-based looping
      self._remainingCycles = self._remainingCycles - 1
      
      if self._remainingCycles > 0 or self._shouldAlternate then
        self._currentFrame = self._loopPoint
      else
        self._currentFrame = util.size(self._quads)
      end
    end
  end
end

--[[
  Displays the current frame of the animation.
--]]
function Animation:draw(x, y, rotation, scaleX, scaleY)
  validate.typeNumber(x, "x")
  validate.typeNumber(y, "y")
  validate.typeNumber(rotation, "rotation")
  validate.typeNumber(scaleX, "scaleX")
  validate.typeNumber(scaleY, "scaleY")
  
  love.graphics.draw(self._img, self._quads[self._currentFrame],
    x, y, rotation,
    scaleX, scaleY, -self._offsetX, -self._offsetY)
end

--[[
  Freezes an active animation.
]]--
function Animation:pause()
  self._paused = true
end

--[[
  Resumes a paused animation.
]]--
function Animation:resume()
  self._paused = false
end

--[[
  Restarts the animation from the beginning of its cycles.
]]--
function Animation:restart()
  self._currentFrame = 1
  self._frameTimer = self._frameDuration
  self._remainingCycles = self._cycles
end

--[[
  Sets the frame duration of the animation.
]]--
function Animation:setFrameDuration(frameDuration)
  validate.typeNumber(frameDuration, "frameDuration")
  self._frameTimer = self._frameTimer - (self._frameDuration - frameDuration)
  self._frameDuration = frameDuration
end

--[[
  Returns the current frame number of the animation.
--]]
function Animation:getCurrentFrame()
  return self._currentFrame
end

--[[
  Returns whether the animation is paused or playing.
]]--
function Animation:isPaused()
  return self._paused
end

--[[
  Returns whether the animation is currently animating, or if it's reached the
  end of its cycle. EXT: Looped animations will always return true.
]]--
function Animation:isDone()
  return self._remainingCycles == 0
end

--[[
  Returns the X-coordinate position of the current frame's action point.
]]--
function Animation:getActionPointX(actionPointName)
  if type(self._actionPoints[actionPointName]) ~= Type.NIL then
    return self._actionPoints[actionPointName][self._currentFrame].x
  else
    return 0
  end
end

--[[
  Returns the Y-coordinate position of the current frame's action point.
]]--
function Animation:getActionPointY(actionPointName)
  if type(self._actionPoints[actionPointName]) ~= Type.NIL then
    return self._actionPoints[actionPointName][self._currentFrame].y
  else
    return 0
  end
end
