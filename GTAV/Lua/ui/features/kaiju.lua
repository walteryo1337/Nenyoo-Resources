-- Kaiju Attack. A boss health bar while the monster is out. Published fields: active (bool), down (bool, it has been
-- beaten), name (which monster), hp (1..0), distance (metres away), hit (bool, it was just hurt).
features.on_draw("Kaiju Attack", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    local w = 620 * s
    local x0, y0 = cx - w / 2, 46 * s
    local name = string.upper(f.name or "")
    text.draw(font.small, cx - text.width(font.small, name) / 2, y0, 255, 220, 200, 255, name)
    local by = y0 + 30 * s
    draw.rect(x0 - 3 * s, by - 3 * s, x0 + w + 3 * s, by + 17 * s, 10, 6, 6, 230, 4 * s)
    local k = math.max(0, math.min(1, f.hp or 0))
    local r, g, b = 210, 40, 40
    if f.hit then r, g, b = 255, 230, 230 end
    if k > 0 then draw.rect(x0, by, x0 + w * k, by + 14 * s, r, g, b, 255, 3 * s) end
    if f.down then
        local msg = "MONSTER DOWN"
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, 255, 220, 90, 255, msg)
    else
        local dist = string.format("%.0fM AWAY", f.distance or 0)
        text.draw(font.tiny, cx - text.width(font.tiny, dist) / 2, by + 22 * s, 220, 200, 200, 220, dist)
    end
end)
