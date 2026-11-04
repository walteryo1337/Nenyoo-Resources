-- Crate Tower. Shown while a tower is being built. Published fields: active (bool), hover (bool, a crate is waiting to
-- be dropped), over (bool, the tower is finished), floors (current height in crates), best (tallest this session),
-- lives (drops you can still miss), pop (last drop: 0 none, 1 perfect, 2 good, 3 missed, 4 collapsed), pop_k (1..0
-- fade of that message).
local pops = { "PERFECT!", "NICE DROP", "MISSED", "COLLAPSE!" }
local pop_col = { { 255, 220, 90 }, { 170, 230, 140 }, { 255, 90, 80 }, { 255, 90, 80 } }

features.on_draw("Crate Tower", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 230 * s, 112 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 210, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "CRATE TOWER")
    local fl = string.format("%d", math.floor(f.floors or 0))
    text.draw(font.title, x0 + 14 * s, y0 + 34 * s, 255, 220, 90, 255, fl)
    text.draw(font.tiny, x0 + 20 * s + text.width(font.title, fl), y0 + 52 * s, 200, 200, 214, 230, "FLOORS")
    local lives = math.floor(f.lives or 0)
    for i = 1, 3 do
        local cx = x0 + w - 24 * s - (3 - i) * 22 * s
        local on = i <= lives
        draw.rect(cx - 7 * s, y0 + 16 * s, cx + 7 * s, y0 + 30 * s, on and 200 or 50, on and 150 or 50, on and 80 or 60, 255, 2 * s)
    end
    text.draw(font.tiny, x0 + 14 * s, y0 + h - 26 * s, 190, 190, 205, 230, string.format("BEST %d", math.floor(f.best or 0)))

    local p = math.floor(f.pop or 0)
    local k = f.pop_k or 0
    if p > 0 and k > 0 and pops[p] then
        local c = pop_col[p]
        local msg = pops[p]
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.28 - 24 * s * (1 - k), c[1], c[2], c[3], math.floor(255 * k), msg)
    end

    if f.over then
        local msg = string.format("TOWER DONE - %d FLOORS", math.floor(f.floors or 0))
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.36, 245, 245, 250, 255, msg)
    elseif f.hover then
        local hint = "PRESS  E  TO DROP"
        text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, sh - 120 * s, 220, 220, 230, math.floor(170 + 60 * math.sin(t * 3)), hint)
    end
end)
