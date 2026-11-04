-- Pocket Connect Four. Published fields: active (bool), state (1 your turn, 2 CPU thinking, 3 game over), cursor
-- (0-6 column you are aiming at), winner (0 draw / none, 1 you, 2 CPU), last_cell (row * cols + col of the last disc,
-- -1 none), wins / losses / draws (this session), cols / rows, board (blob, rows * cols characters from the top row:
-- "0" empty, "1" yours, "2" CPU), win_cells (blob "a,b,c,d", the four winning cells once someone wins).
features.on_draw("Pocket Connect Four", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cols, rows = math.floor(f.cols or 7), math.floor(f.rows or 6)
    local cell = 74 * s
    local bw, bh = cell * cols, cell * rows
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 30 * s
    local state = math.floor(f.state or 0)
    local board = f.board or ""

    local win = {}
    for n in string.gmatch(f.win_cells or "", "(%d+)") do win[tonumber(n)] = true end

    draw.rect(x0 - 20 * s, y0 - 140 * s, x0 + bw + 20 * s, y0 + bh + 60 * s, 12, 12, 16, 225, 12 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 30, 60, 160, 255, 10 * s)

    local t = ctx.time() or 0
    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local idx = r * cols + c
            local v = board:sub(idx + 1, idx + 1)
            local px, py = x0 + (c + 0.5) * cell, y0 + (r + 0.5) * cell
            local rad = cell * 0.4
            if v == "1" then draw.circle(px, py, rad, 240, 70, 60, 255)
            elseif v == "2" then draw.circle(px, py, rad, 250, 210, 60, 255)
            else draw.circle(px, py, rad, 14, 14, 20, 255) end
            if win[idx] then
                local pulse = 0.5 + 0.5 * math.sin(t * 8)
                draw.circle_outline(px, py, rad, 255, 255, 255, math.floor(150 + 105 * pulse), 4 * s)
            elseif idx == math.floor(f.last_cell or -1) then
                draw.circle_outline(px, py, rad * 0.35, 255, 255, 255, 140, 2 * s)
            end
        end
    end

    if state == 1 then
        local px = x0 + (math.floor(f.cursor or 3) + 0.5) * cell
        draw.circle(px, y0 - cell * 0.55, cell * 0.38, 240, 70, 60, 255)
    end

    local msg
    if state == 1 then msg = "YOUR TURN"
    elseif state == 2 then msg = "CPU IS THINKING"
    else
        local w = math.floor(f.winner or 0)
        msg = w == 1 and "YOU WIN" or (w == 2 and "CPU WINS" or "DRAW")
    end
    text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, y0 - 132 * s, 245, 245, 250, 255, msg)
    local foot = state == 3 and "E TO PLAY AGAIN" or "A / D MOVE     E OR S DROP"
    foot = foot .. string.format("     %d-%d-%d", math.floor(f.wins or 0), math.floor(f.losses or 0), math.floor(f.draws or 0))
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + bh + 16 * s, 200, 200, 214, 230, foot)
end)
