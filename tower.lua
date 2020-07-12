local Bullet = require("bullet")
local Utils = require("utils")

local function common_isInRadius(self, targets)
    local target = nil
    local targetdist = self.radius
    for _, enemy in pairs(targets) do
        local pos = {x = self.actual_x, y = self.actual_y}
        local d = Utils.distanceOO(pos, enemy) - enemy.size
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
            if self.last_shot > self.cooldown then
                self.anim_delay = self.anim_cooldown
                self.last_shot = 0
                return Bullet.new(self.x, self.y, self.bullet.size, self.angle, self.bullet.speed, self.bullet.damage, self.bullet.type)
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

            init = function(self, _)
                self.actual_angle = math.random()*math.tau
                self.angle = self.actual_angle
                self.angular_speed = math.pi/2

                self.size = 25

                self.turn_cooldown = 0.2 + math.random()*0.8
                self.turn_delay = 0

                self.sprites = {
                    idle = {
                        head = love.graphics.newImage("sprites/stroller_head.png"),
                        body = love.graphics.newImage("sprites/body.png"),
                    },
                    attacking = {
                        head = love.graphics.newImage("sprites/stroller_head_nom.png"),
                        body = love.graphics.newImage("sprites/body.png"),
                    }
                }
            end,

            update = function(self, target, dt)
                self.anim_delay = math.max(self.anim_delay - dt, 0)

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = not target and 0.04 or 0.2
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                --Actual Position
                self.actual_x = self.actual_x+math.cos(self.angle)*self.speed*dt
                self.actual_y = self.actual_y+math.sin(self.angle)*self.speed*dt

                if not target then
                    self.turn_delay = self.turn_delay + dt
                    if self.turn_delay >= self.turn_cooldown then
                        self.actual_angle = self.actual_angle + Utils.randomSign() * self.angular_speed * math.random()
                        self.turn_cooldown = 0.2 + math.random()*0.8
                        self.turn_delay = 0
                    end
                else
                    self.actual_angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end

            end,
            draw = function(self)
                --[[
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.actual_x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
                --]]

                love.graphics.setColor(self.colour)
                local body = self.sprites.idle.body
                local head = self.anim_delay <= 0 and self.sprites.idle.head or self.sprites.attacking.head
                local xs = 1
                if (self.angle % math.tau) < math.pi/2 or (self.angle % math.tau) > math.pi + math.pi/2 then
                    xs = -1
                end

                local ox, oy = 10, 10
                local offX, offY = -14, 11
                love.graphics.draw(body, self.x, self.y, 0, xs, 1, body:getWidth()/2, body:getHeight()/2)
                love.graphics.draw(head, self.x-(body:getWidth()/2.5+offX)*xs, self.y-body:getHeight()/2.5+offY, self.angle+math.pi*((1+xs)/2), xs, 1, head:getWidth()/2+ox, head:getHeight()/2+oy)
            end,
        },

        patrol = {
            cost = 0,
            cooldown = 0.2,

            bullet = {size = 3, speed = 150, damage = 7, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, _)
                self.home_pos = {x = self.x, y = self.y}
                self.patroling_radius = 100
                self.isOutside = false

                self.anim_cooldown = 0.25
                self.anim_delay = 0
                self.sprites = {
                    idle = {
                        head = love.graphics.newImage("sprites/patroller_head.png"),
                        body = love.graphics.newImage("sprites/body.png"),
                    },
                    attacking = {
                        head = love.graphics.newImage("sprites/patroller_head_nom.png"),
                        body = love.graphics.newImage("sprites/body.png"),
                    }
                }
            end,

            update = function(self, target, dt)
                self.anim_delay = math.max(self.anim_delay - dt, 0)

                local smoothingVal = not target and 0.04 or 0.2
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal
                if not target then
                    if not self.isOutside then
                        self.actual_angle = self.actual_angle + Utils.randomSign() * self.angular_speed * math.random()
                    end
                    local d = Utils.distanceOO(self, self.home_pos)
                    if d > self.patroling_radius and not self.isOutside then
                        self.isOutside = true
                    end
                    if self.isOutside then
                        local home_angle = Utils.angleBetweenOO(self, self.home_pos)
                        self.actual_angle = home_angle -- - math.rad(math.random(-30, 30))
                    end
                    if d < self.patroling_radius * 0.8 and self.isOutside then
                        self.isOutside = false
                    end

                    --What it draws and uses to calculate stuff with enemy's pos
                    self.x = self.x + (self.actual_x - self.x) * smoothingVal
                    self.y = self.y + (self.actual_y - self.y) * smoothingVal

                    --Actual Position
                    self.actual_x = self.actual_x+math.cos(self.angle)*self.speed*dt
                    self.actual_y = self.actual_y+math.sin(self.angle)*self.speed*dt
                else
                    self.actual_angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end
            end,

            draw = function(self)
                --[[
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.home_pos.x, self.home_pos.y, self.patroling_radius)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
                --]]

                love.graphics.setColor(1,1,1,1)
                love.graphics.circle("line", self.home_pos.x, self.home_pos.y, self.patroling_radius)

                love.graphics.setColor(self.colour)
                local body = self.sprites.idle.body
                local head = self.anim_delay <= 0 and self.sprites.idle.head or self.sprites.attacking.head
                local xs = 1
                if (self.angle % math.tau) < math.pi/2 or (self.angle % math.tau) > math.pi + math.pi/2 then
                    xs = -1
                end

                local ox, oy = 10, 10
                local offX, offY = -10, 11
                love.graphics.draw(body, self.x, self.y, 0, xs, 1, body:getWidth()/2, body:getHeight()/2)
                love.graphics.draw(head, self.x-(body:getWidth()/2.5+offX)*xs, self.y-body:getHeight()/2.5+offY, self.angle+math.pi*((1+xs)/2), xs, 1, head:getWidth()/2+ox, head:getHeight()/2+oy)

            end
        },

        patrol2p = {
            cost = 0,
            cooldown = 0.2,

            bullet = {size = 3, speed = 150, damage = 7, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, clicks)
                local click = clicks[1]
                self.targetWaypoint = 1
                self.path = {
                    {x = self.x, y = self.y},
                    {x = click.x, y = click.y}
                }

                self.actual_angle = Utils.angleBetweenOO(self.path[1], self.path[2])
                self.angle = self.actual_angle
            end,

            update = function(self, target, dt)
                if not target then
                    local waypoint = {
                        x = self.path[self.targetWaypoint].x,
                        y = self.path[self.targetWaypoint].y
                    }
                    self.actual_angle = Utils.angleBetweenOO(self, waypoint)

                    --What it draws and uses to calculate stuff with enemy's pos
                    local smoothingVal = not target and 0.04 or 0.2
                    self.x = self.x + (self.actual_x - self.x) * smoothingVal
                    self.y = self.y + (self.actual_y - self.y) * smoothingVal
                    self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                    --Actual Position
                    self.actual_x = self.actual_x+math.cos(self.angle)*self.speed*dt
                    self.actual_y = self.actual_y+math.sin(self.angle)*self.speed*dt


                    local d = Utils.distanceOO(self, waypoint)
                    if d < 5 then
                        self.targetWaypoint = (self.targetWaypoint % #self.path) + 1
                    end
                else
                    self.actual_angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end
            end,
            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)

                love.graphics.line(self.path[1].x, self.path[1].y, self.path[2].x, self.path[2].y)
            end,
        },

        static = {
            cost = 0,
            cooldown = 5,

            bullet = {size = 20, speed = 20, damage = 85, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, _)
                self.cooldown = math.random(5)
                self.sleep_max = 2
                self.sleep_current = 0
                self.sleeping = true
                self.colour[4] = 0.5
            end,

            update = function(self, target, dt)
                if not target then
                    --self.angle = self.angle + Utils.randomSign() * self.angular_speed * math.random()
                    if not self.sleeping then
                        self.sleep_current = self.sleep_current + dt/2
                        if self.sleep_current > self.sleep_max then
                            self.colour[4] = 0.5
                            self.sleep_current = 0
                            self.sleeping = true
                        end
                    end
                elseif self.sleeping then
                    self.sleep_current = self.sleep_current + dt
                    if self.sleep_current > self.sleep_max then
                        self.colour[4] = 1
                        self.sleep_current = 0
                        self.sleeping = false
                    end
                else
                    self.actual_angle = Utils.angleBetweenOO(self, target)
                    self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * 0.1
                    local b = self:fire(target, dt)
                    if self.last_shot == 0 then self.cooldown = math.random(5) end
                    return b
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
                costs = {
                    10, 20
                },
                {
                    cooldown = 0.5
                },
                {
                    bullet = {
                        damage = 2
                    }
                },
            },

            isInRadius = common_isInRadius,

            init = function(self, _)
                self.tp_cooldown = 1
                self.tp_delay = 0
            end,

            update = function(self, target, dt)
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * 0.15

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = not target and 0.04 or 0.2
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                self.tp_delay = self.tp_delay + dt
                if not target then
                    if self.tp_delay >= self.tp_cooldown then
                        local boundary = self.radius/(2^0.5)
                        self.actual_x, self.actual_y = math.random(boundary, 720-boundary), math.random(boundary, 720-boundary)
                        self.x, self.y = self.actual_x, self.actual_y
                        self.tp_delay = 0
                    end
                    self.actual_angle = self.actual_angle + Utils.randomSign() * self.angular_speed * math.random()
                else
                    if self.tp_delay >= self.tp_cooldown then
                        local rngRadius = math.random(50, 100)
                        local rngRad    = math.random()*math.tau
                        self.actual_x = target.x + math.cos(rngRad) * rngRadius
                        self.actual_y = target.y + math.sin(rngRad) * rngRadius
                        self.x, self.y = self.actual_x, self.actual_y
                        self.tp_delay = 0
                    end
                    self.actual_angle = Utils.angleBetweenOO(self, target)
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
                local targetList = {}
                for _, q_tower in pairs(self.q_towers) do
                    local target = nil
                    local targetdist = self.radius
                    local pos = {x = q_tower.actual_x, y = q_tower.actual_y}
                    for _, enemy in pairs(targets) do
                        local d = Utils.distanceOO(pos, enemy) - enemy.size
                        if d <= targetdist then
                            target = enemy
                            targetdist = d
                        end
                    end
                    if target then
                        table.insert(targetList, target)
                    end
                end

                return targetList[math.random(#targetList)]
            end,

            init = function(self, clicks)
                self.colour = Utils.HSVA(math.random(0, 359), 0.5, 1, 0.4)
                self.q_towers = {}

                self.switch_cooldown = 1
                self.switch_delay = 0

                table.insert(self.q_towers, {actual_x = self.actual_x, actual_y = self.actual_y})
                for _, pt in ipairs(clicks) do
                    table.insert(self.q_towers, {actual_x = pt.x, actual_y = pt.y})
                end
            end,

            update = function(self, target, dt)
                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = 0.4
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                self.switch_delay = self.switch_delay + dt
                if self.switch_delay >= self.switch_cooldown then
                    local rngActive = self.q_towers[math.random(#self.q_towers)]
                    self.actual_x, self.actual_y = rngActive.actual_x, rngActive.actual_y
                    self.switch_cooldown = 0.2 + math.random()
                    self.switch_delay = 0
                end

                if not target then
                    self.actual_angle = self.actual_angle + Utils.randomSign() * self.angular_speed * math.random()
                else
                    self.actual_angle = Utils.angleBetweenOO(self, target)
                    return self:fire(target, dt)
                end
            end,

            draw = function(self)
                local points = {}
                for _, q_tower in pairs(self.q_towers) do
                    love.graphics.setColor(self.colour)
                    love.graphics.circle("fill", q_tower.actual_x, q_tower.actual_y, self.size)
                    love.graphics.setColor(1,1,1,0.5)
                    love.graphics.circle("line", q_tower.actual_x, q_tower.actual_y, self.radius)
                    love.graphics.line(q_tower.actual_x, q_tower.actual_y, q_tower.actual_x+math.cos(self.angle)*self.radius, q_tower.actual_y+math.sin(self.angle)*self.radius)

                    table.insert(points, q_tower.actual_x)
                    table.insert(points, q_tower.actual_y)
                end

                love.graphics.polygon("line", points)
            end,
        },
        
        little_goblin = {
            cost = 0,
            cooldown = 0.02,

            bullet = {size = 5, speed = 160, damage = 15, type = "basic"},

            isInRadius = common_isInRadius,

            init = function(self, _)
                self.actual_angle = math.random()*math.tau
                self.angle = self.actual_angle
                self.angular_speed = math.pi/2
                self.shake = 0

                self.turn_cooldown = 0.2 + math.random()*0.8
                self.turn_delay = 0
            end,

            update = function(self, target, dt)
                local smoothingVal = not target and 0.04 or 0.2
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal
                
                print(self.actual_angle)
                if not target then
                    self.shake = math.max(0, self.shake - smoothingVal)
                    --What it draws and uses to calculate stuff with enemy's pos
                    self.x = self.x + (self.actual_x - self.x) * smoothingVal + Utils.randomSign()*math.random()*self.shake
                    self.y = self.y + (self.actual_y - self.y) * smoothingVal + Utils.randomSign()*math.random()*self.shake

                    --Actual Position
                    self.actual_x = self.actual_x+math.cos(self.angle)*self.speed*dt
                    self.actual_y = self.actual_y+math.sin(self.angle)*self.speed*dt
                    
                    self.turn_delay = self.turn_delay + dt
                    if self.turn_delay >= self.turn_cooldown then
                        self.actual_angle = self.actual_angle + Utils.randomSign() * self.angular_speed * math.random()
                        self.turn_cooldown = 0.2 + math.random()*0.8
                        self.turn_delay = 0
                    end
                else
                    self.shake = math.min(5, self.shake + smoothingVal)
                    self.x = self.x + (self.actual_x - self.x) * smoothingVal + Utils.randomSign()*math.random()*self.shake
                    self.y = self.y + (self.actual_y - self.y) * smoothingVal + Utils.randomSign()*math.random()*self.shake
                    self.last_shot = self.last_shot + dt

                    if self.last_shot > self.cooldown then
                        self.last_shot = 0
                        return Bullet.new(self.x, self.y,
                                          self.bullet.size,
                                          math.random()*math.tau,
                                          self.bullet.speed*(0.9+0.2*math.random()),
                                          self.bullet.damage,
                                          self.bullet.type
                        )
                    end
                end

            end,
            draw = function(self)
                love.graphics.setColor(self.colour)
                love.graphics.circle("fill", self.x, self.y, self.size)
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.circle("line", self.x, self.y, self.radius)
                love.graphics.line(self.x, self.y, self.actual_x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
            end,
        }
    }
}
function Tower.new(x, y, type, colour, extra)
    local tower = {
        actual_x    = x or 0,
        actual_y    = y or 0,
        actual_angle= 0,

        x       = x or 0,
        y       = y or 0,
        angle   = 0,

        size = 10,
        radius = 100,
        speed = 20,
        colour = colour or {1,1,1,1}, --{0.1,0.7,0.5,1},
        last_shot = 0,
        angular_speed = math.pi/8,

        anim_cooldown = 0.5,
        anim_delay = 0,
        sprites = {
            idle = {
                head = nil,
                body = nil,
            },
            attack = {
                head = nil,
                body = nil,
            },
        },

        cooldown = Tower.towers[type].cooldown,
        bullet   = Tower.towers[type].bullet,
        
        init        = Tower.towers[type].init,
        isInRadius  = Tower.towers[type].isInRadius,
        update      = Tower.towers[type].update,
        draw        = Tower.towers[type].draw,
        fire        = Tower.fire,
    }

    tower:init(extra)

    return tower
end
return Tower