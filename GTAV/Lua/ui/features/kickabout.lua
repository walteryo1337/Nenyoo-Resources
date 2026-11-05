-- Kickabout. Published fields: active (bool), goals, saves (by the keeper), best (most goals in a round),
-- time_left (seconds), event (1 goal, 2 saved, 3 out of play) + event_age (seconds since it), finished (bool).
features.on_draw("Kickabout", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2

    local t = math.max(0, f.time_left or 0)
    local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
    local w, h = 260 * s, 46 * s
    local x, y = cx - w / 2, sh * 0.05
    draw.rect(x, y, x + w, y + h, 10, 14, 10, 200, 6 * s)
    draw.rect(x, y + h - 3 * s, x + w, y + h, ar, ag, ab, 255, 0)
    local score = string.format("GOALS %d", math.floor(f.goals or 0))
    text.draw(font.hud, x + 12 * s, y + h / 2 - text.height(font.hud) / 2, 245, 245, 250, 255, score)
    local cr, cg, cb = 245, 245, 250
    if t < 15 and not f.finished then cr, cg, cb = 240, 80, 70 end
    text.draw(font.hud, x + w - 12 * s - text.width(font.hud, clock), y + h / 2 - text.height(font.hud) / 2, cr, cg, cb, 255, clock)
    local sub = string.format("SAVES %d   BEST %d", math.floor(f.saves or 0), math.floor(f.best or 0))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, sub) / 2, y + h + 4 * s, 180, 180, 195, 220, sub)

    local age = f.event_age or 99
    local ev = math.floor(f.event or 0)
    if age < 1.8 and ev > 0 then
        local a = math.floor(255 * math.min(1, (1.8 - age) * 2))
        local msg, r, g, b = "GOAL!", ar, ag, ab
        if ev == 2 then msg, r, g, b = "SAVED!", 240, 90, 70
        elseif ev == 3 then msg, r, g, b = "OUT OF PLAY", 200, 200, 210 end
        local pop = 1 + math.max(0, 0.3 - age) * 0.8
        -- A goal in the last seconds is still showing when FULL TIME appears; stack it above.
        local ey = f.finished and sh * 0.3 - text.height(big) - 8 * s or sh * 0.3
        text.draw(big, cx - text.width(big, msg) / 2, ey - (pop - 1) * 20 * s, r, g, b, a, msg)
    end
    if f.finished then
        local msg = "FULL TIME"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 245, 245, 250, 255, msg)
    end
end)
