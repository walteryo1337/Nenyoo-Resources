-- Pocket Breakout. Published fields: active (bool), state (1 ball on the paddle, 2 playing, 3 game over), paddle_x /
-- ball_x / ball_y (0-1 across and down the field; the field is 4:3), lives, level, score, best (this session), cols /
-- rows (brick grid size), bricks (blob, rows * cols characters, row by row from the top: "1" brick, "0" broken).
local row_colors = {
    { 240, 80, 70 }, { 245, 150, 60 }, { 240, 210, 70 }, { 110, 210, 100 }, { 80, 170, 240 }, { 160, 110, 230 },
}

-- matches the C++ field: bricks start 8/75 down and each row is 3/75 tall; the paddle sits at 70/75 and is 16/100 wide
local BRICK_TOP, BRICK_H, PADDLE_Y, PADDLE_W, BALL_R = 8 / 75, 3 / 75, 70 / 75, 0.16, 1.2 / 100

features.on_draw("Pocket Breakout", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local fw = 640 * s
    local fh = fw * 0.75
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    draw.rect(x0 - 10 * s, y0 - 50 * s, x0 + fw + 10 * s, y0 + fh + 10 * s, 12, 12, 16, 225, 10 * s)
    draw.rect(x0, y0, x0 + fw, y0 + fh, 6, 6, 10, 255, 4 * s)

    local cols, rows = math.floor(f.cols or 10), math.floor(f.rows or 6)
    local bricks = f.bricks or ""
    local bw = fw / cols
    local bh = fh * BRICK_H
    for r = 0, rows - 1 do
        local c3 = row_colors[r + 1] or row_colors[#row_colors]
        for c = 0, cols - 1 do
            local idx = r * cols + c + 1
            if bricks:sub(idx, idx) == "1" then
                local bx = x0 + c * bw
                local by = y0 + fh * BRICK_TOP + r * bh
                draw.rect(bx + 1.5 * s, by + 1.5 * s, bx + bw - 1.5 * s, by + bh - 1.5 * s, c3[1], c3[2], c3[3], 255, 2 * s)
            end
        end
    end

    local px = x0 + (f.paddle_x or 0.5) * fw
    local py = y0 + PADDLE_Y * fh
    draw.rect(px - fw * PADDLE_W / 2, py, px + fw * PADDLE_W / 2, py + 6 * s, ar, ag, ab, 255, 3 * s)
    draw.circle(x0 + (f.ball_x or 0.5) * fw, y0 + (f.ball_y or 0.9) * fh, math.max(4 * s, fw * BALL_R), 245, 245, 250, 255)

    local hud = string.format("SCORE %d   LEVEL %d", math.floor(f.score or 0), math.floor(f.level or 1))
    text.draw(font.hud, x0, y0 - 40 * s, 245, 245, 250, 255, hud)
    local lives = string.rep("o ", math.floor(f.lives or 0))
    text.draw(font.hud, x0 + fw - text.width(font.hud, lives), y0 - 40 * s, 240, 90, 90, 255, lives)

    local state = math.floor(f.state or 0)
    local msg
    if state == 1 then msg = "A / D MOVE     W LAUNCH"
    elseif state == 3 then msg = string.format("GAME OVER   BEST %d", math.floor(f.best or 0)) end
    if msg then
        text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + fh * 0.6, 220, 220, 232, 240, msg)
    end
end)
