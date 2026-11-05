-- Pocket Checkers. Published fields: active (bool), state (1 your turn, 2 phone thinking, 3 won, 4 lost, 5 draw), cx / cy
-- (cursor square), selected (square index of the piece you are moving, absent when none), ai_from / ai_to (the phone's
-- last move), board (blob, 64 chars row by row: "r" your man, "R" your king, "b" phone man, "B" phone king, "." empty),
-- marks (blob, 64 chars: "1" = a piece you can move, or a square the selected piece can land on), yours / theirs
-- (pieces left), wins, played, must_jump (bool, a capture is available so you have to take it).
features.on_draw("Pocket Checkers", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local c = 54 * s
    local bw = 8 * c
    local pw, ph = bw + 40 * s, bw + 130 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    local bx, by = x0 + 20 * s, y0 + 56 * s
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 12, 12, 230, 12 * s)
    text.draw(font.hud, x0 + 20 * s, y0 + 16 * s, 245, 245, 250, 255, "CHECKERS")
    local tally = string.format("YOU %d   PHONE %d", math.floor(f.yours or 0), math.floor(f.theirs or 0))
    text.draw(font.hud_small, x0 + pw - 20 * s - text.width(font.hud_small, tally), y0 + 20 * s, 200, 200, 212, 255, tally)

    local board, marks = f.board or "", f.marks or ""
    local state = math.floor(f.state or 0)
    local sel = f.selected and math.floor(f.selected)
    local af, at = f.ai_from and math.floor(f.ai_from), f.ai_to and math.floor(f.ai_to)
    for i = 0, 63 do
        local r, col = math.floor(i / 8), i % 8
        local x, y = bx + col * c, by + r * c
        if (r + col) % 2 == 1 then draw.rect(x, y, x + c, y + c, 70, 45, 30, 255, 0)
        else draw.rect(x, y, x + c, y + c, 220, 200, 170, 255, 0) end
        if i == af or i == at then draw.rect(x, y, x + c, y + c, 120, 160, 255, 70, 0) end
        local m = marks:sub(i + 1, i + 1) == "1"
        local ch = board:sub(i + 1, i + 1)
        if m and ch == "." then draw.circle(x + c / 2, y + c / 2, c * 0.14, 120, 240, 120, 200) end
        if ch ~= "." and ch ~= "" then
            local mine = ch == "r" or ch == "R"
            local pr, pg, pb = 210, 50, 50
            if not mine then pr, pg, pb = 35, 35, 40 end
            draw.circle(x + c / 2, y + c / 2 + 3 * s, c * 0.38, 0, 0, 0, 120)
            draw.circle(x + c / 2, y + c / 2, c * 0.38, pr, pg, pb, 255)
            draw.circle_outline(x + c / 2, y + c / 2, c * 0.27, math.min(255, pr + 40), math.min(255, pg + 40), math.min(255, pb + 40), 255, 2 * s)
            if ch == "R" or ch == "B" then
                local cw = c * 0.3
                draw.rect(x + c / 2 - cw / 2, y + c / 2 - cw * 0.25, x + c / 2 + cw / 2, y + c / 2 + cw * 0.3, 245, 205, 70, 255, 2 * s)
                for k = -1, 1 do draw.circle(x + c / 2 + k * cw * 0.4, y + c / 2 - cw * 0.35, 3 * s, 245, 205, 70, 255) end
            end
            if m and mine and not sel then draw.circle_outline(x + c / 2, y + c / 2, c * 0.44, 120, 240, 120, 220, 2 * s) end
        end
        if sel == i then draw.circle_outline(x + c / 2, y + c / 2, c * 0.46, 255, 230, 90, 255, 3 * s) end
    end

    if state == 1 then
        local x, y = bx + math.floor(f.cx or 0) * c, by + math.floor(f.cy or 0) * c
        local a = math.floor(255 * (0.6 + 0.4 * math.sin(t * 8)))
        draw.rect(x, y, x + c, y + 3 * s, 255, 230, 90, a, 0)
        draw.rect(x, y + c - 3 * s, x + c, y + c, 255, 230, 90, a, 0)
        draw.rect(x, y, x + 3 * s, y + c, 255, 230, 90, a, 0)
        draw.rect(x + c - 3 * s, y, x + c, y + c, 255, 230, 90, a, 0)
    end

    local msg, cr, cg, cb
    if state == 1 then
        if sel then msg = "E MOVE HERE   Q PICK ANOTHER PIECE" else msg = "W A S D MOVE   E PICK UP A PIECE" end
        cr, cg, cb = 220, 220, 232
        if f.must_jump then msg, cr, cg, cb = msg .. "   YOU MUST JUMP", 255, 190, 90 end
    elseif state == 2 then msg, cr, cg, cb = "PHONE IS THINKING...", 255, 180, 90
    elseif state == 3 then msg, cr, cg, cb = "YOU WIN!   E TO PLAY AGAIN", 120, 240, 120
    elseif state == 4 then msg, cr, cg, cb = "YOU LOSE   E TO PLAY AGAIN", 255, 100, 100
    else msg, cr, cg, cb = "DRAW   E TO PLAY AGAIN", 220, 220, 120 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, by + bw + 16 * s, cr, cg, cb, 255, msg)
    local rec = string.format("WINS %d/%d", math.floor(f.wins or 0), math.floor(f.played or 0))
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, rec) / 2, by + bw + 42 * s, 160, 160, 175, 255, rec)
end)
