Room = {}
Room.__index = Room

--[[
  Constructor
]]--
function Room:new(roomName)
  local o = {}
  setmetatable(o, Room)

  roomName = roomName or "(untitled)"
  validate.typeString(roomName, "roomName")

  o._roomName = roomName

  return o
end

--[[
  Updates the core back-end functionality of the room.
]]--
function Room:updateRoom()
  -- Update entities
  for k, v in pairs(self) do
    if type(v) ~= Type.FUNCTION and v._isEntity then
      v:_animate()
    end
  end

  -- Call room-specific update function
  if type(self.update) ~= Type.NIL then self:update() end
end

--[[
  Draws the entities in the room.
]]--
function Room:drawRoom()
  -- Draw entities
  for k, v in pairs(self) do
    if type(v) ~= Type.FUNCTION and v._isEntity then
      v:_draw()
    end
  end

  -- Call room-specific draw function
  if type(self.draw) ~= Type.NIL then self:draw() end
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
