-- Pocket Minigolf. Published fields: active (bool), state (1 aiming, 2 rolling, 3 hole finished, 4 round over), hole
-- (0-8), par, strokes (this hole), total / total_par (round so far), best (best round, after one), rounds, x / y (ball,
-- 0-1 across the 2:1 course), cup_x / cup_y, angle (radians, 0 = right, positive turns down), power (0-1), event (1
-- sunk, 2 water hazard +1, 3 picked up at par + 4, 4 lipped out) + event_age (ms), walls / sand / water (blobs
-- "x1,y1,x2,y2;" 0-1 rectangles; the moving gate on hole 9 is the last wall), card (blob "n," strokes per hole, 0 =
-- not played yet).
local BALL_R, CUP_R = 0.02, 0.036
local names = { [-3] = "ALBATROSS", [-2] = "EAGLE", [-1] = "BIRDIE", [0] = "PAR", [1] = "BOGEY", [2] = "DOUBLE BOGEY" }

local function rects(blob, fn)
    for a, b, c, d in string.gmatch(blob or "", "([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+);") do
        fn(tonumber(a), tonumber(b), tonumber(c), tonumber(d))
    end
end

features.on_draw("Pocket Minigolf", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cw = 820 * s
    local ch = cw / 2
    local border = 16 * s
    local x0, y0 = sw / 2 - cw / 2, sh / 2 - ch / 2 + 20 * s
    draw.rect(x0 - border - 10 * s, y0 - border - 64 * s, x0 + cw + border + 10 * s, y0 + ch + border + 104 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0 - border, y0 - border, x0 + cw + border, y0 + ch + border, 120, 80, 50, 255, 10 * s)
    draw.rect(x0, y0, x0 + cw, y0 + ch, 60, 160, 70, 255, 0)
    for i = 0, 9 do
        if i % 2 == 0 then draw.rect(x0 + i * cw / 10, y0, x0 + (i + 1) * cw / 10, y0 + ch, 70, 172, 80, 255, 0) end
    end

    rects(f.water, function(a, b, c, d)
        local shimmer = math.floor(20 * math.sin(t * 3))
        draw.rect(x0 + a * cw, y0 + b * ch, x0 + c * cw, y0 + d * ch, 40, 110 + shimmer, 210, 255, 6 * s)
    end)
    rects(f.sand, function(a, b, c, d)
        draw.rect(x0 + a * cw, y0 + b * ch, x0 + c * cw, y0 + d * ch, 225, 200, 140, 255, 14 * s)
    end)
    rects(f.walls, function(a, b, c, d)
        draw.rect(x0 + a * cw + 2 * s, y0 + b * ch + 3 * s, x0 + c * cw + 2 * s, y0 + d * ch + 3 * s, 0, 0, 0, 80, 3 * s)
        draw.rect(x0 + a * cw, y0 + b * ch, x0 + c * cw, y0 + d * ch, 150, 100, 60, 255, 3 * s)
    end)

    local cx, cy = x0 + (f.cup_x or 0.9) * cw, y0 + (f.cup_y or 0.5) * ch
    local cr = CUP_R / 2 * cw
    draw.circle(cx, cy, cr, 15, 30, 15, 255)
    draw.line(cx, cy, cx, cy - 46 * s, 230, 230, 230, 255, 2 * s)
    local wave = math.sin(t * 4) * 3 * s
    draw.rect(cx, cy - 46 * s, cx + 22 * s, cy - 32 * s + wave * 0.3, 230, 60, 60, 255, 2 * s)

    local state = math.floor(f.state or 0)
    local bx, by = x0 + (f.x or 0.1) * cw, y0 + (f.y or 0.5) * ch
    local br = BALL_R / 2 * cw
    if state ~= 3 or (f.event and math.floor(f.event) ~= 1) then
        draw.circle(bx + 2 * s, by + 2 * s, br, 0, 0, 0, 90)
        draw.circle(bx, by, br, 250, 250, 250, 255)
    end
    if state == 1 then
        local a = f.angle or 0
        local len = (40 + 160 * (f.power or 0.5)) * s
        local ex, ey = bx + math.cos(a) * len, by + math.sin(a) * len
        local steps = 8
        for i = 0, steps - 1, 2 do
            local t1, t2 = i / steps, (i + 1) / steps
            draw.line(bx + (ex - bx) * t1, by + (ey - by) * t1, bx + (ex - bx) * t2, by + (ey - by) * t2, 255, 255, 255, 200, 2 * s)
        end
        draw.circle(ex, ey, 3 * s, 255, 255, 255, 220)
    end

    local hole = math.floor(f.hole or 0) + 1
    local diff = math.floor(f.total or 0) - math.floor(f.total_par or 0)
    local sign = diff > 0 and "+" or ""
    local hud = string.format("HOLE %d   PAR %d   STROKES %d", hole, math.floor(f.par or 3), math.floor(f.strokes or 0))
    text.draw(font.hud, x0 - border, y0 - border - 52 * s, 245, 245, 250, 255, hud)
    local tot = string.format("TOTAL %d (%s%d)", math.floor(f.total or 0), sign, diff)
    text.draw(font.hud, x0 + cw + border - text.width(font.hud, tot), y0 - border - 52 * s, 200, 230, 200, 255, tot)

    local pbw = 200 * s
    local pbx = x0 + cw + border - pbw
    local pby = y0 + ch + border + 14 * s
    draw.rect(pbx, pby, pbx + pbw, pby + 12 * s, 40, 40, 48, 255, 6 * s)
    draw.rect(pbx, pby, pbx + pbw * (f.power or 0), pby + 12 * s, 255, 170, 60, 255, 6 * s)

    local i = 0
    local card = ""
    for v in string.gmatch(f.card or "", "(%d+),") do
        i = i + 1
        card = card .. (v == "0" and "-" or v) .. (i < 9 and "  " or "")
    end
    text.draw(font.hud_small, x0 - border, pby - 2 * s, 190, 210, 190, 255, "CARD  " .. card)

    local ev = math.floor(f.event or 0)
    local age = f.event_age or 99999
    local banner
    if ev == 1 and state == 3 then
        local strokes = math.floor(f.strokes or 0)
        banner = strokes == 1 and "HOLE IN ONE!" or (names[strokes - math.floor(f.par or 3)] or string.format("%d OVER PAR", strokes - math.floor(f.par or 3)))
    elseif ev == 2 and age < 1400 then banner = "SPLASH!  +1 STROKE"
    elseif ev == 3 and state == 3 then banner = "PICKED UP"
    elseif ev == 4 and age < 700 then banner = "LIPPED OUT!" end
    if banner then
        local w = text.width(font.display, banner)
        draw.rect(sw / 2 - w / 2 - 16 * s, y0 + ch / 2 - 30 * s, sw / 2 + w / 2 + 16 * s, y0 + ch / 2 + 30 * s, 12, 12, 16, 210, 8 * s)
        text.draw(font.display, sw / 2 - w / 2, y0 + ch / 2 - text.height(font.display) / 2, 255, 230, 120, 255, banner)
    end

    local msg
    if state == 4 then
        msg = string.format("ROUND OVER: %d (%s%d)", math.floor(f.total or 0), sign, diff)
        if f.best then msg = msg .. string.format("   BEST %d", math.floor(f.best)) end
        msg = msg .. "   E TO PLAY AGAIN"
    else msg = "A / D AIM   W / S POWER   E PUTT   Q RESTART ROUND" end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, pby + 34 * s, 220, 220, 232, 255, msg)
end)
