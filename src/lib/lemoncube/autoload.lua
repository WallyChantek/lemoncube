local pkg = (...):match("(.-)[^%.]+$")

-- Utility ---------------------------------------------------------------------
require(pkg .. "helperFunctions")
require(pkg .. "constants")


-- Engine System Components ----------------------------------------------------
require(pkg .. "errorHandler")


-- Game Engine Core ------------------------------------------------------------
require(pkg .. "engine")


-- Engine Game Components ------------------------------------------------------
require(pkg .. "inputController")
require(pkg .. "room")
require(pkg .. "animation")
require(pkg .. "entity")
