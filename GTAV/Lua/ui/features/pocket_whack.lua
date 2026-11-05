-- Pocket Whack-a-Mole. Published fields: active (bool), state (1 playing, 2 round over), score, best (this
-- session), streak (hits in a row), time_left (seconds), holes (blob, 9 characters for the grid from the top
-- left: "0" empty, "1" mole, "2" golden mole, "3" bomb, "4" just whacked, "5" bomb went off).
local KEYS = { "Q", "W", "E", "A", "S", "D", "Z", "X", "C" }
local ROUND = 30

local function mole(cx, cy, r, gold, s)
    local br, bg, bb = 140, 95, 60
    if gold then br, bg, bb = 240, 195, 60 end
    draw.circle(cx, cy, r, br, bg, bb, 255)
    draw.circle(cx - r * 0.35, cy - r * 0.2, r * 0.13, 20, 20, 20, 255)
    draw.circle(cx + r * 0.35, cy - r * 0.2, r * 0.13, 20, 20, 20, 255)
    draw.circle(cx, cy + r * 0.15, r * 0.18, 235, 120, 140, 255)
end

local function bomb(cx, cy, r, s, t)
    draw.circle(cx, cy + r * 0.1, r * 0.8, 30, 30, 36, 255)
    draw.line(cx + r * 0.4, cy - r * 0.5, cx + r * 0.7, cy - r * 0.9, 160, 130, 90, 255, 3 * s)
    local flick = 0.5 + 0.5 * math.sin(t * 25)
    draw.circle(cx + r * 0.72, cy - r * 0.95, r * 0.14 + flick * r * 0.06, 255, 190, 60, 255)
end

features.on_draw("Pocket Whack-a-Mole", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cell = 150 * s
    local gw = cell * 3
    local x0, y0 = sw / 2 - gw / 2, sh / 2 - gw / 2 + 30 * s
    local holes = f.holes or ""
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 30 * s, y0 - 130 * s, x0 + gw + 30 * s, y0 + gw + 70 * s, 12, 12, 16, 225, 12 * s)
    draw.rect(x0 - 10 * s, y0 - 10 * s, x0 + gw + 10 * s, y0 + gw + 10 * s, 80, 150, 70, 255, 10 * s)

    for i = 0, 8 do
        local cx = x0 + (i % 3 + 0.5) * cell
        local cy = y0 + (math.floor(i / 3) + 0.5) * cell
        local r = cell * 0.36
        draw.circle(cx, cy + r * 0.35, r, 60, 40, 25, 255)
        draw.circle(cx, cy + r * 0.35, r * 0.82, 30, 20, 12, 255)
        local v = holes:sub(i + 1, i + 1)
        if v == "1" or v == "2" then
            mole(cx, cy - r * 0.05, r * 0.7, v == "2", s)
        elseif v == "3" then
            bomb(cx, cy, r * 0.7, s, t)
        elseif v == "4" then
            draw.circle_outline(cx, cy, r * 0.9, 255, 255, 255, 220, 4 * s)
            text.draw(font.display, cx - text.width(font.display, "POW") / 2, cy - text.height(font.display) / 2, 255, 230, 90, 255, "POW")
        elseif v == "5" then
            draw.circle(cx, cy, r * 1.05, 255, 140, 40, 200)
            draw.circle(cx, cy, r * 0.6, 255, 230, 120, 230)
        end
        local key = KEYS[i + 1]
        text.draw(font.hud_small, cx - r - 6 * s, cy - r - 4 * s, 235, 235, 240, 210, key)
    end

    local tl = f.time_left or 0
    local frac = math.max(0, math.min(1, tl / ROUND))
    local by = y0 - 32 * s
    draw.rect(x0, by, x0 + gw, by + 8 * s, 0, 0, 0, 160, 4 * s)
    local r, g = 90, 200
    if frac < 0.25 then r, g = 235, 80 end
    draw.rect(x0, by, x0 + gw * frac, by + 8 * s, r, g, 90, 255, 4 * s)

    local score = string.format("%d", math.floor(f.score or 0))
    text.draw(font.display, sw / 2 - text.width(font.display, score) / 2, y0 - 120 * s, 245, 245, 250, 255, score)
    local streak = math.floor(f.streak or 0)
    local info = string.format("BEST %d", math.floor(f.best or 0))
    if streak >= 3 then info = info .. string.format("     STREAK x%d", streak) end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, info) / 2, y0 - 66 * s, 200, 200, 214, 230, info)

    local foot = state == 2 and "TIME UP     SPACE TO PLAY AGAIN" or "HIT THE KEY FOR EACH HOLE     AVOID THE BOMBS"
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, foot) / 2, y0 + gw + 26 * s, 200, 200, 214, 230, foot)
end)
