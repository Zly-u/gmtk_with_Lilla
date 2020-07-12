local Utils = require("utils")

local Enemy = {
    enemies = {
        basic = {
            init = function(self)
                self.money = self.hp/2 * self.speed/3 + math.random()*200
            end,

            update = function(self, path, dt)
                local waypoint = {
                    x = path[self.targetWaypoint][1],
                    y = path[self.targetWaypoint][2]
                }

                self.actual_angle = Utils.angleBetweenOO(self, waypoint)

                --Actual Position
                self.actual_x = self.actual_x+math.cos(self.angle)*self.speed*dt
                self.actual_y = self.actual_y+math.sin(self.angle)*self.speed*dt

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = 0.08
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                local d = Utils.distanceXYXY(self.x, self.y, waypoint.x, waypoint.y)
                if d < 15 then
                    if self.targetWaypoint < #path then
                        self.targetWaypoint = self.targetWaypoint + 1
                    else
                        self.reachedEnd = true
                    end
                end
            end,
            draw = function(self)
                --[[
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle("fill", self.x-self.size/2, self.y-self.size/2, self.size, self.size)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(self.x, self.y, self.x + math.cos(self.angle)*self.size*1.3, self.y + math.sin(self.angle)*self.size*1.3)
                love.graphics.setColor(1, 1, 1, 1)
                --]]
                local size = self.size/35
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.draw(self.sprite, self.x, self.y, 0, size, size, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
            end
        },

        drunk = {
            init = function(self)
                self.isOffWay = false
                self.offWayDelay = 0
                self.offWayCooldown = 1

                self.money = self.hp/2 * self.speed + math.random()*400
            end,

            update = function(self, path, dt)
                self.offWayDelay = self.offWayDelay + dt
                if self.offWayDelay >= self.offWayCooldown then
                    self.offWayCooldown = 0.1 + math.random()*3

                    self.isOffWay = not self.isOffWay
                    if self.isOffWay then
                        local goOff = Utils.randomBool(0.34)
                        self.actual_angle =  self.actual_angle + math.random()*(math.pi/((not goOff) and 3 or 1.5))*Utils.randomSign()

                    end

                    self.offWayDelay = 0
                end
                local waypoint = {
                    x = path[self.targetWaypoint][1],
                    y = path[self.targetWaypoint][2]
                }
                if not self.isOffWay then
                    self.actual_angle = Utils.angleBetweenOO(self, waypoint)
                end

                --Actual Position
                self.actual_x = self.actual_x+math.cos(self.actual_angle)*self.speed*dt
                self.actual_y = self.actual_y+math.sin(self.actual_angle)*self.speed*dt

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = 0.08
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                local d = Utils.distanceXYXY(self.x, self.y, waypoint.x, waypoint.y)
                if d < 40 then
                    if self.targetWaypoint < #path then
                        self.targetWaypoint = self.targetWaypoint + 1
                    else
                        self.reachedEnd = true
                    end
                end
            end,
            draw = function(self)
                --[[
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("fill", self.x, self.y, self.size, 3)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(self.x, self.y, self.x + math.cos(self.angle)*self.size*1.3, self.y + math.sin(self.angle)*self.size*1.3)
                love.graphics.setColor(1, 1, 1, 1)
                --]]

                local size = self.size/35
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.draw(self.sprite, self.x, self.y, 0, size, size, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
            end
        },

        wandering = {
            init = function(self)
                self.isOffWay = false
                self.offWayDelay = 0
                self.offWayCooldown = 1

                self.money = self.hp/1.5 * self.speed + math.random()*600
            end,

            update = function(self, path, dt)
                local oob = 720 * 0.1
                if self.x <= -oob or self.y <= -oob or
                   self.x >= 720+oob or self.y >= 720+oob then
                    self.actual_angle = Utils.angleBetweenOO(self, {x = 360, y = 360})
                end


                self.offWayDelay = self.offWayDelay + dt
                if self.offWayDelay >= self.offWayCooldown then
                    self.offWayCooldown = 0.1 + math.random()*3


                    self.isOffWay = Utils.randomBool(0.8)

                    if self.isOffWay then
                        local goOff = Utils.randomBool(0.4)
                        self.actual_angle = self.actual_angle + math.random()*(math.pi/((not goOff) and 2 or 1))*Utils.randomSign()
                    end

                    self.offWayDelay = 0
                end

                local waypoint = {
                    x = path[#path][1],
                    y = path[#path][2]
                }

                if not self.isOffWay then
                    self.actual_angle = Utils.angleBetweenOO(self, waypoint)
                end

                --Actual Position
                self.actual_x = self.actual_x+math.cos(self.actual_angle)*self.speed*dt
                self.actual_y = self.actual_y+math.sin(self.actual_angle)*self.speed*dt

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = 0.04
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                local d = Utils.distanceXYXY(self.x, self.y, waypoint.x, waypoint.y)
                if d < 15 then
                    if self.targetWaypoint < #path then
                        self.targetWaypoint = self.targetWaypoint + 1
                    else
                        self.reachedEnd = true
                    end
                end
            end,
            draw = function(self)
                --[[
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("fill", self.x, self.y, self.size, 5)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(self.x, self.y, self.x + math.cos(self.angle)*self.size*1.3, self.y + math.sin(self.angle)*self.size*1.3)
                love.graphics.setColor(1, 1, 1, 1)
                --]]

                local size = self.size/35
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.draw(self.sprite, self.x, self.y, 0, size, size, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
            end
        },

        funky = {
            init = function(self)
                self.timer = 0
                self.funkAmp = 3+math.random()*80
                self.funkFreq = 300+math.random()*300

                self.speedAmp = 3+math.random()*(self.speed/1.2)
                self.speedFreq = 300+math.random()*400

                self._speed = self.speed
                self.money = self.hp/2 * self.speed/2 + math.random()*600
            end,

            update = function(self, path, dt)
                local waypoint = {
                    x = path[self.targetWaypoint][1],
                    y = path[self.targetWaypoint][2]
                }

                self.timer = self.timer+dt
                self.actual_angle = Utils.angleBetweenOO(self, waypoint)+math.rad(math.sin(math.rad(self.timer*self.funkFreq)) * self.funkAmp)
                self.speed = self._speed + math.sin(math.rad(self.timer*self.speedFreq)) * self.speedAmp

                --Actual Position
                self.actual_x = self.actual_x+math.cos(self.actual_angle)*self.speed*dt
                self.actual_y = self.actual_y+math.sin(self.actual_angle)*self.speed*dt

                --What it draws and uses to calculate stuff with enemy's pos
                local smoothingVal = 0.08
                self.x = self.x + (self.actual_x - self.x) * smoothingVal
                self.y = self.y + (self.actual_y - self.y) * smoothingVal
                self.angle = self.angle + Utils.angleDifference(self.actual_angle, self.angle) * smoothingVal

                local d = Utils.distanceXYXY(self.x, self.y, waypoint.x, waypoint.y)
                if d < 25 then
                    if self.targetWaypoint < #path then
                        self.targetWaypoint = self.targetWaypoint + 1
                    else
                        self.reachedEnd = true
                    end
                end
            end,
            draw = function(self)
                --[[
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle("fill", self.x-self.size/2, self.y-self.size/2, self.size, self.size)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(self.x, self.y, self.x + math.cos(self.angle)*self.size*1.3, self.y + math.sin(self.angle)*self.size*1.3)
                love.graphics.setColor(1, 1, 1, 1)
                --]]

                local size = self.size/35
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.draw(self.sprite, self.x, self.y, 0, size, size, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
            end
        },
    },
}

function Enemy.new(x, y, size, speed, actual_angle, hp, _type)
    local enemy = {
        actual_x    = x or 0,
        actual_y    = y or 0,
        actual_angle= actual_angle or 0,

        x       = x or 0,
        y       = y or 0,
        angle   = actual_angle or 0,

        size    = size or 1,
        speed   = speed or 1,

        hp      = hp or 100,

        sprite = love.graphics.newImage("sprites/eye.png"),
        targetWaypoint  = 1,
        reachedEnd      = false,

        init    = Enemy.enemies[_type].init,
        update  = Enemy.enemies[_type].update,
        draw    = Enemy.enemies[_type].draw
    }

    enemy:init()
    return enemy
end

return Enemy