local Utils = require("utils")
local Tower = require("tower")

local shoplist = {
    {name = "Stroller",  cost =   100, clicks = 1, key = "basic"},
    {name = "Patroller", cost =  2000, clicks = 1, key = "patrol"},
    {name = "Marcher",   cost =  2000, clicks = 2, key = "patrol2p"},
    {name = "Sleeper",   cost =  5000, clicks = 1, key = "static"},
    {name = "Warper",    cost = 10000, clicks = 1, key = "teleporting"},
}

local engine = {
    towers = {},
    enemies = {},
    bullets = {},
    path = {},
    money = 0,
    crossed = 0,
    oob_distance = 100,
    canvas = love.graphics.newCanvas(720,720),
    placing_tower = nil,
    tower_clicks = {},
    
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
        
        for k, entry in pairs(shoplist) do
            love.graphics.setColor(Utils.HSVA(k*30, 1, 0.3))
            love.graphics.rectangle("fill", 720, 50*k, 560, 50)
            love.graphics.setColor(Utils.HSVA(k*30))
            love.graphics.rectangle("line", 720, 50*k, 560, 50)
            love.graphics.print(string.format("%s: ¤%d", entry.name, entry.cost), 750, 20+50*k)
        end
    end,
    
    mousepressed = function(self, x, y, button, istouch, presses)
        if button == 1 then 
            if x >= 720 and not self.placing_tower then
                local item = shoplist[math.floor(y/50)]
                if item and self.money >= item.cost then
                    self.money = self.money - item.cost
                    self.tower_clicks = {}
                    self.placing_tower = item
                end
            elseif x < 720 and self.placing_tower then
                table.insert(self.tower_clicks, {x = x, y = y})
                if #self.tower_clicks == self.placing_tower.clicks then
                    local pos = table.remove(self.tower_clicks, 1)
                    self:addTower(Tower.new(pos.x, pos.y, 15, 100, 15, math.pi/10, self.placing_tower.key, self.tower_clicks))
                    self.placing_tower = nil
                end
            end
        end
    end
}

return engine