Utils = require("utils")

local engine = {
    towers = {},
    enemies = {},
    map = {}
    
    addTower = function(game, tower)
        table.insert(game.towers, tower)
    end,
    
    addEnemy = function(game, enemy)
        table.insert(game.enemies, enemy)
    end,
    
    setMap = function(game, points)
        game.map = points
    end
    
    clearTowers = function(game)
        game.towers = {}
    end,
    
    clearEnemies = function(game)
        game.enemies = {}
    end,
    
    update = function(game, dt)
        for _, enemy in pairs(game.enemies) do
            enemy:update(map, dt)
        end
        
        for _, tower in pairs(game.towers) do
            tower:update(dt)
            local target = nil
            local targetdist = tower.radius
            for _, enemy in pairs(game.enemies) do
                local d = Utils.distanceOO(enemy, tower)
                if d <= targetdist then
                    target = enemy
                    targetdist = d
                end
            end
            tower:fire(target, dt)
        end
    end
}
return engine