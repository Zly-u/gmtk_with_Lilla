local Enemy = {
    updates = {
        basic = function(self, path, dt)
            self.x = self.x+math.cos(self.dir)*self.speed*dt
            self.y = self.y+math.sin(self.dir)*self.speed*dt

            local waypointX = path[self.targetWaypoint][1]
            local waypointY = path[self.targetWaypoint][2]

            self.dir = math.atan2(waypointY-self.y, waypointX-self.x)

            if (self.x-waypointX)^2+(self.y-waypointY)^2 < 25 then
                if not self.targetWaypoint == #path-1 then
                    self.targetWaypoint = self.targetWaypoint + 1
                else
                    self.isReached = true
                end
            end
        end
    },

    draw = function(self)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", self.x-self.size/2, self.y-self.size/2, self.size, self.size)
        love.graphics.setColor(1, 1, 1, 1)
    end,


    new = function(x, y, size, speed, dir, hp, _type)
        local enemy = {
            x       = x or 0,
            y       = y or 0,
            size    = size or 1,
            speed   = speed or 1,
            dir     = dir or 0,

            hp = hp or 100,

            targetWaypoint = 1,
            isReached = false,
            --sprite  = {},

            update = Enemy.updates[_type],
            draw = Enemy.draw
        }

        return enemy
    end
}

return Enemy