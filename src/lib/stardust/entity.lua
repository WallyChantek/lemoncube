Entity = {}
Entity.__index = Entity

function Entity:new(x, y)
    local o = {}
    setmetatable(o, Entity)
    
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
    o._currentAnimation = ""
    o._angle = 0
    o._horizontalFlip = 1
    o._verticalFlip = 1
    o._xScale = 1
    o._yScale = 1
    o._isVisible = true

    return o
end


-- Graphics --------------------------------------------------------------------

--[[
    Displays the entity's graphics.
]]--
function Entity:_draw(originSize)
    -- Draw current graphic
    if self._isVisible and self._colorMix.a > 0 then
        love.graphics.setColor(self._colorMix.r, self._colorMix.g,
            self._colorMix.b, self._colorMix.a)
        if type(self._animations[self._currentAnimation]) ~= Const.LUA_TYPE.NIL
        then
            self._animations[self._currentAnimation]:_draw(self._x, self._y,
                math.rad(self._angle), self._horizontalFlip * self._xScale,
                self._verticalFlip * self._yScale)
        end
    end
    
    -- Draw collider(s) (for debugging)
    if (Engine.debugConfig.showColliders) then
        for k, collider in pairs(self._colliders) do
            if Engine.debugConfig.highlightCollisions and collider.isColliding
            then
                love.graphics.setColor(0, 1, 0, 0.5)
            else
                love.graphics.setColor(1, 0, 0, 0.5)
            end
            
            if collider.shape == Const.COLLIDER_SHAPE.RECTANGLE then
                love.graphics.rectangle("fill", collider.x, collider.y,
                    collider.width, collider.height)
            else
                love.graphics.circle("fill", collider.x, collider.y,
                    collider.radius)
            end
        end
    end

    -- Draw origin point (for debugging)
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

--[[
    Shows the entity's graphic.
]]--
function Entity:show()
    self._isVisible = true
end

--[[
    Hides the entity's graphic.
]]--
function Entity:hide()
    self._isVisible = false
end

--[[
    Sets the color influence for the entity's graphic.
]]--
function Entity:setColorMix(r, g, b)
    self._colorMix.r = math.clamp(r, 0, 1)
    self._colorMix.g = math.clamp(g, 0, 1)
    self._colorMix.b = math.clamp(b, 0, 1)
end

--[[
    Returns the color influence for the entity's graphic.
]]--
function Entity:getColorMix()
    return {
        self._colorMix.r,
        self._colorMix.g,
        self._colorMix.b
    }
end

--[[
    Sets the alpha/semi-transparency for the entity's graphic.
]]--
function Entity:setTransparency(a)
    self._colorMix.a = math.clamp(a, 0, 1)
end

--[[
    Returns the alpha/semi-transparency for the entity's graphic.
]]--
function Entity:getTransparency()
    return self._colorMix.a
end

--[[
    Flips the entity's graphic horizontally.
]]--
function Entity:flipHorizontally(isFlipped)
    if type(isFlipped) == Const.LUA_TYPE.NIL then
        self._horizontalFlip = self._horizontalFlip - (self._horizontalFlip * 2)
    else
        if isFlipped then
            self._horizontalFlip = -1
        else
            self._horizontalFlip = 1
        end
    end
end

--[[
    Flips the entity's graphic vertically.
]]--
function Entity:flipVertically(isFlipped)
    if type(isFlipped) == Const.LUA_TYPE.NIL then
        self._verticalFlip = self._verticalFlip - (self._verticalFlip * 2)
    else
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
    Processes the entity's currently animation.
]]--
function Entity:_animate()
    if type(self._animations[self._currentAnimation]) ~= Const.LUA_TYPE.NIL then
        self._animations[self._currentAnimation]:_animate()
    end
end

--[[
    Adds a new animation to the entity.
]]--
function Entity:addAnimation(animationName, image, width, height, options)
    self._animations[animationName] = Animation:new(
        image, width, height, options)
    
    -- If this is the entity's first animation to be created, then display it
    if self._currentAnimation == "" then
        self._currentAnimation = animationName
    end
end

--[[
    Changes the currently animation.
]]--
function Entity:changeAnimation(animationName)
    if self._currentAnimation ~= animationName then
        self._currentAnimation = animationName
        self._animations[self._currentAnimation]:_restart()
    end
end

--[[
    Pauses the currently animation.
]]--
function Entity:pauseAnimation()
    self._animations[self._currentAnimation]:_pause()
end

--[[
    Resumes the currently animation
]]--
function Entity:resumeAnimation()
    self._animations[self._currentAnimation]:_resume()
end

--[[
    Restarts the currently animation.
]]--
function Entity:restartAnimation()
    self._animations[self._currentAnimation]:_restart()
end

--[[
    Sets the frame duration of the current animation.
]]--
function Entity:setAnimationFrameDuration(newDuration)
    self._animations[self._currentAnimation]:_setFrameDuration(newDuration)
end

--[[
    Returns the current animation's name.
]]--
function Entity:getAnimationName()
    return self._currentAnimation
end

--[[
    Returns the current frame number of the current animation.
]]--
function Entity:getAnimationFrame()
    return self._animations[self._currentAnimation]:_getCurrentFrame()
end

--[[
    Returns whether the current animation is paused or playing.
]]--
function Entity:isAnimationPaused()
    return self._animations[self._currentAnimation]:_isPaused()
end

--[[
    Returns whether the current animation has reached the end of its cycle.
]]--
function Entity:isAnimationDone()
    return self._animations[self._currentAnimation]:_isDone()
end

