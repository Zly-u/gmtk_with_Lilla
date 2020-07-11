local Utils = require("utils")
local Tower = require("tower")

local engine = {
    towers = {},
    enemies = {},
    bullets = {},
    path = {},
    money = 0,
    crossed = 0,
    oob_distance = 100,
    
    addTower = function(self, tower)
        table.insert(self.towers, tower)
    end,

    addEnemy = function(self, enemy)
        table.insert(self.enemies, enemy)
    end,
    
    setPath = function(self, points)
        self.path = points
    end,

    clearTowers = function(self)
        self.towers = {}
    end,
    
    clearEnemies = function(self)
        self.enemies = {}
    end,
    
    reset = function(self, path, startmoney)
        self:clearEnemies()
        self:clearTowers()
        self:setPath(path)
        self.money = startmoney
        self.crossed = 0
    end,
    
    update = function(self, dt)
        for _, enemy in pairs(self.enemies) do
            enemy:update(self.path, dt)
        end
        
        for _, tower in pairs(self.towers) do
            local target = nil
            local targetdist = tower.radius
            for _, enemy in pairs(self.enemies) do
                local d = Utils.distanceOO(enemy, tower) - enemy.size
                if d <= targetdist then
                    target = enemy
                    targetdist = d
                end
            end
            local bullet = tower:update(target, dt)
            if bullet then table.insert(self.bullets, bullet) end
        end
        
        local nextframe_bullets = {}
        for _, bullet in pairs(self.bullets) do
            bullet:update(dt)

            local target = nil
            local targetdist = bullet.size
            for _, enemy in pairs(self.enemies) do
                local d = Utils.distanceOO(enemy, bullet) - enemy.size
                if d <= targetdist then
                    target = enemy
                    targetdist = d
                end
            end
            if target then
                -- bullet:hit(target) later, for now just apply damage and stop keeping track of the bullet -- Lilla
                target.hp = target.hp - bullet.damage
            elseif bullet.x >   0 - self.oob_distance
            and    bullet.y >   0 - self.oob_distance
            and    bullet.x < 720 + self.oob_distance
            and    bullet.y < 720 + self.oob_distance
            then
                table.insert(nextframe_bullets, bullet)
            end
        end
        self.bullets = nextframe_bullets
        
        for k = #self.enemies, 1, -1 do
            local enemy = self.enemies[k]
            if enemy.hp < 0 then
                table.remove(self.enemies, k)
                self.money = self.money + enemy.money
            elseif enemy.reachedEnd then
                table.remove(self.enemies, k)
                self.crossed = self.crossed + 1
            end
        end
    end,

    draw = function(self)
        love.graphics.rectangle("line", 0,0, 720,720)
        for _, enemy  in pairs(self.enemies) do enemy :draw() end
        for _, tower  in pairs(self.towers ) do tower :draw() end
        for _, bullet in pairs(self.bullets) do bullet:draw() end
        local line = {}
        for _, point in ipairs(self.path) do
            table.insert(line, point[1])
            table.insert(line, point[2])
        end
        love.graphics.setColor(Utils.HSVA(60, 0.7, 0.8, 1))
        love.graphics.line(line)
        
        love.graphics.print(string.format("current funds: ¤%d", self.money), 750, 30)
        
        local k = 1
        for name, tower in pairs(Tower.towers) do
            love.graphics.setColor(Utils.HSVA(k*30, 1, 0.3))
            love.graphics.rectangle("fill", 720, 50*k, 560, 50)
            love.graphics.setColor(Utils.HSVA(k*30))
            love.graphics.rectangle("line", 720, 50*k, 560, 50)
            love.graphics.print(string.format("%s: ¤%d", name, tower.cost), 750, 20+50*k)
            k = k + 1
        end
    end
}

return engine