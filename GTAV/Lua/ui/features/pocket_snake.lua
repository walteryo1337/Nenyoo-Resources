-- Pocket Snake. Published fields: active (bool), state (1 playing, 2 game over), score, best, food_x / food_y (cell,
-- -1 when the board is full), grid_w / grid_h (board size in cells), body (blob of "x,y;" cells, head first).
features.on_draw("Pocket Snake", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local gw, gh = math.floor(f.grid_w or 24), math.floor(f.grid_h or 16)
    local cell = math.floor(18 * s)
    local bw, bh = gw * cell, gh * cell
    local pad = 18 * s
    local cx = sw / 2
    local x0, y0 = cx - bw / 2, sh * 0.5 - bh / 2

    draw.rect(x0 - pad, y0 - pad - 30 * s, x0 + bw + pad, y0 + bh + pad + 26 * s, 40, 42, 52, 245, 18 * s)
    draw.rect(x0 - 4 * s, y0 - 4 * s, x0 + bw + 4 * s, y0 + bh + 4 * s, 20, 22, 26, 255, 6 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 150, 172, 110, 255, 2 * s)

    local score = string.format("SCORE %d", math.floor(f.score or 0))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_small, x0, y0 - pad - 26 * s + (26 * s - text.height(font.hud_small)) / 2, 220, 225, 235, 255, score)
    text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, best), y0 - pad - 26 * s + (26 * s - text.height(font.hud_small)) / 2, 180, 185, 195, 255, best)

    local fx, fy = math.floor(f.food_x or -1), math.floor(f.food_y or -1)
    if fx >= 0 then
        draw.circle(x0 + (fx + 0.5) * cell, y0 + (fy + 0.5) * cell, cell * 0.38, 120, 30, 30, 255)
    end

    local first = true
    for px, py in string.gmatch(f.body or "", "(%-?%d+),(%-?%d+);") do
        local cx1 = x0 + tonumber(px) * cell
        local cy1 = y0 + tonumber(py) * cell
        local r, g, b = 40, 52, 30
        if first then r, g, b = 20, 28, 14 end
        draw.rect(cx1 + 1, cy1 + 1, cx1 + cell - 1, cy1 + cell - 1, r, g, b, 255, 2 * s)
        first = false
    end

    local hint = "W A S D TO STEER   TURN OFF TO QUIT"
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, hint) / 2, y0 + bh + pad + 4 * s, 170, 175, 190, 230, hint)

    if math.floor(f.state or 0) == 2 then
        draw.rect(x0, y0, x0 + bw, y0 + bh, 20, 22, 26, 170, 2 * s)
        local over = "GAME OVER"
        local big = font.display
        text.draw(big, cx - text.width(big, over) / 2, y0 + bh / 2 - text.height(big), ar, ag, ab, 255, over)
        local again = "PRESS ANY DIRECTION TO PLAY AGAIN"
        text.draw(font.hud_small, cx - text.width(font.hud_small, again) / 2, y0 + bh / 2 + 4 * s, 235, 235, 245, 255, again)
    end
end)
