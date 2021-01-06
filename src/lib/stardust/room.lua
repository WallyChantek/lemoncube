Room = {}
Room.__index = Room

function Room:new(roomName)
    local o = {}
    setmetatable(o, Room)

    o:_init(roomName or "(untitled)")

    return o
end

function Room:_init(roomName)
    self._roomName = roomName
    self._mapTiles = {}
    self._mapColliders = {}
    self._mapColliderObjects = {} -- This is just for quick retrieval
    self._entityCount = 0
end

--[[
    Updates the logic for the room instance.
]]--
function Room:_updateRoom()
    self._entityCount = 0
    
    -- Update entities
    self:_updateEntities(self)
    
    -- Call room-specific update function
    if type(self.update) ~= Const.LUA_TYPE.NIL then self:update() end
end

--[[
    Updates the entities in the room. Called automatically by updateRoom().
]]
function Room:_updateEntities(t)
    for k, v in pairs(t) do
        if type(v) == Const.LUA_TYPE.TABLE then
            if v._isEntity then
                self._entityCount = self._entityCount + 1
                v:_animate()
                v:_updateColliders()
            else
                self:_updateEntities(v)
            end
        end
    end
end

--[[
    Draws the graphics for the room instance.
]]--
function Room:_drawRoom()
    -- Draw entities
    self:_drawEntities(self)
    
    -- Call room-specific draw function
    if type(self.draw) ~= Const.LUA_TYPE.NIL then self:draw() end
end

--[[
    Draws the entities in the room. Called automatically by drawRoom().
]]
function Room:_drawEntities(t)
    for k, v in pairs(t) do
        if type(v) == Const.LUA_TYPE.TABLE then
            if v._isEntity then
                v:_draw()
            else
                self:_drawEntities(v)
            end
        end
    end
end

--[[
    Cleans up the data related to the room.
]]--
function Room:_destroy()
    local rn = self._roomName
    
    -- Clean up non-function datatypes
    for k, v in pairs(self) do
        if type(v) ~= Const.LUA_TYPE.FUNCTION then
            self[k] = nil
        end
    end
    
    self:_init(rn)
end

--[[
    Returns the user-specified name of the room.
]]--
function Room:_getName()
    return self._roomName
end

--[[
    Loads a tile/collision map.
]]--
function Room:loadMap(map)
    -- Load graphical tiles
    for row=1, util.size(map.tiles) do
        for col, tile in ipairs(map.tiles[row]) do
            if tile ~= 0 then
                -- Create tile entity
                local t = Entity:new(
                    (col-1)*Engine._tileWidth, (row-1)*Engine._tileHeight)
                t:addAnimation("t", res.sprite.tiles,
                    Engine._tileWidth, Engine._tileHeight, {
                    startingFrame = tile
                })
                t:pauseAnimation()
                
                -- Store tile entity
                table.insert(self._mapTiles, t)
            end
        end
    end
    
    -- Load collision map
    local cmap = util.cloneTable(map.collision)
    -- Add blank row so we don't have to do any weird handling for the final row
    local lr = {}
    for i=1, util.size(cmap[1]) do
        lr[i] = 0
    end
    table.insert(cmap, lr)
    -- Determine how to create the collision masks in a somewhat-efficient
    -- manner; we traverse through each row, then each column, determining
    -- a starting point, figuring out the max width of a collision rectangle,
    -- and then determining where it ends
    local quadFound = false
    local rowGood = true
    local tileType = 0
    local quadStart = { row = nil, col = nil }
    local quadEnd = { row = nil, col = nil }
    local row = 1
    while (row <= util.size(cmap)) do
        rowGood = true
        
        for col, tile in ipairs(cmap[row]) do
            -- Determine starting row/column of quad
            if not quadFound then
                if tile ~= 0 then
                    quadFound = true
                    tileType = tile
                    quadStart.row = row
                    quadStart.col = col
                    quadEnd.row = row
                    quadEnd.col = col
                    cmap[row][col] = 0
                    goto continue
                end
            else
                -- Continue search through first row to determine quad "width"
                if row == quadStart.row then
                    if tile == tileType then
                        -- Try to find ending column of quad on first row
                        quadEnd.col = col
                        cmap[row][col] = 0
                        goto continue
                    else
                        -- Jump to next row if we hit an empty space
                        break
                    end
                -- Search through subsequent rows
                else
                    -- Check next row for any tiles that may break this quad
                    -- Obstacle tiles before quad's starting column
                    if tile == tileType and (col < quadStart.col) then
                        rowGood = false
                    end
                    -- Blank or different tile types within quad width boundary
                    if tile ~= tileType and
                        (col >= quadStart.col and col <= quadEnd.col) then
                        rowGood = false
                    end
                    
                    -- Jump to next row if we make it to the end without issue
                    if rowGood then
                        if col > quadEnd.col then
                            -- Zero out good tiles so we don't hit them again
                            for i = quadStart.col, quadEnd.col do
                                cmap[row][i] = 0
                            end
                            
                            -- Jump to next row
                            quadEnd.row = row
                            break
                        end
                    -- Terminate further searching if the row was not a match,
                    -- creating our new entity and starting a new search from
                    -- the starting row of this quad
                    else
                        local c = Entity:new(
                            (quadStart.col-1)*Engine._tileWidth,
                            (quadStart.row-1)*Engine._tileHeight)
                        c:addCollider("physbox", {
                            width = ((quadEnd.col - quadStart.col) *
                                Engine._tileWidth) + Engine._tileWidth,
                            height = ((quadEnd.row - quadStart.row) *
                                Engine._tileHeight) + Engine._tileHeight
                        })
                        c:getCollider("physbox").tileType = tileType
                        
                        table.insert(self._mapColliderObjects, c:getCollider("physbox"))
                        table.insert(self._mapColliders, c)
                        
                        quadFound = false
                        tileType = 0
                        row = quadStart.row - 1
                        break
                    end
                end
            end
            
            ::continue::
        end
        
        row = row + 1
    end
end

--[[
    Returns all the obstacle colliders for the loaded/calculated collision map.
]]--
function Room:getMapColliders()
    return self._mapColliderObjects
end

--[[
    Returns all the platform colliders for the loaded/calculated collision map.
]]--
function Room:getMapPlatforms()
    return self._mapPlatforms
end

--[[
    Returns the number of entities that exist in the room instance.
]]--
function Room:getEntityCount()
    return self._entityCount
end
