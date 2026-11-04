-- Keepy Uppy. Shown while the game is on. Published fields: active (bool), streak (touches in a row), best (best streak
-- this session), reach (bool, the ball is close enough to hit), grade (last touch: 0 none, 1 perfect, 2 good, 3 scrape),
-- grade_k (1..0 fade of that word).
local words = { "PERFECT", "GOOD", "SCRAPED IT" }
local cols = { { 255, 220, 90 }, { 170, 230, 140 }, { 220, 220, 230 } }

features.on_draw("Keepy Uppy", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    local streak = string.format("%d", math.floor(f.streak or 0))
    text.draw(font.title, cx - text.width(font.title, streak) / 2, 50 * s, 255, 255, 255, 255, streak)
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.tiny, cx - text.width(font.tiny, best) / 2, 100 * s, 200, 200, 214, 220, best)

    local g = math.floor(f.grade or 0)
    local k = f.grade_k or 0
    if g > 0 and k > 0 then
        local c = cols[g]
        local w = words[g]
        text.draw(font.small, cx - text.width(font.small, w) / 2, sh * 0.34 - 20 * s * (1 - k), c[1], c[2], c[3], math.floor(255 * k), w)
    end
    if f.reach then
        local hint = "E"
        local r = 18 * s
        draw.circle(cx, sh * 0.58, r, 255, 220, 90, 220)
        text.draw(font.small, cx - text.width(font.small, hint) / 2, sh * 0.58 - 11 * s, 20, 20, 24, 255, hint)
    end
end)
