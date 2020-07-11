local Bullet = require("bullet")
local Utils = require("utils")

local function common_isInRadius(self, targets)
    local target = nil
    local targetdist = self.radius
    for _, enemy in pairs(targets) do
        local d = Utils.distanceOO(self, enemy) - enemy.size
        if d <= targetdist then
            target = enemy
            targetdist = d
        end
    end

    return target
end

local Tower = {
    fire = function(self, target, dt)
        self.last_shot = self.last_shot + dt
        if target then 
            local angle = Utils.angleBetweenOO(self, target)
            if self.last_shot > self.cooldown then
                self.last_shot = 0
                return Bullet.new(self.x, self.y, self.bullet.size, angle, self.bullet.speed, self.bullet.damage, self.bullet.type)
            end
        end
        return nil
    end,

    towers = {
        basic = {
            cost = 0,
            cooldown = 1,

            bullet = {size = 5, speed = 70, damage = 15, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, clicks)

            end,

            update = function(self, target, dt)
                self.x = self.x + dt * self.speed * math.cos(self.angle)
                self.y = self.y + dt * self.speed * math.sin(self.angle)

                if not target then
                    self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                else
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end

            end,
            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end,
        },

        patrol = {
            cost = 0,
            cooldown = 0.2,

            bullet = {size = 3, speed = 120, damage = 4, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, clicks)
                self.home_pos = {x = self.x, y = self.y}
                self.patroling_radius = 100
                self.isOutside = false
            end,

            update = function(self, target, dt)
                if not target then
                    if not self.isOutside then
                        self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                    end
                    local d = Utils.distanceOO(self, self.home_pos)
                    if d > self.patroling_radius and not self.isOutside then
                        local home_angle = Utils.angleBetweenOO(self, self.home_pos)
                        self.angle = home_angle - math.rad(math.random(-30, 30))
                        self.isOutside = true
                    end
                    if d < self.patroling_radius * 0.7 and self.isOutside then
                        self.isOutside = false
                    end

                    self.x = self.x + dt * self.speed * math.cos(self.angle)
                    self.y = self.y + dt * self.speed * math.sin(self.angle)
                else
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end
            end,

            draw = function(self)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.home_pos.x, self.home_pos.y, self.patroling_radius)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end
        },

        patrol2p = {
            cost = 0,
            cooldown = 1,

            bullet = {size = 5, speed = 70, damage = 15, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, clicks)

            end,

            update = function(self, target, dt)
                self.x = self.x + dt * self.speed * math.cos(self.angle)
                self.y = self.y + dt * self.speed * math.sin(self.angle)

                if not target then
                    self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                else
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end

            end,
            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end,
        },

        static = {
            cost = 0,
            cooldown = 1,

            bullet = {size = 5, speed = 70, damage = 15, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, params)
                for name, val in pairs(params or {}) do
                    self[name] = val
                end
            end,

            update = function(self, target, dt)
                if not target then
                    self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                else
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end

            end,

            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end,
        },

        teleporting = {
            cost = 0,
            cooldown = 1,

            bullet = {size = 5, speed = 70, damage = 15, type = "basic"},

            upgrades = {
                {
                    cost = 10,

                    cooldown = 0.5
                },
                {
                    cost = 10,

                    bullet = {
                        damage = 2
                    }
                },
            },

            isInRadius = common_isInRadius,

            init = function(self, clicks)
                self.tp_cooldown = 1
                self.tp_delay = 0
            end,

            update = function(self, target, dt)
                self.tp_delay = self.tp_delay + dt
                if not target then
                    if self.tp_delay >= self.tp_cooldown then
                        local boundary = self.radius/(2^0.5)
                        self.x, self.y = math.random(boundary, 720-boundary), math.random(boundary, 720-boundary)
                        self.tp_delay = 0
                    end
                    self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                else
                    if self.tp_delay >= self.tp_cooldown then
                        local rngRadius = math.random(50, 100)
                        local rngRad    = math.random()*math.tau
                        self.x = target.x + math.cos(rngRad) * rngRadius
                        self.y = target.y + math.sin(rngRad) * rngRadius
                        self.tp_delay = 0
                    end
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end
            end,

            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end,
        },

        quantum = {
            cost = 0,
            cooldown = 1,

            bullet = {size = 5, speed = 70, damage = 15, type = "basic"},

            isInRadius = function(self, targets)
                local target = nil
                local targetdist = self.radius
                for _, enemy in pairs(targets) do
                    local d = Utils.distanceOO(self, enemy) - enemy.size
                    if d <= targetdist then
                        target = enemy
                        targetdist = d
                    end
                end

                return target
            end,

            init = function(self, clicks)
                self.colour = Utils.HSVA(math.random(0, 359), 0.5, 1, 0.5)
                self.q_towers = {}

                local boundary = self.radius/(2^0.5)
                table.insert(self.q_towers, {x = self.x, y = self.y})
                for _ = 1, 3 do
                    local pos = {
                        x = math.random(boundary, 720-boundary),
                        y = math.random(boundary, 720-boundary)
                    }
                    table.insert(self.q_towers, pos)
                end
            end,

            update = function(self, target, dt)
                self.x = self.x + dt * self.speed * math.cos(self.angle)
                self.y = self.y + dt * self.speed * math.sin(self.angle)

                if not target then
                    self.angle = self.angle + Utils.randomSign() * self.angularspeed * math.random()
                else
                    self.angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end

            end,
            draw = function(self)
                for _, q_tower in pairs(self.q_towers) do
                    love.graphics.setColor(self.colour)
                    love.graphics.circle("fill", q_tower.x, q_tower.y, self.size)
                    love.graphics.setColor(1,1,1,0.5)
                    love.graphics.circle("line", q_tower.x, q_tower.y, self.radius)
                    love.graphics.line(q_tower.x, q_tower.y, q_tower.x+math.cos(self.angle)*self.radius, q_tower.y+math.sin(self.angle)*self.radius)
                end
            end,
        },
    }
}
function Tower.new(x, y, size, radius, speed, ang_speed, type, extra)
    local tower = {
        x = x,
        y = y,
        size = size,
        radius = radius,
        speed = 20,
        colour = {0.1,0.7,0.5,1},
        last_shot = 0,
        angle = math.tau*math.random(),
        speed = speed,
        angularspeed = ang_speed,

        cooldown = Tower.towers[type].cooldown,
        bullet   = Tower.towers[type].bullet,
        
        init        = Tower.towers[type].init,
        isInRadius  = Tower.towers[type].isInRadius,
        update      = Tower.towers[type].update,
        draw        = Tower.towers[type].draw,
        fire        = Tower.fire,
    }

    --For Patrol Tower
    --[[
        home_pos = {x = 0, y = 0},
        patroling_radius = 100,
        isOutside = false,
    --]]

    --For Teeporting Tower
    --[[
        tp_cooldown = 1,
        tp_delay = 0,
    --]]
    tower:init(extra)

    return tower
end
return Tower