-- Metal Detecting. Published fields: active (bool, on foot outdoors with the feature on), signal (0..1,
-- 0 = nothing in range), dig_here (bool, standing on the spot), progress (0..1 while digging), finds,
-- earned (this session).
features.on_draw("Metal Detecting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local signal = math.max(0, math.min(1, f.signal or 0))
    local progress = f.progress or 0

    local bars = 10
    local bw, gap = 9 * s, 4 * s
    local max_h = 34 * s
    local w = bars * bw + (bars - 1) * gap
    local cx = sw / 2
    local x = cx - w / 2
    local base = sh * 0.88

    local lit = math.floor(signal * bars + 0.5)
    local pulse = 0.75 + 0.25 * math.abs(math.sin(ctx.time() * (4 + signal * 10)))
    for i = 1, bars do
        local bh = max_h * (0.25 + 0.75 * i / bars)
        local bx = x + (i - 1) * (bw + gap)
        if i <= lit then
            local r = math.floor(ar + (255 - ar) * (i / bars))
            local g = math.floor(ag * (1 - i / bars) + 210 * (i / bars))
            draw.rect(bx, base - bh, bx + bw, base, r, g, ab, math.floor(255 * pulse), 2 * s)
        else
            draw.rect(bx, base - bh, bx + bw, base, 40, 40, 50, 170, 2 * s)
        end
    end

    local label
    if progress > 0 then
        label = "DIGGING..."
    elseif f.dig_here then
        label = "DIG HERE"
    elseif signal > 0 then
        label = "SIGNAL"
    else
        label = "SEARCHING"
    end
    local lw = text.width(font.hud_small, label)
    local lr, lg, lb = 220, 220, 230
    if f.dig_here or progress > 0 then lr, lg, lb = 120, 230, 120 end
    text.draw(font.hud_small, cx - lw / 2, base - max_h - text.height(font.hud_small) - 6 * s, lr, lg, lb, 255, label)

    if progress > 0 then
        draw.rect(x, base + 6 * s, x + w, base + 9 * s, 0, 0, 0, 150, 0)
        draw.rect(x, base + 6 * s, x + w * progress, base + 9 * s, ar, ag, ab, 255, 0)
    end

    local stats = string.format("FINDS %d   $%d", math.floor(f.finds or 0), math.floor(f.earned or 0))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, stats) / 2, base + 12 * s, 170, 170, 185, 220, stats)
end)
