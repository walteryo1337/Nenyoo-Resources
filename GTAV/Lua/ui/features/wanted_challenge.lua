-- Most Wanted. Published fields: active (bool), state (1 running, 2 result), stars (challenge level), wanted (current
-- wanted level), time_left (seconds), result (1 survived, 2 escaped, 3 busted, 4 wasted), pay, streak.
features.on_draw("Most Wanted", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local t = math.max(0, f.time_left or 0)
        local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
        local w, h = 260 * s, 64 * s
        local x, y = cx - w / 2, sh * 0.05
        draw.rect(x, y, x + w, y + h, 14, 10, 10, 200, 6 * s)
        draw.rect(x, y + h - 3 * s, x + w, y + h, 230, 60, 60, 255, 0)
        local stars = math.floor(f.stars or 0)
        local wanted = math.floor(f.wanted or 0)
        local sx = x + 14 * s
        for i = 1, 5 do
            local lit = i <= wanted
            local goal = i <= stars
            local r, g, b, a = 90, 90, 100, 160
            if lit then r, g, b, a = 255, 255, 255, 255 elseif goal then r, g, b, a = 200, 120, 120, 200 end
            draw.circle(sx + (i - 1) * 20 * s, y + 18 * s, 6 * s, r, g, b, a)
        end
        local cr, cg, cb = 245, 245, 250
        if t < 15 then cr, cg, cb = 120, 230, 120 end
        text.draw(font.title, x + w - 14 * s - text.width(font.title, clock), y + 6 * s, cr, cg, cb, 255, clock)
        local sub = "SURVIVE OR LOSE THEM"
        if math.floor(f.streak or 0) > 0 then sub = sub .. string.format("   STREAK %d", math.floor(f.streak)) end
        text.draw(font.tiny, x + 14 * s, y + h - 8 * s - text.height(font.tiny), 210, 200, 200, 235, sub)
        return
    end

    local result = math.floor(f.result or 0)
    local msgs = { "SURVIVED", "ESCAPED", "BUSTED", "WASTED" }
    local msg = msgs[result] or ""
    local r, g, b = 240, 80, 70
    if result == 1 or result == 2 then r, g, b = ar, ag, ab end
    text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
    if (f.pay or 0) > 0 then
        local p = string.format("+$%d", math.floor(f.pay))
        text.draw(font.item, cx - text.width(font.item, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
    end
end)
