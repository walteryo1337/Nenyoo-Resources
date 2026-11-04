-- Pocket Slots. Published fields: active (bool), state (1 ready, 2 spinning, 3 result), state_age (ms), pos1 / pos2 /
-- pos3 (reel positions in symbols; the symbol at strip index k sits on the payline when pos == k), strips (blob, three
-- 26-char strips joined by '|', chars '0'-'5': cherry, lemon, bell, bar, seven, diamond), bet, staked, win, multiple
-- (payout multiple of the last spin), cash (Story Mode wallet), net (session profit), spins, biggest (largest win).
local function money(v)
    local n = tostring(math.floor(math.abs(v)))
    local out = n:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return "$" .. out
end

local function cherry(cx, cy, z, a)
    draw.line(cx - 0.2 * z, cy + 0.12 * z, cx + 0.06 * z, cy - 0.34 * z, 60, 150, 50, a, 0.06 * z)
    draw.line(cx + 0.2 * z, cy + 0.2 * z, cx + 0.06 * z, cy - 0.34 * z, 60, 150, 50, a, 0.06 * z)
    draw.circle(cx + 0.16 * z, cy - 0.34 * z, 0.08 * z, 80, 180, 60, a)
    draw.circle(cx - 0.2 * z, cy + 0.16 * z, 0.2 * z, 210, 20, 40, a)
    draw.circle(cx + 0.2 * z, cy + 0.24 * z, 0.2 * z, 230, 30, 50, a)
    draw.circle(cx - 0.26 * z, cy + 0.1 * z, 0.06 * z, 255, 200, 200, math.floor(a * 0.8))
    draw.circle(cx + 0.14 * z, cy + 0.18 * z, 0.06 * z, 255, 200, 200, math.floor(a * 0.8))
end

local function lemon(cx, cy, z, a)
    draw.circle(cx - 0.3 * z, cy, 0.09 * z, 230, 200, 30, a)
    draw.circle(cx + 0.3 * z, cy, 0.09 * z, 230, 200, 30, a)
    for k = -1, 1 do draw.circle(cx + k * 0.13 * z, cy, 0.25 * z, 250, 220, 50, a) end
    draw.circle(cx - 0.08 * z, cy - 0.1 * z, 0.08 * z, 255, 250, 200, math.floor(a * 0.8))
end

local function bell(cx, cy, z, a)
    draw.circle(cx, cy - 0.36 * z, 0.06 * z, 200, 150, 30, a)
    draw.circle(cx, cy - 0.08 * z, 0.24 * z, 245, 190, 40, a)
    draw.rect(cx - 0.24 * z, cy - 0.08 * z, cx + 0.24 * z, cy + 0.2 * z, 245, 190, 40, a)
    draw.rect(cx - 0.34 * z, cy + 0.16 * z, cx + 0.34 * z, cy + 0.28 * z, 225, 165, 30, a, 0.05 * z)
    draw.circle(cx, cy + 0.32 * z, 0.07 * z, 170, 120, 20, a)
    draw.line(cx - 0.12 * z, cy - 0.18 * z, cx - 0.12 * z, cy + 0.12 * z, 255, 240, 170, math.floor(a * 0.7), 0.05 * z)
end

local function bar(cx, cy, z, a)
    draw.rect(cx - 0.38 * z, cy - 0.2 * z, cx + 0.38 * z, cy + 0.2 * z, 230, 180, 50, a, 0.05 * z)
    draw.rect(cx - 0.34 * z, cy - 0.16 * z, cx + 0.34 * z, cy + 0.16 * z, 20, 20, 28, a, 0.04 * z)
    local w = text.width(font.item, "BAR")
    text.draw(font.item, cx - w / 2, cy - text.height(font.item, "BAR") / 2, 255, 255, 255, a, "BAR")
end

