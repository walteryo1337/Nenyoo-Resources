-- Pocket Frogger. Published fields: active (bool), state (1 playing, 2 just died, 3 game over), frog_x (cells, float
-- while riding a log), frog_y (row, 0 = home bays at the top, 12 = start), lives, level, score, best (this session),
-- time_left (0-1 for the current frog), cause (1 hit by traffic, 2 drowned, 3 out of time, 4 missed the bay), cols / rows,
-- bays (blob, one char per bay: "1" filled; bay i sits at column 3 * i), objs (blob "row,x,len;" per log, turtle group
-- or vehicle: x is the left edge in cells and may run off either side). Rows 1-5 are river (2 and 5 are turtles), 6 is
-- the median, 7-11 are road.
local causes = { "SPLAT!", "SPLASH!", "OUT OF TIME", "MISSED THE BAY" }
local car_colors = {
    [7] = { 230, 230, 235 }, [8] = { 240, 80, 80 }, [9] = { 250, 210, 70 },
    [10] = { 90, 170, 255 }, [11] = { 200, 120, 255 },
}

features.on_draw("Pocket Frogger", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cols, rows = math.floor(f.cols or 13), math.floor(f.rows or 13)
    local c = 44 * s
    local fw, fh = cols * c, rows * c
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    local t = ctx.time() or 0
    draw.rect(x0 - 10 * s, y0 - 50 * s, x0 + fw + 10 * s, y0 + fh + 24 * s, 12, 12, 16, 225, 10 * s)

    for r = 0, rows - 1 do
        local ry = y0 + r * c
        local col
        if r == 0 then col = { 30, 90, 40 }
        elseif r <= 5 then col = { 20, 60, 140 }
        elseif r == 6 or r == rows - 1 then col = { 70, 50, 110 }
        else col = { 30, 30, 34 } end
        draw.rect(x0, ry, x0 + fw, ry + c, col[1], col[2], col[3], 255, 0)
        if r >= 7 and r <= 10 then
            for dx = 0, cols - 1, 2 do
                draw.rect(x0 + (dx + 0.3) * c, ry + c - 1.5 * s, x0 + (dx + 1.2) * c, ry + c + 1.5 * s, 200, 200, 200, 160, 0)
            end
        end
    end

    local bays = f.bays or ""
    for i = 0, 4 do
        local bx = x0 + i * 3 * c
        draw.rect(bx + 3 * s, y0 + 4 * s, bx + c - 3 * s, y0 + c - 2 * s, 15, 40, 90, 255, 6 * s)
        if bays:sub(i + 1, i + 1) == "1" then
            draw.rect(bx + 9 * s, y0 + 10 * s, bx + c - 9 * s, y0 + c - 8 * s, 120, 230, 90, 255, 6 * s)
        end
    end

    for row, ox, len in string.gmatch(f.objs or "", "(%d+),([%d%.%-]+),([%d%.]+);") do
        row, ox, len = tonumber(row), tonumber(ox), tonumber(len)
        local ry = y0 + row * c
        if row == 2 or row == 5 then
            for k = 0, len - 1 do
                local cx = x0 + (ox + k + 0.5) * c
                if cx > x0 + c * 0.4 and cx < x0 + fw - c * 0.4 then
                    draw.circle(cx, ry + c / 2, c * 0.4, 50, 150, 80, 255)
                    draw.circle(cx, ry + c / 2, c * 0.25, 30, 110, 60, 255)
                end
            end
        else
            local a = math.max(x0, x0 + ox * c + 2 * s)
            local b = math.min(x0 + fw, x0 + (ox + len) * c - 2 * s)
            if b > a then
                if row <= 5 then
                    draw.rect(a, ry + 6 * s, b, ry + c - 6 * s, 130, 85, 45, 255, 8 * s)
                else
                    local cc = car_colors[row] or car_colors[8]
                    draw.rect(a, ry + 7 * s, b, ry + c - 7 * s, cc[1], cc[2], cc[3], 255, 6 * s)
                    draw.rect(a + 6 * s, ry + 12 * s, math.max(a + 6 * s, b - 6 * s), ry + c - 12 * s, 20, 20, 26, 140, 3 * s)
                end
            end
        end
    end

    local state = math.floor(f.state or 0)
    if state ~= 3 then
        local fx = x0 + (f.frog_x or 6) * c
        local fy = y0 + (f.frog_y or 12) * c
        local fr, fg, fb = 110, 235, 90
        if state == 2 and math.floor(t * 10) % 2 == 0 then fr, fg, fb = 255, 70, 70 end
        draw.rect(fx + 8 * s, fy + 8 * s, fx + c - 8 * s, fy + c - 6 * s, fr, fg, fb, 255, 9 * s)
        draw.circle(fx + 14 * s, fy + 11 * s, 5 * s, 250, 250, 250, 255)
        draw.circle(fx + c - 14 * s, fy + 11 * s, 5 * s, 250, 250, 250, 255)
        draw.circle(fx + 14 * s, fy + 11 * s, 2.5 * s, 10, 10, 10, 255)
        draw.circle(fx + c - 14 * s, fy + 11 * s, 2.5 * s, 10, 10, 10, 255)
    end

    local tl = f.time_left or 0
    local tr, tg = 90, 220
    if tl < 0.3 then tr, tg = 240, 80 end
    draw.rect(x0, y0 + fh + 8 * s, x0 + fw, y0 + fh + 16 * s, 40, 40, 46, 255, 4 * s)
    if tl > 0 then draw.rect(x0, y0 + fh + 8 * s, x0 + fw * tl, y0 + fh + 16 * s, tr, tg, 80, 255, 4 * s) end

    local hud = string.format("SCORE %d   LEVEL %d", math.floor(f.score or 0), math.floor(f.level or 1))
    text.draw(font.hud, x0, y0 - 40 * s, 245, 245, 250, 255, hud)
    for i = 1, math.floor(f.lives or 0) do
        local lx = x0 + fw - i * 28 * s
        draw.rect(lx, y0 - 34 * s, lx + 20 * s, y0 - 16 * s, 110, 235, 90, 255, 6 * s)
    end

    local msg
    if state == 3 then msg = string.format("GAME OVER   BEST %d   W TO PLAY AGAIN", math.floor(f.best or 0))
    elseif state == 2 then msg = causes[math.floor(f.cause or 1)]
    elseif math.floor(f.score or 0) == 0 and math.floor(f.frog_y or 12) == rows - 1 then msg = "W A S D TO HOP" end
    if msg then
        local w = text.width(font.hud, msg)
        local my = y0 + 6 * c + c / 2 - text.height(font.hud) / 2
        draw.rect(sw / 2 - w / 2 - 12 * s, my - 6 * s, sw / 2 + w / 2 + 12 * s, my + text.height(font.hud) + 6 * s, 10, 10, 14, 220, 6 * s)
        text.draw(font.hud, sw / 2 - w / 2, my, 245, 245, 250, 255, msg)
    end
end)
