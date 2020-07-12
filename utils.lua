local function tablePrint(vTable, vTab)
    local tab = vTab or ""
    if type(vTable) ~= "table" then return end

    for i, v in pairs(vTable) do
        print(tab..tostring(i), v)
        if type(v) == "table" and v ~= vTable then
            tablePrint(v, tab.."\t")
        end
    end
end



local Utils = {
    distanceOO = function(objA, objB)
        return ( (objA.x-objB.x)^2 + (objA.y-objB.y)^2 ) ^ 0.5
    end,
    
    distanceXYXY = function(xA, yA, xB, yB)
        return ( (xA-xB)^2 + (yA-yB)^2 ) ^ 0.5
    end,
    
    closestPtOnLn = function(P, L1, L2) -- closest point from P on [L1 L2]
        if not ( P.x and  P.y) then  P.x,  P.y = unpack( P) end
        if not (L1.x and L1.y) then L1.x, L1.y = unpack(L1) end
        if not (L2.x and L2.y) then L2.x, L2.y = unpack(L2) end
        assert ( P.x and  P.y, "bad argument #1 to vectorPtSg (coordinate missing)")
        assert (L1.x and L1.y, "bad argument #2 to vectorPtSg (coordinate missing)")
        assert (L2.x and L2.y, "bad argument #3 to vectorPtSg (coordinate missing)")
        
        local len2 = (L1.x-L2.x)^2 + (L1.y-L2.y)^2
        if len2 == 0 then return L1, P end -- case where L1 == L2
        local l1pX,  l1pY  =  P.x - L1.x,  P.y - L1.y  -- vector L1->P
        local l1l2X, l1l2Y = L2.x - L1.x, L2.y - L1.y  -- vector L1->L2
        local t = math.max(0, math.min(1, (l1pX*l1l2X + l1pY*l1l2Y) / len2)) -- dot product to find projection of P on [L1 L2]
        return {x = L1.x + l1l2X * t, y = L1.y + l1l2Y * t}
    end,
    
    extendLine = function(A, B, newlength) -- returns a new B' so that [A B'] is same direction as [A B] but its length is newlength
        if not (A.x and A.y) then A.x, A.y = unpack(L1) end
        if not (B.x and B.y) then B.x, B.y = unpack(L2) end
        assert (A.x and A.y, "bad argument #1 to extendLine (coordinate missing)")
        assert (B.x and B.y, "bad argument #2 to extendLine (coordinate missing)")
        local lX, lY = B.x - A.x, B.y - A.y  -- vector A->B
        assert(not (lX == 0 and lY == 0), "extendLine: same two points given, cannot get a line to extend") -- there's no line
        local d = (lX^2+lY^2)^0.5 -- curent distance
        local t = newlength/d     -- ratio of lengths which gives the multiple of A->B we want
        return {x = A.x + t*lX, y = A.y + t*lY}
    end,
    
    randomSign = function()
        return math.random(0,1)*2-1
    end,
    
    randomBool = function(pTrue)
        return math.random() < (pTrue or 0.5)
    end,

    angleBetweenOO = function(objA, objB)
        return math.atan2(objB.y-objA.y, objB.x-objA.x)
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
    
    commaValue = function(n) -- credit http://richard.warburton.it
        local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
        return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
    end,

    truncate = function(n, d)
        -- if d is negative, truncate n to -d digits after the decimal point
        -- if d is positive, round n down to a multiple of 10^d (leaving d 0s before the decimal point)
        d = d or 0
        local e = 10^d
        return math.floor(n/e)*e
    end,
    
    tablePrint = tablePrint,
}

return Utils