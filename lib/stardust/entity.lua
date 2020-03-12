Entity = {}
Entity.__index = Entity

--[[
  Constructor
]]--
function Entity:new(x, y)
  local o = {}
  setmetatable(o, Entity)
  
  -- Check arguments
  validate.typeNumber(x, "x")
  validate.typeNumber(y, "y")

  -- Marker indicating this is an entity (used in room cleanup)
  o._isEntity = true

  -- Object's position
  o._x = x
  o._y = y
  
  -- Object's colliders
  o._colliders = {}
  
  -- Object's graphical/animation data
  o._colorMix = { r = 1, g = 1, b = 1, a = 1 }
  o._animations = {}
  o._activeAnimation = ""
  o._angle = 0
  o._horizontalFlip = 1
  o._verticalFlip = 1
  o._xScale = 1
  o._yScale = 1
  o._isVisible = true

  return o
end

--[[
  Displays the entity's graphics.
]]--
function Entity:_draw(originSize)
  -- Draw current graphic
  if self._isVisible and self._colorMix.a > 0 then
    love.graphics.setColor(self._colorMix.r, self._colorMix.g, self._colorMix.b,
      self._colorMix.a)
    self._animations[self._activeAnimation]:draw(self._x, self._y,
      math.rad(self._angle), self._horizontalFlip * self._xScale,
      self._verticalFlip * self._yScale)
  end
  
  -- Draw collider(s)
  if (Engine.debugOptions.showColliders) then
    love.graphics.setColor(1, 0, 0, 0.5)
    for k, collider in pairs(self._colliders) do
      self:_updateColliders()
      if collider.shape == Option.RECTANGLE then
        love.graphics.rectangle("fill", collider.x, collider.y,
          collider.width, collider.height)
      else
        love.graphics.ellipse("fill", collider.x, collider.y,
          collider.width / 2, collider.height / 2)
      end
    end
  end

  -- Draw origin point
  if Engine.debugOptions.originCrosshairRadius > 0 then
    local orgOut = Engine.debugOptions.originCrosshairRadius +
      (Engine.debugOptions.originCrosshairRadius / 2)
    local orgIn = orgOut - Engine.debugOptions.originCrosshairRadius
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.points(self._x, self._y)
    love.graphics.ellipse("line", self._x, self._y,
      Engine.debugOptions.originCrosshairRadius,
      Engine.debugOptions.originCrosshairRadius)
    love.graphics.line(self._x - orgIn, self._y, self._x - orgOut, self._y)
    love.graphics.line(self._x + orgIn, self._y, self._x + orgOut, self._y)
    love.graphics.line(self._x, self._y - orgIn, self._x, self._y - orgOut)
    love.graphics.line(self._x, self._y + orgIn, self._x, self._y + orgOut)
  end
end


-- Graphics --------------------------------------------------------------------
--[[
  Makes the entity visible.
]]--
function Entity:show()
  self._isVisible = true
end

--[[
  Makes the entity invisible.
]]--
function Entity:hide()
  self._isVisible = false
end

--[[
  Sets the color influence for the entity's graphics.
]]--
function Entity:setColorMix(r, g, b)
  validate.typeNumber(r, "r")
  validate.typeNumber(g, "g")
  validate.typeNumber(b, "b")
  
  self._colorMix.r = math.clamp(r, 0, 1)
  self._colorMix.g = math.clamp(g, 0, 1)
  self._colorMix.b = math.clamp(b, 0, 1)
end

--[[
  Returns the color influence for the entity's graphics.
]]--
function Entity:getColorMix()
  return {
    self._colorMix.r,
    self._colorMix.g,
    self._colorMix.b
  }
end

--[[
  Sets the alpha/semi-transparency for the entity's graphics.
]]--
function Entity:setTransparency(a)
  validate.typeNumber(a, "a")
  
  self._colorMix.a = math.clamp(a, 0, 1)
end

