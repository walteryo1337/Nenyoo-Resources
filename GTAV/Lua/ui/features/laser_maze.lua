-- Laser Maze. Shown while the maze is up. Published fields: active (bool); ready / running / won / failed (bool, the
-- current phase); count (seconds left before the run starts); level; lives / max_lives; time_left (seconds); has_loot
-- (bool, the case has been grabbed); flash_k (1..0 red flash after touching a beam); best (highest level cleared).
features.on_draw("Laser Maze", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2

    local fk = f.flash_k or 0
    if fk > 0 then draw.rect(0, 0, sw, sh, 255, 20, 20, math.floor(90 * fk), 0) end

    local w, h = 340 * s, 86 * s
    local x0, y0 = cx - w / 2, 40 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 10, 8, 12, 225, 12 * s)
    draw.rect(x0, y0, x0 + w, y0 + 4 * s, 255, 40, 40, 230, 0)
    local title = string.format("LASER MAZE  LEVEL %d", math.floor(f.level or 1))
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 12 * s, 255, 150, 150, 240, title)
    local t = f.time_left or 0
    local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
    local cr, cg, cb = 245, 245, 250
    if f.running and t < 10 then cr, cg, cb = 255, 90, 80 end
    text.draw(font.hud_small, x0 + w - 14 * s - text.width(font.hud_small, clock), y0 + 8 * s, cr, cg, cb, 255, clock)
    local goal = f.has_loot and "GET BACK PAST THE GREEN LINE" or "GRAB THE CASE  (E)"
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 40 * s, 235, 235, 245, 235, goal)
    local lives, maxl = math.floor(f.lives or 0), math.floor(f.max_lives or 3)
    for i = 1, maxl do
        local px = x0 + 20 * s + (i - 1) * 22 * s
        if i <= lives then draw.circle(px, y0 + 68 * s, 6 * s, 255, 60, 60, 255)
        else draw.circle(px, y0 + 68 * s, 6 * s, 70, 50, 50, 200) end
    end
    if (f.best or 0) > 0 then
        local best = string.format("BEST LEVEL %d", math.floor(f.best))
        text.draw(font.hud_tiny, x0 + w - 14 * s - text.width(font.hud_tiny, best), y0 + 58 * s, 190, 190, 205, 210, best)
    end

    if f.ready then
        local n = string.format("%d", math.max(1, math.ceil(f.count or 0)))
        text.draw(font.display, cx - text.width(font.display, n) / 2, sh * 0.32, 255, 90, 90, 255, n)
    elseif f.won then
        local msg = "CLEAN GETAWAY"
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.3, 120, 255, 160, 255, msg)
    elseif f.failed then
        local msg = "ALARM TRIPPED"
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.3, 255, 80, 70, 255, msg)
    end
end)
