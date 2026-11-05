-- Driving Test. Published fields: active (bool), state (1 driving, 2 finished), index / total (checkpoint you are heading
-- for, 0-based, out of total), distance (m to it), points (penalty points so far), fail_at (points that end the test),
-- speed / limit (km/h), cp_time (s left before a lateness penalty), penalty (1 speeding, 2 collision, 3 wheels off the
-- ground, 4 too slow) + penalty_age (ms), passes (tests passed this session), best (fewest penalty points on a pass).
local penalties = { "SPEEDING", "COLLISION", "WHEELS OFF THE ROAD", "TOO SLOW" }

local function grade(points)
    if points < 5 then return "A", 120, 240, 120 end
    if points < 10 then return "B", 200, 230, 110 end
    return "C", 245, 200, 80
end

features.on_draw("Driving Test", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local state = math.floor(f.state or 0)
    local points = math.floor(f.points or 0)
    local fail_at = math.floor(f.fail_at or 15)

    local pw, ph = 320 * s, 132 * s
    local px, py = sw - pw - 30 * s, sh * 0.30
    draw.rect(px, py, px + pw, py + ph, 12, 12, 16, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, ar or 90, ag or 200, ab or 255, 255, 2 * s)
    text.draw(font.hud, px + 16 * s, py + 10 * s, 245, 245, 250, 255, "DRIVING TEST")
    local g, gr, gg, gb = grade(points)
    text.draw(font.display, px + pw - 20 * s - text.width(font.display, g), py + 6 * s, gr, gg, gb, 255, g)

    if state == 1 then
        local cp = string.format("CHECKPOINT %d/%d   %dm", math.floor(f.index or 0) + 1, math.floor(f.total or 8), math.floor(f.distance or 0))
        text.draw(font.hud_small, px + 16 * s, py + 42 * s, 210, 210, 222, 255, cp)
        local speed, limit = math.floor(f.speed or 0), math.floor(f.limit or 80)
        local sr, sg, sb = 210, 210, 222
        if speed > limit then sr, sg, sb = 255, 90, 90 end
        text.draw(font.hud_small, px + 16 * s, py + 64 * s, sr, sg, sb, 255, string.format("%d / %d KM/H", speed, limit))
        local tl = math.floor(f.cp_time or 0)
        local tc = tl < 10 and { 255, 160, 80 } or { 170, 170, 185 }
        local tt = string.format("%ds", tl)
        text.draw(font.hud_small, px + pw - 16 * s - text.width(font.hud_small, tt), py + 64 * s, tc[1], tc[2], tc[3], 255, tt)
    else
        text.draw(font.hud_small, px + 16 * s, py + 42 * s, 210, 210, 222, 255, "TEST OVER")
        local rec = string.format("PASSES %d", math.floor(f.passes or 0))
        if f.best then rec = rec .. string.format("   BEST %d PTS", math.floor(f.best)) end
        text.draw(font.hud_small, px + 16 * s, py + 64 * s, 170, 170, 185, 255, rec)
    end

    local bx1, bx2, by = px + 16 * s, px + pw - 16 * s, py + 98 * s
    draw.rect(bx1, by, bx2, by + 10 * s, 40, 40, 48, 255, 5 * s)
    local frac = math.min(1, points / fail_at)
    if frac > 0 then
        local r, gc = 120 + math.floor(135 * frac), 220 - math.floor(150 * frac)
        draw.rect(bx1, by, bx1 + (bx2 - bx1) * frac, by + 10 * s, r, gc, 90, 255, 5 * s)
    end
    text.draw(font.hud_tiny, bx1, by + 14 * s, 160, 160, 175, 255, string.format("%d / %d PENALTY POINTS", points, fail_at))

    local p = penalties[math.floor(f.penalty or 0)]
    local age = f.penalty_age or 99999
    if p and age < 1600 then
        local a = math.floor(255 * (1 - age / 1600))
        local w = text.width(font.display, p)
        text.draw(font.display, sw / 2 - w / 2, sh * 0.22, 255, 90, 90, a, p)
    end
end)
