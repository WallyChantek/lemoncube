Room = {}
Room.__index = Room

--[[
  Constructor
]]--
function Room:new(roomName)
  local o = {}
  setmetatable(o, Room)

  roomName = roomName or "(untitled)"
  Validate.typeString(roomName, "roomName")

  o._roomName = roomName

  return o
end

--[[
  Updates the core back-end functionality of the room.
]]--
function Room:updateRoom()
  -- Update entities
  self:updateEntities(self)

  -- Call room-specific update function
  if type(self.update) ~= Type.NIL then self:update() end
end

--[[
  Draws the entities in the room.
]]--
function Room:drawRoom()
  -- Draw entities
  self:drawEntities(self)

  -- Call room-specific draw function
  if type(self.draw) ~= Type.NIL then self:draw() end
end

function Room:drawEntities(t)
  for k, v in pairs(t) do
    if type(v) == Type.TABLE then
      if v._isEntity then
        v:_draw()
      else
        self:drawEntities(v)
      end
    end
  end
end

function Room:updateEntities(t)
  for k, v in pairs(t) do
    if type(v) == Type.TABLE then
      if v._isEntity then
        v:_animate()
        v:_updateColliders()
      else
        self:updateEntities(v)
      end
    end
  end
end

--[[
  Cleans up the data related to the room.
]]--
function Room:leave()
  -- Clean up non-function datatypes
  for k, v in pairs(self) do
    if type(v) ~= Type.FUNCTION then
      v = nil
    end
  end
end

--[[
  Returns the user-specified name of the room.
]]--
function Room:getName()
  return self._roomName
end
