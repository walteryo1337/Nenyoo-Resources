-- Air Drop. Published fields: active (bool), state (1 flying to the zone, 2 crate falling, 3 crate scored, 4 finished),
-- done / total (crates dropped), points, distance (metres to the drop zone), altitude (metres above ground),
-- pred_ahead / pred_side (present when a prediction is available: metres the crate would land past (+) or short (-) of
-- the centre, and right (+) or left (-) of it), last_grade (1 bullseye, 2 close, 3 on target, 4 miss), last_miss
-- (metres from the centre), paid.
local grades = {
    { "BULLSEYE", 255, 205, 60 }, { "CLOSE", 120, 230, 120 }, { "ON TARGET", 90, 170, 255 }, { "MISSED", 240, 80, 70 },
}

features.on_draw("Air Drop", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 4 then
        local msg = "DROPS COMPLETE"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, 255, 205, 60, 255, msg)
        local sub = string.format("%d POINTS   +$%d", math.floor(f.points or 0), math.floor(f.paid or 0))
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.26 + text.height(big), 245, 245, 250, 255, sub)
        return
    end

    local w, h = 270 * s, 96 * s
    local x, y = sw - w - 30 * s, sh * 0.32
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 210, 8 * s)
    draw.rect(x, y, x + 3 * s, y + h, 255, 205, 60, 255, 0)
    text.draw(font.hud, x + 14 * s, y + 8 * s, 245, 245, 250, 255,
        string.format("CRATE %d / %d", math.min(math.floor(f.done or 0) + 1, math.floor(f.total or 1)), math.floor(f.total or 1)))
    local lh = text.height(font.hud_small) + 4 * s
    local y2 = y + 14 * s + text.height(font.hud)
    text.draw(font.hud_small, x + 14 * s, y2, 210, 210, 222, 240, string.format("ZONE %d M   ALT %d M", math.floor(f.distance or 0), math.floor(f.altitude or 0)))
    text.draw(font.hud_small, x + 14 * s, y2 + lh, 210, 210, 222, 240, string.format("%d POINTS", math.floor(f.points or 0)))

    if f.pred_ahead then
        -- a small top-down scope: the ring is the drop zone, the dot is where the crate would land
        local r = 70 * s
        local scx, scy = cx, sh * 0.80
        draw.circle(scx, scy, r + 8 * s, 12, 12, 16, 200)
        draw.circle_outline(scx, scy, r, 255, 205, 60, 200, 2 * s)
        draw.circle_outline(scx, scy, r * 0.5, 255, 205, 60, 160, 2 * s)
        draw.circle_outline(scx, scy, r * 0.2, 255, 205, 60, 160, 2 * s)
        local scale = r / 50
        local px = math.max(-r, math.min(r, f.pred_side * scale))
        local py = math.max(-r, math.min(r, -f.pred_ahead * scale))
        local miss = math.sqrt(f.pred_ahead * f.pred_ahead + f.pred_side * f.pred_side)
        local dr, dg, db = 240, 90, 80
        if miss < 10 then dr, dg, db = 120, 230, 120 elseif miss < 50 then dr, dg, db = 255, 205, 60 end
        draw.circle(scx + px, scy + py, 6 * s, dr, dg, db, 255)
        local hint
        if miss < 10 then hint = "DROP NOW  [E]"
        elseif f.pred_ahead < 0 then hint = string.format("%d M SHORT", math.floor(-f.pred_ahead))
        else hint = string.format("%d M LONG", math.floor(f.pred_ahead)) end
        text.draw(font.hud_small, scx - text.width(font.hud_small, hint) / 2, scy + r + 12 * s, dr, dg, db, 255, hint)
    elseif state == 2 then
        local msg = "CRATE AWAY"
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.2, ar, ag, ab, 255, msg)
    end

    if state == 3 then
        local g = grades[math.floor(f.last_grade or 4)] or grades[4]
        text.draw(big, cx - text.width(big, g[1]) / 2, sh * 0.2, g[2], g[3], g[4], 255, g[1])
        local m = string.format("%d M FROM CENTRE", math.floor(f.last_miss or 0))
        text.draw(font.hud, cx - text.width(font.hud, m) / 2, sh * 0.2 + text.height(big), 235, 235, 245, 255, m)
    end
end)
