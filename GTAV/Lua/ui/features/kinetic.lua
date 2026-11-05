-- Kinetic Absorber. Published fields: active (bool), charge (0..1 of the stored energy capacity), flash (1..0
-- right after a release). Drawn as a segmented arc under the crosshair with the charge percentage.
features.on_draw("Kinetic Absorber", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local charge = math.max(0, math.min(1, f.charge or 0))
    local flash = f.flash or 0
    if charge <= 0.001 and flash <= 0 then return end

    local cx, cy, r = sw / 2, sh / 2, 46 * s
    local segments = 20
    local start, span = math.pi * 0.25, math.pi * 0.5
    local lit = math.floor(segments * charge + 0.5)
    local full = charge >= 0.999
    for i = 0, segments - 1 do
        local a1 = start + span * (i / segments)
        local a2 = start + span * ((i + 0.8) / segments)
        local on = i < lit
        local rr, gg, bb, aa = 60, 60, 80, 140
        if on then
            rr, gg, bb, aa = 255, 150 + math.floor(80 * (i / segments)), 60, 230
            if full then aa = math.floor(170 + 85 * math.abs(math.sin(t * 6))) end
        end
        draw.line(cx + math.cos(a1) * r, cy + math.sin(a1) * r, cx + math.cos(a2) * r, cy + math.sin(a2) * r, rr, gg, bb, aa, 4 * s)
    end
    local label = full and "KINETIC  FULL" or string.format("KINETIC  %d%%", math.floor(charge * 100 + 0.5))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, label) / 2, cy + r + 6 * s, 255, 210, 150, 230, label)
    if flash > 0 then
        draw.circle_outline(cx, cy, r + (1 - flash) * 80 * s, 255, 200, 120, math.floor(255 * flash), 3 * s)
    end
end)
