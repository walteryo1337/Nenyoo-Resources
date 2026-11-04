-- Pocket Lights Out. Published fields: active (bool), state (1 playing, 2 solved), cx / cy (cursor), level, moves (this
-- level), par (presses the level was scrambled with, so it can be solved in that many or fewer), lit (lights still on),
-- last_press + last_age (ms; cell just pressed, for the ripple), total_moves, cells (blob, 25 chars row by row, "1" lit).
local N = 5

features.on_draw("Pocket Lights Out", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local c = 80 * s
    local gw = N * c
    local pw, ph = gw + 40 * s, gw + 130 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    local gx, gy = x0 + 20 * s, y0 + 60 * s
    draw.rect(x0, y0, x0 + pw, y0 + ph, 10, 10, 16, 235, 12 * s)
    text.draw(font.item, x0 + 20 * s, y0 + 18 * s, 245, 245, 250, 255, string.format("LIGHTS OUT   LEVEL %d", math.floor(f.level or 1)))
    local info = string.format("MOVES %d   PAR %d", math.floor(f.moves or 0), math.floor(f.par or 0))
    text.draw(font.small, x0 + pw - 20 * s - text.width(font.small, info), y0 + 22 * s, 200, 200, 212, 255, info)

    local cells = f.cells or ""
    local state = math.floor(f.state or 0)
    local lp = f.last_press and math.floor(f.last_press)
    local ripple = (f.last_age or 99999) < 200
    for i = 0, N * N - 1 do
        local r, col = math.floor(i / N), i % N
        local x, y = gx + col * c, gy + r * c
        local on = cells:sub(i + 1, i + 1) == "1"
        local inset = 5 * s
        if ripple and lp and (i == lp or (math.abs(i - lp) == N) or (math.floor(i / N) == math.floor(lp / N) and math.abs(i - lp) == 1)) then inset = 9 * s end
        if on then
            local glow = 0.85 + 0.15 * math.sin(t * 4 + i)
            draw.rect(x + inset - 4 * s, y + inset - 4 * s, x + c - inset + 4 * s, y + c - inset + 4 * s, 255, 220, 90, math.floor(60 * glow), 12 * s)
            draw.rect(x + inset, y + inset, x + c - inset, y + c - inset, math.floor(255 * glow), math.floor(210 * glow), 80, 255, 10 * s)
        else
            local g = state == 2 and 70 or 40
            draw.rect(x + inset, y + inset, x + c - inset, y + c - inset, 30, g, 50, 255, 10 * s)
        end
    end
    if state == 1 then
        local x, y = gx + math.floor(f.cx or 0) * c, gy + math.floor(f.cy or 0) * c
        local a = math.floor(255 * (0.6 + 0.4 * math.sin(t * 8)))
        draw.rect(x + 1 * s, y + 1 * s, x + c - 1 * s, y + 4 * s, 120, 200, 255, a, 0)
        draw.rect(x + 1 * s, y + c - 4 * s, x + c - 1 * s, y + c - 1 * s, 120, 200, 255, a, 0)
        draw.rect(x + 1 * s, y + 1 * s, x + 4 * s, y + c - 1 * s, 120, 200, 255, a, 0)
        draw.rect(x + c - 4 * s, y + 1 * s, x + c - 1 * s, y + c - 1 * s, 120, 200, 255, a, 0)
    end

    local msg, cr, cg, cb = "W A S D MOVE   E PRESS   Q RESET LEVEL", 220, 220, 232
    if state == 2 then
        local under = math.floor(f.moves or 0) <= math.floor(f.par or 0)
        msg = under and "LIGHTS OUT! AT OR UNDER PAR   E NEXT LEVEL" or "LIGHTS OUT!   E NEXT LEVEL"
        cr, cg, cb = 120, 240, 140
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, gy + gw + 18 * s, cr, cg, cb, 255, msg)
    local rec = string.format("LIGHTS ON %d   TOTAL PRESSES %d", math.floor(f.lit or 0), math.floor(f.total_moves or 0))
    text.draw(font.small, sw / 2 - text.width(font.small, rec) / 2, gy + gw + 44 * s, 160, 160, 175, 255, rec)
end)
