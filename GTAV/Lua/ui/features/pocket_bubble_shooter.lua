-- Pocket Bubble Shooter. Published fields: active (bool), state (1 playing, 2 board cleared, 3 game over), state_age
-- (ms), cols / rows / lose_row, field_h (field is 1 wide and field_h tall, y down), shooter_y, parity (rows where
-- (row + parity) is odd are shifted half a bubble right and hold cols - 1 bubbles), grid (blob, rows * cols chars:
-- '.' empty or '0'-'5' colour), angle (aim, radians from straight up, positive right), cur / next (colours), flying
-- (bool) with bx / by / shot_color, effects (blob "x,y,colour,kind,age;" kind 0 popped, 1 dropped), score, best, level,
-- misses / drop_every (shots without a pop before the ceiling drops a row).
local COLS = { { 235, 60, 70 }, { 60, 140, 255 }, { 80, 210, 100 }, { 250, 210, 50 }, { 180, 90, 230 }, { 255, 140, 40 } }

local function bubble(x, y, r, colour, a)
    local col = COLS[colour + 1] or COLS[1]
    draw.circle(x, y, r, col[1], col[2], col[3], a)
    draw.circle(x - r * 0.3, y - r * 0.3, r * 0.32, 255, 255, 255, math.floor(a * 0.45))
    draw.circle_outline(x, y, r, math.floor(col[1] * 0.6), math.floor(col[2] * 0.6), math.floor(col[3] * 0.6), a, 1.5)
end

features.on_draw("Pocket Bubble Shooter", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cols, rows = math.floor(f.cols or 10), math.floor(f.rows or 14)
    local fh_n = f.field_h or 1.3
    local fw = 560 * s
    local fh = fw * fh_n
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 14 * s
    local d = 1 / cols
    local rh = d * 0.866
    local parity = math.floor(f.parity or 0)
    local state = math.floor(f.state or 0)
    local function P(x, y) return x0 + x * fw, y0 + y * fw end
    draw.rect(x0 - 14 * s, y0 - 58 * s, x0 + fw + 14 * s, y0 + fh + 46 * s, 14, 12, 26, 240, 10 * s)
    draw.rect_gradient(x0, y0, x0 + fw, y0 + fh, 30, 26, 60, 255, 30, 26, 60, 255, 14, 12, 30, 255, 14, 12, 30, 255)
    local _, ly = P(0, math.floor(f.lose_row or 12) * rh)
    for k = 0, 19 do
        local xa = x0 + k * fw / 20
        draw.line(xa, ly, xa + fw / 40, ly, 255, 80, 80, 160, 2 * s)
    end

    local grid = f.grid or ""
    local r = d * fw * 0.48
    for row = 0, rows - 1 do
        local off = (row + parity) % 2
        for c = 0, cols - 1 - off do
            local i = row * cols + c + 1
            local ch = string.sub(grid, i, i)
            if ch ~= "." and ch ~= "" then
                local x, y = P((c + 0.5 + off * 0.5) * d, row * rh + d / 2)
                bubble(x, y, r, tonumber(ch) or 0, 255)
            end
        end
    end

    for x, y, colour, kind, age in string.gmatch(f.effects or "", "([%d%.]+),([%d%.]+),(%d+),(%d+),(%d+);") do
        x, y, colour, kind, age = tonumber(x), tonumber(y), tonumber(colour), tonumber(kind), tonumber(age)
        local u = age / 700
        local px, py = P(x, y)
        if kind == 0 then
            local col = COLS[colour + 1] or COLS[1]
            draw.circle_outline(px, py, r * (1 + u * 1.2), col[1], col[2], col[3], math.floor(255 * (1 - u)), 3 * s)
        else
            local fall = (age / 1000) ^ 2 * 1.6 * fw
            bubble(px, py + fall, r, colour, math.floor(255 * (1 - u)))
        end
    end

    local sx, sy = P(0.5, f.shooter_y or (fh_n - 0.07))
    local ang = f.angle or 0
    if state == 1 and not f.flying then
        local gx, gy = 0.5, f.shooter_y or (fh_n - 0.07)
        local vx, vy = math.sin(ang), -math.cos(ang)
        local step = 0.03
        for k = 1, 40 do
            gx, gy = gx + vx * step, gy + vy * step
            if gx < d / 2 then gx, vx = d / 2, -vx elseif gx > 1 - d / 2 then gx, vx = 1 - d / 2, -vx end
            if gy < d / 2 then break end
            if k % 2 == 0 then
                local px, py = P(gx, gy)
                draw.circle(px, py, 2.5 * s, 255, 255, 255, math.floor(200 * (1 - k / 40)))
            end
        end
    end
    draw.line(sx, sy, sx + math.sin(ang) * 60 * s, sy - math.cos(ang) * 60 * s, 220, 220, 230, 255, 6 * s)
    draw.circle(sx, sy, r * 1.35, 60, 60, 80, 255)
    if f.flying then
        local bx, by = P(f.bx or 0.5, f.by or 1)
        bubble(bx, by, r, math.floor(f.shot_color or 0), 255)
    elseif state == 1 then
        bubble(sx, sy, r, math.floor(f.cur or 0), 255)
    end
    local nx = x0 + 50 * s
    text.draw(font.tiny, nx - text.width(font.tiny, "NEXT") / 2, sy - r * 2.4, 200, 200, 215, 255, "NEXT")
    bubble(nx, sy, r * 0.8, math.floor(f.next or 0), 255)
    local left = math.floor(f.drop_every or 5) - math.floor(f.misses or 0)
    for k = 1, left do
        draw.circle(x0 + fw - 20 * s - (k - 1) * 16 * s, sy, 5 * s, 255, 200, 60, 255)
    end

    local hy = y0 - 46 * s
    text.draw(font.item, x0, hy - 4 * s, 245, 245, 250, 255, string.format("SCORE %d", math.floor(f.score or 0)))
    local lvl = string.format("LEVEL %d", math.floor(f.level or 1))
    text.draw(font.small, x0 + fw / 2 - text.width(font.small, lvl) / 2, hy, 200, 200, 215, 255, lvl)
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.small, x0 + fw - text.width(font.small, best), hy, 255, 200, 60, 255, best)

    local msg, mr, mg, mb = "A / D AIM (SHIFT FINE)   E SHOOT   Q SWAP   MATCH 3 TO POP", 225, 225, 240
    if state == 2 then msg, mr, mg, mb = "BOARD CLEARED!   BONUS", 120, 240, 140
    elseif state == 3 then msg, mr, mg, mb = string.format("THE BUBBLES REACHED THE LINE   SCORE %d   E TO PLAY AGAIN", math.floor(f.score or 0)), 255, 120, 100 end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + fh + 12 * s, mr, mg, mb, 255, msg)
end)
