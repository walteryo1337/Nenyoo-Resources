-- Pocket Solitaire (Klondike). Published fields: active (bool), state (1 playing, 2 auto-finishing, 3 won), state_age
-- (ms), stock_n (cards left in the stock), waste (blob "card," showing the face-up waste, top card last), found (blob of
-- 4 "n," foundation counts for spades, hearts, diamonds, clubs), tableau (blob, per column "facedown:card,card,...|"),
-- row / col / depth (cursor: row 0 is stock, waste, gap, then the four foundations; row 1 the seven columns, depth the
-- card index in the column), holding (bool) with hold_row / hold_col / hold_depth, moves, elapsed (ms), wins, best (ms),
-- restart_hold (0-1 while Q is held to redeal). A card is suit * 13 + rank - 1 (suits 0 spades, 1 hearts, 2 diamonds,
-- 3 clubs).
local RANKS = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" }

local function clock(ms)
    local secs = math.floor((ms or 0) / 1000)
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

local function suit_icon(x, y, sz, suit)
    local red = suit == 1 or suit == 2
    local r, g, b = 20, 20, 26
    if red then r, g, b = 210, 30, 40 end
    if suit == 2 then
        for k = 0, 4 do
            local w = sz * (1 - k / 5)
            draw.line(x - w, y - k * sz / 5, x + w, y - k * sz / 5, r, g, b, 255, sz / 5 + 1)
            draw.line(x - w, y + k * sz / 5, x + w, y + k * sz / 5, r, g, b, 255, sz / 5 + 1)
        end
    elseif suit == 1 then
        draw.circle(x - sz * 0.45, y - sz * 0.25, sz * 0.5, r, g, b, 255)
        draw.circle(x + sz * 0.45, y - sz * 0.25, sz * 0.5, r, g, b, 255)
        for k = 0, 5 do
            local w = sz * 0.95 * (1 - k / 6)
            draw.line(x - w, y + k * sz / 6, x + w, y + k * sz / 6, r, g, b, 255, sz / 6 + 1)
        end
    elseif suit == 0 then
        draw.circle(x - sz * 0.42, y + sz * 0.2, sz * 0.46, r, g, b, 255)
        draw.circle(x + sz * 0.42, y + sz * 0.2, sz * 0.46, r, g, b, 255)
        for k = 0, 5 do
            local w = sz * 0.9 * (1 - k / 6)
            draw.line(x - w, y - k * sz / 6, x + w, y - k * sz / 6, r, g, b, 255, sz / 6 + 1)
        end
        draw.line(x, y + sz * 0.3, x, y + sz, r, g, b, 255, sz * 0.25)
    else
        draw.circle(x, y - sz * 0.45, sz * 0.42, r, g, b, 255)
        draw.circle(x - sz * 0.45, y + sz * 0.15, sz * 0.42, r, g, b, 255)
        draw.circle(x + sz * 0.45, y + sz * 0.15, sz * 0.42, r, g, b, 255)
        draw.line(x, y, x, y + sz, r, g, b, 255, sz * 0.25)
    end
end

