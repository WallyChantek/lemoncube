Entity = {}
Entity.__index = Entity

--[[
  Constructor
]]--
function Entity:new(x, y)
  local o = {}
  setmetatable(o, Entity)
  
  -- Check arguments
  assert(type(x) == Type.NUMBER,
    "Argument \"x\" must be of type: "..Type.NUMBER)
  assert(type(y) == Type.NUMBER,
    "Argument \"y\" must be of type: "..Type.NUMBER)

  -- Marker indicating this is an entity (used in room cleanup)
  o.isEntity = true

  -- Object's position
  o._x = x
  o._y = y
  
  -- Object's colliders
  o._colliders = {}
  
  -- Object's graphical/animation data
  o._rgba = { r = 1, g = 1, b = 1, a = 1 }
  o._animations = {}
  o._currentAnimation = ""
  o._rotation = 0
  o._flipX = 1
  o._flipY = 1
  o._scaleX = 1
  o._scaleY = 1

  return o
end

--[[
  Displays the entity's graphics.
]]--
function Entity:draw(originSize)
  -- Draw current graphic
  love.graphics.setColor(self._rgba.r, self._rgba.g, self._rgba.b, self._rgba.a)
  self._animations[self._currentAnimation]:draw(self._x, self._y,
    math.rad(self._rotation), self._flipX * self._scaleX,
    self._flipY * self._scaleY)
  
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
  Sets the color influence for the entity's graphics.
]]--
function Entity:setColorTint(r, g, b)
  assert(type(r) == Type.NUMBER,
    "Argument \"r\" must be of type: "..Type.NUMBER)
  assert(type(g) == Type.NUMBER,
    "Argument \"g\" must be of type: "..Type.NUMBER)
  assert(type(b) == Type.NUMBER,
    "Argument \"b\" must be of type: "..Type.NUMBER)
  
  self._rgba.r = math.clamp(r, 0, 1)
  self._rgba.g = math.clamp(g, 0, 1)
  self._rgba.b = math.clamp(b, 0, 1)
end

--[[
  Sets the alpha/semi-transparency for the entity's graphics.
]]--
function Entity:setTransparency(a)
  assert(type(a) == Type.NUMBER,
    "Argument \"a\" must be of type: "..Type.NUMBER)
  
  self._rgba.a = math.clamp(a, 0, 1)
end

--[[
  Returns the horizontal-flipped state for the entity.
]]--
function Entity:getHorizontalDirection()
  return util.numberToBoolean(1 - self._flipX)
end

--[[
  Returns the vertical-flipped state for the entity.
]]--
function Entity:getVerticalDirection()
  return util.numberToBoolean(1 - self._flipY)
end

--[[
  Flips the entity's graphics horizontally.
]]--
function Entity:flipHorizontally(isFlipped)
  if type(isFlipped) == Type.NIL then
    self._flipX = self._flipX - (self._flipX * 2)
  else
    assert(type(isFlipped) == Type.BOOLEAN,
      "Argument \"isFlipped\" must be of type: "..Type.BOOLEAN)
      
    if isFlipped then self._flipX = -1 else self._flipX = 1 end
  end
end

--[[
  Flips the entity's graphics vertically.
]]--
function Entity:flipVertically(isFlipped)
  if type(isFlipped) == Type.NIL then
    self._flipY = self._flipY - (self._flipY * 2)
  else
    assert(type(isFlipped) == Type.BOOLEAN,
      "Argument \"isFlipped\" must be of type: "..Type.BOOLEAN)
    
    if isFlipped then self._flipY = -1 else self._flipY = 1 end
  end
end


-- Animation -------------------------------------------------------------------
--[[
  Processes the entity currently-active animation.
]]--
function Entity:animate()
  self._animations[self._currentAnimation]:animate()
end

--[[
  Adds an animation to the entity.
]]--
function Entity:addAnimation(animationId, image, width, height, options)
  assert(type(animationId) == Type.STRING,
    "Argument \"animationId\" must be of type: "..Type.STRING)
  
  self._animations[animationId] = Animation:new(image, width, height, options)
  
  if self._currentAnimation == "" then
    self._currentAnimation = animationId
  end
end

--[[
  Changes the current animation.
]]--
function Entity:changeAnimation(animationId)
  assert(type(animationId) == Type.STRING,
    "Argument \"animationId\" must be of type: "..Type.STRING)
  
  self._currentAnimation = animationId
  self._animations[self._currentAnimation]:reset()