--[[
  Returns the alpha/semi-transparency for the entity's graphics.
]]--
function Entity:getTransparency()
  return self._colorMix.a
end

--[[
  Flips the entity's graphics horizontally.
]]--
function Entity:flipHorizontally(isFlipped)
  if type(isFlipped) == Type.NIL then
    self._horizontalFlip = self._horizontalFlip - (self._horizontalFlip * 2)
  else
    validate.typeBoolean(isFlipped, "isFlipped")
    if isFlipped then
      self._horizontalFlip = -1
    else
      self._horizontalFlip = 1
    end
  end
end

--[[
  Flips the entity's graphics vertically.
]]--
function Entity:flipVertically(isFlipped)
  if type(isFlipped) == Type.NIL then
    self._verticalFlip = self._verticalFlip - (self._verticalFlip * 2)
  else
    validate.typeBoolean(isFlipped, "isFlipped")
    if isFlipped then
      self._verticalFlip = -1
    else
      self._verticalFlip = 1
    end
  end
end

--[[
  Returns the horizontal-flipped state for the entity.
]]--
function Entity:isFlippedHorizontally()
  return util.numberToBoolean(1 - self._horizontalFlip)
end

--[[
  Returns the vertical-flipped state for the entity.
]]--
function Entity:isFlippedVertically()
  return util.numberToBoolean(1 - self._verticalFlip)
end


-- Animation -------------------------------------------------------------------
--[[
  Processes the entity currently-active animation.
]]--
function Entity:_animate()
  self._animations[self._activeAnimation]:animate()
end

--[[
  Adds an animation to the entity.
]]--
function Entity:addAnimation(animationName, image, width, height, options)
  validate.typeString(animationName, "animationName")
  
  self._animations[animationName] = Animation:new(image, width, height, options)
  
  if self._activeAnimation == "" then
    self._activeAnimation = animationName
  end
end

--[[
  Changes the current animation.
]]--
function Entity:changeAnimation(animationName)
  validate.typeString(animationName, "animationName")
  
  self._activeAnimation = animationName
  self._animations[self._activeAnimation]:restart()
end

--[[
  Pauses or resumes the current animation.
]]--
function Entity:pauseAnimation(isPaused)
  isPaused = isPaused or not self._animations[self._activeAnimation]:isPaused()
  validate.typeBoolean(isPaused, "isPaused")
  
  if isPaused then
    self._animations[self._activeAnimation]:pause()
  else
    self._animations[self._activeAnimation]:resume()
  end
end

--[[
  Restarts the current animation.
]]--
function Entity:restartAnimation()
  self._animations[self._activeAnimation]:restart()
end

--[[
  Sets the frame duration of the current animation.
]]--
function Entity:setAnimationFrameDuration(newDuration)
  self._animations[self._activeAnimation]:setFrameDuration(newDuration)
end

--[[
  Returns the current animation's name.
]]--
function Entity:getAnimationName()
  return self._activeAnimation
end

--[[
  Returns the current frame number of the animation.
]]--
function Entity:getAnimationFrame()
  return self._animations[self._activeAnimation]:getCurrentFrame()
end

--[[
  Returns whether the animation is paused or playing.
]]--
function Entity:isAnimationPaused()
  return self._animations[self._activeAnimation]:isPaused()
end

--[[
  Returns whether the animation has reached the end of its cycle.
]]--
function Entity:isAnimationDone()
  return self._animations[self._activeAnimation]:isDone()
end

--[[
  Returns the X-coordinate position of one of the animation's action points.
]]--
function Entity:getActionPointX(actionPointName)
  if type(self._animations[self._activeAnimation]) ~= Type.NIL then
    return self._animations[self._activeAnimation]:getActionPointX(
      actionPointName)
  else
    return 0
  end
end

--[[
  Returns the Y-coordinate position of one of the animation's action points.
]]--
function Entity:getActionPointY(actionPointName)
  if type(self._animations[self._activeAnimation]) ~= Type.NIL then
    return self._animations[self._activeAnimation]:getActionPointY(
      actionPointName)
  else
    return 0
  end
