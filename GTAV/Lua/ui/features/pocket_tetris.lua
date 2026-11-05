-- Pocket Tetris. Published fields: active (bool), state (1 playing, 2 game over), score, lines, level, best, next (0-6
-- piece id: I O T S Z J L), clear_flash (0..1 after a line clear), board (blob of 200 digits, row by row from the top,
-- 10 wide: 0 empty, 1-7 piece colours, 8 drop ghost).
local colours = {
    { 80, 210, 230 }, { 240, 210, 60 }, { 170, 90, 210 }, { 90, 200, 90 },
    { 230, 70, 70 }, { 70, 110, 230 }, { 240, 150, 50 },
}
local previews = {
    { { -1, 0 }, { 0, 0 }, { 1, 0 }, { 2, 0 } },
    { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } },
    { { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, -1 } },
    { { -1, 0 }, { 0, 0 }, { 0, -1 }, { 1, -1 } },
    { { -1, -1 }, { 0, -1 }, { 0, 0 }, { 1, 0 } },
    { { -1, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 } },
    { { 1, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 } },
}

local function block(x, y, size, c, a)
    draw.rect(x + 1, y + 1, x + size - 1, y + size - 1, c[1], c[2], c[3], a, 3)
    draw.rect(x + 3, y + 3, x + size - 3, y + size * 0.35, 255, 255, 255, math.floor(a * 0.25), 2)
end

features.on_draw("Pocket Tetris", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cell = math.floor(30 * s)
    local bw, bh = 10 * cell, 20 * cell
    local x0, y0 = sw / 2 - bw / 2 - 70 * s, sh / 2 - bh / 2

    draw.rect(x0 - 8 * s, y0 - 8 * s, x0 + bw + 8 * s, y0 + bh + 8 * s, 30, 32, 40, 245, 8 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 10, 12, 16, 255, 0)
    local flash = f.clear_flash or 0
    if flash > 0 then draw.rect(x0, y0, x0 + bw, y0 + bh, 255, 255, 255, math.floor(60 * flash), 0) end

    local board = f.board or ""
    for i = 1, math.min(200, #board) do
        local v = string.byte(board, i) - 48
        if v > 0 then
            local idx = i - 1
            local cx = x0 + (idx % 10) * cell
            local cy = y0 + math.floor(idx / 10) * cell
            if v == 8 then
                draw.rect(cx + 3, cy + 3, cx + cell - 3, cy + cell - 3, 255, 255, 255, 40, 3)
            else
                block(cx, cy, cell, colours[v] or colours[1], 255)
            end
        end
    end

    local px = x0 + bw + 26 * s
    local function stat(label, value, y)
        text.draw(font.hud_tiny, px, y, 180, 185, 195, 230, label)
        text.draw(font.display, px, y + text.height(font.hud_tiny), 245, 245, 250, 255, value)
        return y + text.height(font.hud_tiny) + text.height(font.display) + 10 * s
    end
    local y = y0
    text.draw(font.hud_tiny, px, y, 180, 185, 195, 230, "NEXT")
    y = y + text.height(font.hud_tiny) + 6 * s
    local nb = math.floor(22 * s)
    draw.rect(px, y, px + nb * 5, y + nb * 3, 10, 12, 16, 230, 4 * s)
    local nxt = math.floor(f.next or 0) + 1
    for _, c in ipairs(previews[nxt] or previews[1]) do
        block(px + (c[1] + 1.5) * nb, y + (c[2] + 1.5) * nb, nb, colours[nxt] or colours[1], 255)
    end
    y = y + nb * 3 + 16 * s
    y = stat("SCORE", tostring(math.floor(f.score or 0)), y)
    y = stat("LINES", tostring(math.floor(f.lines or 0)), y)
    y = stat("LEVEL", tostring(math.floor(f.level or 0) + 1), y)
    y = stat("BEST", tostring(math.floor(f.best or 0)), y)
    local help = { "A D  MOVE", "W  ROTATE", "S  SOFT DROP", "SPACE  HARD DROP" }
    for i, line in ipairs(help) do
        text.draw(font.hud_tiny, px, y + (i - 1) * (text.height(font.hud_tiny) + 2 * s), 170, 175, 190, 220, line)
    end

    if math.floor(f.state or 0) == 2 then
        draw.rect(x0, y0, x0 + bw, y0 + bh, 10, 12, 16, 190, 0)
        local msg = "GAME OVER"
        text.draw(big, x0 + bw / 2 - text.width(big, msg) / 2, y0 + bh / 2 - text.height(big), ar, ag, ab, 255, msg)
        local again = "W OR SPACE TO RESTART"
        text.draw(font.hud_small, x0 + bw / 2 - text.width(font.hud_small, again) / 2, y0 + bh / 2 + 6 * s, 235, 235, 245, 255, again)
    end
end)
