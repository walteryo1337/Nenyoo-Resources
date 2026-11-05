-- Pocket Reversi. Published fields: active (bool), state (1 your turn, 2 CPU thinking, 3 game over), cursor (square
-- index, row * 8 + col), last_move (square of the last disc placed, -1 none), you / cpu (disc counts), passed (bool, the
-- other side had no move and had to pass), wins / losses (this session), board (blob, 64 chars "0" empty, "1" your black
-- disc, "2" CPU white disc), legal (blob, "1" where you can play right now).
features.on_draw("Pocket Reversi", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cell = 66 * s
    local size = cell * 8
    local x0, y0 = sw / 2 - size / 2, sh / 2 - size / 2 + 20 * s
    draw.rect(x0 - 20 * s, y0 - 70 * s, x0 + size + 20 * s, y0 + size + 60 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0, y0, x0 + size, y0 + size, 30, 120, 70, 255, 4 * s)
    for i = 1, 7 do
        draw.line(x0 + i * cell, y0, x0 + i * cell, y0 + size, 15, 70, 40, 255, 2 * s)
        draw.line(x0, y0 + i * cell, x0 + size, y0 + i * cell, 15, 70, 40, 255, 2 * s)
    end

    local board, legal = f.board or "", f.legal or ""
    local last = math.floor(f.last_move or -1)
    for i = 0, 63 do
        local v = board:sub(i + 1, i + 1)
        local cx = x0 + (i % 8 + 0.5) * cell
        local cy = y0 + (math.floor(i / 8) + 0.5) * cell
        if v == "1" then draw.circle(cx, cy, cell * 0.4, 20, 20, 24, 255)
        elseif v == "2" then draw.circle(cx, cy, cell * 0.4, 240, 240, 245, 255)
        elseif legal:sub(i + 1, i + 1) == "1" then draw.circle(cx, cy, cell * 0.1, 15, 70, 40, 255) end
        if i == last then draw.circle(cx, cy, cell * 0.08, 230, 60, 60, 255) end
    end

    if math.floor(f.state or 0) == 1 then
        local c = math.floor(f.cursor or 0)
        local x, y = x0 + (c % 8) * cell, y0 + math.floor(c / 8) * cell
        draw.rect(x, y, x + cell, y + 3 * s, ar, ag, ab, 255, 0)
        draw.rect(x, y + cell - 3 * s, x + cell, y + cell, ar, ag, ab, 255, 0)
        draw.rect(x, y, x + 3 * s, y + cell, ar, ag, ab, 255, 0)
        draw.rect(x + cell - 3 * s, y, x + cell, y + cell, ar, ag, ab, 255, 0)
    end

    local you, cpu = math.floor(f.you or 0), math.floor(f.cpu or 0)
    text.draw(font.display, x0, y0 - 60 * s, 245, 245, 250, 255, string.format("YOU %d", you))
    local ct = string.format("%d CPU", cpu)
    text.draw(font.display, x0 + size - text.width(font.display, ct), y0 - 60 * s, 245, 245, 250, 255, ct)

    local state = math.floor(f.state or 0)
    local foot
    if state == 3 then
        foot = (you > cpu and "YOU WIN" or (cpu > you and "CPU WINS" or "DRAW")) ..
            string.format("   %d-%d   E TO PLAY AGAIN", math.floor(f.wins or 0), math.floor(f.losses or 0))
    elseif state == 2 then foot = "CPU IS THINKING"
    else foot = "W A S D MOVE     E PLACE" end
    if f.passed then foot = "NO MOVE, TURN PASSED   " .. foot end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, foot) / 2, y0 + size + 18 * s, 220, 220, 232, 240, foot)
end)
