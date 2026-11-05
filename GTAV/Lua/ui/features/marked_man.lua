-- Marked Man. Published fields: active (bool), state (0 waiting for the next squad, 1 being hunted, 2 result), next_in
-- (seconds until the next squad), left / size (hitmen still alive / sent), nearest (metres to the closest hitman),
-- result (1 squad eliminated, 2 they lost you, 3 wasted), pay, streak.
features.on_draw("Marked Man", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local state = math.floor(f.state or 0)
    local t = ctx.time() or 0

    local w, h = 220 * s, 58 * s
    local x, y = sw - w - 30 * s, sh * 0.2
    draw.rect(x, y, x + w, y + h, 14, 10, 10, 200, 6 * s)

    if state == 0 then
        draw.rect(x, y, x + 3 * s, y + h, 150, 40, 40, 255, 0)
        local n = math.max(0, f.next_in or 0)
        text.draw(font.hud_small, x + 14 * s, y + 8 * s, 210, 200, 200, 235, "CONTRACT ACTIVE")
        local sub = n < 15 and "THEY ARE CLOSE" or string.format("NEXT SQUAD ~%d:%02d", math.floor(n / 60), math.floor(n % 60))
        local r, g, b = 245, 245, 250
        if n < 15 then r, g, b = 240, 90, 70 end
        text.draw(font.hud, x + 14 * s, y + 10 * s + text.height(font.hud_small), r, g, b, 255, sub)
        local streak = math.floor(f.streak or 0)
        if streak > 0 then
            local st = "x" .. streak
            text.draw(font.hud_small, x + w - 12 * s - text.width(font.hud_small, st), y + 8 * s, ar, ag, ab, 255, st)
        end
        return
    end

    if state == 1 then
        local pulse = 0.5 + 0.5 * math.sin(t * 6)
        draw.rect(x, y, x + 3 * s, y + h, 235, math.floor(50 + 40 * pulse), 45, 255, 0)
        text.draw(font.hud_small, x + 14 * s, y + 8 * s, 240, 120, 100, 255, "HIT SQUAD")
        local size = math.floor(f.size or 0)
        local left = math.floor(f.left or 0)
        local dot = 7 * s
        for i = 1, size do
            local alive = i <= left
            local r, g, b, a = 235, 60, 50, 255
            if not alive then r, g, b, a = 90, 90, 100, 150 end
            draw.circle(x + 14 * s + dot + (i - 1) * (dot * 2 + 6 * s), y + h - 10 * s - dot, dot, r, g, b, a)
        end
        local d = string.format("%d M", math.floor(f.nearest or 0))
        text.draw(font.hud, x + w - 12 * s - text.width(font.hud, d), y + h - 8 * s - text.height(font.hud), 245, 245, 250, 255, d)
        return
    end

    local result = math.floor(f.result or 0)
    local msgs = { "SQUAD ELIMINATED", "THEY LOST YOU", "WASTED" }
    local msg = msgs[result] or ""
    local r, g, b = 220, 220, 230
    if result == 1 then r, g, b = ar, ag, ab elseif result == 3 then r, g, b = 240, 80, 70 end
    draw.rect(x, y, x + 3 * s, y + h, r, g, b, 255, 0)
    text.draw(font.hud, x + 14 * s, y + 8 * s, r, g, b, 255, msg)
    if (f.pay or 0) > 0 then
        local p = string.format("BOUNTY +$%d", math.floor(f.pay))
        text.draw(font.hud_small, x + 14 * s, y + 10 * s + text.height(font.hud), 235, 235, 245, 255, p)
    end
end)
