-- Health Readout. Published fields: active (bool), health, max_health (hit points above the death
-- threshold), armor, max_armor. Drawn just above the minimap's health and armour bars.
local function colour(frac)
    if frac < 0.25 then return 235, 70, 70 end
    if frac < 0.5 then return 240, 180, 60 end
    return 120, 220, 140
end

features.on_draw("Health Readout", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local hp, hp_max = math.floor(f.health or 0), math.max(1, math.floor(f.max_health or 1))
    local ar, ar_max = math.floor(f.armor or 0), math.max(1, math.floor(f.max_armor or 100))

    local hp_text = string.format("HP %d / %d", hp, hp_max)
    local ar_text = string.format("ARMOR %d / %d", ar, ar_max)

    local x = 28 * s
    local y = sh - 252 * s
    local pad = 6 * s
    local gap = 14 * s
    local hw = text.width(font.tiny, hp_text)
    local aw = text.width(font.tiny, ar_text)
    local h = text.height(font.tiny) + pad * 2
    local w = hw + gap + aw + pad * 2

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 150, 4 * s)
    local r, g, b = colour(hp / hp_max)
    text.draw(font.tiny, x + pad, y + pad, r, g, b, 255, hp_text)
    text.draw(font.tiny, x + pad + hw + gap, y + pad, 90, 170, 255, 255, ar_text)
end)
