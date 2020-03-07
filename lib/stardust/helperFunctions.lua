util = {}

--[[
  Returns a string containing the formatted contents of a table.
]]--
function util.examine(o, tab)
  local tab = tab or 1
  
  if type(o) == "table" then
    local s = "{"
      for k, v in pairs(o) do
        if type(k) ~= "number" then k = "\""..k.."\"" end
        s = s .. "\n" .. string.rep("  ", tab) .. "["..k.."] = " ..
          util.examine(v, tab + 1) .. ","
      end
    if s:sub(-1) == "," then s = s:sub(1, -2) end
    return s .. "\n" .. string.rep("  ", tab - 1) .. "}"
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
function util.reverseArray(arr)
  local i, j = 1, #arr

  while i < j do
    arr[i], arr[j] = arr[j], arr[i]

    i = i + 1
    j = j - 1
  end
end

--[[
  Forces a number to be within a certain range. EXT: Inclusive, use terms like "boundaries"
]]--
function math.clamp(value, limitLower, limitUpper)
    assert(type(value) == TYPE_NUMBER,
      "Argument \"value\" ust be of type: "..TYPE_NUMBER)
    assert(type(limitLower) == TYPE_NUMBER,
      "Argument \"limitLower\" ust be of type: "..TYPE_NUMBER)
    assert(type(limitUpper) == TYPE_NUMBER,
      "Argument \"limitUpper\" ust be of type: "..TYPE_NUMBER)
    
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
  assert(type(value) == TYPE_NUMBER,
    "Argument \"value\" must be of type: "..TYPE_NUMBER)
  assert(type(numDecimalPlaces) == TYPE_NUMBER,
    "Argument \"numDecimalPlaces\" must be of type: "..TYPE_NUMBER)
  
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(value * mult + 0.5) / mult
end

--[[
  Returns the positive or negative sign of a value. EXT: Returns 0 if 0
]]--
function math.sign(value)
  assert(type(value) == TYPE_NUMBER,
    "Argument \"value\" must be of type: "..TYPE_NUMBER)

  if value == 0 then return 0 end

  return value / math.abs(value)
end
