-- Pocket Slide Puzzle. Published fields: active (bool), state (1 playing, 2 solved), n (3-5 grid size), tiles (blob, n * n
-- chars row by row, each char's byte minus 48 is the tile number, 0 = the gap), moves, elapsed (s, starts on the first
-- move), best_moves / best_time (this grid size, present after a solve), solves, last_tile + move_age (ms; the tile you
-- just slid, for the slide animation).
features.on_draw("Pocket Slide Puzzle", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    ar, ag, ab = ar or 90, ag or 160, ab or 255
    local n = math.floor(f.n or 4)
    local bw = 420 * s
    local c = bw / n
    local pw, ph = bw + 40 * s, bw + 140 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    local bx, by = x0 + 20 * s, y0 + 60 * s
    draw.rect(x0, y0, x0 + pw, y0 + ph, 14, 14, 20, 230, 12 * s)
    text.draw(font.item, x0 + 20 * s, y0 + 18 * s, 245, 245, 250, 255, "SLIDE PUZZLE")
    local el = f.elapsed or 0
    local info = string.format("%d MOVES   %d:%02d", math.floor(f.moves or 0), math.floor(el / 60), math.floor(el % 60))
    text.draw(font.small, x0 + pw - 20 * s - text.width(font.small, info), y0 + 22 * s, 200, 200, 212, 255, info)
    draw.rect(bx - 4 * s, by - 4 * s, bx + bw + 4 * s, by + bw + 4 * s, 30, 30, 40, 255, 8 * s)

    local tiles = f.tiles or ""
    local state = math.floor(f.state or 0)
    local pop = (f.move_age or 99999) < 120
    for i = 0, n * n - 1 do
        local v = (tiles:byte(i + 1) or 48) - 48
        if v > 0 then
            local r, col = math.floor(i / n), i % n
            local x, y = bx + col * c, by + r * c
            local inset = 4 * s
            if pop and math.floor(f.last_tile or 0) == v then inset = 1 * s end
            local home = v == i + 1
            local tr, tg, tb = 230, 230, 238
            if home then tr, tg, tb = math.floor(ar * 0.6 + 90), math.floor(ag * 0.6 + 90), math.floor(ab * 0.6 + 90) end
            if state == 2 then tr, tg, tb = 120, 230, 140 end
            draw.rect(x + inset, y + inset, x + c - inset, y + c - inset, tr, tg, tb, 255, 8 * s)
            local label = tostring(v)
            local fnt = n >= 5 and font.item or font.title
            text.draw(fnt, x + c / 2 - text.width(fnt, label) / 2, y + c / 2 - text.height(fnt) / 2, 25, 25, 32, 255, label)
        end
    end

    local msg, cr, cg, cb
    if state == 2 then msg, cr, cg, cb = "SOLVED!   E FOR A NEW PUZZLE", 120, 240, 140
    else msg, cr, cg, cb = "W A S D SLIDE A TILE INTO THE GAP   Q RESHUFFLE", 220, 220, 232 end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, by + bw + 18 * s, cr, cg, cb, 255, msg)
    local rec = string.format("SOLVED %d", math.floor(f.solves or 0))
    if f.best_moves then
        local bt = f.best_time or 0
        rec = rec .. string.format("   BEST %d MOVES   %d:%02d", math.floor(f.best_moves), math.floor(bt / 60), math.floor(bt % 60))
    end
    text.draw(font.small, sw / 2 - text.width(font.small, rec) / 2, by + bw + 44 * s, 160, 160, 175, 255, rec)
end)
