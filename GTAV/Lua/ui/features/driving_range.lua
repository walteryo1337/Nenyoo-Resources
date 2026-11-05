-- Driving Range. Published fields: active (bool), state (1 address the ball, 2 ball in flight, 3 shot result,
-- 4 bucket finished), meter (0..1 swing power; live while addressing, locked after the swing), perfect (meter value
-- for full power), carry / total (metres), peak (metres high), shot_points + shot_green (-1 missed, 0..2 green hit),
-- balls_left, points (this bucket), best (best bucket), state_age (seconds in this state).
features.on_draw("Driving Range", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local state = math.floor(f.state or 0)

    local mw, mh = 18 * s, 220 * s
    local mx, my = sw - 60 * s, sh * 0.5 - mh / 2
    draw.rect(mx, my, mx + mw, my + mh, 10, 12, 18, 200, 4 * s)
    local perfect = f.perfect or 0.92
    draw.rect(mx, my, mx + mw, my + mh * (1 - perfect), 255, 205, 60, 120, 4 * s)
    local m = math.max(0, math.min(1, f.meter or 0))
    local fy = my + mh * (1 - m)
    local r, g, b = ar, ag, ab
    if m >= perfect then r, g, b = 255, 205, 60 end
    draw.rect(mx + 2 * s, fy, mx + mw - 2 * s, my + mh - 2 * s, r, g, b, 230, 3 * s)
    draw.rect(mx - 4 * s, fy - 2 * s, mx + mw + 4 * s, fy + 2 * s, 255, 255, 255, 255, 1 * s)
    text.draw(font.hud_tiny, mx + mw / 2 - text.width(font.hud_tiny, "POWER") / 2, my + mh + 6 * s, 210, 210, 222, 235, "POWER")

    local info = string.format("BALLS %d   POINTS %d   BEST %d", math.floor(f.balls_left or 0), math.floor(f.points or 0), math.floor(f.best or 0))
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, info) / 2, sh * 0.06, 240, 240, 248, 255, info)

    if state == 2 then
        local d = string.format("%d M", math.floor(f.total or 0))
        text.draw(big, sw / 2 - text.width(big, d) / 2, sh * 0.12, 255, 255, 255, 255, d)
    elseif state == 3 then
        local pts = math.floor(f.shot_points or 0)
        local green = math.floor(f.shot_green or -1)
        local labels = { [0] = "GREEN 1", "GREEN 2", "GREEN 3" }
        local msg = pts > 0 and string.format("%s  +%d", labels[green] or "GREEN", pts) or "MISSED THE GREENS"
        local cr, cg, cb = 220, 220, 230
        if pts > 0 then cr, cg, cb = ar, ag, ab end
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.12, cr, cg, cb, 255, msg)
        local sub = string.format("CARRY %d M   TOTAL %d M   PEAK %d M", math.floor(f.carry or 0), math.floor(f.total or 0), math.floor(f.peak or 0))
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, sub) / 2, sh * 0.12 + text.height(big), 210, 210, 222, 240, sub)
        if (f.meter or 0) >= perfect then
            local p = "PERFECT STRIKE"
            text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, p) / 2, sh * 0.12 + text.height(big) + text.height(font.hud_small), 255, 205, 60, 255, p)
        end
    elseif state == 4 then
        local msg = "BUCKET DONE"
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.12, ar, ag, ab, 255, msg)
    end
end)
