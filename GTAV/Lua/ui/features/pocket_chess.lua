-- Pocket Chess. Published fields: active (bool), state (1 your turn, 2 phone thinking, 3 won, 4 lost, 5 draw), cx / cy
-- (cursor square), selected (square index of the piece you picked up, absent when none), last_from / last_to (last move),
-- in_check (bool, the side to move is in check), wins / losses / draws, material (your material lead in centipawns),
-- board (blob, 64 chars row by row from the phone's side: uppercase PNBRQK yours, lowercase the phone's, "." empty),
-- marks (blob, 64 chars: "1" = a square the selected piece can move to).
local glyph = { k = "K", q = "Q", r = "R", b = "B", n = "N", p = "" }

local function piece(cx, cy, size, ch, s)
    local mine = ch == ch:upper()
    local t = ch:lower()
    local fr, fg, fb = 245, 240, 230
    local er, eg, eb = 40, 40, 46
    if not mine then fr, fg, fb, er, eg, eb = 40, 40, 46, 230, 225, 215 end
    local r = size * (t == "p" and 0.26 or 0.36)
    draw.circle(cx + 2 * s, cy + 3 * s, r, 0, 0, 0, 90)
    draw.circle(cx, cy, r, fr, fg, fb, 255)
    draw.circle_outline(cx, cy, r, er, eg, eb, 255, 2 * s)
    if t == "k" then
        draw.rect(cx - r * 0.12, cy - r * 1.25, cx + r * 0.12, cy - r * 0.7, er, eg, eb, 255, 0)
        draw.rect(cx - r * 0.35, cy - r * 1.1, cx + r * 0.35, cy - r * 0.9, er, eg, eb, 255, 0)
    elseif t == "q" then
        for k = -1, 1 do draw.circle(cx + k * r * 0.45, cy - r * 1.0, 3 * s, er, eg, eb, 255) end
    end
    local g = glyph[t] or ""
    if g ~= "" then text.draw(font.hud, cx - text.width(font.hud, g) / 2, cy - text.height(font.hud) / 2, er, eg, eb, 255, g) end
end

features.on_draw("Pocket Chess", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local c = 66 * s
    local bw = c * 8
    local pw, ph = bw + 60 * s, bw + 130 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    local bx, by = x0 + 40 * s, y0 + 56 * s
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 14, 18, 235, 12 * s)
    text.draw(font.hud, x0 + 20 * s, y0 + 16 * s, 245, 245, 250, 255, "CHESS")
    local rec = string.format("W %d   L %d   D %d", math.floor(f.wins or 0), math.floor(f.losses or 0), math.floor(f.draws or 0))
    text.draw(font.hud_small, x0 + pw - 20 * s - text.width(font.hud_small, rec), y0 + 20 * s, 190, 190, 205, 255, rec)

    local board, marks = f.board or "", f.marks or ""
    local sel = f.selected and math.floor(f.selected)
    local lf, lt = f.last_from and math.floor(f.last_from), f.last_to and math.floor(f.last_to)
    local state = math.floor(f.state or 0)
    for i = 0, 63 do
        local r, col = math.floor(i / 8), i % 8
        local x, y = bx + col * c, by + r * c
        if (r + col) % 2 == 0 then draw.rect(x, y, x + c, y + c, 235, 215, 180, 255, 0)
        else draw.rect(x, y, x + c, y + c, 180, 135, 95, 255, 0) end
        if i == lf or i == lt then draw.rect(x, y, x + c, y + c, 250, 230, 90, 90, 0) end
        if i == sel then draw.rect(x, y, x + c, y + c, 120, 200, 255, 120, 0) end
        local ch = board:sub(i + 1, i + 1)
        if ch == "K" and f.in_check and state == 1 then draw.circle(x + c / 2, y + c / 2, c * 0.48, 255, 60, 60, 140) end
        if ch == "k" and f.in_check and state == 2 then draw.circle(x + c / 2, y + c / 2, c * 0.48, 255, 60, 60, 140) end
        if ch ~= "." and ch ~= "" then piece(x + c / 2, y + c / 2, c, ch, s) end
        if marks:sub(i + 1, i + 1) == "1" then
            if ch ~= "." then draw.circle_outline(x + c / 2, y + c / 2, c * 0.45, 60, 160, 90, 230, 3 * s)
            else draw.circle(x + c / 2, y + c / 2, c * 0.13, 60, 160, 90, 200) end
        end
    end
    for k = 0, 7 do
        text.draw(font.hud_tiny, bx - 16 * s, by + k * c + c / 2 - text.height(font.hud_tiny) / 2, 160, 160, 175, 255, tostring(8 - k))
        local file = string.sub("abcdefgh", k + 1, k + 1)
        text.draw(font.hud_tiny, bx + k * c + c / 2 - text.width(font.hud_tiny, file) / 2, by + bw + 4 * s, 160, 160, 175, 255, file)
    end
    if state == 1 then
        local x, y = bx + math.floor(f.cx or 0) * c, by + math.floor(f.cy or 0) * c
        local a = math.floor(255 * (0.6 + 0.4 * math.sin(t * 8)))
        draw.rect(x, y, x + c, y + 3 * s, 40, 120, 255, a, 0)
        draw.rect(x, y + c - 3 * s, x + c, y + c, 40, 120, 255, a, 0)
        draw.rect(x, y, x + 3 * s, y + c, 40, 120, 255, a, 0)
        draw.rect(x + c - 3 * s, y, x + c, y + c, 40, 120, 255, a, 0)
    end

    local msg, cr, cg, cb
    if state == 1 then
        msg = sel and "E MOVE HERE   Q PUT IT BACK" or "W A S D MOVE   E PICK UP A PIECE"
        cr, cg, cb = 220, 220, 232
        if f.in_check then msg, cr, cg, cb = "CHECK!   " .. msg, 255, 120, 100 end
    elseif state == 2 then msg, cr, cg, cb = f.in_check and "CHECK!   PHONE IS THINKING..." or "PHONE IS THINKING...", 255, 180, 90
    elseif state == 3 then msg, cr, cg, cb = "CHECKMATE - YOU WIN!   E TO PLAY AGAIN", 120, 240, 120
    elseif state == 4 then msg, cr, cg, cb = "CHECKMATE - YOU LOSE   E TO PLAY AGAIN", 255, 100, 100
    else msg, cr, cg, cb = "DRAW   E TO PLAY AGAIN", 220, 220, 120 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, by + bw + 26 * s, cr, cg, cb, 255, msg)
    local m = math.floor((f.material or 0) / 100)
    if m ~= 0 then
        local mt = m > 0 and string.format("YOU +%d", m) or string.format("PHONE +%d", -m)
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, mt) / 2, by + bw + 50 * s, 160, 160, 175, 255, mt)
    end
end)
