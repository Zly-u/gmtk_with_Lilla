local Utils = {
    distanceOO = function(objA, objB)
        return ( (objA.x-objB.x)^2 + (objA.y-objB.y)^2 ) ^ 0.5
    end,
    
    distanceXYXY = function(xA, yA, xB, yB)
        return ( (xA-xB)^2 + (yA-yB)^2 ) ^ 0.5
    end,
    
    randomSign = function()
        return math.random(0,1)*2-1
    end,
    
    randomBool = function(pTrue)
        return math.random() < (pTrue or 0.5)
    end,
    
    HSVA = function(h, s, v, a)
        local colour
        h = h or 0
        s = s or 1
        v = v or 1
        a = a or 1
        
        -- find a colour from hue and saturation
        h = (h%360)/60
        local i, f, g, t
        i, f = math.modf(h)
        g = 1-f -- for descending gradients
        t = 1-s -- min colour intensity based on saturation
        f, g = s*f+t, s*g+t -- apply saturation to the gradient values
            if i == 0 then colour = {1, f, t, a}
        elseif i == 1 then colour = {g, 1, t, a}
        elseif i == 2 then colour = {t, 1, f, a}
        elseif i == 3 then colour = {t, g, 1, a}
        elseif i == 4 then colour = {f, t, 1, a}
        elseif i == 5 then colour = {1, t, g, a}
        else colour = {1, 1, 1, a}
        end
        
        for n, c in ipairs(colour) do colour[n] = c*v end
        
        return colour
    end,
}

return Utils