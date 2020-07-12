local Bullet = {
    bullets = {
        basic = {
            init = function(self)

            end,
            update = function(self, dt)
                self.x = self.x+math.cos(self.dir)*self.speed*dt
                self.y = self.y+math.sin(self.dir)*self.speed*dt
            end,
            draw = function(self)
                love.graphics.setColor(1, 1, 0, 1)
                love.graphics.circle("fill", self.x, self.y, self.size, 6)
                love.graphics.setColor(1, 1, 1, 1)
            end
        }
    },
}

Bullet.new = function(x, y, size, dir, speed, damage, _type)
    local bullet = {
        x = x,
        y = y,
        size = size,
        dir = dir,
        speed = speed,

        damage = damage,

        sprite = nil,

        --TODO: maybe, just to not make it travel across the screen idk
        --destX = nil,
        --destY = nil,

        init    = Bullet.bullets[_type].init,
        update  = Bullet.bullets[_type].update,
        draw    = Bullet.bullets[_type].draw
    }

    bullet:init()
    return bullet
end

return Bullet