--[[
    Returns the X position of one of the current animation's action points.
]]--
function Entity:getActionPointX(actionPointName)
    if type(self._animations[self._currentAnimation]) ~= Const.LUA_TYPE.NIL then
        return self._animations[self._currentAnimation]:_getActionPointX(
            actionPointName)
    else
        return 0
    end
end

--[[
    Returns the Y position of one of the current animation's action points.
]]--
function Entity:getActionPointY(actionPointName)
    if type(self._animations[self._currentAnimation]) ~= Const.LUA_TYPE.NIL then
        return self._animations[self._currentAnimation]:_getActionPointY(
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
    options = options or {}
    
    -- Set option defaults
    local collider = {}
    collider.x = self._x
    collider.y = self._y
    collider.shape = options.shape or Const.COLLIDER_SHAPE.RECTANGLE
    collider.width = options.width or 16
    collider.height = options.height or 16
    collider.radius = options.radius or 8
    collider.baseWidth = collider.width
    collider.baseHeight = collider.height
    collider.baseRadius = collider.radius
    collider.offsetX = options.offsetX or 0
    collider.offsetY = options.offsetY or 0
    collider.relativity = options.relativity or
        Const.COLLIDER_POSITION.ORIGIN_POINT
    collider.relativeActionPoint = options.relativeActionPoint
    collider.isColliding = false
    collider.isCollider = true
    
    -- Add to entity's list of colliders
    self._colliders[colliderName] = collider
    
    -- Update colliders
    self:_updateColliders()
end

--[[
    Removes an existing collider from the entity.
]]--
function Entity:removeCollider(colliderName)
    self._colliders[colliderName] = nil
end

--[[
    Retrieves a collider by its name.
]]--
function Entity:getCollider(colliderName)
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
    if util.size(self._colliders) == 0 then return end
    
    local r = math.rad(self._angle)
    local scaleX = self._xScale -
        ((self._xScale - self._yScale) * math.abs(math.sin(r)))
    local scaleY = self._yScale -
        ((self._yScale - self._xScale) * math.abs(math.sin(r)))
    
    for k, collider in pairs(self._colliders) do
        -- Recalculate object's size relative to entity's scale
        if collider.shape == Const.COLLIDER_SHAPE.RECTANGLE then
            collider.width = collider.baseWidth * scaleX
            collider.height = collider.baseHeight * scaleY
        else
            collider.radius = collider.baseRadius *
                math.average(self._xScale, self._yScale)
        end
        
        
        -- Offset for positioning the collider relatively
        local offsetX = collider.offsetX
        local offsetY = collider.offsetY
        if collider.relativity == Const.COLLIDER_POSITION.ACTION_POINT then
            offsetX = offsetX + self:getActionPointX(
                collider.relativeActionPoint)
            offsetY = offsetY + self:getActionPointY(
                collider.relativeActionPoint)
        end
        
        -- Reposition offset to rectangle's actual midpoint (gets undone later)
        if collider.shape == Const.COLLIDER_SHAPE.RECTANGLE then
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
        if collider.shape == Const.COLLIDER_SHAPE.RECTANGLE then
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
    Sets the entity's X-axis position.
]]--
function Entity:setX(x)
    self._x = x
    self:_updateColliders()
end

--[[
    Sets the entity's Y-axis position.
]]--
function Entity:setY(y)
    self._y = y
    self:_updateColliders()
end

--[[
    Sets the entity's X & Y positions.
]]--
function Entity:setPosition(x, y)
    self._x = x
    self._y = y
    self:_updateColliders()
end

--[[
    Moves the entity's position horizontally by a specified amount.
]]--
function Entity:moveX(pixels)
    self._x = self._x + pixels
    self:_updateColliders()
end

--[[
    Moves the entity's position vertically by a specified amount.
]]--
function Entity:moveY(pixels)
    self._y = self._y + pixels
    self:_updateColliders()
end

--[[
    Moves the entity's position by a specified amount.
]]--
function Entity:move(pixelsX, pixelsY)
    self._x = self._x + pixelsX
    self._y = self._y + pixelsY
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
    Rotates the entity's graphic.
]]--
function Entity:setAngle(degrees)
    self._angle = degrees % 360
    self:_updateColliders()
end

--[[
    Rotates the entity's graphic by a specified amount.
]]--
function Entity:rotate(degrees)
    self._angle = (self._angle + degrees) % 360
    self:_updateColliders()
end

--[[
    Returns the current rotation degrees for the entity's graphics.
]]--
function Entity:getAngle()
    return self._angle
end

--[[
    Sets the horizontal scale for the entity's graphics.
]]--
function Entity:setHorizontalScale(scale)
    self._xScale = scale
    self:_updateColliders()
end

--[[
    Sets the vertical scale for the entity's graphics.
]]--
function Entity:setVerticalScale(scale)
    self._yScale = scale
    self:_updateColliders()
end

--[[
    Sets the scale for the entity's graphics.
]]--
function Entity:setScale(scaleX, scaleY)
    self._xScale = scaleX
    self._yScale = scaleY
    self:_updateColliders()
end

--[[
    Scales the entity's graphics horizontally.
]]--
function Entity:scaleHorizontally(scale)
    self._xScale = self._xScale + scale
    self:_updateColliders()
end

--[[
    Scales the entity's graphics vertically.
]]--
function Entity:scaleVertically(scale)
    self._yScale = self._yScale + scale
    self:_updateColliders()
end

--[[
    Scales the entity's graphics.
]]--
function Entity:scale(scaleX, scaleY)
    self._xScale = self._xScale + scaleX
    self._yScale = self._yScale + scaleY
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
