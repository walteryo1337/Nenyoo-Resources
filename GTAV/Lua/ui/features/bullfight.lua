-- Bullfighting. Shown while the bull is out. Published fields: active (bool); pawing / charging / done (bool, the
-- current phase); lives / max_lives; score (points this round); passes (clean dodges this round); best (best score this
-- session); tti (seconds until the bull reaches you while it is charging, 0 otherwise); window (the earliest moment a
-- dodge counts, in the same seconds); call (last call: 0 none, 1 ole, 2 close shave, 3 too early, 4 gored); call_k (1..0
-- fade of that call).
local calls = { "OLE!", "CLOSE SHAVE!", "TOO EARLY", "GORED" }
local cols = { { 255, 220, 90 }, { 255, 160, 60 }, { 230, 230, 240 }, { 255, 80, 70 } }

features.on_draw("Bullfighting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2

    local w, h = 300 * s, 64 * s
    local x0, y0 = cx - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 24, 10, 10, 220, 12 * s)
    draw.rect(x0, y0, x0 + w, y0 + 4 * s, 220, 40, 40, 230, 0)
    local score = string.format("%d", math.floor(f.score or 0))
    text.draw(font.display, x0 + 16 * s, y0 + 10 * s, 255, 255, 255, 255, score)
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_tiny, x0 + 70 * s, y0 + 14 * s, 210, 200, 200, 220, best)
    local passes = string.format("%d PASSES", math.floor(f.passes or 0))
    text.draw(font.hud_tiny, x0 + 70 * s, y0 + 36 * s, 210, 200, 200, 220, passes)
    local lives, maxl = math.floor(f.lives or 0), math.floor(f.max_lives or 3)
    for i = 1, maxl do
        local px = x0 + w - 16 * s - (maxl - i) * 22 * s
        if i <= lives then draw.circle(px, y0 + h / 2, 7 * s, 230, 50, 50, 255)
        else draw.circle(px, y0 + h / 2, 7 * s, 80, 60, 60, 200) end
    end

    local tti = f.tti or 0
    local win = f.window or 0.45
    if f.charging and tti > 0 then
        local k = math.min(tti / 1.5, 1)
        local r = (24 + 90 * k) * s
        local inside = tti <= win
        local cr, cg, cb = 255, 255, 255
        if inside then cr, cg, cb = 255, 210, 80 end
        draw.circle(cx, cy, r, cr, cg, cb, inside and 200 or 90)
        draw.circle(cx, cy, 22 * s, 20, 20, 24, 200)
        local hint = "E"
        text.draw(font.hud_small, cx - text.width(font.hud_small, hint) / 2, cy - 11 * s, cr, cg, cb, 255, hint)
    elseif f.pawing then
        local hint = "THE BULL IS PAWING THE GROUND"
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, hint) / 2, sh * 0.66, 235, 225, 225, 220, hint)
    end

    local c = math.floor(f.call or 0)
    local ck = f.call_k or 0
    if c > 0 and ck > 0 and calls[c] then
        local col = cols[c]
        local word = calls[c]
        text.draw(font.display, cx - text.width(font.display, word) / 2, sh * 0.30 - 24 * s * (1 - ck), col[1], col[2], col[3], math.floor(255 * ck), word)
    end
    if f.done then
        local msg = "THE BULL WINS"
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.36, 255, 90, 80, 255, msg)
    end
end)
