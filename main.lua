local Game = require("engine")
local Enemy = require("enemy")
local Tower = require("tower")

local pathWay = {
    {0, 0},
    {50, 50},
    {50, 360},
    {360, 670},
    {360, 50},
    {670, 360},
    {670, 670},
    {720, 720},
}

local next_spawn = 3

function love.load()
    Game:setPath(pathWay)
end

function love.update(dt)
    Game:update(dt)
    next_spawn = next_spawn - dt
    if next_spawn <= 0 then
        Game:addEnemy(Enemy.new(0, 0, 10, 30, 0, 100, "basic"))
        next_spawn = (1-math.random())^2*9 + 1
    end
end

function love.draw()
    love.graphics.setLineStyle("rough")
    Game:draw()
    love.graphics.setColor(1,1,1,1)
    local mx, my = love.mouse.getPosition()
    love.graphics.line(mx-10, my-10, mx+10, my+10)
    love.graphics.line(mx-10, my+10, mx+10, my-10)
    love.graphics.circle("line", mx, my, 10)
end

--[[
function love.keypressed(key)
        if key == "e" then Game:addEnemy(Enemy.new(0, 0, 10, 30, 0, 100, "basic"))
    elseif key == "t" then Game:addTower(Tower.new(360, 360, 15, 100, 1))
    end
end
--]]

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        Game:addTower(Tower.new(x, y, 15, 100, 1))
    end
end