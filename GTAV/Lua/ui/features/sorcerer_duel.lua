-- Sorcerer Duel. Published fields: active (bool), state (1 fighting, 2 won, 3 lost), health (0..1 of the
-- sorcerer's health), warning (bool, a lightning strike is about to land where you stood), title (difficulty
-- name, e.g. "Archmage").
features.on_draw("Sorcerer Duel", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)
    local hp = math.max(0, math.min(1, f.health or 0))

    local w, h = 620 * s, 16 * s
    local x0, y0 = sw / 2 - w / 2, 70 * s
    local title = string.upper(f.title or "Sorcerer")
    text.draw(font.small, sw / 2 - text.width(font.small, title) / 2, y0 - 30 * s, 220, 180, 255, 255, title)
    draw.rect(x0 - 3 * s, y0 - 3 * s, x0 + w + 3 * s, y0 + h + 3 * s, 14, 8, 22, 220, 6 * s)
    if hp > 0 then
        local enraged = hp < 0.35 and state == 1
        local a = enraged and math.floor(190 + 65 * math.abs(math.sin(t * 6))) or 255
        local r1, g1, b1 = 120, 60, 220
        local r2, g2, b2 = 200, 120, 255
        if enraged then r1, g1, b1, r2, g2, b2 = 200, 40, 90, 255, 90, 140 end
        draw.rect_gradient(x0, y0, x0 + w * hp, y0 + h, r1, g1, b1, a, r2, g2, b2, a, r2, g2, b2, a, r1, g1, b1, a)
    end
    for i = 1, 3 do
        local mx = x0 + w * (i / 4)
        draw.line(mx, y0, mx, y0 + h, 0, 0, 0, 90, 1 * s)
    end

    if f.warning and state == 1 then
        local msg = "LIGHTNING  -  MOVE!"
        local pulse = math.floor(160 + 95 * math.abs(math.sin(t * 10)))
        text.draw(font.item, sw / 2 - text.width(font.item, msg) / 2, y0 + h + 14 * s, 255, 230, 120, pulse, msg)
    end
    if state == 2 or state == 3 then
        local msg = state == 2 and "SORCERER DEFEATED" or "YOU WERE BESTED"
        local r, g, b = 150, 255, 170
        if state == 3 then r, g, b = 255, 110, 110 end
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.32, r, g, b, 255, msg)
    end
end)
