-- Pocket Darts. Published fields: active (bool), state (1 your aim, 2 dart landed, 3 opponent throwing, 4 game over),
-- my_score / ai_score (points left from 301), ai_turn (bool), darts_left (this turn), aim_x / aim_y (reticle in board
-- units: 0,0 is the bull, 1 is the outer double wire, y grows downward), bust (bool, this turn went bust), winner (0 you,
-- 1 opponent, -1 none yet), wins / losses (this session), darts (blob "x,y,value,mult;" for darts thrown this turn).
local order = { 20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 }

local function label(value, mult)
    if value == 0 then return "MISS" end
    if value == 25 then return mult == 2 and "BULL" or "25" end
    local p = mult == 3 and "T" or (mult == 2 and "D" or "")
    return p .. value
end

features.on_draw("Pocket Darts", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx, cy = sw / 2, sh / 2 + 10 * s
    local R = 300 * s

    draw.rect(cx - R - 40 * s, cy - R - 80 * s, cx + R + 40 * s, cy + R + 50 * s, 12, 12, 16, 225, 12 * s)
    draw.circle(cx, cy, R * 1.12, 20, 20, 24, 255)
    draw.circle(cx, cy, R, 220, 50, 50, 255)
    draw.circle(cx, cy, R * 0.953, 30, 30, 34, 255)
    draw.circle(cx, cy, R * 0.629, 40, 150, 70, 255)
    draw.circle(cx, cy, R * 0.582, 30, 30, 34, 255)
    draw.circle(cx, cy, R * 0.0935, 40, 150, 70, 255)
    draw.circle(cx, cy, R * 0.0374, 220, 50, 50, 255)
    for i = 0, 19 do
        local a = (i + 0.5) * math.pi / 10
        local sx, sy = math.sin(a), -math.cos(a)
        draw.line(cx + sx * R * 0.0935, cy + sy * R * 0.0935, cx + sx * R, cy + sy * R, 160, 160, 165, 200, 1.5 * s)
        local na = i * math.pi / 10
        local n = tostring(order[i + 1])
        local nx, ny = cx + math.sin(na) * R * 1.06, cy - math.cos(na) * R * 1.06
        text.draw(font.small, nx - text.width(font.small, n) / 2, ny - text.height(font.small) / 2, 245, 245, 250, 255, n)
    end

    local throws = {}
    for x, y, v, m in string.gmatch(f.darts or "", "([%d%.%-]+),([%d%.%-]+),(%d+),(%d+);") do
        throws[#throws + 1] = { x = tonumber(x), y = tonumber(y), v = tonumber(v), m = tonumber(m) }
    end
    for _, d in ipairs(throws) do
        local dx, dy = cx + d.x * R, cy + d.y * R
        draw.circle(dx, dy, 6 * s, 20, 20, 24, 255)
        draw.circle(dx, dy, 4 * s, f.ai_turn and 240 or ar, f.ai_turn and 110 or ag, f.ai_turn and 80 or ab, 255)
    end

    local state = math.floor(f.state or 0)
    if state == 1 then
        local rx, ry = cx + (f.aim_x or 0) * R, cy + (f.aim_y or 0) * R
        draw.circle_outline(rx, ry, 14 * s, 255, 255, 255, 230, 2 * s)
        draw.line(rx - 22 * s, ry, rx + 22 * s, ry, 255, 255, 255, 230, 2 * s)
        draw.line(rx, ry - 22 * s, rx, ry + 22 * s, 255, 255, 255, 230, 2 * s)
    end

    local top = cy - R - 70 * s
    local you = string.format("YOU %d", math.floor(f.my_score or 0))
    local them = string.format("%d CPU", math.floor(f.ai_score or 0))
    local yr, yg, yb = 245, 245, 250
    local tr, tg, tb = 180, 180, 195
    if f.ai_turn then yr, yg, yb, tr, tg, tb = 180, 180, 195, 245, 245, 250 end
    text.draw(font.title, cx - R, top, yr, yg, yb, 255, you)
    text.draw(font.title, cx + R - text.width(font.title, them), top, tr, tg, tb, 255, them)

    local parts = {}
    for _, d in ipairs(throws) do parts[#parts + 1] = label(d.v, d.m) end
    local line = table.concat(parts, "  ")
    if f.bust then line = line .. "  BUST" end
    if line ~= "" then text.draw(font.item, cx - text.width(font.item, line) / 2, top + 6 * s, f.bust and 240 or 235, f.bust and 90 or 235, f.bust and 80 or 245, 255, line) end

    local foot
    if state == 4 then
        foot = (math.floor(f.winner or -1) == 0 and "YOU WIN" or "CPU WINS") ..
            string.format("   %d-%d   E TO PLAY AGAIN", math.floor(f.wins or 0), math.floor(f.losses or 0))
    elseif state == 1 then
        foot = string.format("W A S D AIM   E THROW   %d DARTS LEFT", math.floor(f.darts_left or 0))
    elseif f.ai_turn then
        foot = "CPU IS THROWING"
    end
    if foot then text.draw(font.small, cx - text.width(font.small, foot) / 2, cy + R + 18 * s, 220, 220, 232, 240, foot) end
end)