local function seven(cx, cy, z, a)
    local function stroke(r, g, b, th)
        draw.line(cx - 0.26 * z, cy - 0.3 * z, cx + 0.26 * z, cy - 0.3 * z, r, g, b, a, th)
        draw.line(cx + 0.24 * z, cy - 0.3 * z, cx - 0.06 * z, cy + 0.36 * z, r, g, b, a, th)
    end
    stroke(110, 10, 20, 0.2 * z)
    stroke(235, 35, 45, 0.13 * z)
end

local function diamond(cx, cy, z, a)
    local h, w = 0.36 * z, 0.3 * z
    local step = math.max(1.5, h / 18)
    local y = -h
    while y <= h do
        local half = w * (1 - math.abs(y) / h)
        local shade = y < 0 and 255 or 200
        draw.line(cx - half, cy + y, cx + half, cy + y, math.floor(shade * 0.35), shade, 255, a, step + 0.6)
        y = y + step
    end
    draw.line(cx - w * 0.5, cy - h * 0.5, cx, cy - h, 255, 255, 255, math.floor(a * 0.7), 0.04 * z)
end

local DRAW = { [0] = cherry, lemon, bell, bar, seven, diamond }

local function symbol(kind, cx, cy, z, a)
    local fn = DRAW[kind]
    if fn then fn(cx, cy, z, a) end
end

