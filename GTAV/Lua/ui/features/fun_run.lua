-- Fun Run. Published fields: active (bool), state (1 countdown, 2 racing, 3 result), countdown (seconds), elapsed
-- (seconds), distance (metres to the finish), position / field (live place out of everyone running), place (final
-- place, 0 = did not finish), time (final seconds), best (fastest finish, missing until one).
local function ordinal(n)
    local suffix = "TH"
    if n % 100 < 11 or n % 100 > 13 then
        if n % 10 == 1 then suffix = "ST" elseif n % 10 == 2 then suffix = "ND" elseif n % 10 == 3 then suffix = "RD" end
    end
    return tostring(n) .. suffix
end

features.on_draw("Fun Run", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "GO"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
        return
    end

    if state == 2 then
        local pos = math.floor(f.position or 1)
        local field = math.floor(f.field or 7)
        local pstr = ordinal(pos)
        local r, g, b = 245, 245, 250
        if pos == 1 then r, g, b = 255, 205, 60 elseif pos <= 3 then r, g, b = ar, ag, ab end
        local x, y = 28 * s, sh * 0.42
        text.draw(big, x, y, r, g, b, 255, pstr)
        text.draw(font.hud_small, x + text.width(big, pstr) + 6 * s, y + text.height(big) - text.height(font.hud_small) - 4 * s, 200, 200, 212, 235, "/ " .. field)
        local t = f.elapsed or 0
        local sub = string.format("%d:%04.1f   %d M TO GO", math.floor(t / 60), t % 60, math.floor(f.distance or 0))
        text.draw(font.hud_small, x, y + text.height(big), 225, 225, 235, 240, sub)
        return
    end

    local place = math.floor(f.place or 0)
    local medals = { "GOLD", "SILVER", "BRONZE" }
    local msg = place == 0 and "DID NOT FINISH" or (medals[place] and (medals[place] .. " - " .. ordinal(place)) or ordinal(place) .. " PLACE")
    local r, g, b = 220, 220, 230
    if place == 1 then r, g, b = 255, 205, 60 elseif place == 2 then r, g, b = 200, 205, 215 elseif place == 3 then r, g, b = 205, 127, 50
    elseif place == 0 then r, g, b = 240, 80, 70 end
    text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
    if place > 0 then
        local sub = string.format("%.1f S", f.time or 0)
        if f.best then sub = sub .. string.format("   BEST %.1f S", f.best) end
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.28 + text.height(big), 235, 235, 245, 255, sub)
    end
end)
