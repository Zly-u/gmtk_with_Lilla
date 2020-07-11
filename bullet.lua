local Bullet = {
    updates = {
        basic = function(self, dt)
            self.x = self.x+math.cos(self.dir)*self.speed*dt
            self.y = self.y+math.sin(self.dir)*self.speed*dt
        end
    },

    draw = function(self)
        love.graphics.setColor(0, 0, 1, 1)
        love.graphics.circle("fill", self.x, self.y, self.size, 6)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    new = function(x, y, size, dir, speed, damage, _type)
        local bullet = {
            x = x,
            y = y,
            size = size,
            dir = dir,
            speed = speed,

            damage = damage,

            --TODO: maybe, just to not make it travel across the screen idk
            --destX = nil,
            --destY = nil,

            update = Bullet.updates[_type],
            draw = Bullet.draw
        }

        return bullet
    end
}

return Bullet