features.on_draw("Pocket Solitaire", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local cw, ch, gap = 86 * s, 120 * s, 16 * s
    local bw = 7 * cw + 6 * gap
    local x0 = sw / 2 - bw / 2
    local y0 = sh / 2 - 330 * s
    local tab_y = y0 + ch + 34 * s
    local bottom = y0 + 680 * s
    draw.rect(x0 - 30 * s, y0 - 70 * s, x0 + bw + 30 * s, bottom + 60 * s, 18, 80, 44, 240, 14 * s)

    local function col_x(c) return x0 + c * (cw + gap) end
    local function card_back(x, y)
        draw.rect(x, y, x + cw, y + ch, 245, 245, 245, 255, 8 * s)
        draw.rect(x + 5 * s, y + 5 * s, x + cw - 5 * s, y + ch - 5 * s, 40, 70, 160, 255, 6 * s)
        draw.rect(x + 12 * s, y + 12 * s, x + cw - 12 * s, y + ch - 12 * s, 60, 100, 200, 255, 4 * s)
    end
    local function card_face(x, y, card)
        local suit, rank = math.floor(card / 13), card % 13 + 1
        draw.rect(x + 3 * s, y + 4 * s, x + cw + 3 * s, y + ch + 4 * s, 0, 0, 0, 70, 8 * s)
        draw.rect(x, y, x + cw, y + ch, 250, 250, 246, 255, 8 * s)
        local red = suit == 1 or suit == 2
        local r, g, b = 20, 20, 26
        if red then r, g, b = 210, 30, 40 end
        text.draw(font.hud, x + 7 * s, y + 3 * s, r, g, b, 255, RANKS[rank])
        suit_icon(x + cw - 18 * s, y + 18 * s, 9 * s, suit)
        suit_icon(x + cw / 2, y + ch * 0.6, 20 * s, suit)
    end
    local function slot(x, y)
        draw.rect(x, y, x + cw, y + ch, 255, 255, 255, 30, 8 * s)
    end
    local function outline(x, y, h, r, g, b, a)
        local th = 3 * s
        draw.line(x - th, y - th, x + cw + th, y - th, r, g, b, a, th)
        draw.line(x - th, y + h + th, x + cw + th, y + h + th, r, g, b, a, th)
        draw.line(x - th, y - th, x - th, y + h + th, r, g, b, a, th)
        draw.line(x + cw + th, y - th, x + cw + th, y + h + th, r, g, b, a, th)
    end

    local row, col, depth = math.floor(f.row or 1), math.floor(f.col or 0), math.floor(f.depth or 0)
    local holding = f.holding
    local hr, hc, hd = math.floor(f.hold_row or 0), math.floor(f.hold_col or 0), math.floor(f.hold_depth or 0)
    local cur_a = 160 + math.floor(90 * math.abs(math.sin(t * 6)))

    local stock_n = math.floor(f.stock_n or 0)
    if stock_n > 0 then card_back(col_x(0), y0) else slot(col_x(0), y0) end
    local waste = {}
    for v in string.gmatch(f.waste or "", "(%d+),") do waste[#waste + 1] = tonumber(v) end
    if #waste == 0 then slot(col_x(1), y0) end
    for i, card in ipairs(waste) do
        local x = col_x(1) + (i - 1) * 20 * s
        local y = y0
        if i == #waste and holding and hr == 0 and hc == 1 then y = y - 14 * s end
        card_face(x, y, card)
    end
    local found = {}
    for v in string.gmatch(f.found or "", "(%d+),") do found[#found + 1] = tonumber(v) end
    for i = 1, 4 do
        local x = col_x(2 + i)
        local n = found[i] or 0
        if n > 0 then
            local y = y0
            if holding and hr == 0 and hc == 2 + i then y = y - 14 * s end
            card_face(x, y, (i - 1) * 13 + n - 1)
        else
            slot(x, y0)
            suit_icon(x + cw / 2, y0 + ch / 2, 16 * s, i - 1)
        end
    end
    if state == 1 and row == 0 then outline(col_x(col), y0, ch, 255, 200, 40, cur_a) end

    local c = 0
    for down, cards in string.gmatch(f.tableau or "", "(%d+):([^|]*)|") do
        down = tonumber(down)
        local list = {}
        for v in string.gmatch(cards, "(%d+),") do list[#list + 1] = tonumber(v) end
        local x = col_x(c)
        local n = #list
        if n == 0 then slot(x, tab_y) end
        local avail = bottom - tab_y - ch
        local up_off = 30 * s
        local down_off = 12 * s
        local need = down * down_off + math.max(0, n - down - 1) * up_off
        if need > avail and n - down > 1 then up_off = math.max(12 * s, (avail - down * down_off) / (n - down - 1)) end
        local y = tab_y
        local cur_y, cur_h
        for i = 1, n do
            local idx = i - 1
            local lifted = holding and hr == 1 and hc == c and idx >= hd
            local yy = lifted and y - 14 * s or y
            if idx < down then card_back(x, yy) else card_face(x, yy, list[i]) end
            if state == 1 and row == 1 and col == c and idx == depth then
                cur_y = yy
                cur_h = ch + (n - 1 - idx) * up_off
            end
            y = y + (idx < down and down_off or up_off)
        end
        if state == 1 and row == 1 and col == c then
            if n == 0 then outline(x, tab_y, ch, 255, 200, 40, cur_a)
            elseif cur_y then outline(x, cur_y, cur_h, 255, 200, 40, cur_a) end
        end
        c = c + 1
    end

    local hy = y0 - 56 * s
    text.draw(font.hud, x0, hy, 245, 245, 235, 255, clock(f.elapsed))
    local mid = string.format("MOVES %d   WINS %d", math.floor(f.moves or 0), math.floor(f.wins or 0))
    text.draw(font.hud_small, x0 + bw / 2 - text.width(font.hud_small, mid) / 2, hy + 4 * s, 220, 235, 220, 255, mid)
    if f.best then
        local b = "BEST " .. clock(f.best)
        text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, b), hy + 4 * s, 255, 210, 90, 255, b)
    end
    local hold = f.restart_hold or 0
    if hold > 0 then
        draw.rect(x0, hy + 34 * s, x0 + 160 * s, hy + 40 * s, 30, 50, 34, 255, 3 * s)
        draw.rect(x0, hy + 34 * s, x0 + 160 * s * math.min(1, hold), hy + 40 * s, 255, 120, 80, 255, 3 * s)
    end

    local msg, mr, mg, mb = "W A S D MOVE   E PICK UP / DROP / DRAW   Q SEND TO FOUNDATION   HOLD Q REDEAL", 230, 240, 230
    if state == 2 then msg = "FINISHING UP..."
    elseif state == 3 then msg, mr, mg, mb = string.format("SOLVED IN %s, %d MOVES!   E TO DEAL AGAIN", clock(f.elapsed), math.floor(f.moves or 0)), 255, 230, 120 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, bottom + 24 * s, mr, mg, mb, 255, msg)
end)