end

--[[
  Pauses the current animation.
]]--
function Entity:pauseAnimation()
  self._animations[self._currentAnimation]:pause()
end

--[[
  Resumes the current animation.
]]--
function Entity:resumeAnimation()
  self._animations[self._currentAnimation]:resume()
end

--[[
  Gets the current animation's ID.
]]--
function Entity:getCurrentAnimationId()
  return self._currentAnimation
end

--[[
  Returns the X-coordinate position of the animation's current action point.
]]--
function Entity:getActionPointX(actionPointId)
  if type(self._animations[self._currentAnimation]) ~= Type.NIL then
    return self._animations[self._currentAnimation]:getActionPointX(
      actionPointId)
  else
    return 0
  end
end

--[[
  Returns the Y-coordinate position of the animation's current action point.
]]--
function Entity:getActionPointY(actionPointId)
  if type(self._animations[self._currentAnimation]) ~= Type.NIL then
    return self._animations[self._currentAnimation]:getActionPointY(
      actionPointId)
  else
    return 0
  end
end


-- Collisions ------------------------------------------------------------------
--[[
  Adds a new collider to the entity.
]]--
function Entity:addCollider(colliderId, options)
  
  -- Check arguments
  options = options or {}
  assert(type(colliderId) == Type.STRING,
    "Argument \"colliderId\" must be of type: "..Type.STRING)
  assert(type(options) == Type.TABLE,
    "Argument \"options\" must be of type: "..Type.TABLE)
  
  -- Validate option names
  for option, v in pairs(options) do
    if option ~= "shape" and
      option ~= "width" and
      option ~= "height" and
      option ~= "offsetX" and
      option ~= "offsetY" and
      option ~= "relativity" then
      error("Option \""..option.."\" is not a valid option")
    end
  end
  
  -- Set option defaults
  self._colliders[colliderId] = {}
  self._colliders[colliderId].x = self._x
  self._colliders[colliderId].y = self._y
  self._colliders[colliderId].shape = options.shape or Option.RECTANGLE
  self._colliders[colliderId].width = options.width or 16
  self._colliders[colliderId].height = options.height or 16
  self._colliders[colliderId].baseWidth = self._colliders[colliderId].width
  self._colliders[colliderId].baseHeight = self._colliders[colliderId].height
  self._colliders[colliderId].offsetX = options.offsetX or 0
  self._colliders[colliderId].offsetY = options.offsetY or 0
  self._colliders[colliderId].relativity = options.relativity or
    Option.RELATIVE_ORIGIN_POINT
  
  -- Check option types
  assert(type(self._colliders[colliderId].shape) == Type.NUMBER,
    "Option \"shape\" must use a valid constant value")
  assert(type(self._colliders[colliderId].width) == Type.NUMBER,
    "Option \"width\" must be of type: "..Type.NUMBER)
  assert(type(self._colliders[colliderId].height) == Type.NUMBER,
    "Option \"height\" must be of type: "..Type.NUMBER)
  assert(type(self._colliders[colliderId].offsetX) == Type.NUMBER,
    "Option \"offsetX\" must be of type: "..Type.NUMBER)
  assert(type(self._colliders[colliderId].offsetY) == Type.NUMBER,
    "Option \"offsetY\" must be of type: "..Type.NUMBER)
  assert(type(self._colliders[colliderId].relativity) == Type.NUMBER,
    "Option \"relativity\" must use a valid constant value")

  -- Check option values
  assert(self._colliders[colliderId].shape >= Option.RECTANGLE
    and self._colliders[colliderId].shape <= Option.CIRCLE,
    "Option \"shape\" must use a valid constant value")
  assert(self._colliders[colliderId].width >= 1,
    "Option \"width\" must be at least 1")
  assert(self._colliders[colliderId].height >= 1,
    "Option \"height\" must be at least 1")
  assert(self._colliders[colliderId].relativity >= Option.RELATIVE_ORIGIN_POINT
    and self._colliders[colliderId].relativity <= Option.RELATIVE_ACTION_POINT,
    "Option \"relativity\" must use a valid constant value")
end

--[[
  Retrieves a collider by its ID.
]]--
function Entity:getCollider(colliderId)
  assert(type(colliderId) == Type.STRING,
    "Argument \"colliderId\" must be of type: "..Type.STRING)
  
  self:_updateColliders()
  
  return self._colliders[colliderId]
