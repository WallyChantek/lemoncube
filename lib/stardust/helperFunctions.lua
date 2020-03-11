-- Data-validation Functions ---------------------------------------------------
validate = {}

--[[
  Returns the correct error message for validation failure.
]]--
function validate._msg(defaultMsg, userMsg)
  if type(userMsg) ~= Type.NIL then
    return userMsg
  else
    return defaultMsg
  end
end

--[[
  Verifies that a value is of a specified type.
]]--
function validate._type(val, varType, varName, msg)
  assert(type(val) == varType,
    "\""..varName.."\""..validate._msg(
      " must be of type: "..varType,
      msg
    ))
end

--[[
  Verifies that a value is nil.
]]--
function validate.typeNil(val, varName, msg)
  validate._type(val, Type.NIL, varName, msg)
end

--[[
  Verifies that a value is a boolean.
]]--
function validate.typeBoolean(val, varName, msg)
  validate._type(val, Type.BOOLEAN, varName, msg)
end

--[[
  Verifies that a value is a number.
]]--
function validate.typeNumber(val, varName, msg)
  validate._type(val, Type.NUMBER, varName, msg)
end

--[[
  Verifies that a value is a string.
]]--
function validate.typeString(val, varName, msg)
  validate._type(val, Type.STRING, varName, msg)
end

--[[
  Verifies that a value is userdata.
]]--
function validate.typeUserdata(val, varName, msg)
  validate._type(val, Type.USERDATA, varName, msg)
end

--[[
  Verifies that a value is a function.
]]--
function validate.typeFunction(val, varName, msg)
  validate._type(val, Type.FUNCTION, varName, msg)
end

--[[
  Verifies that a value is a thread.
]]--
function validate.typeThread(val, varName, msg)
  validate._type(val, Type.THREAD, varName, msg)
end

--[[
  Verifies that a value is a table.
]]--
function validate.typeTable(val, varName, msg)
  validate._type(val, Type.TABLE, varName, msg)
end

--[[
  Verifies that a value is equal to another value.
]]--
function validate.equals(val, varName, value, msg)
  assert(val == value,
    "\""..varName.."\""..validate._msg(
      " must be equal to "..value,
      msg
    ))
end

--[[
  Verifies that a value is greater than another value.
]]--
function validate.greaterThan(val, varName, value, msg)
  assert(val > value,
    "\""..varName.."\""..validate._msg(
      " must be greater than "..value,
      msg
     ))
end

--[[
  Verifies that a value is less than another value.
]]--
function validate.lessThan(val, varName, value, msg)
  assert(val < value,
    "\""..varName.."\""..validate._msg(
      " must be less than "..value,
      msg
     ))
end

--[[
  Verifies that a value is greater than or equal to another value.
]]--
function validate.atLeast(val, varName, value, msg)
  assert(val >= value,
    "\""..varName.."\""..validate._msg(
      " must be at least "..value,
      msg
    ))
end

--[[
  Verifies that a value is less than or equal to another value.
]]--
function validate.atMost(val, varName, value, msg)
  assert(val <= value,
      "\""..varName.."\""..validate._msg(
        " must be at most "..value,
        msg
      ))
end

--[[
  Verifies that a list of options does not contain any invalid option names.
]]--
function validate.optionNames(options, validOptionNames, msg)
  for optionName, v in pairs(options) do
    local found = false
    for i, validOptionName in pairs(validOptionNames) do
      if optionName == validOptionName then found = true end
    end
    
    assert(found,
      "Option \""..optionName.."\""..validate._msg(
        " is not a valid option",
        msg
      ))
  end
end

--[[
  Verifies that a value matches a list of constant values.
]]--
function validate.constant(val, varName, validConstants, msg)
  local found = false
  for i, validConstant in pairs(validConstants) do
    if val == validConstant then found = true end
  end
  
  assert(found,
    "Option \""..varName.."\""..validate._msg(
      " requires a valid constant value",
      msg
    ))
end


-- Utility Functions -----------------------------------------------------------
util = {}

--[[
  Returns a string containing the formatted contents of a table.
]]--
function util.examine(o, indent)
  local indent = indent or 1

  validate.typeNumber(indent, "indent")
  
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
  validate.typeTable(t, "t")

  local i, j = 1, util.size(t)

  while i < j do
    t[i], t[j] = t[j], t[i]

    i = i + 1
    j = j - 1
  end
end

--[[
  Returns the number of elements in a table, including those with keys.
]]--
function util.size(t)
  validate.typeTable(t, "t")
  
  local c = 0
  for k,v in pairs(t) do c = c + 1 end
  return c
end

--[[
  Returns a numeric value based on a boolean value (1 or 0).
]]--
function util.booleanToNumber(b)
  validate.typeBoolean(b, "b")
  return b and 1 or 0
end

--[[
  Returns a boolean value based on a numeric value.
]]--
function util.numberToBoolean(n)
  validate.typeNumber(n, "n")
  return n > 0 and true or false
end


-- Math Extensions -------------------------------------------------------------
--[[
  Forces a number to be within a certain range. EXT: Inclusive, use terms like "boundaries"
]]--
function math.clamp(value, limitLower, limitUpper)
  validate.typeNumber(value, "value")
  validate.typeNumber(limitLower, "limitLower")
  validate.typeNumber(limitUpper, "limitUpper")
  
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
  validate.typeNumber(value, "value")
  validate.typeNumber(numDecimalPlaces, "numDecimalPlaces")
  
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(value * mult + 0.5) / mult
end

--[[
  Returns the positive or negative sign of a value. EXT: Returns 0 if 0
]]--
function math.sign(value)
  validate.typeNumber(value, "value")

  if value == 0 then return 0 end

  return value / math.abs(value)
end
