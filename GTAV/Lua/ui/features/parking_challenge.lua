-- Parking Challenge. Published fields: active (bool), state (1 parking, 2 result), time_left (seconds), distance (metres
-- to the bay), lateral / along (metres off-centre sideways and lengthways), angle (degrees off straight), slack (spare
-- length in the bay), settle (0..1 while held still inside), stars (result, 0 = failed), round, total_stars, bumped (bool).
local function gauge(x, y, w, label, value, ok_limit, max_value, s)
    local good = value <= ok_limit
    local frac = math.min(1, value / max_value)
    draw.rect(x, y, x + w, y + 6 * s, 0, 0, 0, 150, 3 * s)
    local okw = w * math.min(1, ok_limit / max_value)
    draw.rect(x, y, x + okw, y + 6 * s, 60, 120, 60, 160, 3 * s)
    local r, g, b = 240, 90, 70
    if good then r, g, b = 90, 230, 110 end
    local mx = x + w * frac
    draw.rect(mx - 2 * s, y - 3 * s, mx + 2 * s, y + 9 * s, r, g, b, 255, 1 * s)
    text.draw(font.hud_tiny, x, y - text.height(font.hud_tiny) - 2 * s, 210, 210, 222, 235, label)
end

features.on_draw("Parking Challenge", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 2 then
        local stars = math.floor(f.stars or 0)
        local msg = stars > 0 and "PARKED" or "OUT OF TIME"
        local r, g, b = 240, 90, 70
        if stars > 0 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if stars > 0 then
            local y = sh * 0.28 + text.height(big) + 14 * s
            for i = 1, 3 do
                local x = cx + (i - 2) * 46 * s
                local lit = i <= stars
                draw.circle(x, y, 16 * s, lit and 255 or 70, lit and 205 or 70, lit and 60 or 80, 255)
            end
            if f.bumped then
                local note = "BUMPED A CAR  -1 STAR"
                text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, note) / 2, y + 26 * s, 240, 150, 90, 240, note)
            end
        end
        return
    end

    local w, h = 260 * s, 150 * s
    local x, y = sw - w - 28 * s, sh * 0.36
    draw.rect(x, y, x + w, y + h, 10, 12, 18, 190, 8 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local t = math.max(0, f.time_left or 0)
    local clock = string.format("%d", math.ceil(t))
    local cr, cg, cb = 245, 245, 250
    if t < 10 then cr, cg, cb = 240, 80, 70 end
    text.draw(font.display, x + w - 12 * s - text.width(font.display, clock), y + 8 * s, cr, cg, cb, 255, clock)
    text.draw(font.hud_small, x + 12 * s, y + 10 * s, 240, 240, 248, 255, string.format("BAY %d", math.floor(f.round or 0)))
    text.draw(font.hud_tiny, x + 12 * s, y + 10 * s + text.height(font.hud_small), 190, 190, 205, 230,
        string.format("%d M   STARS %d", math.floor(f.distance or 0), math.floor(f.total_stars or 0)))

    local gx, gw = x + 12 * s, w - 24 * s
    local gy = y + 62 * s
    gauge(gx, gy, gw, "SIDEWAYS", f.lateral or 0, 0.9, 3.0, s)
    gauge(gx, gy + 30 * s, gw, "LENGTHWAYS", f.along or 0, (f.slack or 1) * 0.5, 6.0, s)
    gauge(gx, gy + 60 * s, gw, "ANGLE", f.angle or 0, 15, 60, s)

    local settle = f.settle or 0
    if settle > 0 then
        draw.rect(x, y + h - 4 * s, x + w * settle, y + h, 90, 230, 110, 255, 0)
    end
end)
