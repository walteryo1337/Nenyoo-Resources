-- Damage Monitor. Published fields: active (bool), engine, body, tank (0..1 health),
-- tyres_burst, tyres_total (cars only; 0 total for other vehicles).
local shown = 0

local function colour(frac)
    if frac < 0.3 then return 235, 70, 70 end
    if frac < 0.65 then return 240, 180, 60 end
    return 120, 220, 140
end

features.on_draw("Damage Monitor", function(f)
    shown = shown + ((f.active and 1 or 0) - shown) * 0.12
    if shown < 0.01 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local a = math.floor(255 * shown)

    local rows = {
        { "ENGINE", f.engine or 1 },
        { "BODY", f.body or 1 },
        { "FUEL TANK", f.tank or 1 },
    }

    local pad = 10 * s
    local lh = text.height(font.hud_tiny) + 12 * s
    local w = 200 * s
    local extra = (f.tyres_total or 0) > 0 and lh or 0
    local h = pad * 2 + lh * #rows + extra
    local x = sw - w - 18 * s
    local y = sh * 0.62

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(150 * shown), 6 * s)

    for i, r in ipairs(rows) do
        local ry = y + pad + (i - 1) * lh
        local frac = r[2]
        local cr, cg, cb = colour(frac)
        text.draw(font.hud_tiny, x + pad, ry, 170, 170, 180, math.floor(230 * shown), r[1])
        local pct = string.format("%d%%", math.floor(frac * 100 + 0.5))
        local pw = text.width(font.hud_tiny, pct)
        text.draw(font.hud_tiny, x + w - pad - pw, ry, cr, cg, cb, a, pct)
        local by = ry + text.height(font.hud_tiny) + 3 * s
        local bw = w - pad * 2
        draw.rect(x + pad, by, x + pad + bw, by + 4 * s, 0, 0, 0, math.floor(140 * shown), 2 * s)
        if frac > 0 then draw.rect(x + pad, by, x + pad + bw * frac, by + 4 * s, cr, cg, cb, a, 2 * s) end
    end

    if extra > 0 then
        local ry = y + pad + #rows * lh
        local burst, total = math.floor(f.tyres_burst or 0), math.floor(f.tyres_total or 0)
        local label = string.format("%d / %d", total - burst, total)
        local cr, cg, cb = 120, 220, 140
        if burst > 0 then cr, cg, cb = 235, 70, 70 end
        text.draw(font.hud_tiny, x + pad, ry, 170, 170, 180, math.floor(230 * shown), "TYRES OK")
        local lw = text.width(font.hud_tiny, label)
        text.draw(font.hud_tiny, x + w - pad - lw, ry, cr, cg, cb, a, label)
    end
end)
