-- Pocket Nonogram. Published fields: active (bool), state (1 solving, 2 solved), state_age (ms), n (grid side), grid
-- (blob, n * n chars row by row: '0' empty, '1' filled, '2' crossed out), row_clues / col_clues (blobs: per line the run
-- lengths separated by spaces, lines separated by '|', "0" for an empty line), row_done / col_done (blobs of n chars,
-- '1' where the line already matches its clue), cx / cy (cursor), elapsed (ms), best (fastest solve at this size, ms).
local function split_lines(blob)
    local lines = {}
    for line in string.gmatch(blob or "", "([^|]*)|") do lines[#lines + 1] = line end
    return lines
end

local function clock(ms)
    local secs = math.floor((ms or 0) / 1000)
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

features.on_draw("Pocket Nonogram", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.n or 5)
    local state = math.floor(f.state or 0)
    local c = math.min(58 * s, 560 * s / n)
    local rows, cols = split_lines(f.row_clues), split_lines(f.col_clues)
    local row_done, col_done = f.row_done or "", f.col_done or ""
    local clue_w, clue_h = 150 * s, 130 * s
    local gw = n * c
    local x0 = sw / 2 - (gw + clue_w) / 2 + clue_w
    local y0 = sh / 2 - (gw + clue_h) / 2 + clue_h
    draw.rect(x0 - clue_w - 24 * s, y0 - clue_h - 64 * s, x0 + gw + 24 * s, y0 + gw + 60 * s, 16, 18, 24, 235, 12 * s)
    draw.rect(x0, y0, x0 + gw, y0 + gw, 236, 232, 222, 255, 4 * s)

    for i = 1, n do
        local done = string.sub(row_done, i, i) == "1"
        local label = rows[i] or ""
        local y = y0 + (i - 0.5) * c - text.height(font.hud_small) / 2
        local r, g, b = 235, 235, 240
        if done then r, g, b = 110, 200, 120 end
        if i - 1 == math.floor(f.cy or 0) and state == 1 then draw.rect(x0 - clue_w, y0 + (i - 1) * c, x0 - 4 * s, y0 + i * c, 255, 255, 255, 25, 4 * s) end
        text.draw(font.hud_small, x0 - 10 * s - text.width(font.hud_small, label), y, r, g, b, 255, label)
    end
    for i = 1, n do
        local done = string.sub(col_done, i, i) == "1"
        local r, g, b = 235, 235, 240
        if done then r, g, b = 110, 200, 120 end
        local nums = {}
        for v in string.gmatch(cols[i] or "", "(%d+)") do nums[#nums + 1] = v end
        local cx = x0 + (i - 0.5) * c
        if i - 1 == math.floor(f.cx or 0) and state == 1 then draw.rect(x0 + (i - 1) * c, y0 - clue_h, x0 + i * c, y0 - 4 * s, 255, 255, 255, 25, 4 * s) end
        local lh = text.height(font.hud_small) + 2 * s
        for k = #nums, 1, -1 do
            local label = nums[k]
            local y = y0 - 8 * s - (#nums - k + 1) * lh
            text.draw(font.hud_small, cx - text.width(font.hud_small, label) / 2, y, r, g, b, 255, label)
        end
    end

    local grid = f.grid or ""
    for y = 0, n - 1 do
        for x = 0, n - 1 do
            local i = y * n + x + 1
            local ch = string.sub(grid, i, i)
            local px, py = x0 + x * c, y0 + y * c
            if ch == "1" then
                local r, g, b = 34, 40, 56
                if state == 2 then r, g, b = theme.accent() end
                draw.rect(px + 2 * s, py + 2 * s, px + c - 2 * s, py + c - 2 * s, r, g, b, 255, 3 * s)
            elseif ch == "2" then
                draw.line(px + c * 0.3, py + c * 0.3, px + c * 0.7, py + c * 0.7, 200, 80, 70, 255, 2 * s)
                draw.line(px + c * 0.7, py + c * 0.3, px + c * 0.3, py + c * 0.7, 200, 80, 70, 255, 2 * s)
            end
        end
    end
    for k = 0, n do
        local thick = (k % 5 == 0) and 3 * s or 1
        draw.line(x0 + k * c, y0, x0 + k * c, y0 + gw, 120, 116, 108, 255, thick)
        draw.line(x0, y0 + k * c, x0 + gw, y0 + k * c, 120, 116, 108, 255, thick)
    end
    if state == 1 then
        local cx, cy = math.floor(f.cx or 0), math.floor(f.cy or 0)
        local a = 160 + math.floor(90 * math.abs(math.sin(t * 6)))
        draw.rect(x0 + cx * c - 2 * s, y0 + cy * c - 2 * s, x0 + (cx + 1) * c + 2 * s, y0 + cy * c + 2 * s, 255, 170, 40, a, 0)
        draw.rect(x0 + cx * c - 2 * s, y0 + (cy + 1) * c - 2 * s, x0 + (cx + 1) * c + 2 * s, y0 + (cy + 1) * c + 2 * s, 255, 170, 40, a, 0)
        draw.rect(x0 + cx * c - 2 * s, y0 + cy * c, x0 + cx * c + 2 * s, y0 + (cy + 1) * c, 255, 170, 40, a, 0)
        draw.rect(x0 + (cx + 1) * c - 2 * s, y0 + cy * c, x0 + (cx + 1) * c + 2 * s, y0 + (cy + 1) * c, 255, 170, 40, a, 0)
    end

    local hy = y0 - clue_h - 50 * s
    local lx = x0 - clue_w - 6 * s
    text.draw(font.hud, lx, hy, 245, 245, 250, 255, clock(f.elapsed))
    if f.best then
        local b = "BEST " .. clock(f.best)
        text.draw(font.hud_small, x0 + gw - text.width(font.hud_small, b), hy + 4 * s, 255, 200, 60, 255, b)
    end

    local msg, mr, mg, mb = "W A S D MOVE   E FILL   Q CROSS OUT   HOLD E OR Q AND MOVE TO PAINT A LINE", 220, 220, 232
    if state == 2 then msg, mr, mg, mb = string.format("SOLVED IN %s!   E FOR A NEW PUZZLE", clock(f.elapsed)), 120, 240, 140 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + gw + 24 * s, mr, mg, mb, 255, msg)
end)
