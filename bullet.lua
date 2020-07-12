local Bullet = {
    bullets = {
        basic = {
            init = function(self)

            end,
            update = function(self, dt)
                self.angle = self.angle + ((self.speed/3)*dt)

                self.x = self.x+math.cos(self.dir)*self.speed*dt
                self.y = self.y+math.sin(self.dir)*self.speed*dt
            end,
            draw = function(self)
                --[[
                love.graphics.setColor(1, 1, 0, 1)
                love.graphics.circle("fill", self.x, self.y, self.size, 6)
                love.graphics.setColor(1, 1, 1, 1)
                --]]


                local sprite = self.sprite
                love.graphics.draw(sprite, self.x, self.y, self.angle, (self.size)/10, (self.size)/10, sprite:getWidth()/2, sprite:getHeight()/2)

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

        angle = 0,
        sprite = love.graphics.newImage("sprites/fireball.png"),

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