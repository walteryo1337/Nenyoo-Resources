-- Pocket Gomoku. Published fields: active (bool), state (1 your turn, 2 CPU thinking, 3 game over), cursor
-- (row * size + col of the point you are aiming at), winner (0 draw / none, 1 you, 2 CPU), last_cell (row * size + col
-- of the last stone, -1 none), wins / losses / draws (this session), size (points per side), board (blob, size * size
-- characters from the top row: "0" empty, "1" yours, "2" CPU), win_cells (blob "a,b,c,d,e", the winning five).
features.on_draw("Pocket Gomoku", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local n = math.floor(f.size or 13)
    local gap = 44 * s
    local span = gap * (n - 1)
    local margin = gap * 0.7
    local x0, y0 = sw / 2 - span / 2, sh / 2 - span / 2 + 30 * s
    local state = math.floor(f.state or 0)
    local board = f.board or ""
    local t = ctx.time() or 0

    local win = {}
    for v in string.gmatch(f.win_cells or "", "(%d+)") do win[tonumber(v)] = true end

    draw.rect(x0 - margin - 20 * s, y0 - margin - 110 * s, x0 + span + margin + 20 * s, y0 + span + margin + 56 * s, 12, 12, 16, 225, 12 * s)
    draw.rect(x0 - margin, y0 - margin, x0 + span + margin, y0 + span + margin, 205, 160, 95, 255, 8 * s)

    for i = 0, n - 1 do
        local p = i * gap
        draw.line(x0, y0 + p, x0 + span, y0 + p, 70, 45, 20, 220, 1.4 * s)
        draw.line(x0 + p, y0, x0 + p, y0 + span, 70, 45, 20, 220, 1.4 * s)
    end
    local mid = math.floor(n / 2)
    for _, hr in ipairs({ 3, mid, n - 4 }) do
        for _, hc in ipairs({ 3, mid, n - 4 }) do
            draw.circle(x0 + hc * gap, y0 + hr * gap, 3.5 * s, 70, 45, 20, 255)
        end
    end

    local rad = gap * 0.43
    local last = math.floor(f.last_cell or -1)
    for r = 0, n - 1 do
        for c = 0, n - 1 do
            local idx = r * n + c
            local v = board:sub(idx + 1, idx + 1)
            local px, py = x0 + c * gap, y0 + r * gap
            if v == "1" then
                draw.circle(px + 2 * s, py + 3 * s, rad, 0, 0, 0, 90)
                draw.circle(px, py, rad, 22, 22, 26, 255)
            elseif v == "2" then
                draw.circle(px + 2 * s, py + 3 * s, rad, 0, 0, 0, 90)
                draw.circle(px, py, rad, 240, 240, 236, 255)
            end
            if win[idx] then
                local pulse = 0.5 + 0.5 * math.sin(t * 8)
                draw.circle_outline(px, py, rad + 2 * s, 230, 60, 60, math.floor(150 + 105 * pulse), 3.5 * s)
            elseif idx == last then
                draw.circle(px, py, rad * 0.22, 230, 60, 60, 230)
            end
        end
    end

    if state == 1 then
        local cur = math.floor(f.cursor or 0)
        local cr, cc = math.floor(cur / n), cur % n
        local px, py = x0 + cc * gap, y0 + cr * gap
        local pulse = 0.6 + 0.4 * math.sin(t * 6)
        local filled = board:sub(cur + 1, cur + 1) ~= "0"
        if filled then
            draw.circle_outline(px, py, rad + 3 * s, 230, 60, 60, math.floor(255 * pulse), 2.5 * s)
        else
            draw.circle(px, py, rad, 22, 22, 26, math.floor(110 * pulse))
            draw.circle_outline(px, py, rad + 3 * s, 255, 255, 255, math.floor(255 * pulse), 2.5 * s)
        end
    end

    local msg
    if state == 1 then msg = "YOUR TURN"
    elseif state == 2 then msg = "CPU IS THINKING"
    else
        local w = math.floor(f.winner or 0)
        msg = w == 1 and "YOU WIN" or (w == 2 and "CPU WINS" or "DRAW")
    end
    text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, y0 - margin - 100 * s, 245, 245, 250, 255, msg)
    local foot = state == 3 and "E TO PLAY AGAIN" or "W A S D MOVE     E PLACE"
    foot = foot .. string.format("     %d-%d-%d", math.floor(f.wins or 0), math.floor(f.losses or 0), math.floor(f.draws or 0))
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + span + margin + 14 * s, 200, 200, 214, 230, foot)
end)
