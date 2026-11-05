-- Weapon Wear. Published fields: active (bool), armed (bool, holding a gun that wears), condition (0..1 of that gun),
-- jam_age (seconds since the last jam), jams (session total).
features.on_draw("Weapon Wear", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080

    if f.armed then
        local c = f.condition or 1
        local r, g, b = 90, 220, 110
        local label = "GOOD"
        if c < 0.25 then r, g, b, label = 240, 70, 60, "FILTHY"
        elseif c < 0.5 then r, g, b, label = 240, 150, 60, "WORN"
        elseif c < 0.8 then r, g, b, label = 230, 210, 80, "USED" end
        local w, h = 150 * s, 5 * s
        local x, y = sw - w - 28 * s, sh * 0.88
        local line = string.format("CONDITION %d%%  %s", math.floor(c * 100 + 0.5), label)
        text.draw(font.hud_tiny, x + w - text.width(font.hud_tiny, line), y - text.height(font.hud_tiny) - 3 * s, 225, 225, 235, 235, line)
        draw.rect(x, y, x + w, y + h, 0, 0, 0, 150, 2 * s)
        draw.rect(x + w * (1 - c), y, x + w, y + h, r, g, b, 240, 2 * s)
    end

    local age = f.jam_age or 99
    if age < 1.5 then
        local a = math.floor(255 * math.min(1, (1.5 - age) * 2))
        local big = font.display
        local msg = "JAMMED!"
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.6, 240, 90, 60, a, msg)
    end
end)
