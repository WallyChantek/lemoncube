-- Utility Functions -----------------------------------------------------------
util = {}

--[[
    Returns a string containing the formatted contents of a table.
]]--
function util.examine(o, indent)
    local indent = indent or 1

    if type(o) == "table" then
        local s = "{"
            for k, v in pairs(o) do
                if type(k) ~= "number" then k = "\""..k.."\"" end
                s = s .. "\n" .. string.rep("    ", indent) .. "["..k.."] = " ..
                    util.examine(v, indent + 1) .. ","
            end
        if s:sub(-1) == "," then s = s:sub(1, -2) end
        return s .. "\n" .. string.rep("    ", indent - 1) .. "}"
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
    local c = 0
    for k,v in pairs(t) do c = c + 1 end
    return c
end

--[[
    Returns a numeric value based on a boolean value (true = 1, false = 0).
]]--
function util.booleanToNumber(b)
    return b and 1 or 0
end

--[[
    Returns a boolean value based on a numeric value (1 = true, 0 = false).
]]--
function util.numberToBoolean(n)
    return n > 0 and true or false
end

--[[
    Returns a deep copy of a table.
]]--
function util.cloneTable(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[util.cloneTable(orig_key, copies)] =
                    util.cloneTable(orig_value, copies)
            end
            setmetatable(copy, util.cloneTable(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- Math Extensions -------------------------------------------------------------
--[[
    Returns the average value of a series of numbers.
]]--
function math.average(...)
    local values = {...}
    local total = 0
    
    for i, value in pairs(values) do
        total = total + value
    end
    
    return total / util.size(values)
end

--[[
    Forces a number to be within a certain range (inclusive).
]]--
function math.clamp(value, limitLower, limitUpper)
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
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(value * mult + 0.5) / mult
end

--[[
    Returns the positive (1) or negative (-1) sign of a value. Returns 0 if 0.
]]--
function math.sign(value)
    if value == 0 then return 0 end
    return value / math.abs(value)
end
