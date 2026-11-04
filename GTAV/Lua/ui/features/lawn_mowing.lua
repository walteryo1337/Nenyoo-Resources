-- Lawn Mowing. Published fields: active (bool), time_left (seconds), coverage (0..1 of the lawn cut),
-- finished (bool), in_mower (bool), cols / rows (lawn grid size), grid (string of cols*rows '0' uncut / '1' cut,
-- row by row starting at the edge nearest where the job began).
features.on_draw("Lawn Mowing", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cols, rows = math.floor(f.cols or 0), math.floor(f.rows or 0)
    local grid = f.grid or ""
    local cell = 14 * s
    local pad = 10 * s
    local w = math.max(cols * cell, 150 * s) + pad * 2
    local h = rows * cell + pad * 3 + text.height(font.title) + text.height(font.tiny) + 6 * s
    local x = sw - w - 28 * s
    local y = sh * 0.38

    draw.rect(x, y, x + w, y + h, 10, 14, 10, 175, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local t = math.max(0, f.time_left or 0)
    local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
    local cr, cg, cb = 245, 245, 250
    if t < 20 and not f.finished then cr, cg, cb = 235, 70, 70 end
    text.draw(font.title, x + pad, y + pad, cr, cg, cb, 255, clock)
    local pct = string.format("%d%%", math.floor((f.coverage or 0) * 100))
    text.draw(font.title, x + w - pad - text.width(font.title, pct), y + pad, ar, ag, ab, 255, pct)

    local gx = x + (w - cols * cell) / 2
    local gy = y + pad * 2 + text.height(font.title)
    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local i = r * cols + c + 1
            local cut = grid:sub(i, i) == "1"
            local px = gx + c * cell
            local py = gy + (rows - 1 - r) * cell
            if cut then
                local shade = (c % 2 == 0) and 150 or 125
                draw.rect(px + 1, py + 1, px + cell - 1, py + cell - 1, 90, shade, 70, 255, 1 * s)
            else
                draw.rect(px + 1, py + 1, px + cell - 1, py + cell - 1, 40, 80, 35, 255, 1 * s)
            end
        end
    end

    local sub = f.finished and "JOB DONE" or (f.in_mower and "MOW THE LONG GRASS" or "GET BACK ON THE MOWER")
    local sr, sg, sb = 200, 200, 210
    if not f.in_mower and not f.finished then sr, sg, sb = 240, 170, 70 end
    text.draw(font.tiny, x + w / 2 - text.width(font.tiny, sub) / 2, gy + rows * cell + pad * 0.6, sr, sg, sb, 235, sub)
end)
