-- Ghost Hunt. Published fields: active (bool, night time with the feature on), hunting (bool, a ghost is out
-- there), emf (0..1, how close it is), capture (0..1 while you hold your aim on it), captured, earned.
features.on_draw("Ghost Hunt", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local emf = math.max(0, math.min(1, f.emf or 0))
    local now = ctx.time()

    local w, h = 170 * s, 74 * s
    local x, y = 28 * s, sh * 0.30
    draw.rect(x, y, x + w, y + h, 8, 12, 10, 190, 6 * s)
    text.draw(font.tiny, x + 10 * s, y + 6 * s, 140, 255, 170, 230, "EMF METER")

    local jitter = emf > 0 and (math.sin(now * 23) * 0.04 + math.sin(now * 9) * 0.03) * emf or 0
    local level = math.max(0, math.min(1, emf + jitter))
    local leds = 5
    local lw, gap = 22 * s, 6 * s
    local ly = y + 26 * s
    local colors = { { 90, 230, 90 }, { 160, 235, 80 }, { 240, 220, 70 }, { 250, 150, 60 }, { 250, 70, 60 } }
    for i = 1, leds do
        local lx = x + 10 * s + (i - 1) * (lw + gap)
        local c = colors[i]
        if level >= (i - 0.5) / leds then
            draw.rect(lx, ly, lx + lw, ly + 12 * s, c[1], c[2], c[3], 255, 2 * s)
        else
            draw.rect(lx, ly, lx + lw, ly + 12 * s, 40, 45, 42, 200, 2 * s)
        end
    end

    local status
    if not f.hunting then
        status = "QUIET... FOR NOW"
    elseif emf <= 0 then
        status = "NO READING"
    elseif emf > 0.75 then
        status = "IT'S RIGHT HERE"
    else
        status = "SOMETHING NEARBY"
    end
    text.draw(font.tiny, x + 10 * s, ly + 18 * s, 200, 220, 205, 230, status)
    local tally = string.format("%d  $%d", math.floor(f.captured or 0), math.floor(f.earned or 0))
    text.draw(font.tiny, x + w - 10 * s - text.width(font.tiny, tally), y + 6 * s, 170, 190, 175, 220, tally)

    local cap = f.capture or 0
    if cap > 0 then
        local cw = 220 * s
        local cx, cy = sw / 2 - cw / 2, sh * 0.58
        draw.rect(cx, cy, cx + cw, cy + 6 * s, 0, 0, 0, 160, 3 * s)
        draw.rect(cx, cy, cx + cw * cap, cy + 6 * s, 140, 255, 170, 255, 3 * s)
        local msg = "CAPTURING"
        text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, cy - text.height(font.small) - 4 * s, 140, 255, 170, 240, msg)
    end
end)
