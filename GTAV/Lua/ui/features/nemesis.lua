-- Nemesis. Shown while your nemesis is hunting you. Published fields: active (bool, you have a nemesis), hunting (bool,
-- they are out there right now), level (1-6, how dangerous they are), health (0..1), distance (metres), scarred (bool,
-- they survived you once already), name (their name and title).
features.on_draw("Nemesis", function(f)
    if not f.active or not f.hunting then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 320 * s, 84 * s
    local x0, y0 = sw - 30 * s - w, 120 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 18, 8, 10, 220, 10 * s)
    draw.rect(x0, y0, x0 + 4 * s, y0 + h, 200, 30, 30, 255, 0)
    text.draw(font.tiny, x0 + 16 * s, y0 + 8 * s, 255, 90, 80, math.floor(190 + 60 * math.sin(t * 4)), "NEMESIS")
    local lvl = string.format("LEVEL %d", math.floor(f.level or 1))
    text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, lvl), y0 + 8 * s, 255, 210, 90, 230, lvl)
    text.draw(font.small, x0 + 16 * s, y0 + 26 * s, 245, 235, 235, 255, f.name or "")

    local bx0, bx1, by = x0 + 16 * s, x0 + w - 14 * s, y0 + 58 * s
    draw.rect(bx0, by, bx1, by + 8 * s, 50, 20, 22, 255, 4 * s)
    local k = math.max(0, math.min(1, f.health or 0))
    if k > 0 then draw.rect(bx0, by, bx0 + (bx1 - bx0) * k, by + 8 * s, 220, 40, 40, 255, 4 * s) end
    local dist = string.format("%.0fM", f.distance or 0)
    text.draw(font.tiny, bx1 - text.width(font.tiny, dist), by + 10 * s, 200, 190, 190, 220, dist)
    if f.scarred then text.draw(font.tiny, bx0, by + 10 * s, 200, 160, 160, 220, "SURVIVED YOU BEFORE") end
end)
