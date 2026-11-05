-- Shooting Stats. Published fields: active (bool), shots (rounds fired), hits (people hit), headshots, longest (metres,
-- longest hit), hit_flash (0..1 just after a hit).
features.on_draw("Shooting Stats", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    local shots = math.floor(f.shots or 0)
    local hits = math.floor(f.hits or 0)
    local heads = math.floor(f.headshots or 0)
    local acc = shots > 0 and math.min(100, hits * 100 / shots) or 0
    local hs = hits > 0 and heads * 100 / hits or 0

    local lh = text.height(font.hud_tiny) + 2 * s
    local w = 190 * s
    local h = 24 * s + text.height(font.hud_tiny) + text.height(font.display) + 4 * lh
    local x, y = sw - w - 30 * s, sh * 0.62
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 190, 6 * s)
    local flash = f.hit_flash or 0
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, math.floor(160 + 95 * flash), 0)

    text.draw(font.hud_tiny, x + 14 * s, y + 8 * s, 190, 190, 205, 230, "ACCURACY")
    local pct = string.format("%d%%", math.floor(acc + 0.5))
    local r, g, b = 245, 245, 250
    if shots >= 10 then
        if acc >= 50 then r, g, b = 120, 230, 120 elseif acc < 20 then r, g, b = 240, 120, 90 end
    end
    text.draw(font.display, x + 14 * s, y + 10 * s + text.height(font.hud_tiny), r, g, b, 255, pct)

    local rows = {
        { "SHOTS", tostring(shots) },
        { "HITS", tostring(hits) },
        { "HEADSHOTS", string.format("%d  (%d%%)", heads, math.floor(hs + 0.5)) },
        { "LONGEST", string.format("%d M", math.floor(f.longest or 0)) },
    }
    local ry = y + 14 * s + text.height(font.hud_tiny) + text.height(font.display)
    for i, row in ipairs(rows) do
        local yy = ry + (i - 1) * lh
        text.draw(font.hud_tiny, x + 14 * s, yy, 180, 180, 195, 230, row[1])
        text.draw(font.hud_tiny, x + w - 12 * s - text.width(font.hud_tiny, row[2]), yy, 235, 235, 245, 255, row[2])
    end
end)
