-- Cooked Grenades. Published fields: active (bool, a frag grenade is being held past a quick tap),
-- left (seconds of fuse remaining), fraction (0 to 1, how much of the fuse has burned).
-- Drawn as a fuse ring just under the crosshair that turns red as it runs out.
features.on_draw("Cooked Grenades", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2 + 70 * s
    local radius = 22 * s
    local frac = math.max(0, math.min(1, f.fraction or 0))
    local left = f.left or 0

    local r, g, b = 255, 210, 80
    if frac > 0.75 then
        if math.floor((ctx.time() or 0) * 8) % 2 == 0 then r, g, b = 240, 60, 50 else r, g, b = 255, 140, 60 end
    elseif frac > 0.5 then
        r, g, b = 255, 150, 60
    end

    draw.circle(cx, cy, radius + 4 * s, 10, 10, 14, 170)
    draw.circle_outline(cx, cy, radius, 70, 70, 80, 220, 3 * s)
    local steps = 40
    local burned = math.floor(steps * (1 - frac) + 0.5)
    for i = 0, burned - 1 do
        local a1 = -math.pi / 2 + i / steps * math.pi * 2
        local a2 = -math.pi / 2 + (i + 1) / steps * math.pi * 2
        draw.line(cx + math.cos(a1) * radius, cy + math.sin(a1) * radius, cx + math.cos(a2) * radius, cy + math.sin(a2) * radius, r, g, b, 255, 4 * s)
    end

    local label = string.format("%.1f", left)
    text.draw(font.small, cx - text.width(font.small, label) / 2, cy - text.height(font.small) / 2, 245, 245, 250, 255, label)
    local hint = "RELEASE TO THROW"
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, cy + radius + 8 * s, 220, 220, 230, 220, hint)
end)