end

--[[
  Removes an existing collider from the entity.
]]--
function Entity:removeCollider(colliderId)
  assert(type(colliderId) == Type.STRING,
    "Argument \"colliderId\" must be of type: "..Type.STRING)
  
  self._colliders[colliderId] = nil
end

--[[
  Updates the collider's position based on its relativity setting.
]]--
function Entity:_updateColliders()
  for k, collider in pairs(self._colliders) do
    -- Recalculate object's size relative to entity's scale
    local r = math.rad(self._rotation)
    local scaleX = self._scaleX -
      ((self._scaleX - self._scaleY) * math.abs(math.sin(r)))
    local scaleY = self._scaleY -
      ((self._scaleY - self._scaleX) * math.abs(math.sin(r)))
    collider.width = collider.baseWidth * scaleX
    collider.height = collider.baseHeight * scaleY
    
    -- Offset for positioning the collider relatively
    local offsetX = collider.offsetX
    local offsetY = collider.offsetY
    if collider.relativity == Option.RELATIVE_ACTION_POINT then
      offsetX = offsetX + self:getActionPointX()
      offsetY = offsetY + self:getActionPointY()
    end
    
    -- Reposition offset to rectangle's actual midpoint (gets undone later)
    if collider.shape == Option.RECTANGLE then
      offsetX = offsetX + (collider.baseWidth / 2.0)
      offsetY = offsetY + (collider.baseHeight / 2.0)
    end
    
    -- Apply scaling/flipping transformations
    offsetX = offsetX * self._scaleX * self._flipX
    offsetY = offsetY * self._scaleY * self._flipY
    
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
  Sets the entity's X-axis position.
]]--
function Entity:setX(x)
  assert(type(x) == Type.NUMBER,
    "Argument \"x\" must be of type: "..Type.NUMBER)
  
  self._x = x
end

--[[
  Sets the entity's Y-axis position.
]]--
function Entity:setY(y)
  assert(type(y) == Type.NUMBER,
    "Argument \"y\" must be of type: "..Type.NUMBER)
  
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
  assert(type(pixels) == Type.NUMBER,
    "Argument \"pixels\" must be of type: "..Type.NUMBER)
  
  self:setX(self._x + pixels)
end

--[[
  Moves the entity's position vertically by a specified amount.
]]--
function Entity:moveY(pixels)
  assert(type(pixels) == Type.NUMBER,
    "Argument \"pixels\" must be of type: "..Type.NUMBER)
  
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
  Rotates the entity's graphics by a specified amount.
]]--
function Entity:rotate(degrees)
  self:setRotation(self._rotation + degrees)
end

--[[
  Sets the rotation degree for the entity's graphics.
]]--
function Entity:setRotation(degrees)
  self._rotation = degrees % 360
end

--[[
  Gets the horizontal scale for the entity's graphics.
]]--
function Entity:getHorizontalScale()
  return self._scaleX
end

--[[
  Gets the vertical scale for the entity's graphics.
]]--
function Entity:getVerticalScale()
  return self._scaleY
end

--[[
  Sets the horizontal scale for the entity's graphics.
]]--
function Entity:setHorizontalScale(scale)
  assert(type(scale) == Type.NUMBER,
    "Argument \"scale\" must be of type: "..Type.NUMBER)
  
  self._scaleX = math.max(scale, 0)
end

--[[
  Sets the vertical scale for the entity's graphics.
]]--
function Entity:setVerticalScale(scale)
  assert(type(scale) == Type.NUMBER,
    "Argument \"scale\" must be of type: "..Type.NUMBER)
  
  self._scaleY = math.max(scale, 0)
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
  assert(type(scale) == Type.NUMBER,
    "Argument \"scale\" must be of type: "..Type.NUMBER)
  
  self:setHorizontalScale(self._scaleX + scale)
end

--[[
  Scales the entity's graphics vertically.
]]--
function Entity:scaleVertically(scale)
  assert(type(scale) == Type.NUMBER,
    "Argument \"scale\" must be of type: "..Type.NUMBER)
  
  self:setVerticalScale(self._scaleY + scale)
end

--[[
  Scales the entity's graphics.
]]--
function Entity:scale(scaleX, scaleY)
  self:scaleHorizontally(scaleX)
  self:scaleVertically(scaleY)
end
