Player = {}
Player.__index = Player

function Player:new(x, y)
    local o = {}
    setmetatable(o, Player)
    
    return o
end

function Player:update()

end