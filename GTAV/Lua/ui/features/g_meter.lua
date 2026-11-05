-- G-Force Meter. Published fields: active (bool), lat (g, + = turning right), lon (g, + = accelerating,
-- - = braking), peak_lat, peak_brake, peak_accel. The dot shows the force the driver feels: it is pushed
-- outward in corners, back under acceleration and forward under braking.
local shown = 0
local trail = {}
local trail_t = 0
local full_scale = 2.0

features.on_draw("G-Force Meter", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 5) else shown = math.max(0, shown - dt * 5) end
    if shown <= 0 then
        trail = {}
        return
    end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local a = shown
    local radius = 62 * s
    local pad = 10 * s
    local cx = sw - radius - 60 * s
    local cy = sh * 0.60

    local lat, lon = f.lat or 0, f.lon or 0
    local function plot(gx, gy)
        local px, py = -gx / full_scale, gy / full_scale
        local len = math.sqrt(px * px + py * py)
        if len > 1 then px, py = px / len, py / len end
        return cx + px * radius, cy + py * radius
    end

    trail_t = trail_t + dt
    if f.active and trail_t >= 0.05 then
        trail_t = 0
        table.insert(trail, 1, { lat, lon })
        if #trail > 24 then table.remove(trail) end
    end

    local th = text.height(font.hud_tiny)
    local peaks = string.format("LAT %.1f  BRK %.1f  ACC %.1f", f.peak_lat or 0, f.peak_brake or 0, f.peak_accel or 0)
    local half = math.max(radius + pad, text.width(font.hud_tiny, peaks) / 2 + pad)
    draw.rect(cx - half, cy - radius - pad, cx + half, cy + radius + pad + th * 2 + 6 * s, 10, 10, 16, math.floor(150 * a), 8 * s)
    draw.circle(cx, cy, radius, 0, 0, 0, math.floor(90 * a))
    for i = 1, 3 do
        draw.circle_outline(cx, cy, radius * (i * 0.5) / full_scale, 255, 255, 255, math.floor(40 * a), 1)
    end
    draw.circle_outline(cx, cy, radius, 255, 255, 255, math.floor(90 * a), 1.2)
    draw.line(cx - radius, cy, cx + radius, cy, 255, 255, 255, math.floor(35 * a), 1)
    draw.line(cx, cy - radius, cx, cy + radius, 255, 255, 255, math.floor(35 * a), 1)

    for i = #trail, 1, -1 do
        local tx, ty = plot(trail[i][1], trail[i][2])
        local fade = 1 - (i - 1) / #trail
        draw.circle(tx, ty, 2.2 * s, ar, ag, ab, math.floor(110 * fade * a))
    end
    local dx, dy = plot(lat, lon)
    draw.circle(dx, dy, 5 * s, ar, ag, ab, math.floor(255 * a))
    draw.circle_outline(dx, dy, 7 * s, 255, 255, 255, math.floor(160 * a), 1.2)

    local total = math.sqrt(lat * lat + lon * lon)
    local big = string.format("%.2f G", total)
    local ty = cy + radius + 4 * s
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, big) / 2, ty, 245, 245, 250, math.floor(255 * a), big)
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, peaks) / 2, ty + th + 2 * s, 180, 180, 195, math.floor(220 * a), peaks)
end)
