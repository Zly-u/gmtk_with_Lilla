local game = require("engine")
local enemy = require("enemy")

local pathWay = {
    {50, 50},
    {50, 200},
    {200, 10},
    {200, 200},
    {50, 600},
}

function love.load()
    game:setPath(pathWay)
    game:addEnemy(enemy.new(0, 0, 10, 4*60, 0, 100, "basic"))
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    love.graphics.setLineStyle("rough")
    game:draw()
end