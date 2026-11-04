-- Pocket Mancala. Published fields: active (bool), state (1 your turn, 2 phone thinking, 3 won, 4 lost, 5 draw), cursor
-- (0-5, your pit), board (blob, 14 comma-separated seed counts: 0-5 your pits left to right, 6 your store on the right,
-- 7-12 the phone's pits right to left along the top, 13 the phone's store on the left), last_pit / last_end (slot the
-- last move started from and where its final seed landed) + last_age (ms), extra (bool, that move earned another turn),
-- captured (bool, it captured), wins, played.
local function seeds(cx, cy, n, r, s)
    local shown = math.min(n, 12)
    for i = 1, shown do
        local a = i * 2.39996
        local d = r * 0.55 * math.sqrt(i / 12)
        draw.circle(cx + math.cos(a) * d, cy + math.sin(a) * d, 4.5 * s, 180 + (i * 37) % 70, 120 + (i * 53) % 90, 200 - (i * 29) % 80, 255)
    end
end

features.on_draw("Pocket Mancala", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local b = {}
    for v in string.gmatch(f.board or "", "(%d+),") do b[#b + 1] = tonumber(v) end
    if #b < 14 then return end
    local pr = 38 * s
    local gap = 92 * s
    local bw = gap * 6 + 2 * 110 * s
    local pw, ph = bw + 40 * s, 330 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 12, 12, 230, 12 * s)
    text.draw(font.item, x0 + 20 * s, y0 + 16 * s, 245, 245, 250, 255, "MANCALA")
    local rec = string.format("WINS %d/%d", math.floor(f.wins or 0), math.floor(f.played or 0))
    text.draw(font.small, x0 + pw - 20 * s - text.width(font.small, rec), y0 + 20 * s, 190, 190, 205, 255, rec)

    local bx, by = x0 + 20 * s, y0 + 60 * s
    local bh = 210 * s
    draw.rect(bx, by, bx + bw, by + bh, 120, 75, 40, 255, 40 * s)
    local cx_left, cx_right = bx + 55 * s, bx + bw - 55 * s
    local cy_mid = by + bh / 2
    local top_y, bot_y = by + bh * 0.27, by + bh * 0.73
    local state = math.floor(f.state or 0)
    local fresh = (f.last_age or 99999) < 900
    local last_end = f.last_end and math.floor(f.last_end) + 1

    -- idx is the 1-based board index: 1-6 your pits, 8-13 the phone's pits (right to left)
    local function pit_pos(idx)
        if idx <= 6 then return bx + 110 * s + (idx - 0.5) * gap, bot_y end
        return bx + 110 * s + (13 - idx + 0.5) * gap, top_y
    end
    for idx = 1, 13 do
        if idx ~= 7 then
            local px, py = pit_pos(idx)
            draw.circle(px, py, pr, 70, 40, 20, 255)
            if fresh and last_end == idx then draw.circle_outline(px, py, pr + 3 * s, 255, 230, 120, 220, 3 * s) end
            seeds(px, py, b[idx], pr, s)
            local n = tostring(b[idx])
            local ly = idx <= 6 and py + pr + 6 * s or py - pr - 6 * s - text.height(font.small)
            text.draw(font.small, px - text.width(font.small, n) / 2, ly, 245, 235, 220, 255, n)
        end
    end
    for _, st in ipairs({ { 7, cx_right }, { 14, cx_left } }) do
        local idx, sx = st[1], st[2]
        draw.rect(sx - 38 * s, by + 22 * s, sx + 38 * s, by + bh - 22 * s, 70, 40, 20, 255, 36 * s)
        if fresh and last_end == idx then draw.rect(sx - 40 * s, by + 20 * s, sx + 40 * s, by + bh - 20 * s, 255, 230, 120, 60, 36 * s) end
        local n = tostring(b[idx])
        text.draw(font.title, sx - text.width(font.title, n) / 2, cy_mid - text.height(font.title) / 2, 245, 235, 220, 255, n)
    end
    text.draw(font.tiny, cx_right - text.width(font.tiny, "YOU") / 2, by + bh - 18 * s, 255, 230, 120, 255, "YOU")
    text.draw(font.tiny, cx_left - text.width(font.tiny, "PHONE") / 2, by + bh - 18 * s, 220, 220, 230, 255, "PHONE")

    if state == 1 then
        local px, py = pit_pos(math.floor(f.cursor or 0) + 1)
        local a = math.floor(255 * (0.6 + 0.4 * math.sin(t * 8)))
        draw.circle_outline(px, py, pr + 7 * s, 255, 255, 255, a, 3 * s)
    end

    local msg, cr, cg, cb
    if state == 1 then
        msg, cr, cg, cb = "A / D PICK A PIT   E SOW", 220, 220, 232
        local mine = f.last_pit and f.last_pit < 6
        if fresh and mine and f.extra then msg, cr, cg, cb = "LAST SEED IN YOUR STORE - GO AGAIN", 120, 240, 140 end
        if fresh and mine and f.captured then msg, cr, cg, cb = "CAPTURE!", 255, 220, 90 end
        if fresh and not mine and f.captured then msg, cr, cg, cb = "THE PHONE CAPTURED YOUR SEEDS", 255, 140, 90 end
    elseif state == 2 then msg, cr, cg, cb = "PHONE IS THINKING...", 255, 180, 90
    elseif state == 3 then msg, cr, cg, cb = "YOU WIN!   E TO PLAY AGAIN", 120, 240, 120
    elseif state == 4 then msg, cr, cg, cb = "YOU LOSE   E TO PLAY AGAIN", 255, 100, 100
    else msg, cr, cg, cb = "DRAW   E TO PLAY AGAIN", 220, 220, 120 end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, by + bh + 20 * s, cr, cg, cb, 255, msg)
end)
