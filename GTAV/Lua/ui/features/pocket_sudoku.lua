-- Pocket Sudoku. Published fields: active (bool), state (1 playing, 2 solved), cursor (cell index, row * 9 + col), level
-- (1 easy, 2 medium, 3 hard), seconds (time on this puzzle), best (fastest solve at this level this session; missing
-- until one), grid (blob, 81 chars "0" empty or "1"-"9"), given (blob, "1" for the puzzle's fixed numbers), conflict
-- (blob, "1" where a number clashes with its row, column or box).
local levels = { "EASY", "MEDIUM", "HARD" }

features.on_draw("Pocket Sudoku", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cell = 58 * s
    local size = cell * 9
    local x0, y0 = sw / 2 - size / 2, sh / 2 - size / 2 + 20 * s
    draw.rect(x0 - 20 * s, y0 - 70 * s, x0 + size + 20 * s, y0 + size + 60 * s, 12, 12, 16, 230, 12 * s)
    draw.rect(x0, y0, x0 + size, y0 + size, 238, 238, 244, 255, 4 * s)

    local grid, given, conflict = f.grid or "", f.given or "", f.conflict or ""
    local cur = math.floor(f.cursor or 0)
    local cr, cc = math.floor(cur / 9), cur % 9
    for r = 0, 8 do
        for c = 0, 8 do
            local x, y = x0 + c * cell, y0 + r * cell
            if r == cr or c == cc then draw.rect(x, y, x + cell, y + cell, 220, 225, 240, 255, 0) end
        end
    end
    draw.rect(x0 + cc * cell, y0 + cr * cell, x0 + (cc + 1) * cell, y0 + (cr + 1) * cell, ar, ag, ab, 110, 0)

    for i = 0, 8 do
        local thick = (i % 3 == 0) and 3 * s or 1 * s
        draw.line(x0 + i * cell, y0, x0 + i * cell, y0 + size, 40, 40, 50, 255, thick)
        draw.line(x0, y0 + i * cell, x0 + size, y0 + i * cell, 40, 40, 50, 255, thick)
    end
    draw.line(x0 + size, y0, x0 + size, y0 + size, 40, 40, 50, 255, 3 * s)
    draw.line(x0, y0 + size, x0 + size, y0 + size, 40, 40, 50, 255, 3 * s)

    for i = 0, 80 do
        local ch = grid:sub(i + 1, i + 1)
        if ch ~= "" and ch ~= "0" then
            local r, c = math.floor(i / 9), i % 9
            local x, y = x0 + c * cell, y0 + r * cell
            local fixed = given:sub(i + 1, i + 1) == "1"
            local bad = conflict:sub(i + 1, i + 1) == "1"
            local tr, tg, tb = 40, 70, 170
            if fixed then tr, tg, tb = 25, 25, 30 end
            if bad then tr, tg, tb = 220, 50, 50 end
            text.draw(font.title, x + cell / 2 - text.width(font.title, ch) / 2, y + cell / 2 - text.height(font.title) / 2, tr, tg, tb, 255, ch)
        end
    end

    local t = f.seconds or 0
    local head = string.format("%s   %d:%02d", levels[math.floor(f.level or 1)] or "", math.floor(t / 60), math.floor(t % 60))
    text.draw(font.item, x0, y0 - 54 * s, 245, 245, 250, 255, head)
    if f.best then
        local b = string.format("BEST %d:%02d", math.floor(f.best / 60), math.floor(f.best % 60))
        text.draw(font.item, x0 + size - text.width(font.item, b), y0 - 54 * s, 200, 200, 214, 240, b)
    end
    local foot = math.floor(f.state or 0) == 2 and "SOLVED!   E FOR A NEW PUZZLE" or "W A S D MOVE     E NUMBER UP     Q NUMBER DOWN"
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + size + 18 * s, 220, 220, 232, 240, foot)
end)
