InputController = {}
InputController.__index = InputController

--[[
  Constructor
]]--
function InputController:new()
  local o = {}
  setmetatable(o, InputController)
  
  -- Table to hold inputs
  o._inputs = {}

  -- Add to Engine's input controller list
  table.insert(Engine._inputControllers, o)
  
  return o
end

--[[
  Handles state changes for the controller.
]]--
function InputController:update()
  for k, input in pairs(self._inputs) do
    -- Keep track of input's state from previous frame
    input.wasHeldLast = input.isHeldNow
    
    -- Check if input is active this frame
    if input.inputType == Option.INPUT_KB then
      input.isHeldNow = love.keyboard.isDown(input.input)
    end
    -- TODO: Handle other inputs
    
    -- Toggle whether input was pressed or released
    input.wasPressed = (input.isHeldNow and not input.wasHeldLast)
    input.wasReleased = (input.wasHeldLast and not input.isHeldNow)
  end
end

--[[
  Adds a new input or changes an existing input.
]]--
function InputController:setInput(inputId, inputType, input)
  validate.typeString(inputId, "inputId")
  validate.typeNumber(inputType, "inputType")
  validate.typeString(input, "input")
  validate.constant(inputType, "inputType", {
    Option.INPUT_KB,
    Option.INPUT_JOY_BTN,
    Option.INPUT_JOY_AXIS,
    Option.INPUT_JOY_HAT
  })
  
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
  Removes an existing input.
]]--
function InputController:removeInput(inputId)
  validate.typeString(inputId, "inputId")
  self._inputs[inputId] = nil
end

--[[
  Returns whether the target input is currently down/active.
]]--
function InputController:isBeingHeld(inputId)
  validate.typeString(inputId, "inputId")
  
  local input = self._inputs[inputId]
  if (input.inputType == Option.INPUT_KB) then
    return love.keyboard.isDown(input.input)
  elseif (input.inputType == Option.INPUT_JOYBTN) then
    -- TODO: Input was joystick
  end
end

--[[
  Returns whether the target input was pressed down during the current frame.
]]--
function InputController:wasPressed(inputId)
  validate.typeString(inputId, "inputId")
  return self._inputs[inputId].wasPressed
end

--[[
  Returns whether the target input was released during the current frame.
]]--
function InputController:wasReleased(inputId)
  validate.typeString(inputId, "inputId")
  return self._inputs[inputId].wasReleased
end

-- TODO: function InputController:getAxisValue?
-- TODO: function InputController:getHatValue?
