-- Pocket Minesweeper. Published fields: active (bool), state (1 playing, 2 won, 3 lost), cursor_x / cursor_y (0-8),
-- time (seconds), flags_left, best (fastest clear, missing until one), cells (blob of 81 chars row by row: h hidden,
-- f flagged, 0-8 opened with that many neighbouring mines, m mine, x the mine you hit).
local number_colours = {
    { 60, 110, 230 }, { 50, 150, 60 }, { 220, 60, 60 }, { 40, 40, 150 },
    { 140, 40, 40 }, { 40, 140, 140 }, { 30, 30, 30 }, { 120, 120, 120 },
}

features.on_draw("Pocket Minesweeper", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local n = 9
    local cell = math.floor(44 * s)
    local size = n * cell
    local cx = sw / 2
    local x0, y0 = cx - size / 2, sh / 2 - size / 2 + 16 * s
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 12 * s, y0 - 52 * s, x0 + size + 12 * s, y0 + size + 34 * s, 40, 42, 52, 245, 10 * s)
    local t = f.time or 0
    local clock = string.format("%03d", math.min(999, math.floor(t)))
    local flags = string.format("%02d", math.max(0, math.floor(f.flags_left or 0)))
    text.draw(font.display, x0, y0 - 44 * s, 240, 80, 70, 255, flags)
    text.draw(font.display, x0 + size - text.width(font.display, clock), y0 - 44 * s, 240, 80, 70, 255, clock)
    if f.best then
        local b = string.format("BEST %.1f", f.best)
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, b) / 2, y0 - 36 * s, 190, 190, 205, 230, b)
    end

    local cells = f.cells or ""
    for i = 1, math.min(n * n, #cells) do
        local ch = string.sub(cells, i, i)
        local idx = i - 1
        local x = x0 + (idx % n) * cell
        local y = y0 + math.floor(idx / n) * cell
        if ch == "h" or ch == "f" then
            draw.rect(x + 1, y + 1, x + cell - 1, y + cell - 1, 150, 155, 170, 255, 3)
            draw.rect(x + 3, y + 3, x + cell - 3, y + cell * 0.45, 255, 255, 255, 40, 2)
            if ch == "f" then
                draw.line(x + cell * 0.4, y + cell * 0.25, x + cell * 0.4, y + cell * 0.78, 30, 30, 30, 255, 3 * s)
                draw.rect(x + cell * 0.42, y + cell * 0.25, x + cell * 0.72, y + cell * 0.48, 230, 50, 50, 255, 0)
            end
        else
            local bg = { 215, 218, 228 }
            if ch == "x" then bg = { 230, 60, 50 } end
            draw.rect(x + 1, y + 1, x + cell - 1, y + cell - 1, bg[1], bg[2], bg[3], 255, 3)
            if ch == "m" or ch == "x" then
                draw.circle(x + cell / 2, y + cell / 2, cell * 0.22, 25, 25, 30, 255)
            else
                local v = tonumber(ch) or 0
                if v > 0 then
                    local c = number_colours[v]
                    local label = tostring(v)
                    text.draw(font.display, x + cell / 2 - text.width(font.display, label) / 2, y + cell / 2 - text.height(font.display) / 2, c[1], c[2], c[3], 255, label)
                end
            end
        end
    end

    if state == 1 then
        local qx = x0 + math.floor(f.cursor_x or 0) * cell
        local qy = y0 + math.floor(f.cursor_y or 0) * cell
        local th = 3 * s
        draw.rect(qx, qy, qx + cell, qy + th, ar, ag, ab, 255, 0)
        draw.rect(qx, qy + cell - th, qx + cell, qy + cell, ar, ag, ab, 255, 0)
        draw.rect(qx, qy, qx + th, qy + cell, ar, ag, ab, 255, 0)
        draw.rect(qx + cell - th, qy, qx + cell, qy + cell, ar, ag, ab, 255, 0)
    end

    local hint = "W A S D  MOVE    E  OPEN    G  FLAG"
    if state >= 2 then hint = "E FOR A NEW GAME   TURN OFF TO QUIT" end
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, hint) / 2, y0 + size + 12 * s, 180, 185, 195, 230, hint)

    if state == 2 or state == 3 then
        local msg = state == 2 and "CLEARED" or "BOOM"
        local r, g, b = 120, 230, 120
        if state == 3 then r, g, b = 240, 80, 70 end
        -- Near-opaque band: at 200 alpha the board's numbers showed through the word.
        draw.rect(x0, y0 + size / 2 - text.height(big) * 0.85, x0 + size, y0 + size / 2 + text.height(big) * 0.45, 20, 22, 26, 240, 0)
        text.draw(big, cx - text.width(big, msg) / 2, y0 + size / 2 - text.height(big) * 0.7, r, g, b, 255, msg)
    end
end)
