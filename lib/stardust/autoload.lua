local pkg = (...):match("(.-)[^%.]+$")

-- System ----------------------------------------------------------------------
require(pkg .. "constants")
require(pkg .. "debugger")
require(pkg .. "errorHandler")
require(pkg .. "helperFunctions")


-- Game Engine Core ------------------------------------------------------------
require(pkg .. "engine")
require(pkg .. "room")
require(pkg .. "animation")
require(pkg .. "entity")
require(pkg .. "inputController")
