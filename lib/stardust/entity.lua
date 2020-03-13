Entity = {}
Entity.__index = Entity

--[[
  Constructor
]]--
function Entity:new(x, y)
  local o = {}
  setmetatable(o, Entity)
  
  -- Check arguments
  Validate.typeNumber(x, "x")
  Validate.typeNumber(y, "y")

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
    if type(self._animations[self._activeAnimation]) ~= Type.NIL then
      self._animations[self._activeAnimation]:draw(self._x, self._y,
        math.rad(self._angle), self._horizontalFlip * self._xScale,
        self._verticalFlip * self._yScale)
    end
  end
  
  -- Draw collider(s)
  if (Engine.debugConfig.showColliders) then
    for k, collider in pairs(self._colliders) do
      if Engine.debugConfig.highlightCollisions and collider.isColliding then
        love.graphics.setColor(0, 1, 0, 0.5)
      else
        love.graphics.setColor(1, 0, 0, 0.5)
      end
      
      if collider.shape == Option.RECTANGLE then
        love.graphics.rectangle("fill", collider.x, collider.y,
          collider.width, collider.height)
      else
        love.graphics.circle("fill", collider.x, collider.y, collider.radius)
      end
    end
  end

  -- Draw origin point
  if Engine.debugConfig.originCrosshairRadius > 0 then
    local orgOut = Engine.debugConfig.originCrosshairRadius +
      (Engine.debugConfig.originCrosshairRadius / 2)
    local orgIn = orgOut - Engine.debugConfig.originCrosshairRadius
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.points(self._x, self._y)
    love.graphics.ellipse("line", self._x, self._y,
      Engine.debugConfig.originCrosshairRadius,
      Engine.debugConfig.originCrosshairRadius)
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
  Validate.typeNumber(r, "r")
  Validate.typeNumber(g, "g")
  Validate.typeNumber(b, "b")
  
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
  Validate.typeNumber(a, "a")
  
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
    Validate.typeBoolean(isFlipped, "isFlipped")
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
    Validate.typeBoolean(isFlipped, "isFlipped")
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
  return Util.numberToBoolean(1 - self._horizontalFlip)
end

--[[
  Returns the vertical-flipped state for the entity.
]]--
function Entity:isFlippedVertically()
  return Util.numberToBoolean(1 - self._verticalFlip)
end


-- Animation -------------------------------------------------------------------
--[[
  Processes the entity currently-active animation.
]]--
function Entity:_animate()
  if type(self._animations[self._activeAnimation]) ~= Type.NIL then
    self._animations[self._activeAnimation]:animate()
  end
end

--[[
  Adds an animation to the entity.
]]--
function Entity:addAnimation(animationName, image, width, height, options)
  Validate.typeString(animationName, "animationName")
  
  self._animations[animationName] = Animation:new(image, width, height, options)
  
  if self._activeAnimation == "" then
    self._activeAnimation = animationName
  end
end

--[[
  Changes the current animation.
]]--
function Entity:changeAnimation(animationName)
  Validate.typeString(animationName, "animationName")
  
  self._activeAnimation = animationName
  self._animations[self._activeAnimation]:restart()
end

