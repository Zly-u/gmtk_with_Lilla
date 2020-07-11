local Utils = require("utils")
local Tower = require("tower")
local Enemy = require("enemy")

local shoplist = {
    {i = 1, name = "Stroller",   cost =   100, clicks = 1, key = "basic"},
    {i = 2, name = "Patroller",  cost =  2000, clicks = 1, key = "patrol"},
    {i = 3, name = "Marcher",    cost =  2000, clicks = 2, key = "patrol2p"},
    {i = 4, name = "Sleeper",    cost =  5000, clicks = 1, key = "static"},
    {i = 5, name = "Warper",     cost = 10000, clicks = 1, key = "teleporting"},
    {i = 6, name = "Superposer", cost = 50000, clicks = 4, key = "quantum"},
}

local enemy_kinds = {
    {size = 20, hp = 200, speed =  5}, --big
    {size = 10, hp = 100, speed = 10}, --normal
    {size =  6, hp =  40, speed = 25}, --small
}

local engine = {
    towers = {},
    enemies = {},
    bullets = {},
    path = {},
    money = 0,
    crossed = 0,
    oob_distance = 100,
    difficulty = 0,
    canvas = love.graphics.newCanvas(720,720),
    placing_tower = nil,
    tower_clicks = {},
    next_wave_in = 0,
    next_enemy_in = 0,
    wave_current_diff = 0,
    
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
        self.difficulty = 0
        self.next_wave_in = 3
        self.next_enemy_in = 0
        self.wave_current_diff = 0
    end,
    
    update = function(self, dt)
        for _, enemy in pairs(self.enemies) do
            enemy:update(self.path, dt)
        end

        for _, tower in pairs(self.towers) do
            local target = tower:isInRadius(self.enemies)

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
        
        
        -- enemy spawn
        self.difficulty = self.difficulty + dt
        if self.next_wave_in > 0 then
            self.next_wave_in = self.next_wave_in - dt
            if self.next_wave_in <= 0 then
                self.wave_current_diff = self.difficulty
            end
        else
            if self.next_enemy_in > 0 then
                self.next_enemy_in = self.next_enemy_in - dt
            else
                local e = enemy_kinds[math.random(math.min(math.floor(self.difficulty/10 + 1), #enemy_kinds))]
                local diffmult = math.max(self.wave_current_diff, self.difficulty * 1.2 * math.random())*0.1
                local x, y = unpack(self.path[1])
                self:addEnemy(Enemy.new(x, y, e.size, e.speed, math.tau*math.random(), e.hp*diffmult, "basic"))
                self.wave_current_diff = self.wave_current_diff - diffmult*10
                print(self.wave_current_diff, diffmult)
                if self.wave_current_diff > 0 then
                    self.next_enemy_in = math.random()*0.5
                else
                    self.next_wave_in = 20+math.random(40)
                end
            end
        end
    end,

    draw = function(self)
        love.graphics.setCanvas(self.canvas) do
            love.graphics.setColor(0,0,0,0)
            love.graphics.clear()

            --Drawing entities
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("line", 1,0, 719,719)
            for _, enemy  in pairs(self.enemies) do enemy :draw() end
            for _, tower  in pairs(self.towers ) do tower :draw() end
            for _, bullet in pairs(self.bullets) do bullet:draw() end

            --Path preview
            local line = {}
            for _, point in ipairs(self.path) do
                table.insert(line, point[1])
                table.insert(line, point[2])
            end
            love.graphics.setColor(Utils.HSVA(60, 0.7, 0.8, 1))
            love.graphics.line(line)
        end love.graphics.setCanvas()

        --oooooo GUI Related
        love.graphics.print(string.format("current funds: ¤%s", Utils.commaValue(Utils.truncate(self.money, -2))), 750, 30)
        love.graphics.setColor(Utils.HSVA(0, 0.7, 0.8, 1))
        love.graphics.print(string.format("difficulty: %d", self.difficulty), 750, 10)

        for k, entry in pairs(shoplist) do
            love.graphics.setColor(Utils.HSVA(k*30, 1, 0.3))
            love.graphics.rectangle("fill", 720, 50*k, 560, 49)
            love.graphics.setColor(Utils.HSVA(k*30))
            love.graphics.rectangle("line", 720, 50*k, 560, 49)
            love.graphics.print(string.format("%s: ¤%s", entry.name, Utils.commaValue(entry.cost)), 750, 20+50*k)
        end

        --Draw shits ooooooo
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.canvas)
        
        if self.placing_tower then
            love.graphics.setColor(Utils.HSVA(self.placing_tower.i*30))
            for _, pt in ipairs(self.tower_clicks) do
            love.graphics.circle("line", pt.x, pt.y, 5)
            end
        end
        local mx, my = love.mouse.getPosition()
        love.graphics.line(mx-10, my-10, mx+10, my+10)
        love.graphics.line(mx-10, my+10, mx+10, my-10)
        love.graphics.circle("line", mx, my, 10)
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
                    self:addTower(Tower.new(pos.x, pos.y, 15, 100, 15,
                                math.pi/10, self.placing_tower.key, self.tower_clicks))
                    self.placing_tower = nil
                end
            end
        end
    end
}

return engine