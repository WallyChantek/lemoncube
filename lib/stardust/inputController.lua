InputController = {}
InputController.__index = InputController

function InputController:new()
    local o = {}
    setmetatable(o, InputController)
    
    -- Table to hold inputs
    o._inputs = {}

    -- Add to Engine's global input controller list
    table.insert(Engine._inputControllers, o)
    
    return o
end

--[[
    Handles state changes for the controller.
]]--
function InputController:_update()
    for k, input in pairs(self._inputs) do
        -- Keep track of input's state from previous frame
        input.wasHeldLast = input.isHeldNow
        
        -- Check if input is active this frame
        if input.inputType == Const.INPUT_SOURCE.KB then
            input.isHeldNow = love.keyboard.isDown(input.input)
        end
        -- TODO: Handle other inputs
        
        -- Indicate whether input was pressed or released
        input.wasPressed = (input.isHeldNow and not input.wasHeldLast)
        input.wasReleased = (input.wasHeldLast and not input.isHeldNow)
    end
end

--[[
    Maps a new input or re-maps an existing input.
]]--
function InputController:setInput(inputId, inputType, input)
    self._inputs[inputId] = {
        inputType = inputType,
        input = input,
        wasHeldLast = false,
        isHeldNow = false,
        wasPressed = false,
        wasReleased = false
    }
end

--[[
    Un-maps an existing input.
]]--
function InputController:removeInput(inputId)
    self._inputs[inputId] = nil
end

--[[
    Returns whether the target input was pressed down during the current frame.
]]--
function InputController:wasPressed(inputId)
    return self._inputs[inputId].wasPressed
end

--[[
    Returns whether the target input was released during the current frame.
]]--
function InputController:wasReleased(inputId)
    return self._inputs[inputId].wasReleased
end

--[[
    Returns whether the target input is currently down/active.
]]--
function InputController:isBeingHeld(inputId)
    local input = self._inputs[inputId]
    if (input.inputType == Const.INPUT_SOURCE.KB) then
        return love.keyboard.isDown(input.input)
    elseif (input.inputType == Const.INPUT_SOURCE.JOYBTN) then
        -- TODO: Input was joystick
    end
end
