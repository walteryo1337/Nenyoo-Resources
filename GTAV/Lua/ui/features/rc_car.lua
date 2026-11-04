-- RC Car. Published fields: active (bool, driving the RC car), signal (0..1, drops with distance from your
-- body), distance and range (metres).
features.on_draw("RC Car", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local signal = math.max(0, math.min(1, f.signal or 0))

    local bars, bw, gap = 5, 7 * s, 4 * s
    local maxh = 26 * s
    local w = bars * bw + (bars - 1) * gap
    local x = sw - 40 * s - w
    local base = sh * 0.12
    local lit = math.ceil(signal * bars)
    local weak = signal < 0.25
    local blink = weak and (math.floor(ctx.time() * 4) % 2 == 0)
    for i = 1, bars do
        local bh = maxh * i / bars
        local bx = x + (i - 1) * (bw + gap)
        if i <= lit and not blink then
            local r, g, b = ar, ag, ab
            if weak then r, g, b = 240, 70, 60 end
            draw.rect(bx, base - bh, bx + bw, base, r, g, b, 255, 1 * s)
        else
            draw.rect(bx, base - bh, bx + bw, base, 50, 50, 60, 170, 1 * s)
        end
    end

    local label = weak and "SIGNAL WEAK" or "RC SIGNAL"
    text.draw(font.tiny, x + w - text.width(font.tiny, label), base - maxh - text.height(font.tiny) - 4 * s, weak and 240 or 200, weak and 80 or 200, weak and 70 or 210, 240, label)
    local d = string.format("%dM / %dM", math.floor(f.distance or 0), math.floor(f.range or 0))
    text.draw(font.tiny, x + w - text.width(font.tiny, d), base + 4 * s, 170, 170, 185, 220, d)
    local hint = "HORN  DETONATE     EXIT  RETURN"
    text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, sh * 0.92, 200, 200, 210, 200, hint)
end)