--[[
  Pauses or resumes the current animation.
]]--
function Entity:pauseAnimation(isPaused)
  isPaused = isPaused or not self._animations[self._activeAnimation]:isPaused()
  Validate.typeBoolean(isPaused, "isPaused")
  
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
  Validate.typeString(colliderName, "colliderName")
  Validate.typeTable(options, "options")
  
  -- Validate option names
  Validate.optionNames(options, {
    "shape",
    "width",
    "height",
    "radius",
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
  collider.radius = options.radius or 8
  collider.baseWidth = collider.width
  collider.baseHeight = collider.height
  collider.baseRadius = collider.radius
  collider.offsetX = options.offsetX or 0
  collider.offsetY = options.offsetY or 0
  collider.relativity = options.relativity or
    Option.RELATIVE_ORIGIN_POINT
  collider.relativeActionPoint = options.relativeActionPoint
  collider.isColliding = false
  
  -- Check option types
  Validate.typeNumber(collider.shape, "shape")
  Validate.typeNumber(collider.width, "width")
  Validate.typeNumber(collider.height, "height")
  Validate.typeNumber(collider.offsetX, "offsetX")
  Validate.typeNumber(collider.offsetY, "offsetY")
  Validate.constant(collider.relativity, "relativity", {
    Option.RELATIVE_ORIGIN_POINT,
    Option.RELATIVE_ACTION_POINT
  })
  if collider.relativity == Option.RELATIVE_ACTION_POINT then
    Validate.typeString(collider.relativeActionPoint, "relativeActionPoint")
  end

  -- Check option values
  Validate.constant(collider.shape, "shape", {
    Option.RECTANGLE,
    Option.CIRCLE
  })
  Validate.atLeast(collider.width, "width", 1)
  Validate.atLeast(collider.height, "height", 1)
  if collider.shape == Option.RECTANGLE then
    if type(options.radius) ~= Type.NIL then
      error("Cannot use option \"radius\" with shape \"rectangle\"")
    end
  else
    if type(options.width) ~= Type.NIL then
      error("Cannot use option \"width\" with shape \"circle\"")
    elseif type(options.height) ~= Type.NIL then
      error("Cannot use option \"height\" with shape \"circle\"")
    end
  end
  
  -- Add to entity's list of colliders
  self._colliders[colliderName] = collider
  
  -- Update colliders
  self:_updateColliders()
end

--[[
  Removes an existing collider from the entity.
]]--
function Entity:removeCollider(colliderName)
  Validate.typeString(colliderName, "colliderName")
  self._colliders[colliderName] = nil
end

--[[
  Retrieves a collider by its name.
]]--
function Entity:getCollider(colliderName)
  Validate.typeString(colliderName, "colliderName")
  return self._colliders[colliderName]
end

--[[
  Retrieves all colliders.
]]--
function Entity:getColliders()
  return self._colliders
end

--[[
  Updates the collider's position based on its relativity setting.
]]--
function Entity:_updateColliders()
  if Util.size(self._colliders) == 0 then return end
  
  local r = math.rad(self._angle)
  local scaleX = self._xScale -
    ((self._xScale - self._yScale) * math.abs(math.sin(r)))
  local scaleY = self._yScale -
    ((self._yScale - self._xScale) * math.abs(math.sin(r)))
  
  for k, collider in pairs(self._colliders) do
    -- Recalculate object's size relative to entity's scale
    if collider.shape == Option.RECTANGLE then
      collider.width = collider.baseWidth * scaleX
      collider.height = collider.baseHeight * scaleY
    else
      collider.radius = collider.baseRadius *
        math.average(self._xScale, self._yScale)
    end
    
    
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
    if self._angle ~= 0 then
      local rotX = offsetX * math.cos(r) - offsetY * math.sin(r)
      local rotY = offsetX * math.sin(r) + offsetY * math.cos(r)
      offsetX = rotX
      offsetY = rotY
    end
    
    -- Undo the midpoint repositioning from earlier
    if collider.shape == Option.RECTANGLE then
      offsetX = offsetX - (collider.width / 2.0)
      offsetY = offsetY - (collider.height / 2.0)
    end
    
    -- Set position to entity's position plus the calculated offset
    collider.x = self._x + offsetX
    collider.y = self._y + offsetY
    
    -- Untoggle the entity's collision state
    collider.isColliding = false
  end
end


-- Transformations -------------------------------------------------------------
--[[
  Internal function for setting entity's X-axis position.
]]--
function Entity:_setX(x, updateColliders)
  self._x = x
end

--[[
  Internal function for setting entity's Y-axis position.
]]--
function Entity:_setY(y, updateColliders)
  self._y = y
end

--[[
  Sets the entity's X-axis position.
]]--
function Entity:setX(x)
Validate.typeNumber(x, "x")
  self:_setX(x)
  self:_updateColliders()
end

--[[
  Sets the entity's Y-axis position.
]]--
function Entity:setY(y)
  Validate.typeNumber(y, "y")
  self:_setY(y)
  self:_updateColliders()
end

--[[
  Sets the entity's X & Y positions.
]]--
function Entity:setPosition(x, y)
  Validate.typeNumber(x, "x")
  Validate.typeNumber(y, "y")
  self:_setX(x)
  self:_setY(y)
  self:_updateColliders()
end

--[[
  Moves the entity's position horizontally by a specified amount.
]]--
function Entity:moveX(pixels)
  Validate.typeNumber(pixels, "pixels")
  self:_setX(self._x + pixels)
  self:_updateColliders()
end

--[[
  Moves the entity's position vertically by a specified amount.
]]--
function Entity:moveY(pixels)
  Validate.typeNumber(pixels, "pixels")
  self:_setY(self._y + pixels)
  self:_updateColliders()
end

--[[
  Moves the entity's position by a specified amount.
]]--
function Entity:move(pixelsX, pixelsY)
  Validate.typeNumber(pixels, "pixels")
  Validate.typeNumber(pixels, "pixels")
  self:_setX(self._x + pixels)
  self:_setY(self._y + pixels)
  self:_updateColliders()
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
  Validate.typeNumber(degrees, "degrees")
  self._angle = degrees % 360
  self:_updateColliders()
end

--[[
  Rotates the entity's graphics by a specified amount.
]]--
function Entity:rotate(degrees)
  Validate.typeNumber(degrees, "degrees")
  self._angle = (self._angle + degrees) % 360
  self:_updateColliders()
end

--[[
  Returns the current rotation degree for the entity's graphics.
]]--
function Entity:getAngle()
  return self._angle
end

--[[
  Internal function for setting the horizontal scale for the entity's graphics.
]]--
function Entity:_setHorizontalScale(scale)
  self._xScale = math.max(scale, 0)
end

--[[
  Internal function for setting the vertical scale for the entity's graphics.
]]--
function Entity:_setVerticalScale(scale)
  self._yScale = math.max(scale, 0)
end

--[[
  Sets the horizontal scale for the entity's graphics.
]]--
function Entity:setHorizontalScale(scale)
  Validate.typeNumber(scale, "scale")
  self:_setHorizontalScale(scale)
  self:_updateColliders()
end

--[[
  Sets the vertical scale for the entity's graphics.
]]--
function Entity:setVerticalScale(scale)
  Validate.typeNumber(scale, "scale")
  self:_setVerticalScale(scale)
  self:_updateColliders()
end

--[[
  Sets the scale for the entity's graphics.
]]--
function Entity:setScale(scaleX, scaleY)
  Validate.typeNumber(scaleX, "scaleX")
  Validate.typeNumber(scaleY, "scaleY")
  self:_setHorizontalScale(scaleX)
  self:_setVerticalScale(scaleY)
  self:_updateColliders()
end

--[[
  Scales the entity's graphics horizontally.
]]--
function Entity:scaleHorizontally(scale)
  Validate.typeNumber(scale, "scale")
  self:_setHorizontalScale(self._xScale + scale)
  self:_updateColliders()
end

--[[
  Scales the entity's graphics vertically.
]]--
function Entity:scaleVertically(scale)
  Validate.typeNumber(scale, "scale")
  self:_setVerticalScale(self._yScale + scale)
  self:_updateColliders()
end

--[[
  Scales the entity's graphics.
]]--
function Entity:scale(scaleX, scaleY)
  Validate.typeNumber(scaleX, "scaleX")
  Validate.typeNumber(scaleY, "scaleY")
  self:_setHorizontalScale(self._xScale + scaleX)
  self:_setVerticalScale(self._yScale + scaleY)
  self:_updateColliders()
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
