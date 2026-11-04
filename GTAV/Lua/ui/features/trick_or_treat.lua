-- Trick or Treat. Published fields: active (bool), candy (pieces collected), left (pumpkins still out),
-- rush (seconds of sugar rush left, missing when none), event (1 treat, 2 big treat, 3 trick, 4 sugar rush) + event_age.
features.on_draw("Trick or Treat", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local pad = 10 * s
    local orange_r, orange_g, orange_b = 255, 140, 30

    local candy = string.format("%d", math.floor(f.candy or 0))
    local sub = string.format("%d PUMPKINS LEFT", math.floor(f.left or 0))
    local w = math.max(text.width(font.title, candy) + 70 * s, text.width(font.tiny, sub)) + pad * 2
    local h = text.height(font.title) + text.height(font.tiny) + pad * 2 + 4 * s
    local x, y = sw - w - 28 * s, sh * 0.3
    draw.rect(x, y, x + w, y + h, 20, 10, 4, 200, 8 * s)
    draw.rect(x, y + h - 3 * s, x + w, y + h, orange_r, orange_g, orange_b, 255, 0)
    local icx, icy = x + pad + 14 * s, y + pad + text.height(font.title) / 2
    draw.circle(icx, icy, 13 * s, orange_r, orange_g, orange_b, 255)
    draw.rect(icx - 2 * s, icy - 17 * s, icx + 2 * s, icy - 11 * s, 80, 140, 40, 255, 1 * s)
    draw.circle(icx - 4 * s, icy - 2 * s, 2.5 * s, 30, 15, 5, 255)
    draw.circle(icx + 4 * s, icy - 2 * s, 2.5 * s, 30, 15, 5, 255)
    draw.rect(icx - 5 * s, icy + 4 * s, icx + 5 * s, icy + 6 * s, 30, 15, 5, 255, 1 * s)
    text.draw(font.title, x + pad + 36 * s, y + pad, 255, 235, 200, 255, candy)
    text.draw(font.tiny, x + pad, y + pad + text.height(font.title) + 4 * s, 220, 190, 160, 230, sub)

    if f.rush then
        local msg = string.format("SUGAR RUSH  %d", math.ceil(f.rush))
        local pulse = 180 + math.floor(75 * math.abs(math.sin(ctx.time() * 6)))
        text.draw(font.small, x + w - text.width(font.small, msg), y + h + 6 * s, 255, 90, 200, pulse, msg)
    end

    local age = f.event_age or 99
    local ev = math.floor(f.event or 0)
    if ev > 0 and age < 1.8 then
        local a = math.floor(255 * math.min(1, (1.8 - age) * 2))
        local msgs = { "TREAT!", "BIG TREAT!", "TRICK!", "SUGAR RUSH!" }
        local msg = msgs[ev] or ""
        local r, g, b = orange_r, orange_g, orange_b
        if ev == 3 then r, g, b = 170, 90, 255 elseif ev == 4 then r, g, b = 255, 90, 200 end
        local big = font.display or font.title
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.3 - math.max(0, 0.3 - age) * 60 * s, r, g, b, a, msg)
    end
end)
