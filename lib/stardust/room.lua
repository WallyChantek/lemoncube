Room = {}
Room.__index = Room

--[[
  Constructor
]]--
function Room:new(roomName)
  local o = {}
  setmetatable(o, Room)

  roomName = roomName or "(untitled)"
  assert(type(roomName) == Type.STRING,
    "Argument \"roomName\" must be of type: "..Type.STRING)

  o._roomName = roomName

  return o
end

--[[
  Updates the core back-end functionality of the room.
]]--
function Room:updateCore()
  -- Update entities
  for k, v in pairs(self) do
    if type(v) ~= Type.FUNCTION and v.isEntity then
      v:animate()
    end
  end

  if type(self.update) ~= Type.NIL then self:update() end
end

--[[
  Draws the entities in the room.
]]--
function Room:drawCore()
  -- Draw entities
  for k, v in pairs(self) do
    if type(v) ~= Type.FUNCTION and v.isEntity then
      v:draw(true, 8)
    end
  end

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

  -- TODO: Clean up shit better? Do I need to recurse through tables?
end

--[[
  Returns the user-specified name of the room.
]]--
function Room:getName()
  return self._roomName
end
