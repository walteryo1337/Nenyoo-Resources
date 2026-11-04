-- Prison Break. Shown during the break and on the result. Published fields: active (bool), breaking / done (bool),
-- won (bool, result of the last break), to_freedom (metres still to go), time (seconds since the riot began), guards
-- (guards still standing), best (fastest escape this session in seconds; missing until you have escaped once).
features.on_draw("Prison Break", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx = sw / 2

    if f.breaking then
        local w, h = 360 * s, 86 * s
        local x0, y0 = cx - w / 2, 40 * s
        draw.rect(x0, y0, x0 + w, y0 + h, 16, 12, 8, 220, 12 * s)
        draw.rect(x0, y0, x0 + w, y0 + 4 * s, 255, 140, 40, math.floor(160 + 90 * math.sin(t * 6)), 0)
        text.draw(font.small, x0 + 16 * s, y0 + 10 * s, 255, 200, 120, 255, "PRISON BREAK")
        local clock = string.format("%d:%02d", math.floor((f.time or 0) / 60), math.floor((f.time or 0) % 60))
        text.draw(font.small, x0 + w - 16 * s - text.width(font.small, clock), y0 + 10 * s, 245, 245, 250, 255, clock)
        local line = string.format("%.0fM TO FREEDOM", f.to_freedom or 0)
        text.draw(font.tiny, x0 + 16 * s, y0 + 44 * s, 235, 235, 245, 240, line)
        local g = string.format("%d GUARDS", math.floor(f.guards or 0))
        text.draw(font.tiny, x0 + w - 16 * s - text.width(font.tiny, g), y0 + 44 * s, 255, 120, 100, 230, g)
        if f.best then
            local b = string.format("BEST ESCAPE %.0fs", f.best)
            text.draw(font.tiny, x0 + 16 * s, y0 + 64 * s, 190, 190, 205, 200, b)
        end
    elseif f.done then
        local msg = f.won and "ESCAPED" or "BUSTED"
        local r, g, b = 120, 255, 160
        if not f.won then r, g, b = 255, 90, 80 end
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, r, g, b, 255, msg)
    end
end)
