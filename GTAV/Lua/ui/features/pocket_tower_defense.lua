-- Pocket Tower Defense. Published fields: active (bool), state (1 building between waves, 2 wave running, 3 game over),
-- cx / cy (cursor cell), build_type (0 gun, 1 cannon, 2 frost), gold, lives, wave, score, best, countdown (seconds to the
-- next wave), msg (1 not enough gold, 2 that is the path, 3 fully upgraded, 4 built, 5 upgraded), cost (of building or
-- upgrading at the cursor; 0 when maxed), cols / rows, and blobs: path "x,y;", towers "x,y,type,level;",
-- enemies "x,y,hp,kind,slowed;" (x/y in cells, hp 0..1, kind 0 normal, 1 fast, 2 tank), shots "x1,y1,x2,y2,type,age;".
local names = { "GUN", "CANNON", "FROST" }
local tcol = { { 120, 200, 255 }, { 255, 160, 70 }, { 160, 240, 255 } }
local msgs = { "NOT ENOUGH GOLD", "CAN'T BUILD ON THE PATH", "FULLY UPGRADED", "TOWER BUILT", "TOWER UPGRADED" }

features.on_draw("Pocket Tower Defense", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cols, rows = math.floor(f.cols or 12), math.floor(f.rows or 8)
    local c = 54 * s
    local fw, fh = cols * c, rows * c
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 10 * s
    draw.rect(x0 - 12 * s, y0 - 64 * s, x0 + fw + 12 * s, y0 + fh + 52 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0, y0, x0 + fw, y0 + fh, 36, 70, 40, 255, 0)
    for gx = 0, cols - 1 do
        for gy = 0, rows - 1 do
            if (gx + gy) % 2 == 0 then
                draw.rect(x0 + gx * c, y0 + gy * c, x0 + (gx + 1) * c, y0 + (gy + 1) * c, 42, 80, 46, 255, 0)
            end
        end
    end

    local first = true
    for px, py in string.gmatch(f.path or "", "(%d+),(%d+);") do
        px, py = tonumber(px), tonumber(py)
        draw.rect(x0 + px * c, y0 + py * c, x0 + (px + 1) * c, y0 + (py + 1) * c, 150, 120, 80, 255, 0)
        if first then
            draw.rect(x0 + px * c, y0 + py * c, x0 + px * c + 4 * s, y0 + (py + 1) * c, 90, 255, 120, 255, 0)
            first = false
        end
    end
    local lastx, lasty
    for px, py in string.gmatch(f.path or "", "(%d+),(%d+);") do lastx, lasty = tonumber(px), tonumber(py) end
    if lastx then
        draw.rect(x0 + (lastx + 1) * c - 4 * s, y0 + lasty * c, x0 + (lastx + 1) * c, y0 + (lasty + 1) * c, 255, 80, 80, 255, 0)
    end

    for tx, ty, tt, tl in string.gmatch(f.towers or "", "(%d+),(%d+),(%d+),(%d+);") do
        tx, ty, tt, tl = tonumber(tx), tonumber(ty), tonumber(tt), tonumber(tl)
        local col = tcol[tt + 1] or tcol[1]
        local cx, cy = x0 + (tx + 0.5) * c, y0 + (ty + 0.5) * c
        draw.rect(x0 + tx * c + 5 * s, y0 + ty * c + 5 * s, x0 + (tx + 1) * c - 5 * s, y0 + (ty + 1) * c - 5 * s, 30, 30, 40, 255, 6 * s)
        draw.circle(cx, cy, c * 0.28, col[1], col[2], col[3], 255)
        for k = 1, tl do
            draw.circle(x0 + tx * c + (8 + (k - 1) * 9) * s, y0 + (ty + 1) * c - 9 * s, 3 * s, 255, 230, 100, 255)
        end
    end

    for x1, y1, x2, y2, st, age in string.gmatch(f.shots or "", "([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+),(%d+),([%d%.]+);") do
        local col = tcol[tonumber(st) + 1] or tcol[1]
        local a = math.floor(255 * (1 - tonumber(age)))
        draw.line(x0 + tonumber(x1) * c, y0 + tonumber(y1) * c, x0 + tonumber(x2) * c, y0 + tonumber(y2) * c, col[1], col[2], col[3], a, 3 * s)
        if tonumber(st) == 1 then
            draw.circle_outline(x0 + tonumber(x2) * c, y0 + tonumber(y2) * c, c * (0.4 + 0.6 * tonumber(age)), 255, 160, 70, a, 2 * s)
        end
    end

    for ex, ey, hp, kind, slowed in string.gmatch(f.enemies or "", "([%d%.]+),([%d%.]+),([%d%.]+),(%d+),(%d+);") do
        ex, ey, hp, kind = tonumber(ex), tonumber(ey), tonumber(hp), tonumber(kind)
        local cx, cy = x0 + ex * c, y0 + ey * c
        local r = c * (kind == 2 and 0.36 or (kind == 1 and 0.2 or 0.26))
        local er, eg, eb = 230, 70, 90
        if kind == 1 then er, eg, eb = 250, 220, 70 elseif kind == 2 then er, eg, eb = 170, 70, 220 end
        if slowed == "1" then er, eg, eb = 150, 210, 255 end
        draw.circle(cx, cy, r, er, eg, eb, 255)
        draw.rect(cx - c * 0.3, cy - r - 8 * s, cx + c * 0.3, cy - r - 4 * s, 40, 20, 20, 255, 0)
        draw.rect(cx - c * 0.3, cy - r - 8 * s, cx - c * 0.3 + c * 0.6 * hp, cy - r - 4 * s, 90, 230, 90, 255, 0)
    end

    local ccx, ccy = math.floor(f.cx or 0), math.floor(f.cy or 0)
    local pulse = math.floor(170 + 80 * math.sin(t * 6))
    draw.rect_outline(x0 + ccx * c, y0 + ccy * c, x0 + (ccx + 1) * c, y0 + (ccy + 1) * c, 255, 255, 255, pulse, 4 * s, 3 * s)

    local bt = math.floor(f.build_type or 0)
    local col = tcol[bt + 1] or tcol[1]
    local hud = string.format("WAVE %d    LIVES %d    $%d", math.floor(f.wave or 0), math.floor(f.lives or 0), math.floor(f.gold or 0))
    text.draw(font.hud_small, x0, y0 - 52 * s, 235, 235, 245, 255, hud)
    local sc = string.format("SCORE %d   BEST %d", math.floor(f.score or 0), math.floor(f.best or 0))
    text.draw(font.hud_tiny, x0 + fw - text.width(font.hud_tiny, sc), y0 - 48 * s, 190, 190, 205, 230, sc)
    local cost = math.floor(f.cost or 0)
    local build = string.format("Q: %s TOWER    E: %s", names[bt + 1] or "", cost > 0 and string.format("BUILD/UPGRADE $%d", cost) or "MAXED")
    text.draw(font.hud_tiny, x0, y0 - 24 * s, col[1], col[2], col[3], 255, build)

    local state = math.floor(f.state or 1)
    local foot
    if state == 1 then foot = string.format("NEXT WAVE IN %d", math.floor(f.countdown or 0))
    elseif state == 3 then foot = "GAME OVER  -  PRESS E TO PLAY AGAIN" end
    local m = math.floor(f.msg or 0)
    if m > 0 and msgs[m] then foot = msgs[m] end
    if foot then
        local fr, fg, fb = 255, 230, 120
        if state == 3 then fr, fg, fb = 255, 110, 110 end
        if m == 1 or m == 2 or m == 3 then fr, fg, fb = 255, 140, 120 elseif m >= 4 then fr, fg, fb = 130, 255, 160 end
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, foot) / 2, y0 + fh + 14 * s, fr, fg, fb, 255, foot)
    else
        local hint = "W A S D  MOVE CURSOR"
        text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, y0 + fh + 18 * s, 190, 190, 205, 200, hint)
    end
end)
