-- Pocket Roulette. Published fields: active (bool), state (1 betting, 2 spinning, 3 just settled), state_age (ms), row
-- (cursor row: 0-2 number rows top to bottom, 3 dozens, 4 outside bets), spot (cursor bet id: 0-36 single numbers,
-- 37-39 columns ending 1/2/3 counted from the bottom row, 40-42 dozens, 43-48 1-18 / even / red / black / odd / 19-36),
-- chip (chip value), staked, cash (Story Mode wallet), net (session profit), win (paid on the last spin), result (last
-- number or -1 while spinning), wheel / ball (angles in radians, pocket i sits at wheel + i * 2pi / 37 measured from the
-- top), ball_r (1 on the outer track, about 0.73 in a pocket), bets (blob "spot:amount;"), history (blob "n,n,...").
local WHEEL = { 0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26 }
local RED = { [1] = true, [3] = true, [5] = true, [7] = true, [9] = true, [12] = true, [14] = true, [16] = true, [18] = true, [19] = true, [21] = true, [23] = true, [25] = true, [27] = true, [30] = true, [32] = true, [34] = true, [36] = true }
local OUTSIDE = { "1-18", "EVEN", "RED", "BLACK", "ODD", "19-36" }
local DOZENS = { "1st 12", "2nd 12", "3rd 12" }

local function money(v)
    local n = tostring(math.floor(math.abs(v)))
    local out = n:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return "$" .. out
end

local function short(v)
    if v >= 1000000 then return string.format("%.1fM", v / 1000000) end
    if v >= 1000 then return (v % 1000 == 0) and string.format("%dK", v / 1000) or string.format("%.1fK", v / 1000) end
    return tostring(v)
end

local function num_colour(n)
    if n == 0 then return 30, 150, 70 end
    if RED[n] then return 200, 30, 40 end
    return 25, 25, 30
end

local function wins(spot, n)
    if n < 0 then return false end
    if spot <= 36 then return spot == n end
    if n == 0 then return false end
    if spot <= 39 then return n % 3 == (spot - 36) % 3 end
    if spot <= 42 then return math.floor((n - 1) / 12) == spot - 40 end
    local o = spot - 43
    if o == 0 then return n <= 18 elseif o == 1 then return n % 2 == 0 elseif o == 2 then return RED[n] == true
    elseif o == 3 then return not RED[n] elseif o == 4 then return n % 2 == 1 end
    return n >= 19
end

