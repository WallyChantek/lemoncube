-- Utility Functions -----------------------------------------------------------
util = {}

--[[
  Returns a string containing the formatted contents of a table.
]]--
function util.examine(o, indent)
  local indent = indent or 1

  assert(type(indent) == "number",
    "Argument \"indent\" must be of type: ".."number")
  
  if type(o) == "table" then
    local s = "{"
      for k, v in pairs(o) do
        if type(k) ~= "number" then k = "\""..k.."\"" end
        s = s .. "\n" .. string.rep("  ", indent) .. "["..k.."] = " ..
          util.examine(v, indent + 1) .. ","
      end
    if s:sub(-1) == "," then s = s:sub(1, -2) end
    return s .. "\n" .. string.rep("  ", indent - 1) .. "}"
  else
    if type(o) == "string" then
      return "\""..o.."\""
    else
      return tostring(o)
    end
  end
end

--[[
  Flips the index order of an array.
]]--
function util.reverseTable(t)
  assert(type(t) == "table",
    "Argument \"t\" must be of type: ".."table")

  local i, j = 1, #t

  while i < j do
    t[i], t[j] = t[j], t[i]

    i = i + 1
    j = j - 1
  end
end


-- Math Extensions -------------------------------------------------------------
--[[
  Forces a number to be within a certain range. EXT: Inclusive, use terms like "boundaries"
]]--
function math.clamp(value, limitLower, limitUpper)
  assert(type(value) == "number",
    "Argument \"value\" must be of type: ".."number")
  assert(type(limitLower) == "number",
    "Argument \"limitLower\" must be of type: ".."number")
  assert(type(limitUpper) == "number",
    "Argument \"limitUpper\" must be of type: ".."number")
  
  -- Allow checking regardless of range order
  if limitLower > limitUpper then
    limitLower, limitUpper = limitUpper, limitLower
  end
  
  return math.max(limitLower, math.min(limitUpper, value))
end

--[[
  Rounds a decimal value to the nearest whole value (up or down).
]]--
function math.round(value, numDecimalPlaces)
  assert(type(value) == "number",
    "Argument \"value\" must be of type: ".."number")
  assert(type(numDecimalPlaces) == "number",
    "Argument \"numDecimalPlaces\" must be of type: ".."number")
  
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(value * mult + 0.5) / mult
end

--[[
  Returns the positive or negative sign of a value. EXT: Returns 0 if 0
]]--
function math.sign(value)
  assert(type(value) == "number",
    "Argument \"value\" must be of type: ".."number")

  if value == 0 then return 0 end

  return value / math.abs(value)
end
