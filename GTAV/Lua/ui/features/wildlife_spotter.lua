-- Wildlife Spotter. Published fields: active (bool), aiming (bool, an animal is under the crosshair), progress (0..1 hold),
-- species (name, only while aiming at one), known (bool, already logged), count, total,
-- last / last_age / last_new (the most recent log, for about 3 seconds).
features.on_draw("Wildlife Spotter", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx, cy = sw / 2, sh / 2

    local log = string.format("LOG  %d / %d", math.floor(f.count or 0), math.floor(f.total or 0))
    local lw = text.width(font.hud_small, log) + 20 * s
    local lx, ly = sw - lw - 24 * s, sh * 0.22
    draw.rect(lx, ly, lx + lw, ly + 26 * s, 10, 12, 16, 190, 5 * s)
    local frac = (f.total or 0) > 0 and (f.count or 0) / f.total or 0
    draw.rect(lx, ly + 23 * s, lx + lw * frac, ly + 26 * s, ar, ag, ab, 255, 0)
    text.draw(font.hud_small, lx + 10 * s, ly + 13 * s - text.height(font.hud_small) / 2, 235, 235, 245, 255, log)

    if f.aiming and f.species then
        local r = 26 * s
        draw.circle_outline(cx, cy, r, 255, 255, 255, 90, 2 * s)
        local p = f.progress or 0
        if f.known then
            draw.circle_outline(cx, cy, r, 150, 150, 160, 200, 3 * s)
        else
            local segs = 40
            local n = math.floor(segs * p)
            for i = 0, n - 1 do
                local a0 = -math.pi / 2 + (i / segs) * math.pi * 2
                local a1 = -math.pi / 2 + ((i + 1) / segs) * math.pi * 2
                draw.line(cx + math.cos(a0) * r, cy + math.sin(a0) * r, cx + math.cos(a1) * r, cy + math.sin(a1) * r, ar, ag, ab, 255, 4 * s)
            end
        end
        local label = f.species
        if f.known then label = label .. "  (logged)" end
        local tw = text.width(font.hud_small, label)
        local ty = cy + r + 10 * s
        draw.rect(cx - tw / 2 - 8 * s, ty - 3 * s, cx + tw / 2 + 8 * s, ty + text.height(font.hud_small) + 3 * s, 10, 12, 16, 180, 4 * s)
        text.draw(font.hud_small, cx - tw / 2, ty, 240, 240, 248, 255, label)
    end

    local age = f.last_age or 99
    if f.last and age < 3 then
        local a = math.floor(255 * math.min(1, (3 - age) * 1.5))
        local msg = f.last_new and ("NEW: " .. f.last) or (f.last .. " already logged")
        local fnt = font.hud
        local r, g, b = 200, 200, 210
        if f.last_new then r, g, b = ar, ag, ab end
        text.draw(fnt, cx - text.width(fnt, msg) / 2, sh * 0.72, r, g, b, a, msg)
    end
end)
