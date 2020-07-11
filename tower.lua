local Bullet = require("bullet")
local Utils = require("utils")

local Tower = {
    fire = function(self, target, dt)
        self.last_shot = self.last_shot + dt
        if target then 
            self.angle = math.atan2(target.y-self.y, target.x-self.x)
            if self.last_shot > self.cooldown then
                self.last_shot = 0
                return Bullet.new(self.x, self.y, self.bullet.size, self.angle, self.bullet.speed, self.bullet.damage, self.bullet.type)
            end
        end
        return nil
    end,
    
    cooldowns = {
        1,
    },
    
    updates = {
        function(self, dt)
            local  linearspeed = 20
            local angularspeed = math.pi/8
            self.x = self.x + dt * linearspeed * math.cos(self.angle)
            self.y = self.y + dt * linearspeed * math.sin(self.angle)
            self.angle = self.angle + Utils.randomSign() * angularspeed
        end,
    },
    
    bullets = {
        {size = 5, speed = 70, damage = 15, type = "basic"},
    },
    
    draw = function(self)
        love.graphics.setColor(self.colour)
        love.graphics.circle("fill", self.x, self.y, self.size)
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.circle("line", self.x, self.y, self.radius)
        love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.radius, self.y+math.sin(self.angle)*self.radius)
    end,
}
Tower.new = function(x, y, size, radius, type)
    local tower = {
        x = x,
        y = y,
        size = size,
        radius = radius,
        colour = {0.1,0.7,0.5,1},
        last_shot = 0,
        cooldown = Tower.cooldowns[type],
        angle = 0,
        bullet = Tower.bullets[type],
        
        update = Tower.updates[type],
        draw = Tower.draw,
        fire = Tower.fire,
    }
    return tower
end
return Tower