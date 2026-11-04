-- Pocket Peg Solitaire. Published fields: active (bool), state (1 playing, 2 no moves left), state_age (ms), n (board
-- side, 7), board (blob, n * n chars row by row: 'o' peg, '.' empty hole, ' ' off the cross), targets (blob, same layout:
-- '1' where the picked peg can land), cx / cy (cursor, 0-based), sel_x / sel_y (picked peg, -1 none), pegs (left),
-- best (fewest pegs you have finished with), centre (bool, finished with one peg in the middle).
features.on_draw("Pocket Peg Solitaire", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.n or 7)
    local c = 84 * s
    local bw = n * c
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bw / 2 + 16 * s
    local state = math.floor(f.state or 0)
    draw.rect(x0 - 40 * s, y0 - 80 * s, x0 + bw + 40 * s, y0 + bw + 60 * s, 18, 14, 10, 230, 12 * s)
    draw.circle(sw / 2, y0 + bw / 2, bw * 0.56, 120, 78, 40, 255)
    draw.circle(sw / 2, y0 + bw / 2, bw * 0.53, 150, 100, 55, 255)

    local board, targets = f.board or "", f.targets or ""
    local cx, cy = math.floor(f.cx or 3), math.floor(f.cy or 1)
    local sx, sy = math.floor(f.sel_x or -1), math.floor(f.sel_y or -1)
    for y = 0, n - 1 do
        for x = 0, n - 1 do
            local i = y * n + x + 1
            local ch = string.sub(board, i, i)
            if ch == "o" or ch == "." then
                local px, py = x0 + (x + 0.5) * c, y0 + (y + 0.5) * c
                draw.circle(px, py, c * 0.2, 70, 44, 22, 255)
                if string.sub(targets, i, i) == "1" then
                    local p = 0.6 + 0.4 * math.abs(math.sin(t * 5))
                    draw.circle_outline(px, py, c * 0.3, 120, 240, 140, math.floor(255 * p), 3 * s)
                end
                if ch == "o" then
                    local lift = (x == sx and y == sy) and 8 * s or 0
                    draw.circle(px + 3 * s, py + 4 * s, c * 0.3, 40, 24, 10, 120)
                    local r, g, b = 220, 60, 60
                    if x == sx and y == sy then r, g, b = 255, 200, 60 end
                    draw.circle(px, py - lift, c * 0.3, r, g, b, 255)
                    draw.circle(px - c * 0.09, py - lift - c * 0.09, c * 0.09, 255, 255, 255, 120)
                end
                if x == cx and y == cy and state == 1 then
                    draw.circle_outline(px, py, c * 0.42, 255, 255, 255, 150 + math.floor(100 * math.abs(math.sin(t * 6))), 3 * s)
                end
            end
        end
    end

    local hy = y0 - 64 * s
    text.draw(font.item, x0, hy, 245, 240, 230, 255, string.format("PEGS %d", math.floor(f.pegs or 0)))
    if f.best then
        local b = string.format("BEST %d", math.floor(f.best))
        text.draw(font.item, x0 + bw - text.width(font.item, b), hy, 255, 200, 60, 255, b)
    end

    local msg, mr, mg, mb = "W A S D MOVE   E PICK A PEG, E AGAIN TO JUMP   Q UNDO", 230, 225, 215
    if state == 2 then
        local left = math.floor(f.pegs or 0)
        if f.centre then msg, mr, mg, mb = "PERFECT! ONE PEG, DEAD CENTRE   E TO PLAY AGAIN", 120, 240, 140
        elseif left == 1 then msg, mr, mg, mb = "GENIUS! ONE PEG LEFT   E TO PLAY AGAIN", 120, 240, 140
        elseif left <= 3 then msg, mr, mg, mb = string.format("NO MOVES LEFT   %d PEGS, NOT BAD   E PLAY AGAIN   Q UNDO", left), 255, 210, 90
        else msg, mr, mg, mb = string.format("NO MOVES LEFT   %d PEGS   E PLAY AGAIN   Q UNDO", left), 255, 140, 110 end
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + bw + 26 * s, mr, mg, mb, 255, msg)
end)
