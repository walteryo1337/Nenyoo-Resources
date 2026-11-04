-- Pocket Pong. Published fields: active (bool), state (1 serve, 2 playing, 3 match over), ball_x / ball_y (0..1 across
-- the court), player_y / cpu_y (paddle centres, 0..1 down the court), player_score / cpu_score, target (points to win),
-- wins (matches won this session).
features.on_draw("Pocket Pong", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cw, ch = 560 * s, 336 * s
    local cx = sw / 2
    local x0, y0 = cx - cw / 2, sh * 0.5 - ch / 2
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 10 * s, y0 - 10 * s, x0 + cw + 10 * s, y0 + ch + 10 * s, 30, 32, 40, 240, 12 * s)
    draw.rect(x0, y0, x0 + cw, y0 + ch, 8, 10, 14, 255, 4 * s)
    for i = 0, 15 do
        local yy = y0 + (i + 0.25) * ch / 16
        draw.rect(cx - 1.5 * s, yy, cx + 1.5 * s, yy + ch / 32, 255, 255, 255, 60, 0)
    end

    local ps = tostring(math.floor(f.player_score or 0))
    local cs = tostring(math.floor(f.cpu_score or 0))
    text.draw(big, cx - 40 * s - text.width(big, ps), y0 + 10 * s, 255, 255, 255, 90, ps)
    text.draw(big, cx + 40 * s, y0 + 10 * s, 255, 255, 255, 90, cs)

    local ph = 0.25 * ch
    local pw = 8 * s
    local px = x0 + 0.03 * cw
    local py = y0 + (f.player_y or 0.5) * ch
    draw.rect(px - pw, py - ph / 2, px, py + ph / 2, ar, ag, ab, 255, 2 * s)
    local qx = x0 + 0.97 * cw
    local qy = y0 + (f.cpu_y or 0.5) * ch
    draw.rect(qx, qy - ph / 2, qx + pw, qy + ph / 2, 235, 235, 245, 255, 2 * s)

    local bx = x0 + (f.ball_x or 0.5) * cw
    local by = y0 + (f.ball_y or 0.5) * ch
    draw.rect(bx - 6 * s, by - 6 * s, bx + 6 * s, by + 6 * s, 255, 255, 255, 255, 1 * s)

    local hint = string.format("W / S TO MOVE   FIRST TO %d   TURN OFF TO QUIT", math.floor(f.target or 7))
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, y0 + ch + 16 * s, 180, 185, 195, 230, hint)

    if state == 3 then
        draw.rect(x0, y0, x0 + cw, y0 + ch, 8, 10, 14, 180, 4 * s)
        local won = (f.player_score or 0) > (f.cpu_score or 0)
        local msg = won and "YOU WIN" or "CPU WINS"
        local r, g, b = 240, 80, 70
        if won then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, y0 + ch / 2 - text.height(big), r, g, b, 255, msg)
        local again = "PRESS W OR S FOR A REMATCH"
        text.draw(font.small, cx - text.width(font.small, again) / 2, y0 + ch / 2 + 6 * s, 235, 235, 245, 255, again)
    end
end)
