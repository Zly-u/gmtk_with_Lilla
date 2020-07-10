--local Bullet = require("bullet")
local Utils = require("utils")

local Tower = {
    fire = function(self, target, dt)
        self.last_shot = self.last_shot + dt
        if target then 
            self.angle = math.atan2(target.x-self.x, target.y-self.y)
            if self.last_shot > self.cooldown then
                self.last_shot = 0
                --return Bullet.new(self.x, self.y, self.angle, self.projectile_params)
            end
        end
        return nil
    end,
    
    cooldowns = {
        1,
    },
    
    updates = {
        function(self, dt)
            local  linearspeed = 10
            local angularspeed = math.pi/8
            self.x = self.x + dt * self.speed * math.cos(self.angle)
            self.angle = Utils.randomSign() * angularspeed
        end,
    },
    
    draw = function(self)
        love.graphics.setColor(self.colour)
        love.graphics.circle("fill", self.x, self.y, self.size)
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.circle("line", self.x, self.y, self.radius)
        love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
    end,
    
    new = function(x, y, size, radius, type, shot)
        local tower = {
            x = x,
            y = y,
            size = size,
            radius = radius,
            colour = {0.1,0.7,0.5,1},
            last_shot = 0,
            cooldown = Tower.cooldowns[type],
            angle = 0,
            projectile_params = shot,
            
            update = Tower.updates[type],
            draw = Tower.draw,
        }
    end
}
return Tower