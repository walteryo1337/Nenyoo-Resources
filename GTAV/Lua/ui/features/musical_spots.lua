-- Musical Spots. Published fields: active (bool), state (1 music playing, 2 scramble, 3 round over, 4 result),
-- players_left (including you), spots (spots this round), you_claimed (bool), camping (bool, you are standing on a spot
-- while the music plays), place (final place, 1 = winner), pay.
features.on_draw("Musical Spots", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)

    if state == 4 then
        local place = math.floor(f.place or 0)
        local msg = place == 1 and "LAST ONE STANDING" or string.format("OUT IN %d%s", place, place == 2 and "ND" or (place == 3 and "RD" or "TH"))
        local r, g, b = 240, 80, 70
        if place == 1 then r, g, b = 255, 205, 60 elseif place <= 3 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if (f.pay or 0) > 0 then
            local p = string.format("+$%d", math.floor(f.pay))
            text.draw(font.item, cx - text.width(font.item, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
        end
        return
    end

    local info = string.format("%d PLAYERS   %d SPOTS", math.floor(f.players_left or 0), math.floor(f.spots or 0))
    text.draw(font.small, cx - text.width(font.small, info) / 2, sh * 0.05, 220, 220, 232, 240, info)

    if state == 1 then
        for i = 0, 2 do
            local bob = math.sin(t * 5 + i * 1.3) * 8 * s
            local nx = cx - 40 * s + i * 40 * s
            local ny = sh * 0.11 + bob
            draw.circle(nx, ny + 16 * s, 8 * s, ar, ag, ab, 255)
            draw.line(nx + 7 * s, ny + 16 * s, nx + 7 * s, ny - 6 * s, ar, ag, ab, 255, 3 * s)
        end
        if f.camping then
            local pulse = 0.5 + 0.5 * math.sin(t * 10)
            local msg = "KEEP MOVING"
            text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.2, 240, 90, 70, math.floor(150 + 105 * pulse), msg)
        end
    elseif state == 2 then
        local msg = f.you_claimed and "SAFE" or "GRAB A SPOT!"
        local r, g, b = 240, 200, 60
        if f.you_claimed then r, g, b = 120, 230, 120 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.14, r, g, b, 255, msg)
    elseif state == 3 then
        local msg = "SOMEONE IS OUT"
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.14, 235, 235, 245, 255, msg)
    end
end)