end


-- Collisions ------------------------------------------------------------------
--[[
  Adds a new collider to the entity.
]]--
function Entity:addCollider(colliderName, options)
  
  -- Check arguments
  options = options or {}
  validate.typeString(colliderName, "colliderName")
  validate.typeTable(options, "options")
  
  -- Validate option names
  validate.optionNames(options, {
    "shape",
    "width",
    "height",
    "offsetX",
    "offsetY",
    "relativity",
    "relativeActionPoint"
  })
  
  -- Set option defaults
  local collider = {}
  collider.x = self._x
  collider.y = self._y
  collider.shape = options.shape or Option.RECTANGLE
  collider.width = options.width or 16
  collider.height = options.height or 16
  collider.baseWidth = collider.width
  collider.baseHeight = collider.height
  collider.offsetX = options.offsetX or 0
  collider.offsetY = options.offsetY or 0
  collider.relativity = options.relativity or
    Option.RELATIVE_ORIGIN_POINT
  collider.relativeActionPoint = options.relativeActionPoint
  
  -- Check option types
  validate.typeNumber(collider.shape, "shape")
  validate.typeNumber(collider.width, "width")
  validate.typeNumber(collider.height, "height")
  validate.typeNumber(collider.offsetX, "offsetX")
  validate.typeNumber(collider.offsetY, "offsetY")
  validate.constant(collider.relativity, "relativity", {
    Option.RELATIVE_ORIGIN_POINT,
    Option.RELATIVE_ACTION_POINT
  })
  if collider.relativity == Option.RELATIVE_ACTION_POINT then
    validate.typeString(collider.relativeActionPoint, "relativeActionPoint")
  end

  -- Check option values
  validate.constant(collider.shape, "shape", {
    Option.RECTANGLE,
    Option.CIRCLE
  })
  validate.atLeast(collider.width, "width", 1)
  validate.atLeast(collider.height, "height", 1)
  
  -- Add to entity's list of colliders
  self._colliders[colliderName] = collider
end

--[[
  Removes an existing collider from the entity.
]]--
function Entity:removeCollider(colliderName)
  validate.typeString(colliderName, "colliderName")
  self._colliders[colliderName] = nil
end

--[[
  Retrieves a collider by its name.
]]--
function Entity:getCollider(colliderName)
  validate.typeString(colliderName, "colliderName")
  self:_updateColliders()
  return self._colliders[colliderName]
end

--[[
  Updates the collider's position based on its relativity setting.
]]--
function Entity:_updateColliders()
  for k, collider in pairs(self._colliders) do
    -- Recalculate object's size relative to entity's scale
    local r = math.rad(self._angle)
    local scaleX = self._xScale -
      ((self._xScale - self._yScale) * math.abs(math.sin(r)))
    local scaleY = self._yScale -
      ((self._yScale - self._xScale) * math.abs(math.sin(r)))
    collider.width = collider.baseWidth * scaleX
    collider.height = collider.baseHeight * scaleY
    
    -- Offset for positioning the collider relatively
    local offsetX = collider.offsetX
    local offsetY = collider.offsetY
    if collider.relativity == Option.RELATIVE_ACTION_POINT then
      offsetX = offsetX + self:getActionPointX(collider.relativeActionPoint)
      offsetY = offsetY + self:getActionPointY(collider.relativeActionPoint)
    end
    
    -- Reposition offset to rectangle's actual midpoint (gets undone later)
    if collider.shape == Option.RECTANGLE then
      offsetX = offsetX + (collider.baseWidth / 2.0)
      offsetY = offsetY + (collider.baseHeight / 2.0)
    end
    
    -- Apply scaling/flipping transformations
    offsetX = offsetX * self._xScale * self._horizontalFlip
    offsetY = offsetY * self._yScale * self._verticalFlip
    
    -- Apply rotation transformation
      local rotX = offsetX * math.cos(r) - offsetY * math.sin(r)
      local rotY = offsetX * math.sin(r) + offsetY * math.cos(r)
      offsetX = rotX
      offsetY = rotY
    
    -- Undo the midpoint repositioning from earlier
    if collider.shape == Option.RECTANGLE then
      offsetX = offsetX - (collider.width / 2.0)
      offsetY = offsetY - (collider.height / 2.0)
    end
    
    -- Set position to entity's position plus the calculated offset
    collider.x = self._x + offsetX
    collider.y = self._y + offsetY
  end
