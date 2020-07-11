require("init")

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
    Game:reset(pathWay, 500000000)
end

function love.update(dt)
    Game:update(dt)
    --[[
    next_spawn = next_spawn - dt
    if next_spawn <= 0 then
        Game:addEnemy(Enemy.new(0, 0, 10, 30, 0, 100, "basic"))
        next_spawn = (1-math.random())^2*9 + 1
    end
    ]]
end

function love.draw()
    love.graphics.setLineStyle("rough")
    Game:draw()
    love.graphics.setColor(1,1,1,1)
end

---[[
function love.keypressed(key)
    if key == "e" then Game:addEnemy(Enemy.new(0, 0, 25, 80, 0, 100, "basic")) end
end
--]]

function love.mousepressed(x, y, button, istouch, presses)
    --[=[
    if button == 1 then
        --[[
        local patrol_param = {
            home_pos = {x = x, y = y},
            patroling_radius = 100,
            isOutside = false,
        }
        Game:addTower(Tower.new(x, y, 15, 100, 10, math.pi/16, "basic", patrol_param))
        --]]
        --[[
        local tp_param = {
            tp_cooldown = 1,
            tp_delay = 0,
        }
        Game:addTower(Tower.new(x, y, 15, 100, 100, math.pi/5, "teleporting", tp_param))
        --]]

        Game:addTower(Tower.new(x, y, 15, 100, 100, math.pi/5, "quantum"))
    end
    --]=]
    Game:mousepressed(x, y, button, istouch, presses)
end