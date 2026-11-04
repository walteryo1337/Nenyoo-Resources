-- Rage Meter. Published fields: active (bool), rage (0-100; while berserk it is the time left), ready (bool, full and
-- waiting for E), berserk (bool), berserk_left / berserk_ms (ms left / full length), kills (this session),
-- berserk_kills (during the current or last berserk), kill_age (ms since your last kill).
features.on_draw("Rage Meter", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local rage = math.max(0, math.min(100, f.rage or 0)) / 100

    if f.berserk then
        local pulse = 0.6 + 0.4 * math.abs(math.sin(t * 5))
        local a = math.floor(110 * pulse)
        local e = 160 * s
        draw.rect_gradient(0, 0, sw, e, 200, 0, 0, a, 200, 0, 0, a, 200, 0, 0, 0, 200, 0, 0, 0)
        draw.rect_gradient(0, sh - e, sw, sh, 200, 0, 0, 0, 200, 0, 0, 0, 200, 0, 0, a, 200, 0, 0, a)
        draw.rect_gradient(0, 0, e, sh, 200, 0, 0, a, 200, 0, 0, 0, 200, 0, 0, 0, 200, 0, 0, a)
        draw.rect_gradient(sw - e, 0, sw, sh, 200, 0, 0, 0, 200, 0, 0, a, 200, 0, 0, a, 200, 0, 0, 0)
    end

    local bw, bh = 360 * s, 14 * s
    local x = sw / 2 - bw / 2
    local y = sh - 120 * s
    draw.rect(x - 10 * s, y - 34 * s, x + bw + 10 * s, y + bh + 10 * s, 10, 8, 8, 190, 8 * s)
    draw.rect(x, y, x + bw, y + bh, 40, 26, 26, 255, 7 * s)
    local r, g, b = 220, 60 + math.floor(110 * (1 - rage)), 40
    if f.ready or f.berserk then
        local p = math.abs(math.sin(t * 6))
        r, g, b = 255, math.floor(30 + 60 * p), math.floor(20 + 30 * p)
    end
    if rage > 0 then draw.rect(x, y, x + bw * rage, y + bh, r, g, b, 255, 7 * s) end
    for k = 1, 3 do
        local tx = x + bw * k / 4
        draw.rect(tx - 1, y + 2 * s, tx + 1, y + bh - 2 * s, 0, 0, 0, 120, 0)
    end

    local label, lr, lg, lb = "RAGE", 230, 200, 200
    if f.berserk then
        label, lr, lg, lb = string.format("BERSERK  %.1fs", (f.berserk_left or 0) / 1000), 255, 80, 60
    elseif f.ready then
        label, lr, lg, lb = "PRESS E TO GO BERSERK", 255, 90, 60
        if math.floor(t * 3) % 2 == 1 then lg, lb = 200, 160 end
    end
    text.draw(font.small, x, y - 26 * s, lr, lg, lb, 255, label)
    local kills = string.format("KILLS %d", math.floor(f.berserk and (f.berserk_kills or 0) or (f.kills or 0)))
    text.draw(font.small, x + bw - text.width(font.small, kills), y - 26 * s, 230, 200, 200, 255, kills)
    local age = f.kill_age or 999999
    if age < 900 then
        local u = age / 900
        local plus = f.berserk and "+1s" or "+RAGE"
        text.draw(font.small, x + bw + 18 * s, y - 4 * s - u * 20 * s, 255, 110, 80, math.floor(255 * (1 - u)), plus)
    end
end)
