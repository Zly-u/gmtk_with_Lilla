require("init")

local Utils = require("utils")
local Game = require("engine")
local Enemy = require("enemy")
local Tower = require("tower")

local pathWay = {
    {-30, -30},
    {0, 0},
    {50, 50},
    {50, 360},
    {360, 670},
    {360, 50},
    {670, 360},
    {670, 670},
    {720, 720},
    {750, 750},
}

function love.load()
    Game:reset(pathWay, 1000000)
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    love.graphics.setLineStyle("rough")
    love.graphics.setLineJoin("bevel")
    Game:draw()
    love.graphics.setColor(1,1,1,1)
end

--[[
function love.keypressed(key)
    if key == "e" then Game:addEnemy(Enemy.new(pathWay[1][1], pathWay[1][2], 25, 100, Utils.angleBetweenXYXY(pathWay[1][1], pathWay[1][2], pathWay[2][1], pathWay[2][2]), 100, "funky")) end
end
--]]

function love.mousepressed(x, y, button, istouch, presses)
    --[=[
    if button == 1 then
        Game:addTower(Tower.new(x, y,  "basic"))
    end
    --]=]
    Game:mousepressed(x, y, button, istouch, presses)
end