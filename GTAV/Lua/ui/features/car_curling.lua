-- Car Curling. Published fields: active (bool), state (1 run-up, 2 sliding, 3 throw scored, 4 match over), throw,
-- throws, points (last throw), total, distance (metres from the centre of the target), speed (m/s), sweep (1..0
-- right after a sweep).
features.on_draw("Car Curling", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)

    local w, h = 320 * s, 72 * s
    local x0, y0 = sw / 2 - w / 2, 36 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "CAR CURLING")
    local th = string.format("THROW %d/%d", math.floor(f.throw or 1), math.floor(f.throws or 1))
    text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, th), y0 + 12 * s, 190, 190, 205, 230, th)
    local total = string.format("%d PTS", math.floor(f.total or 0))
    text.draw(font.item, x0 + 14 * s, y0 + 36 * s, 255, 230, 120, 255, total)

    local d = f.distance or 0
    if state == 2 and d < 60 then
        local dt = string.format("%.1fm TO CENTRE", d)
        text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, dt), y0 + 44 * s, 170, 210, 255, 240, dt)
    end

    local tx, ty, tr = x0 + w + 46 * s, y0 + h / 2, 30 * s
    local rings = { { 1.0, 60, 110, 255 }, { 0.64, 240, 240, 240 }, { 0.36, 230, 50, 50 }, { 0.14, 240, 240, 240 } }
    for _, r in ipairs(rings) do draw.circle(tx, ty, tr * r[1], r[2], r[3], r[4], 220) end
    if (state == 2 or state == 3) and d < 14 then
        local k = d / 14
        draw.circle(tx, ty - tr * k, 4 * s, 255, 230, 60, 255)
    end

    local msg, r, g, b
    if state == 1 then
        msg, r, g, b = "BUILD SPEED AND CROSS THE RED LINE", 255, 230, 120
    elseif state == 2 then
        msg, r, g, b = "SLIDING  -  TAP E TO SWEEP", 170, 210, 255
    elseif state == 3 then
        local p = math.floor(f.points or 0)
        if p >= 10 then msg, r, g, b = "BULLSEYE!  +10", 130, 255, 160
        elseif p > 0 then msg, r, g, b = string.format("+%d", p), 255, 230, 120
        else msg, r, g, b = "NO SCORE", 255, 110, 110 end
    elseif state == 4 then
        msg, r, g, b = string.format("FINAL SCORE  %d", math.floor(f.total or 0)), 130, 255, 160
    end
    if msg then
        local big = state >= 3
        local fnt = big and font.title or font.tiny
        local a = big and 255 or math.floor(170 + 70 * math.sin(t * 2.5))
        text.draw(fnt, sw / 2 - text.width(fnt, msg) / 2, y0 + h + (big and 30 or 10) * s, r, g, b, a, msg)
    end
    local sweep = f.sweep or 0
    if sweep > 0 then
        local sm = "SWEEP!"
        text.draw(font.item, sw / 2 - text.width(font.item, sm) / 2, sh * 0.62, 200, 230, 255, math.floor(255 * sweep), sm)
    end
end)