features.on_draw("Pocket Slots", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local ar, ag, ab = theme.accent()
    local cell = 120 * s
    local rw = 130 * s
    local gap = 12 * s
    local mw = rw * 3 + gap * 2
    local pw = 250 * s
    local total = mw + 40 * s + pw
    local x0 = sw / 2 - total / 2
    local wy = sh / 2 - cell * 1.5
    local strips = {}
    for part in string.gmatch(f.strips or "", "[^|]+") do strips[#strips + 1] = part end

    draw.rect(x0 - 24 * s, wy - 110 * s, x0 + total + 24 * s, wy + cell * 3 + 90 * s, 40, 8, 16, 240, 16 * s)
    draw.rect_gradient(x0 - 12 * s, wy - 98 * s, x0 + mw + 12 * s, wy + cell * 3 + 12 * s, 180, 30, 50, 255, 180, 30, 50, 255, 90, 10, 30, 255, 90, 10, 30, 255)
    local title = "LUCKY POCKET"
    local tw = text.width(font.title, title)
    for k = 0, 9 do
        local on = math.floor(t * 6 + k) % 2 == 0
        draw.circle(x0 + mw / 2 - tw / 2 - 30 * s + k * (tw + 60 * s) / 9, wy - 86 * s, 3.5 * s, 255, on and 230 or 120, on and 120 or 60, 255)
    end
    text.draw(font.title, x0 + mw / 2 - tw / 2, wy - 72 * s, 255, 220, 120, 255, title)

    for r = 1, 3 do
        local rx = x0 + (r - 1) * (rw + gap)
        draw.rect_gradient(rx, wy, rx + rw, wy + cell * 3, 200, 200, 205, 255, 200, 200, 205, 255, 200, 200, 205, 255, 200, 200, 205, 255)
        draw.rect_gradient(rx, wy + cell * 0.6, rx + rw, wy + cell * 2.4, 250, 250, 252, 255, 250, 250, 252, 255, 250, 250, 252, 255, 250, 250, 252, 255)
        local strip = strips[r] or ""
        local n = #strip
        if n > 0 then
            local p = f["pos" .. r] or 0
            local base = math.floor(p)
            local spinning = state == 2 and (f.state_age or 0) <(600 + r * 400)
            for k = base - 2, base + 2 do
                local off = k - p
                if math.abs(off) <= 1.45 then
                    local idx = k % n
                    local kind = tonumber(string.sub(strip, idx + 1, idx + 1)) or 0
                    local a = math.floor(255 * math.max(0, 1 - math.max(0, math.abs(off) - 0.9) / 0.55))
                    if spinning then a = math.floor(a * 0.75) end
                    symbol(kind, rx + rw / 2, wy + cell * 1.5 + off * cell, cell * 0.85, a)
                end
            end
        end
        draw.rect_gradient(rx, wy, rx + rw, wy + cell * 0.45, 0, 0, 0, 150, 0, 0, 0, 150, 0, 0, 0, 0, 0, 0, 0, 0)
        draw.rect_gradient(rx, wy + cell * 2.55, rx + rw, wy + cell * 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 150, 0, 0, 0, 150)
    end
    draw.rect(x0 - 12 * s, wy - 30 * s, x0 + mw + 12 * s, wy, 120, 20, 40, 255)
    draw.rect(x0 - 12 * s, wy + cell * 3, x0 + mw + 12 * s, wy + cell * 3 + 12 * s, 90, 10, 30, 255)

    local win = math.floor(f.win or 0)
    local ly = wy + cell * 1.5
    local glow = state == 3 and win > 0 and (math.floor(t * 8) % 2 == 0) and 255 or 150
    draw.line(x0 - 8 * s, ly, x0 + mw + 8 * s, ly, 255, 60, 60, state == 3 and win > 0 and glow or 90, 3 * s)

    local by = wy + cell * 3 + 26 * s
    local cash = string.format("CASH %s", money(f.cash or 0))
    text.draw(font.item, x0, by, 245, 245, 250, 255, cash)
    local bet = string.format("<  BET %s  >", money(f.bet or 0))
    text.draw(font.item, x0 + mw / 2 - text.width(font.item, bet) / 2, by, 255, 210, 90, 255, bet)
    local net = f.net or 0
    local nets = string.format("NET %s%s", net < 0 and "-" or "+", money(net))
    text.draw(font.item, x0 + mw - text.width(font.item, nets), by, net < 0 and 255 or 120, net < 0 and 110 or 235, net < 0 and 100 or 140, 255, nets)

    local msg, mr, mg, mb = "A / D CHANGE BET   E SPIN", 225, 225, 240
    if state == 2 then msg = "GOOD LUCK..."
    elseif state == 3 and win > 0 then
        msg, mr, mg, mb = string.format("WIN %s  (x%d)", money(win), math.floor(f.multiple or 0)), 120, 245, 140
        if (f.multiple or 0) >= 10 then mr, mg, mb = 255, 220, 80 end
    elseif state == 3 then msg = "NO WIN   E TO SPIN AGAIN" end
    text.draw(font.small, x0 + mw / 2 - text.width(font.small, msg) / 2, by + 34 * s, mr, mg, mb, 255, msg)

    local px = x0 + mw + 40 * s
    local py = wy - 98 * s
    draw.rect(px, py, px + pw, wy + cell * 3 + 12 * s, 20, 16, 30, 245, 10 * s)
    text.draw(font.small, px + 14 * s, py + 12 * s, 255, 220, 120, 255, "PAYS (TIMES BET)")
    local rows = { { 4, 4, 4, 50 }, { 5, 5, 5, 25 }, { 3, 3, 3, 15 }, { 2, 2, 2, 10 }, { 1, 1, 1, 5 }, { 0, 0, 0, 4 }, { 0, 0, -1, 2 }, { 0, -1, -1, 1 } }
    local rh = (wy + cell * 3 - py - 40 * s) / #rows
    for i, row in ipairs(rows) do
        local cy = py + 46 * s + (i - 0.5) * rh
        for k = 1, 3 do
            local sx = px + 30 * s + (k - 1) * 44 * s
            if row[k] >= 0 then symbol(row[k], sx, cy, 40 * s, 255)
            else text.draw(font.small, sx - text.width(font.small, "ANY") / 2, cy - 8 * s, 150, 150, 170, 255, "ANY") end
        end
        local pay = string.format("x%d", row[4])
        text.draw(font.item, px + pw - 18 * s - text.width(font.item, pay), cy - 10 * s, 245, 245, 250, 255, pay)
    end
    local stats = string.format("SPINS %d   BEST %s", math.floor(f.spins or 0), money(f.biggest or 0))
    text.draw(font.tiny, px + 14 * s, wy + cell * 3 - 10 * s, 170, 170, 190, 255, stats)
end)
