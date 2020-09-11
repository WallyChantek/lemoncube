Room = {}
Room.__index = Room

function Room:new(roomName)
    local o = {}
    setmetatable(o, Room)

    o._roomName = roomName or "(untitled)"

    return o
end

--[[
    Updates the logic for the room instance.
]]--
function Room:_updateRoom()
    -- Update entities
    self:_updateEntities(self)

    -- Call room-specific update function
    if type(self.update) ~= Const.LUA_TYPE.NIL then self:update() end
end

--[[
    Updates the entities in the room. Called automatically by updateRoom().
]]
function Room:_updateEntities(t)
    for k, v in pairs(t) do
        if type(v) == Const.LUA_TYPE.TABLE then
            if v._isEntity then
                v:_animate()
                v:_updateColliders()
            else
                self:_updateEntities(v)
            end
        end
    end
end

--[[
    Draws the graphics for the room instance.
]]--
function Room:_drawRoom()
    -- Draw entities
    self:_drawEntities(self)

    -- Call room-specific draw function
    if type(self.draw) ~= Const.LUA_TYPE.NIL then self:draw() end
end

--[[
    Draws the entities in the room. Called automatically by drawRoom().
]]
function Room:_drawEntities(t)
    for k, v in pairs(t) do
        if type(v) == Const.LUA_TYPE.TABLE then
            if v._isEntity then
                v:_draw()
            else
                self:_drawEntities(v)
            end
        end
    end
end

--[[
    Cleans up the data related to the room.
]]--
function Room:_destroy()
    -- Clean up non-function datatypes
    for k, v in pairs(self) do
        if type(v) ~= Const.LUA_TYPE.FUNCTION then
            v = nil
        end
    end
end

--[[
    Returns the user-specified name of the room.
]]--
function Room:_getName()
    return self._roomName
end
