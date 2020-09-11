Const = {}
Const.LUA_TYPE = {}
Const.COLLIDER_SHAPE = {}
Const.COLLIDER_POSITION = {}
Const.ANIM_PLAYBACK = {}
Const.INPUT_SOURCE = {}

-- System ----------------------------------------------------------------------
Const.LUA_TYPE.NIL = "nil"
Const.LUA_TYPE.BOOLEAN = "boolean"
Const.LUA_TYPE.NUMBER = "number"
Const.LUA_TYPE.STRING = "string"
Const.LUA_TYPE.USERDATA = "userdata"
Const.LUA_TYPE.FUNCTION = "function"
Const.LUA_TYPE.THREAD = "thread"
Const.LUA_TYPE.TABLE = "table"


-- Entity ----------------------------------------------------------------------
-- Collider
Const.COLLIDER_SHAPE.RECTANGLE = 0
Const.COLLIDER_SHAPE.CIRCLE = 1
Const.COLLIDER_POSITION.ORIGIN_POINT = 0
Const.COLLIDER_POSITION.ACTION_POINT = 1


-- Animation -------------------------------------------------------------------
Const.ANIM_PLAYBACK.NORMAL = 0
Const.ANIM_PLAYBACK.REVERSE = 1
Const.ANIM_PLAYBACK.ALTERNATE = 2
Const.ANIM_PLAYBACK.ALTERNATE_REVERSE = 3


-- InputController -------------------------------------------------------------
Const.INPUT_SOURCE.KB = 0
Const.INPUT_SOURCE.JOY_BTN = 1
Const.INPUT_SOURCE.JOY_AXIS = 2
Const.INPUT_SOURCE.JOY_HAT = 3
