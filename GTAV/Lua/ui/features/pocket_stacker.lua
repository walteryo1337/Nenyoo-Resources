-- Pocket Stacker. Published fields: active (bool), state (1 playing, 2 reached the top, 3 missed), cols / rows_total
-- (grid), minor_row (rows needed for the minor prize), row (0-based row now moving), pos / width (moving block's left
-- column and width), rows (blob "start,width;" per placed row from the bottom), cut_start / cut_width / cut_row +
-- cut_age (ms; the overhang that was just sliced off), best (highest row reached), wins (tops reached), minor_wins,
-- minor_age (ms since the minor prize line was passed this game).
features.on_draw("Pocket Stacker", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cols, rows = math.floor(f.cols or 7), math.floor(f.rows_total or 12)
    local minor = math.floor(f.minor_row or 8)
    local c = 50 * s
    local gw, gh = cols * c, rows * c
    local pw, ph = gw + 140 * s, gh + 110 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    local gx, gy = x0 + 20 * s, y0 + 60 * s
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 10, 24, 235, 12 * s)
    text.draw(font.item, x0 + 20 * s, y0 + 18 * s, 245, 245, 250, 255, "STACKER")
    draw.rect(gx, gy, gx + gw, gy + gh, 6, 6, 12, 255, 4 * s)

    local function cell(col, row, r, g, b, a)
        local x = gx + col * c
        local y = gy + (rows - 1 - row) * c
        draw.rect(x + 3 * s, y + 3 * s, x + c - 3 * s, y + c - 3 * s, r, g, b, a, 4 * s)
    end
    for col = 0, cols - 1 do
        for row = 0, rows - 1 do cell(col, row, 22, 22, 34, 255) end
    end
    local my = gy + (rows - minor) * c
    draw.line(gx, my, gx + gw, my, 255, 210, 70, 160, 2 * s)
    text.draw(font.tiny, gx + gw + 8 * s, my - text.height(font.tiny) / 2, 255, 210, 70, 255, "MINOR")
    text.draw(font.tiny, gx + gw + 8 * s, gy - text.height(font.tiny) / 2, 120, 240, 255, 255, "MAJOR")

    local row = 0
    for start, width in string.gmatch(f.rows or "", "(%d+),(%d+);") do
        for col = tonumber(start), tonumber(start) + tonumber(width) - 1 do cell(col, row, 70, 160, 255, 255) end
        row = row + 1
    end
    local state = math.floor(f.state or 0)
    if state == 1 then
        local r = math.floor(f.row or 0)
        local pos, w = math.floor(f.pos or 0), math.floor(f.width or 0)
        for col = pos, pos + w - 1 do cell(col, r, 255, 90, 160, 255) end
    end
    local age = f.cut_age or 99999
    if f.cut_width and age < 500 then
        local a = math.floor(255 * (1 - age / 500))
        local drop = age / 500 * 3
        for col = math.floor(f.cut_start), math.floor(f.cut_start) + math.floor(f.cut_width) - 1 do
            cell(col, math.floor(f.cut_row) - drop, 255, 90, 90, a)
        end
    end

    local stats = string.format("BEST %d   TOPS %d   MINORS %d", math.floor(f.best or 0), math.floor(f.wins or 0), math.floor(f.minor_wins or 0))
    text.draw(font.small, x0 + pw - 20 * s - text.width(font.small, stats), y0 + 22 * s, 190, 190, 205, 255, stats)
    local msg, cr, cg, cb = "PRESS E TO DROP THE BLOCK", 220, 220, 232
    if state == 2 then msg, cr, cg, cb = "MAJOR PRIZE!   E TO PLAY AGAIN", 120, 240, 255
    elseif state == 3 then msg, cr, cg, cb = "MISSED!   E TO TRY AGAIN", 255, 100, 100
    elseif (f.minor_age or 99999) < 1500 then msg, cr, cg, cb = "MINOR PRIZE! KEEP GOING", 255, 210, 70 end
    if state ~= 1 or (f.minor_age or 99999) < 1500 or math.floor(t * 2) % 2 == 0 then
        text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, gy + gh + 16 * s, cr, cg, cb, 255, msg)
    end
end)