features.on_draw("Pocket Roulette", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local result = math.floor(f.result or -1)
    local ar, ag, ab = theme.accent()
    local R = 200 * s
    local cw, ch = 46 * s, 54 * s
    local total = R * 2 + 50 * s + cw * 14
    local x0 = sw / 2 - total / 2
    local cx, cy = x0 + R, sh / 2
    local bx0, by0 = x0 + R * 2 + 50 * s, sh / 2 - ch * 2.2

    draw.rect(x0 - 26 * s, cy - R - 70 * s, x0 + total + 26 * s, cy + R + 70 * s, 14, 50, 32, 240, 16 * s)

    draw.circle(cx, cy, R, 90, 50, 25, 255)
    draw.circle(cx, cy, R * 0.97, 60, 32, 16, 255)
    draw.circle(cx, cy, R * 0.88, 150, 120, 60, 255)
    local wheel = f.wheel or 0
    local step = 2 * math.pi / 37
    for i = 0, 36 do
        local a = wheel + i * step - math.pi / 2
        local r1, g1, b1 = num_colour(WHEEL[i + 1])
        for k = -2, 2 do
            local aa = a + k * step / 5.2
            local ca, sa = math.cos(aa), math.sin(aa)
            draw.line(cx + ca * R * 0.62, cy + sa * R * 0.62, cx + ca * R * 0.86, cy + sa * R * 0.86, r1, g1, b1, 255, R * 0.86 * step / 4.2)
        end
    end
    for i = 0, 36 do
        local a = wheel + (i + 0.5) * step - math.pi / 2
        local ca, sa = math.cos(a), math.sin(a)
        draw.line(cx + ca * R * 0.62, cy + sa * R * 0.62, cx + ca * R * 0.86, cy + sa * R * 0.86, 220, 190, 110, 255, 1.5 * s)
        local an = a - step / 2
        local label = tostring(WHEEL[i + 1])
        local nx, ny = cx + math.cos(an) * R * 0.8, cy + math.sin(an) * R * 0.8
        text.draw(font.tiny, nx - text.width(font.tiny, label) / 2, ny - text.height(font.tiny, label) / 2, 255, 255, 255, 255, label)
    end
    draw.circle_outline(cx, cy, R * 0.86, 220, 190, 110, 255, 2 * s)
    draw.circle(cx, cy, R * 0.62, 110, 70, 35, 255)
    draw.circle(cx, cy, R * 0.45, 140, 95, 45, 255)
    for k = 0, 3 do
        local a = wheel + k * math.pi / 2
        draw.line(cx, cy, cx + math.cos(a) * R * 0.32, cy + math.sin(a) * R * 0.32, 230, 200, 120, 255, 5 * s)
        draw.circle(cx + math.cos(a) * R * 0.32, cy + math.sin(a) * R * 0.32, 6 * s, 240, 215, 140, 255)
    end
    draw.circle(cx, cy, R * 0.1, 240, 215, 140, 255)

    if state == 2 or result >= 0 then
        local ba = (f.ball or 0) - math.pi / 2
        local br = (f.ball_r or 1) * 0.95 * R
        draw.circle(cx + math.cos(ba) * br + 2 * s, cy + math.sin(ba) * br + 2 * s, 7 * s, 0, 0, 0, 100)
        draw.circle(cx + math.cos(ba) * br, cy + math.sin(ba) * br, 7 * s, 245, 245, 245, 255)
        draw.circle(cx + math.cos(ba) * br - 2 * s, cy + math.sin(ba) * br - 2 * s, 2.5 * s, 255, 255, 255, 255)
    end

    local function spot_rect(id)
        if id == 0 then return bx0, by0, bx0 + cw, by0 + ch * 3 end
        if id <= 36 then
            local c = math.floor((id - 1) / 3)
            local row = 2 - (id - 1) % 3
            return bx0 + cw * (c + 1), by0 + ch * row, bx0 + cw * (c + 2), by0 + ch * (row + 1)
        end
        if id <= 39 then
            local row = 3 - (id - 36)
            return bx0 + cw * 13, by0 + ch * row, bx0 + cw * 14, by0 + ch * (row + 1)
        end
        if id <= 42 then
            local d = id - 40
            return bx0 + cw * (1 + 4 * d), by0 + ch * 3, bx0 + cw * (5 + 4 * d), by0 + ch * 3.8
        end
        local o = id - 43
        return bx0 + cw * (1 + 2 * o), by0 + ch * 3.8, bx0 + cw * (3 + 2 * o), by0 + ch * 4.6
    end

    local settled = state ~= 2 and result >= 0
    for id = 0, 48 do
        local x1, y1, x2, y2 = spot_rect(id)
        local r, g, b = 20, 90, 50
        if id <= 36 then r, g, b = num_colour(id) end
        draw.rect(x1 + 1, y1 + 1, x2 - 1, y2 - 1, r, g, b, 255)
        draw.rect(x1, y1, x2, y1 + 1, 220, 220, 200, 200)
        draw.rect(x1, y1, x1 + 1, y2, 220, 220, 200, 200)
        if settled and wins(id, result) then
            local pulse = math.floor(90 + 70 * math.sin(t * 6))
            draw.rect(x1 + 1, y1 + 1, x2 - 1, y2 - 1, 255, 230, 120, pulse)
        end
        local label
        if id <= 36 then label = tostring(id)
        elseif id <= 39 then label = "2:1"
        elseif id <= 42 then label = DOZENS[id - 39]
        else label = OUTSIDE[id - 42] end
        local fnt = id <= 39 and font.item or font.small
        if id == 45 or id == 46 then
            local mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            local rr, gg, bb = id == 45 and 200 or 20, id == 45 and 30 or 20, id == 45 and 40 or 25
            local hw, hh = 16 * s, 12 * s
            local y = -hh
            while y <= hh do
                local half = hw * (1 - math.abs(y) / hh)
                draw.line(mx - half, my + y, mx + half, my + y, rr, gg, bb, 255, 1.6 * s)
                y = y + 1.4 * s
            end
        else
            text.draw(fnt, (x1 + x2) / 2 - text.width(fnt, label) / 2, (y1 + y2) / 2 - text.height(fnt, label) / 2, 245, 245, 240, 255, label)
        end
    end
    draw.rect(bx0 + cw * 14 - 1, by0, bx0 + cw * 14, by0 + ch * 3, 220, 220, 200, 200)
    draw.rect(bx0, by0 + ch * 4.6 - 1, bx0 + cw * 13, by0 + ch * 4.6, 220, 220, 200, 200)

    for spot, amount in string.gmatch(f.bets or "", "(%d+):(%d+);") do
        spot, amount = tonumber(spot), tonumber(amount)
        local x1, y1, x2, y2 = spot_rect(spot)
        local mx, my = (x1 + x2) / 2 + 8 * s, (y1 + y2) / 2 + 8 * s
        local cr, cg, cb = 40, 110, 220
        if amount >= 10000 then cr, cg, cb = 160, 60, 200 elseif amount >= 5000 then cr, cg, cb = 230, 120, 30 elseif amount >= 1000 then cr, cg, cb = 30, 30, 30 elseif amount >= 500 then cr, cg, cb = 40, 160, 70 end
        draw.circle(mx + 1.5 * s, my + 2 * s, 13 * s, 0, 0, 0, 120)
        draw.circle(mx, my, 13 * s, cr, cg, cb, 255)
        draw.circle_outline(mx, my, 10 * s, 255, 255, 255, 200, 2 * s)
        local l = short(amount)
        text.draw(font.tiny, mx - text.width(font.tiny, l) / 2, my - text.height(font.tiny, l) / 2, 255, 255, 255, 255, l)
    end

    if state ~= 2 then
        local x1, y1, x2, y2 = spot_rect(math.floor(f.spot or 0))
        local a = math.floor(180 + 75 * math.sin(t * 8))
        for k = 0, 2 do
            local o = k * s
            draw.rect(x1 - 2 * s + o, y1 - 2 * s + o, x2 + 2 * s - o, y1 + o, ar, ag, ab, a)
            draw.rect(x1 - 2 * s + o, y2 - o, x2 + 2 * s - o, y2 + 2 * s - o, ar, ag, ab, a)
            draw.rect(x1 - 2 * s + o, y1 - 2 * s + o, x1 + o, y2 + 2 * s - o, ar, ag, ab, a)
            draw.rect(x2 - o, y1 - 2 * s + o, x2 + 2 * s - o, y2 + 2 * s - o, ar, ag, ab, a)
        end
    end

    local hy = by0 - 56 * s
    local hist = {}
    for n in string.gmatch(f.history or "", "(%d+),") do hist[#hist + 1] = tonumber(n) end
    for i = #hist, 1, -1 do
        local n = hist[i]
        local px = bx0 + cw * 14 - 18 * s - (#hist - i) * 34 * s
        local r, g, b = num_colour(n)
        draw.circle(px, hy + 14 * s, 14 * s, r, g, b, 255)
        if i == #hist then draw.circle_outline(px, hy + 14 * s, 16 * s, 255, 230, 120, 255, 2 * s) end
        local l = tostring(n)
        text.draw(font.tiny, px - text.width(font.tiny, l) / 2, hy + 14 * s - text.height(font.tiny, l) / 2, 255, 255, 255, 255, l)
    end
    text.draw(font.small, bx0, hy + 4 * s, 200, 200, 210, 255, "LAST NUMBERS")

    local iy = by0 + ch * 4.6 + 22 * s
    text.draw(font.item, bx0, iy, 245, 245, 250, 255, string.format("CASH %s", money(f.cash or 0)))
    local chip = string.format("CHIP %s", money(f.chip or 0))
    text.draw(font.item, bx0 + cw * 7 - text.width(font.item, chip) / 2, iy, 255, 210, 90, 255, chip)
    local staked = string.format("ON TABLE %s", money(f.staked or 0))
    text.draw(font.item, bx0 + cw * 14 - text.width(font.item, staked), iy, 220, 220, 235, 255, staked)
    local net = f.net or 0
    local nets = string.format("SESSION %s%s", net < 0 and "-" or "+", money(net))
    text.draw(font.small, bx0, iy + 32 * s, net < 0 and 255 or 120, net < 0 and 110 or 235, net < 0 and 100 or 140, 255, nets)

    local msg, mr, mg, mb = "WASD MOVE   E PLACE CHIP   SHIFT + A / D CHIP VALUE   Q UNDO (SHIFT CLEAR)   R SPIN / REBET", 225, 225, 240
    if state == 2 then msg = "NO MORE BETS..."
    elseif state == 3 then
        local win = math.floor(f.win or 0)
        local colour = result == 0 and "GREEN" or (RED[result] and "RED" or "BLACK")
        if win > 0 then msg, mr, mg, mb = string.format("%d %s   YOU WIN %s", result, colour, money(win)), 120, 245, 140
        else msg, mr, mg, mb = string.format("%d %s   NO WIN", result, colour), 255, 140, 120 end
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, cy + R + 36 * s, mr, mg, mb, 255, msg)
end)
