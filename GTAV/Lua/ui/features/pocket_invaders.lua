-- Pocket Invaders. Published fields: active (bool), state (1 playing, 2 just hit, 3 game over), off_x / off_y (0-1 top
-- left of the formation), ship_x (0-1), shot_x / shot_y (0-1, present while your shot is in the air), lives, wave,
-- score, best (this session), cols / rows (formation), aliens (blob, cols * rows chars row by row: "1" alive), bombs (blob
-- "x,y;" per falling bomb, 0-1). The field is 100 x 75 units; the layout constants below match the C++.
local CELL_W, CELL_H, ALIEN_W, ALIEN_H, SHIP_Y, SHIP_W = 8 / 100, 6 / 75, 5 / 100, 3.5 / 75, 70 / 75, 7 / 100
local row_colors = { { 240, 90, 200 }, { 120, 200, 255 }, { 120, 230, 120 }, { 245, 210, 80 } }

features.on_draw("Pocket Invaders", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local fw = 640 * s
    local fh = fw * 0.75
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    draw.rect(x0 - 10 * s, y0 - 50 * s, x0 + fw + 10 * s, y0 + fh + 10 * s, 12, 12, 16, 225, 10 * s)
    draw.rect(x0, y0, x0 + fw, y0 + fh, 4, 4, 10, 255, 4 * s)

    local cols, rows = math.floor(f.cols or 8), math.floor(f.rows or 4)
    local aliens = f.aliens or ""
    local ox, oy = (f.off_x or 0) * fw, (f.off_y or 0) * fh
    local t = ctx.time() or 0
    local wiggle = math.floor(t * 3) % 2 == 0
    for i = 0, cols * rows - 1 do
        if aliens:sub(i + 1, i + 1) == "1" then
            local r, c = math.floor(i / cols), i % cols
            local ax = x0 + ox + c * CELL_W * fw + (CELL_W - ALIEN_W) * 0.5 * fw
            local ay = y0 + oy + r * CELL_H * fh
            local col = row_colors[r + 1] or row_colors[1]
            local aw, ah = ALIEN_W * fw, ALIEN_H * fh
            draw.rect(ax, ay, ax + aw, ay + ah, col[1], col[2], col[3], 255, 3 * s)
            draw.rect(ax + aw * 0.22, ay + ah * 0.3, ax + aw * 0.38, ay + ah * 0.55, 4, 4, 10, 255, 0)
            draw.rect(ax + aw * 0.62, ay + ah * 0.3, ax + aw * 0.78, ay + ah * 0.55, 4, 4, 10, 255, 0)
            local leg = wiggle and 0.15 or 0.3
            draw.line(ax + aw * leg, ay + ah, ax + aw * (leg - 0.1), ay + ah * 1.35, col[1], col[2], col[3], 255, 2 * s)
            draw.line(ax + aw * (1 - leg), ay + ah, ax + aw * (1.1 - leg), ay + ah * 1.35, col[1], col[2], col[3], 255, 2 * s)
        end
    end

    for bx, by in string.gmatch(f.bombs or "", "([%d%.%-]+),([%d%.%-]+);") do
        local px, py = x0 + tonumber(bx) * fw, y0 + tonumber(by) * fh
        draw.rect(px - 1.5 * s, py - 6 * s, px + 1.5 * s, py, 255, 120, 80, 255, 0)
    end
    if f.shot_x then
        local px, py = x0 + f.shot_x * fw, y0 + f.shot_y * fh
        draw.rect(px - 1.5 * s, py, px + 1.5 * s, py + 8 * s, 255, 255, 255, 255, 0)
    end

    local state = math.floor(f.state or 0)
    if not (state == 2 and math.floor(t * 8) % 2 == 0) then
        local sx = x0 + (f.ship_x or 0.5) * fw
        local sy = y0 + SHIP_Y * fh
        local half = SHIP_W * fw / 2
        draw.rect(sx - half, sy + 4 * s, sx + half, sy + 14 * s, 90, 230, 140, 255, 2 * s)
        draw.rect(sx - 3 * s, sy - 2 * s, sx + 3 * s, sy + 6 * s, 90, 230, 140, 255, 0)
    end

    local hud = string.format("SCORE %d   WAVE %d", math.floor(f.score or 0), math.floor(f.wave or 1))
    text.draw(font.hud, x0, y0 - 40 * s, 245, 245, 250, 255, hud)
    for i = 1, math.floor(f.lives or 0) do
        local lx = x0 + fw - i * 30 * s
        draw.rect(lx, y0 - 26 * s, lx + 22 * s, y0 - 18 * s, 90, 230, 140, 255, 2 * s)
        draw.rect(lx + 9 * s, y0 - 32 * s, lx + 13 * s, y0 - 24 * s, 90, 230, 140, 255, 0)
    end
    local msg
    if state == 3 then msg = string.format("GAME OVER   BEST %d   W TO PLAY AGAIN", math.floor(f.best or 0))
    elseif math.floor(f.score or 0) == 0 then msg = "A / D MOVE     W OR E FIRE" end
    if msg then text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + fh * 0.55, 220, 220, 232, 240, msg) end
end)
