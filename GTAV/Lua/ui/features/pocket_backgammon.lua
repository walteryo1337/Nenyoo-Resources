-- Pocket Backgammon. Published fields: active (bool), state (1 your roll, 2 your move, 3 the phone's turn, 4 no legal
-- moves, 5 game over, 6 match over), state_age (ms), board (blob of 24 "n," counts for points 0-23: positive yours,
-- negative the phone's; you move from 23 down to 0 and bear off from 0-5), bar_you / bar_phone, off_you / off_phone,
-- d1 / d2 (dice rolled), dice_left (blob "d," dice still to play), row / col (cursor: row 0 top shows points 12-23 left
-- to right, row 1 bottom shows 11-0, col 12 on the bottom row is your bear-off tray), sel (picked point, 24 the bar,
-- -1 none), dests (blob of 26 chars indexed by point, 25 = off: '1' the picked checker can land there, '2' a checker
-- here can move), phone_moves (blob "from>to," the phone has played this turn; 24 bar, 25 off), score_you /
-- score_phone, match_to, game_points / winner (0 you, 1 phone; last game), no_moves_side, pip_you / pip_phone.
local PIPS = {
    { { 0, 0 } }, { { -1, -1 }, { 1, 1 } }, { { -1, -1 }, { 0, 0 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }, { { -1, -1 }, { 1, -1 }, { 0, 0 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 1, 1 } },
}

features.on_draw("Pocket Backgammon", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local cw, barw, trayw = 64 * s, 44 * s, 70 * s
    local bh = 600 * s
    local bw = 12 * cw + barw
    local x0 = sw / 2 - (bw + trayw + 14 * s) / 2
    local y0 = sh / 2 - bh / 2 + 18 * s
    local th = bh * 0.4
    draw.rect(x0 - 20 * s, y0 - 70 * s, x0 + bw + trayw + 34 * s, y0 + bh + 60 * s, 40, 24, 12, 240, 14 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 24, 82, 52, 255, 6 * s)
    draw.rect(x0 + 6 * cw, y0, x0 + 6 * cw + barw, y0 + bh, 70, 42, 20, 255, 0)
    local tx0 = x0 + bw + 14 * s
    draw.rect(tx0, y0, tx0 + trayw, y0 + bh, 70, 42, 20, 255, 6 * s)

    local board = {}
    for v in string.gmatch(f.board or "", "(%-?%d+),") do board[#board + 1] = tonumber(v) end
    local dests = f.dests or ""
    local function dest(i) return string.sub(dests, i + 1, i + 1) end
    local function col_x(col) return x0 + col * cw + cw / 2 + (col >= 6 and barw or 0) end
    local function point_slot(pt)
        if pt >= 12 then return 0, pt - 12 end
        return 1, 11 - pt
    end

    local phone_to = {}
    for a, b in string.gmatch(f.phone_moves or "", "(%d+)>(%d+),") do phone_to[tonumber(b)] = true end

    local r = cw * 0.42
    for pt = 0, 23 do
        local row, col = point_slot(pt)
        local cx = col_x(col)
        local base = row == 0 and y0 or y0 + bh
        local tip = row == 0 and y0 + th or y0 + bh - th
        local dark = (pt % 2 == 0)
        local cr, cg, cb = 210, 180, 130
        if dark then cr, cg, cb = 140, 40, 30 end
        for k = 0, 7 do
            local bx = cx - cw / 2 + (k + 0.5) * cw / 8
            draw.line(bx, base, cx, tip, cr, cg, cb, 255, cw / 8 + 1)
        end
        local d = dest(pt)
        if d == "1" then
            local p = 0.5 + 0.5 * math.abs(math.sin(t * 5))
            draw.circle(cx, tip + (row == 0 and 14 * s or -14 * s), 10 * s, 120, 240, 140, math.floor(255 * p))
        end
        local n = board[pt + 1] or 0
        local cnt = math.abs(n)
        local mine = n > 0
        for k = 1, math.min(cnt, 5) do
            local cy = row == 0 and (y0 + r + (k - 1) * r * 2) or (y0 + bh - r - (k - 1) * r * 2)
            draw.circle(cx + 2 * s, cy + 3 * s, r, 0, 0, 0, 90)
            if mine then
                draw.circle(cx, cy, r, 235, 230, 218, 255)
                draw.circle_outline(cx, cy, r * 0.7, 200, 194, 180, 255, 2 * s)
            else
                draw.circle(cx, cy, r, 150, 26, 30, 255)
                draw.circle_outline(cx, cy, r * 0.7, 190, 60, 60, 255, 2 * s)
            end
            if k == math.min(cnt, 5) then
                if math.floor(f.sel or -1) == pt then draw.circle_outline(cx, cy, r + 4 * s, 255, 200, 60, 255, 3 * s) end
                if phone_to[pt] and not mine then draw.circle_outline(cx, cy, r + 3 * s, 255, 110, 90, 200, 2 * s) end
                if d == "2" and state == 2 then draw.circle(cx, cy, r * 0.22, 255, 200, 60, 255) end
                if cnt > 5 then
                    local label = tostring(cnt)
                    text.draw(font.hud_small, cx - text.width(font.hud_small, label) / 2, cy - text.height(font.hud_small) / 2, mine and 40 or 255, mine and 40 or 255, mine and 40 or 255, 255, label)
                end
            end
        end
    end

    local bx = x0 + 6 * cw + barw / 2
    for k = 1, math.floor(f.bar_phone or 0) do
        draw.circle(bx, y0 + bh / 2 - r - (k - 1) * r * 1.6 - 10 * s, r * 0.9, 150, 26, 30, 255)
    end
    for k = 1, math.floor(f.bar_you or 0) do
        local cy = y0 + bh / 2 + r + (k - 1) * r * 1.6 + 10 * s
        draw.circle(bx, cy, r * 0.9, 235, 230, 218, 255)
        if math.floor(f.sel or -1) == 24 and k == math.floor(f.bar_you or 0) then draw.circle_outline(bx, cy, r + 3 * s, 255, 200, 60, 255, 3 * s) end
    end

    local function tray(count, top, rr, gg, bb)
        for k = 1, count do
            local yy = top and (y0 + 10 * s + (k - 1) * 13 * s) or (y0 + bh - 10 * s - k * 13 * s)
            draw.rect(tx0 + 8 * s, yy, tx0 + trayw - 8 * s, yy + 10 * s, rr, gg, bb, 255, 3 * s)
        end
    end
    tray(math.floor(f.off_phone or 0), true, 150, 26, 30)
    tray(math.floor(f.off_you or 0), false, 235, 230, 218)
    if dest(25) == "1" then
        local p = 0.5 + 0.5 * math.abs(math.sin(t * 5))
        draw.rect(tx0 + 4 * s, y0 + bh / 2 + 10 * s, tx0 + trayw - 4 * s, y0 + bh - 4 * s, 120, 240, 140, math.floor(90 * p), 6 * s)
    end

    if state == 1 or state == 2 then
        local row, col = math.floor(f.row or 1), math.floor(f.col or 6)
        local a = 150 + math.floor(100 * math.abs(math.sin(t * 6)))
        if row == 1 and col == 12 then
            draw.line(tx0 - 3 * s, y0 + bh + 3 * s, tx0 + trayw + 3 * s, y0 + bh + 3 * s, 255, 255, 255, a, 4 * s)
        else
            local cx = col_x(col)
            local yy = row == 0 and y0 - 8 * s or y0 + bh + 8 * s
            draw.line(cx - cw / 2 + 4 * s, yy, cx + cw / 2 - 4 * s, yy, 255, 255, 255, a, 4 * s)
        end
    end

    local d1, d2 = math.floor(f.d1 or 0), math.floor(f.d2 or 0)
    local left = {}
    for v in string.gmatch(f.dice_left or "", "(%d+),") do left[#left + 1] = tonumber(v) end
    local function die(cx, cy, v, dim, phone)
        if v < 1 or v > 6 then return end
        local sz = 46 * s
        local alpha = dim and 90 or 255
        local fr, fg, fb, pr, pg, pb = 245, 242, 232, 30, 30, 30
        if phone then fr, fg, fb, pr, pg, pb = 150, 26, 30, 245, 240, 230 end
        draw.rect(cx - sz / 2, cy - sz / 2, cx + sz / 2, cy + sz / 2, fr, fg, fb, alpha, 8 * s)
        for _, p in ipairs(PIPS[v]) do draw.circle(cx + p[1] * sz * 0.27, cy + p[2] * sz * 0.27, sz * 0.08, pr, pg, pb, alpha) end
    end
    if d1 > 0 and (state == 2 or state == 3 or state == 4) then
        local phone = state == 3 or (state == 4 and math.floor(f.no_moves_side or 0) == 1)
        local dcx = phone and (x0 + 3 * cw) or (x0 + 6 * cw + barw + 3 * cw)
        local dcy = y0 + bh / 2
        if d1 == d2 then
            for k = 1, 4 do die(dcx - 84 * s + (k - 1) * 56 * s, dcy, d1, k > #left, phone) end
        else
            local used1, used2 = true, true
            for _, v in ipairs(left) do
                if v == d1 and used1 then used1 = false elseif v == d2 and used2 then used2 = false end
            end
            die(dcx - 30 * s, dcy, d1, used1, phone)
            die(dcx + 30 * s, dcy, d2, used2, phone)
        end
    end

    local hy = y0 - 56 * s
    local need = math.floor(f.match_to or 5)
    text.draw(font.hud, x0, hy, 235, 230, 218, 255, string.format("YOU %d", math.floor(f.score_you or 0)))
    local mid = string.format("FIRST TO %d   PIPS %d : %d", need, math.floor(f.pip_you or 0), math.floor(f.pip_phone or 0))
    text.draw(font.hud_small, x0 + bw / 2 - text.width(font.hud_small, mid) / 2, hy + 4 * s, 220, 210, 190, 255, mid)
    local ph = string.format("PHONE %d", math.floor(f.score_phone or 0))
    text.draw(font.hud, x0 + bw - text.width(font.hud, ph), hy, 230, 90, 90, 255, ph)

    local msg, mr, mg, mb = "", 235, 230, 218
    local pts = math.floor(f.game_points or 1)
    local kind = pts == 3 and "BACKGAMMON" or (pts == 2 and "GAMMON" or "GAME")
    if state == 1 then msg = "YOUR TURN   E TO ROLL"
    elseif state == 2 then msg = "W S PICK ROW   A D MOVE   E PICK A CHECKER, E ON A GREEN SPOT   Q UNDO"
    elseif state == 3 then msg, mr, mg, mb = "THE PHONE IS PLAYING...", 255, 150, 140
    elseif state == 4 then
        if math.floor(f.no_moves_side or 0) == 0 then msg, mr, mg, mb = "NO LEGAL MOVES FOR YOU", 255, 200, 90
        else msg, mr, mg, mb = "THE PHONE CANNOT MOVE", 255, 200, 90 end
    elseif state == 5 or state == 6 then
        local you_won = math.floor(f.winner or 0) == 0
        local tail = state == 6 and "   MATCH OVER   E NEW MATCH" or "   E NEXT GAME"
        if you_won then msg, mr, mg, mb = string.format("YOU WIN THE %s (+%d)%s", kind, pts, tail), 120, 240, 140
        else msg, mr, mg, mb = string.format("THE PHONE WINS THE %s (+%d)%s", kind, pts, tail), 255, 110, 100 end
    end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + bh + 22 * s, mr, mg, mb, 255, msg)
end)