end


-- Transformations -------------------------------------------------------------
--[[
  Sets the entity's X-axis position.
]]--
function Entity:setX(x)
  validate.typeNumber(x, "x")
  self._x = x
end

--[[
  Sets the entity's Y-axis position.
]]--
function Entity:setY(y)
  validate.typeNumber(y, "y")
  self._y = y
end

--[[
  Sets the entity's X & Y positions.
]]--
function Entity:setPosition(x, y)
  self:setX(x)
  self:setY(y)
end

--[[
  Moves the entity's position horizontally by a specified amount.
]]--
function Entity:moveX(pixels)
  validate.typeNumber(pixels, "pixels")
  self:setX(self._x + pixels)
end

--[[
  Moves the entity's position vertically by a specified amount.
]]--
function Entity:moveY(pixels)
  validate.typeNumber(pixels, "pixels")
  self:setY(self._y + pixels)
end

--[[
  Moves the entity's position by a specified amount.
]]--
function Entity:move(pixelsX, pixelsY)
  self:moveX(pixelsX)
  self:moveY(pixelsY)
end

--[[
  Returns the entity's X-axis position.
]]--
function Entity:getX()
  return self._x
end

--[[
  Returns the entity's Y-axis position.
]]--
function Entity:getY()
  return self._y
end

--[[
  Sets the rotation degree for the entity's graphics.
]]--
function Entity:setAngle(degrees)
  validate.typeNumber(degrees, "degrees")
  self._angle = degrees % 360
end

--[[
  Rotates the entity's graphics by a specified amount.
]]--
function Entity:rotate(degrees)
  self:setAngle(self._angle + degrees)
end

--[[
  Returns the current rotation degree for the entity's graphics.
]]--
function Entity:getAngle()
  return self._angle
end

--[[
  Sets the horizontal scale for the entity's graphics.
]]--
function Entity:setHorizontalScale(scale)
  validate.typeNumber(scale, "scale")
  self._xScale = math.max(scale, 0)
end

--[[
  Sets the vertical scale for the entity's graphics.
]]--
function Entity:setVerticalScale(scale)
  validate.typeNumber(scale, "scale")
  self._yScale = math.max(scale, 0)
end

--[[
  Sets the scale for the entity's graphics.
]]--
function Entity:setScale(scaleX, scaleY)
  self:setHorizontalScale(scaleX)
  self:setVerticalScale(scaleY)
end

--[[
  Scales the entity's graphics horizontally.
]]--
function Entity:scaleHorizontally(scale)
  validate.typeNumber(scale, "scale")
  self:setHorizontalScale(self._xScale + scale)
end

--[[
  Scales the entity's graphics vertically.
]]--
function Entity:scaleVertically(scale)
  validate.typeNumber(scale, "scale")
  self:setVerticalScale(self._yScale + scale)
end

--[[
  Scales the entity's graphics.
]]--
function Entity:scale(scaleX, scaleY)
  self:scaleHorizontally(scaleX)
  self:scaleVertically(scaleY)
end

--[[
  Gets the horizontal scale for the entity's graphics.
]]--
function Entity:getHorizontalScale()
  return self._xScale
end

--[[
  Gets the vertical scale for the entity's graphics.
]]--
function Entity:getVerticalScale()
  return self._yScale
end
