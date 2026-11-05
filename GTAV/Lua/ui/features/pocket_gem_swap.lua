-- Pocket Gem Swap. Published fields: active (bool), state (1 your move, 2 matched gems flashing, 3 gems falling,
-- 4 out of moves), state_age (ms), n (board side), board (blob, n * n chars row by row, '0'-'5' gem colour), marked
-- (blob, '1' on gems about to clear), fall (blob, digit = rows the gem is dropping during state 3), cx / cy (cursor),
-- selected (bool, a gem is picked and the next direction swaps it), score, best, moves_left, cascade (chain step),
-- last_points, bad_x / bad_y / bad_age (a swap that made no match bounces back; age in ms, 99999 when none).
local COLS = { { 235, 60, 70 }, { 60, 140, 255 }, { 80, 210, 100 }, { 250, 210, 50 }, { 180, 90, 230 }, { 255, 140, 40 } }
local CLEAR_MS, FALL_MS = 280, 260

local function gem(kind, x, y, r, a)
    local col = COLS[kind + 1] or COLS[1]
    local cr, cg, cb = col[1], col[2], col[3]
    if kind == 0 then
        draw.circle(x, y, r, cr, cg, cb, a)
        draw.circle(x - r * 0.3, y - r * 0.3, r * 0.3, 255, 255, 255, math.floor(a * 0.5))
    elseif kind == 1 then
        for k = 0, 6 do
            local w = r * (1 - k / 7)
            draw.line(x - w, y - k * r / 7, x + w, y - k * r / 7, cr, cg, cb, a, r / 7 + 1)
            draw.line(x - w, y + k * r / 7, x + w, y + k * r / 7, cr, cg, cb, a, r / 7 + 1)
        end
    elseif kind == 2 then
        draw.rect(x - r * 0.85, y - r * 0.85, x + r * 0.85, y + r * 0.85, cr, cg, cb, a, r * 0.2)
        draw.rect(x - r * 0.45, y - r * 0.45, x + r * 0.45, y + r * 0.45, math.min(255, cr + 60), math.min(255, cg + 40), math.min(255, cb + 60), a, r * 0.1)
    elseif kind == 3 then
        for k = 0, 7 do
            local yy = y - r * 0.8 + k * r * 1.6 / 7
            local w = r * 0.95 * k / 7
            draw.line(x - w, yy, x + w, yy, cr, cg, cb, a, r * 1.6 / 7 + 1)
        end
    elseif kind == 4 then
        draw.circle(x, y, r, cr, cg, cb, a)
        draw.circle_outline(x, y, r * 0.55, 255, 255, 255, math.floor(a * 0.6), r * 0.15)
    else
        draw.rect(x - r * 0.8, y - r * 0.8, x + r * 0.8, y + r * 0.8, cr, cg, cb, a, r * 0.5)
        draw.circle(x, y, r * 0.25, 255, 255, 255, math.floor(a * 0.7))
    end
end

features.on_draw("Pocket Gem Swap", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.n or 8)
    local state = math.floor(f.state or 0)
    local age = f.state_age or 0
    local c = 76 * s
    local bw = n * c
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bw / 2 + 18 * s
    draw.rect(x0 - 26 * s, y0 - 76 * s, x0 + bw + 26 * s, y0 + bw + 60 * s, 20, 16, 34, 240, 14 * s)
    for y = 0, n - 1 do
        for x = 0, n - 1 do
            local shade = ((x + y) % 2 == 0) and 46 or 38
            draw.rect(x0 + x * c, y0 + y * c, x0 + (x + 1) * c, y0 + (y + 1) * c, shade, shade - 6, shade + 16, 255, 0)
        end
    end

    local board, marked, fall = f.board or "", f.marked or "", f.fall or ""
    local bx, by, bad = math.floor(f.bad_x or -1), math.floor(f.bad_y or -1), f.bad_age or 99999
    for y = 0, n - 1 do
        for x = 0, n - 1 do
            local i = y * n + x + 1
            local kind = tonumber(string.sub(board, i, i))
            if kind then
                local px, py = x0 + (x + 0.5) * c, y0 + (y + 0.5) * c
                local r = c * 0.36
                local a = 255
                if state == 2 and string.sub(marked, i, i) == "1" then
                    local p = math.min(1, age / CLEAR_MS)
                    r = r * (1 + 0.25 * math.sin(p * math.pi)) * (1 - p * 0.8)
                    a = math.floor(255 * (1 - p * 0.6))
                elseif state == 3 then
                    local dropped = tonumber(string.sub(fall, i, i)) or 0
                    if dropped > 0 then
                        local p = math.min(1, age / FALL_MS)
                        py = py - dropped * c * (1 - p * p)
                    end
                end
                if bad < 300 and x == bx and y == by then px = px + math.sin(bad / 300 * math.pi * 6) * 6 * s end
                if py > y0 - c * 0.2 then gem(kind, px, py, r, a) end
            end
        end
    end

    if state == 1 then
        local cx, cy = math.floor(f.cx or 0), math.floor(f.cy or 0)
        local px, py = x0 + cx * c, y0 + cy * c
        local r, g, b = 255, 255, 255
        local a = 150 + math.floor(100 * math.abs(math.sin(t * 6)))
        if f.selected then r, g, b, a = 255, 200, 40, 255 end
        local th = 3 * s
        draw.line(px, py, px + c, py, r, g, b, a, th)
        draw.line(px, py + c, px + c, py + c, r, g, b, a, th)
        draw.line(px, py, px, py + c, r, g, b, a, th)
        draw.line(px + c, py, px + c, py + c, r, g, b, a, th)
    end
    if state == 2 and (f.last_points or 0) > 0 then
        local label = string.format("+%d", math.floor(f.last_points))
        if (f.cascade or 0) > 1 then label = label .. string.format("  CHAIN x%d", math.floor(f.cascade)) end
        local w = text.width(font.display, label)
        text.draw(font.display, sw / 2 - w / 2, y0 + bw / 2 - 30 * s - age / CLEAR_MS * 20 * s, 255, 230, 120, 255, label)
    end

    local hy = y0 - 60 * s
    text.draw(font.hud, x0, hy, 245, 240, 255, 255, string.format("SCORE %d", math.floor(f.score or 0)))
    local mv = string.format("MOVES %d", math.floor(f.moves_left or 0))
    local mr, mg, mb = 220, 220, 240
    if (f.moves_left or 0) <= 5 then mr, mg, mb = 255, 120, 100 end
    text.draw(font.hud, x0 + bw / 2 - text.width(font.hud, mv) / 2, hy, mr, mg, mb, 255, mv)
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, best), hy + 4 * s, 255, 200, 60, 255, best)

    local msg, r, g, b = "W A S D MOVE   E PICK A GEM, THEN A DIRECTION TO SWAP   LINE UP 3 OR MORE", 225, 220, 240
    if f.selected then msg = "NOW PRESS W A S D TO SWAP   Q OR E TO CANCEL" end
    if state == 4 then msg, r, g, b = string.format("OUT OF MOVES   SCORE %d   E TO PLAY AGAIN", math.floor(f.score or 0)), 255, 210, 90 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + bw + 22 * s, r, g, b, 255, msg)
end)
