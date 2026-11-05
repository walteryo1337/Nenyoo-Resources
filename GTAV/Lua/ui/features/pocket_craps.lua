-- Pocket Craps. Published fields: active (bool), state (1 placing a bet, 2 dice rolling, 3 point is on, 4 showing the
-- result), state_age (ms), d1 / d2 (dice faces shown, 0 before the first roll), point (0 when off), bet (chosen bet),
-- staked (money on the table), side (0 pass line, 1 don't pass), cash (Story Mode wallet), net (session win / loss),
-- outcome (1 win, 2 lose, 3 push; while the result shows), history (blob "total," of recent rolls, oldest first).
local PIPS = {
    { { 0, 0 } },
    { { -1, -1 }, { 1, 1 } },
    { { -1, -1 }, { 0, 0 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { 0, 0 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 1, 1 } },
}

local function money(v)
    local n = math.floor(math.abs(v))
    local str = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if str:sub(1, 1) == "," then str = str:sub(2) end
    return (v < 0 and "-$" or "$") .. str
end

features.on_draw("Pocket Craps", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local w, h = 900 * s, 560 * s
    local x0, y0 = sw / 2 - w / 2, sh / 2 - h / 2 + 16 * s
    draw.rect(x0 - 16 * s, y0 - 16 * s, x0 + w + 16 * s, y0 + h + 16 * s, 70, 40, 20, 255, 22 * s)
    draw.rect(x0, y0, x0 + w, y0 + h, 20, 100, 50, 255, 14 * s)
    draw.rect(x0 + 10 * s, y0 + 10 * s, x0 + w - 10 * s, y0 + h - 10 * s, 26, 116, 58, 255, 10 * s)

    local nums = { 4, 5, 6, 8, 9, 10 }
    local point = math.floor(f.point or 0)
    local bx = x0 + 60 * s
    local bwid = (w - 120 * s) / 6
    for i, n in ipairs(nums) do
        local cx = bx + (i - 0.5) * bwid
        local cy = y0 + 70 * s
        draw.rect(cx - bwid / 2 + 4 * s, cy - 36 * s, cx + bwid / 2 - 4 * s, cy + 36 * s, 240, 240, 230, 40, 6 * s)
        local label = n == 6 and "SIX" or (n == 9 and "NINE" or tostring(n))
        text.draw(font.display, cx - text.width(font.display, label) / 2, cy - text.height(font.display) / 2, 245, 245, 235, 255, label)
        if n == point then
            draw.circle(cx, cy - 50 * s, 18 * s, 245, 245, 245, 255)
            text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, "ON") / 2, cy - 50 * s - text.height(font.hud_tiny) / 2, 20, 20, 20, 255, "ON")
        end
    end
    if point == 0 then
        draw.circle(bx - 26 * s, y0 + 20 * s, 18 * s, 20, 20, 20, 255)
        text.draw(font.hud_tiny, bx - 26 * s - text.width(font.hud_tiny, "OFF") / 2, y0 + 20 * s - text.height(font.hud_tiny) / 2, 245, 245, 245, 255, "OFF")
    end

    local side = math.floor(f.side or 0)
    local ly = y0 + h - 120 * s
    local pass_on, dont_on = side == 0, side == 1
    draw.rect(x0 + 40 * s, ly, x0 + w * 0.62, ly + 46 * s, 240, 240, 230, pass_on and 70 or 20, 6 * s)
    text.draw(font.hud, x0 + 60 * s, ly + 10 * s, 245, 245, 235, 255, "PASS LINE")
    draw.rect(x0 + w * 0.64, ly, x0 + w - 40 * s, ly + 46 * s, 240, 240, 230, dont_on and 70 or 20, 6 * s)
    text.draw(font.hud, x0 + w * 0.66, ly + 10 * s, 245, 245, 235, 255, "DON'T PASS")
    local staked = math.floor(f.staked or 0)
    if staked > 0 then
        local chip_x = pass_on and (x0 + w * 0.5) or (x0 + w * 0.88)
        draw.circle(chip_x, ly + 23 * s, 20 * s, 220, 40, 40, 255)
        draw.circle_outline(chip_x, ly + 23 * s, 14 * s, 255, 255, 255, 255, 2 * s)
    end

    local d1, d2 = math.floor(f.d1 or 0), math.floor(f.d2 or 0)
    local rolling = state == 2
    local function die(cx, cy, v, spin)
        if v < 1 or v > 6 then return end
        local size = 70 * s
        local jx, jy = 0, 0
        if spin then jx, jy = math.sin(t * 40 + cx) * 10 * s, math.cos(t * 37 + cy) * 10 * s end
        draw.rect(cx - size / 2 + jx + 4 * s, cy - size / 2 + jy + 5 * s, cx + size / 2 + jx + 4 * s, cy + size / 2 + jy + 5 * s, 0, 0, 0, 90, 10 * s)
        draw.rect(cx - size / 2 + jx, cy - size / 2 + jy, cx + size / 2 + jx, cy + size / 2 + jy, 235, 30, 40, 255, 10 * s)
        for _, p in ipairs(PIPS[v]) do
            draw.circle(cx + jx + p[1] * size * 0.27, cy + jy + p[2] * size * 0.27, size * 0.08, 255, 255, 255, 255)
        end
    end
    local dy = y0 + h * 0.46
    die(sw / 2 - 50 * s, dy, d1, rolling)
    die(sw / 2 + 50 * s, dy, d2, rolling)
    if d1 > 0 and not rolling then
        local tot = tostring(d1 + d2)
        text.draw(font.hud, sw / 2 - text.width(font.hud, tot) / 2, dy + 50 * s, 245, 245, 235, 255, tot)
    end

    local hist = {}
    for v in string.gmatch(f.history or "", "(%d+),") do hist[#hist + 1] = v end
    local hx = x0 + w - 30 * s
    for i = #hist, 1, -1 do
        local v = hist[i]
        local wv = text.width(font.hud_small, v)
        hx = hx - wv - 14 * s
        local r, g, b = 245, 245, 235
        if v == "7" then r, g, b = 255, 120, 110 end
        text.draw(font.hud_small, hx, y0 + h * 0.3, r, g, b, 255, v)
    end

    local hy = y0 - 56 * s
    text.draw(font.hud, x0, hy, 245, 245, 250, 255, "CASH " .. money(f.cash or 0))
    local net = math.floor(f.net or 0)
    local nr, ng, nb = 200, 200, 210
    if net > 0 then nr, ng, nb = 120, 240, 140 elseif net < 0 then nr, ng, nb = 255, 120, 100 end
    local ns = "SESSION " .. (net >= 0 and "+" or "") .. money(net)
    text.draw(font.hud, x0 + w - text.width(font.hud, ns), hy, nr, ng, nb, 255, ns)

    local msg, mr, mg, mb = "", 245, 245, 235
    local outcome = math.floor(f.outcome or 0)
    if state == 1 then
        msg = string.format("BET %s   A / D CHANGE BET   W / S SWITCH SIDE   E ROLL", money(f.bet or 0))
    elseif state == 2 then
        msg = "ROLLING..."
    elseif state == 3 then
        msg = string.format("POINT IS %d   %s   E ROLL", point, side == 0 and "HIT IT AGAIN BEFORE A 7" or "YOU WANT A 7 FIRST")
    elseif state == 4 then
        if outcome == 1 then msg, mr, mg, mb = "WINNER!", 120, 240, 140
        elseif outcome == 3 then msg, mr, mg, mb = "PUSH, BET RETURNED", 255, 210, 90
        else msg, mr, mg, mb = "THE HOUSE TAKES IT", 255, 110, 100 end
    end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + h + 26 * s, mr, mg, mb, 255, msg)
end)
