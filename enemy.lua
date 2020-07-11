local Utils = require("utils")

local Enemy = {
    updates = {
        basic = function(self, path, dt)
            self.x = self.x+math.cos(self.dir)*self.speed*dt
            self.y = self.y+math.sin(self.dir)*self.speed*dt

            local waypointX = path[self.targetWaypoint][1]
            local waypointY = path[self.targetWaypoint][2]

            self.dir = math.atan2(waypointY-self.y, waypointX-self.x)

            local d = Utils.distanceXYXY(self.x, self.y, waypointX, waypointY)
            if d < 5 then
                if self.targetWaypoint < #path then
                    self.targetWaypoint = self.targetWaypoint + 1
                else
                    self.reachedEnd = true
                end
            end
        end
    },

    draw = function(self)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", self.x-self.size/2, self.y-self.size/2, self.size, self.size)
        love.graphics.setColor(1, 1, 1, 1)
    end,
}

function Enemy.new(x, y, size, speed, dir, hp, _type)
    local enemy = {
        x       = x or 0,
        y       = y or 0,
        size    = size or 1,
        speed   = speed or 1,
        dir     = dir or 0,

        hp = hp or 100,
        --dummy money variable
        money = hp * speed,

        targetWaypoint = 1,
        reachedEnd = false,
        --sprite  = {},

        update = Enemy.updates[_type],
        draw = Enemy.draw
    }

    return enemy
end

return Enemy