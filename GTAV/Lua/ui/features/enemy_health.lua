-- Enemy Health Bars. Published fields: active (bool), bars (string blob of
-- "x,y,health,armour,distance,flags;" entries; x/y are 0..1 screen coords above the head, health and
-- armour 0..1, distance in metres, flags bit 1 = the ped you are aiming at, bit 2 = hostile to you).
features.on_draw("Enemy Health Bars", function(f)
    if not f.active or not f.bars then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()

    for xs, ys, hs, as, ds, fs in string.gmatch(f.bars, "([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^;]+);") do
        local x, y = tonumber(xs) * sw, tonumber(ys) * sh
        local hp, armour, dist = tonumber(hs), tonumber(as), tonumber(ds)
        local flags = tonumber(fs)
        local aimed = flags % 2 == 1
        local hostile = math.floor(flags / 2) % 2 == 1

        local scale = math.max(0.55, math.min(1.0, 18 / math.max(dist, 1)))
        local w = 64 * s * scale
        local h = 6 * s * scale
        local alpha = aimed and 255 or math.floor(math.max(110, 230 - dist * 2.5))
        local left = x - w / 2

        draw.rect(left - 1, y - 1, left + w + 1, y + h + 1, 0, 0, 0, math.floor(alpha * 0.75), 2 * s)
        local r = math.floor(255 * math.min(1, 2 * (1 - hp)))
        local g = math.floor(220 * math.min(1, 2 * hp))
        draw.rect(left, y, left + w * hp, y + h, r, g, 60, alpha, 2 * s)

        if armour > 0 then
            local ay = y + h + 2 * s
            draw.rect(left - 1, ay - 1, left + w + 1, ay + h * 0.6 + 1, 0, 0, 0, math.floor(alpha * 0.6), 2 * s)
            draw.rect(left, ay, left + w * armour, ay + h * 0.6, 80, 160, 255, alpha, 2 * s)
        end

        if aimed then
            draw.rect(left - 3 * s, y - 3 * s, left - 1 * s, y + h + 3 * s, ar, ag, ab, 255, 0)
            draw.rect(left + w + 1 * s, y - 3 * s, left + w + 3 * s, y + h + 3 * s, ar, ag, ab, 255, 0)
            local label = string.format("%d%%", math.floor(hp * 100 + 0.5))
            text.draw(font.tiny, x - text.width(font.tiny, label) / 2, y - text.height(font.tiny) - 2 * s, 245, 245, 250, 255, label)
        elseif hostile then
            draw.rect(x - 2 * s, y - 6 * s, x + 2 * s, y - 2 * s, 255, 70, 60, alpha, 2 * s)
        end
    end
end)
