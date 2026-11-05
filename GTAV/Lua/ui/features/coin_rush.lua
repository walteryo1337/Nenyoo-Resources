-- Coin Rush. Published fields: active (bool), state (1 running, 2 result), collected / total, time_left (seconds), combo
-- (current multiplier, 0 = none), combo_left (0..1 time before the combo drops), nearest (metres to the closest coin),
-- nearest_bearing (degrees from the camera, positive = left), cash (earned from coins), bonus (time bonus for clearing
-- them all), best_combo.
features.on_draw("Coin Rush", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local collected = math.floor(f.collected or 0)
    local total = math.floor(f.total or 0)

    if state == 2 then
        local all = collected >= total and total > 0
        local msg = all and "ALL COINS" or "TIME UP"
        local r, g, b = 255, 205, 60
        if not all then r, g, b = 220, 220, 230 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        local y = sh * 0.26 + text.height(big)
        local sub = string.format("%d / %d   +$%d", collected, total, math.floor((f.cash or 0) + (f.bonus or 0)))
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, y, 240, 240, 248, 255, sub)
        y = y + text.height(font.hud)
        local extra = string.format("BEST COMBO x%d", math.floor(f.best_combo or 0))
        if (f.bonus or 0) > 0 then extra = extra .. string.format("   TIME BONUS $%d", math.floor(f.bonus)) end
        text.draw(font.hud_small, cx - text.width(font.hud_small, extra) / 2, y, 200, 200, 212, 240, extra)
        return
    end

    local w, h = 280 * s, 66 * s
    local x, y = cx - w / 2, sh * 0.05
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 200, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 255, 205, 60, 255, 0)
    draw.circle(x + 26 * s, y + h / 2, 13 * s, 255, 205, 60, 255)
    text.draw(font.hud_small, x + 26 * s - text.width(font.hud_small, "$") / 2, y + h / 2 - text.height(font.hud_small) / 2, 120, 80, 10, 255, "$")
    local count = string.format("%d / %d", collected, total)
    text.draw(font.display, x + 48 * s, y + h / 2 - text.height(font.display) / 2, 245, 245, 250, 255, count)
    local tl = math.max(0, f.time_left or 0)
    local clock = string.format("%d:%02d", math.floor(tl / 60), math.floor(tl % 60))
    local cr, cg, cb = 220, 220, 232
    if tl < 20 then cr, cg, cb = 240, 90, 70 end
    text.draw(font.hud, x + w - 14 * s - text.width(font.hud, clock), y + 10 * s, cr, cg, cb, 255, clock)
    local nd = string.format("NEAREST %d M", math.floor(f.nearest or 0))
    text.draw(font.hud_tiny, x + w - 14 * s - text.width(font.hud_tiny, nd), y + h - 8 * s - text.height(font.hud_tiny), 190, 190, 205, 230, nd)

    local combo = math.floor(f.combo or 0)
    if combo > 1 then
        local cstr = "x" .. combo
        local cy = y + h + 8 * s
        text.draw(font.display, cx - text.width(font.display, cstr) / 2, cy, ar, ag, ab, 255, cstr)
        local bw = 80 * s
        local by = cy + text.height(font.display) + 2 * s
        draw.rect(cx - bw / 2, by, cx + bw / 2, by + 4 * s, 255, 255, 255, 30, 2 * s)
        draw.rect(cx - bw / 2, by, cx - bw / 2 + bw * math.max(0, math.min(1, f.combo_left or 0)), by + 4 * s, ar, ag, ab, 240, 2 * s)
    end

    local a = math.rad(f.nearest_bearing or 0)
    local r = 60 * s
    local px, py = cx - math.sin(a) * r, sh * 0.8 - math.cos(a) * r
    if (f.nearest or 0) > 3 then
        draw.circle(px, py, 6 * s, 255, 205, 60, 230)
        draw.line(cx, sh * 0.8, px, py, 255, 205, 60, 90, 2 * s)
    end
end)
