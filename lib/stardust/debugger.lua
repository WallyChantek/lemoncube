Debugger = {}
Debugger.__index = Debugger

--[[
  Constructor
]]--
function Debugger:new()
  local o = {}
  setmetatable(o, Debugger)
  
  return o
end

--[[
  Displays the debugger information.
]]--
function Debugger:draw()
  -- Display which gamestate is active
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("State: " .. Engine:getRoom():getName(), 4,
    love.graphics.getHeight() - 16)
  
  -- Display FPS
  love.graphics.setColor(1, 0, 0)
  love.graphics.print(tostring(love.timer.getFPS()), 4, 0)
end
