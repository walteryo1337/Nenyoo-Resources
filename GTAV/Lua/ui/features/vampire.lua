-- Vampire. Published fields: active (bool), blood (0..1), state (0 normal, 1 empowered at night, 2 burning in
-- sunlight, 3 starving), feed (0..1 progress while feeding, 0 when not feeding).
features.on_draw("Vampire", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local blood = math.max(0, math.min(1, f.blood or 0))
    local state = math.floor(f.state or 0)

    local w, h = 230 * s, 14 * s
    local x0 = sw - w - 40 * s
    local y0 = sh - 210 * s

    local label, lr, lg, lb = "BLOOD", 220, 200, 205
    if state == 1 then label, lr, lg, lb = "NIGHT  -  EMPOWERED", 200, 140, 255
    elseif state == 2 then label, lr, lg, lb = "SUNLIGHT  -  FIND SHADE", 255, 190, 80
    elseif state == 3 then label, lr, lg, lb = "STARVING  -  FEED", 255, 90, 90 end
    text.draw(font.tiny, x0, y0 - 20 * s, lr, lg, lb, 255, label)

    draw.rect(x0 - 3 * s, y0 - 3 * s, x0 + w + 3 * s, y0 + h + 3 * s, 12, 6, 8, 210, 6 * s)
    if blood > 0 then
        local pulse = 1
        if blood < 0.2 then pulse = 0.6 + 0.4 * math.abs(math.sin(t * 5)) end
        local a = math.floor(255 * pulse)
        draw.rect_gradient(x0, y0, x0 + w * blood, y0 + h, 110, 0, 10, a, 210, 20, 40, a, 210, 20, 40, a, 110, 0, 10, a)
    end
    local pct = string.format("%d%%", math.floor(blood * 100 + 0.5))
    text.draw(font.tiny, x0 + w - text.width(font.tiny, pct), y0 - 20 * s, 230, 230, 236, 230, pct)

    if state == 2 then
        local flick = math.floor(60 + 40 * math.abs(math.sin(t * 8)))
        draw.rect_outline(0, 0, sw, sh, 255, 170, 60, flick, 0, 10 * s)
    end

    local feed = f.feed or 0
    if feed > 0 then
        local cx, cy, r = sw / 2, sh / 2 + 80 * s, 26 * s
        draw.circle_outline(cx, cy, r, 60, 10, 15, 200, 5 * s)
        local steps = math.floor(48 * math.min(1, feed))
        for i = 0, steps - 1 do
            local a1 = -math.pi / 2 + (i / 48) * math.pi * 2
            local a2 = -math.pi / 2 + ((i + 1) / 48) * math.pi * 2
            draw.line(cx + math.cos(a1) * r, cy + math.sin(a1) * r, cx + math.cos(a2) * r, cy + math.sin(a2) * r, 220, 20, 40, 255, 5 * s)
        end
        local tx = "FEEDING"
        text.draw(font.tiny, cx - text.width(font.tiny, tx) / 2, cy + r + 8 * s, 235, 200, 205, 255, tx)
    end
end)
