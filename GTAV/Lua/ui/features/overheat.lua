-- Weapon Overheating. Published fields: active (bool, holding an automatic weapon), heat (0..1),
-- venting (bool, overheated and cooling through a forced reload). Drawn as a thin bar under the crosshair.
local shown = 0

features.on_draw("Weapon Overheating", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    local heat = math.max(0, math.min(1, f.heat or 0))
    local want = f.active and (heat > 0.03 or f.venting)
    if want then shown = math.min(1, shown + dt * 8) else shown = math.max(0, shown - dt * 4) end
    if shown <= 0 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local a = shown
    local w = 90 * s
    local h = 4 * s
    local x = sw / 2 - w / 2
    local y = sh / 2 + 34 * s

    local r, g, b
    if f.venting then
        local pulse = 0.7 + 0.3 * math.sin(ctx.time() * 12)
        r, g, b = math.floor(255 * pulse), 60, 40
    elseif heat < 0.5 then
        r, g, b = 120 + math.floor(250 * heat), 220, 120
    elseif heat < 0.8 then
        r, g, b = 245, 200 - math.floor(150 * (heat - 0.5)), 60
    else
        r, g, b = 240, 90, 50
    end

    draw.rect(x - 1 * s, y - 1 * s, x + w + 1 * s, y + h + 1 * s, 0, 0, 0, math.floor(140 * a), 2 * s)
    draw.rect(x, y, x + w * heat, y + h, r, g, b, math.floor(255 * a), 2 * s)
    if f.venting then
        local label = "OVERHEATED"
        text.draw(font.tiny, sw / 2 - text.width(font.tiny, label) / 2, y + h + 4 * s, r, g, b, math.floor(255 * a), label)
    end
end)
