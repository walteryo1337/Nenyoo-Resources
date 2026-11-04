-- Slow Motion Dive energy meter. Shown on foot with a gun while Energy Meter is on. Published fields: active (bool);
-- energy (0-100); cost (energy one dive with the held gun takes); low (bool, not enough energy to dive).
features.on_draw("Slow Motion Dive", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local w, h = 14 * s, 132 * s
    local x0 = sw * 0.172
    local y0 = sh * 0.835
    local k = math.max(0, math.min(1, (f.energy or 0) / 100))
    local cost_k = math.max(0, math.min(1, (f.cost or 0) / 100))

    draw.rect(x0 - 3 * s, y0 - 3 * s, x0 + w + 3 * s, y0 + h + 3 * s, 0, 0, 0, 150, 6 * s)
    local fill = h * k
    local r, g, b = 235, 200, 120
    if f.low then r, g, b = 230, 60, 50 end
    if fill > 0 then draw.rect(x0, y0 + h - fill, x0 + w, y0 + h, r, g, b, 230, 4 * s) end
    local ty = y0 + h - h * cost_k
    draw.rect(x0 - 3 * s, ty - 1 * s, x0 + w + 3 * s, ty + 1 * s, 255, 255, 255, 170, 0)
end)
