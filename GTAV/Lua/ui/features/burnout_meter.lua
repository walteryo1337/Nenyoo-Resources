-- Burnout Meter. Published fields: active (bool), burning (bool) with score, multiplier and time (seconds) for the
-- burnout in progress, heat (0..1 rear tyre heat), result (last finished score) + result_age, result_time,
-- result_popped (bool, the tyres blew during it), best.
features.on_draw("Burnout Meter", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2

    local heat = f.heat or 0
    if heat > 0.02 then
        local w, h = 220 * s, 8 * s
        local x, y = cx - w / 2, sh * 0.84
        draw.rect(x, y, x + w, y + h, 0, 0, 0, 150, 4 * s)
        local r = 255
        local g = math.floor(200 * (1 - heat))
        draw.rect(x, y, x + w * heat, y + h, r, g, 40, 240, 4 * s)
        local label = heat >= 1 and "TYRES MAXED" or "TYRE HEAT"
        text.draw(font.tiny, cx - text.width(font.tiny, label) / 2, y - text.height(font.tiny) - 3 * s, 235, 210, 190, 235, label)
    end

    if f.burning then
        local n = string.format("%d", math.floor(f.score or 0))
        local shake = math.sin(ctx.time() * 30) * 2 * s * math.min(1, (f.multiplier or 1) - 1)
        text.draw(big, cx - text.width(big, n) / 2 + shake, sh * 0.16, 255, 255, 255, 255, n)
        local m = string.format("BURNOUT  x%.1f", f.multiplier or 1)
        text.draw(font.small, cx - text.width(font.small, m) / 2, sh * 0.16 + text.height(big), ar, ag, ab, 255, m)
        return
    end

    local age = f.result_age or 99
    if age < 3.5 then
        local a = math.floor(255 * math.min(1, (3.5 - age) * 1.5))
        local title = f.result_popped and "TYRES BLOWN" or "BURNOUT"
        local r, g, b = ar, ag, ab
        if f.result_popped then r, g, b = 240, 90, 70 end
        text.draw(font.small, cx - text.width(font.small, title) / 2, sh * 0.15, r, g, b, a, title)
        local n = string.format("%d", math.floor(f.result or 0))
        text.draw(big, cx - text.width(big, n) / 2, sh * 0.15 + text.height(font.small), 255, 255, 255, a, n)
        local sub = string.format("%.1f S   BEST %d", f.result_time or 0, math.floor(f.best or 0))
        text.draw(font.tiny, cx - text.width(font.tiny, sub) / 2, sh * 0.15 + text.height(font.small) + text.height(big), 200, 200, 212, a, sub)
    end
end)
