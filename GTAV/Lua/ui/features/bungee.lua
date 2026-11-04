-- Bungee Jump. Published fields: active (bool), state (1 armed, waiting for you to step off, 2 jumping, 3 being winched
-- back up), jumps, best_dip (closest you have come to the bottom, m), last_dip / last_bounces (previous jump). While
-- jumping or winching: drop (m from the anchor to the bottom), cord (unstretched cord length, m), height (m above the
-- bottom now), lowest (closest so far this jump), bounces, stretch (0+, how far the cord is stretched past its length),
-- rope (blob "x,y;" per point from the anchor to your feet, 0-1 screen coordinates, -1 when off screen).
features.on_draw("Bungee Jump", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local state = math.floor(f.state or 0)

    if f.rope then
        local px, py
        local st = f.stretch or 0
        local r, g, b = 255, 200 - math.min(140, math.floor(st * 400)), 60
        for x, y in string.gmatch(f.rope, "([%d%.%-]+),([%d%.%-]+);") do
            x, y = tonumber(x), tonumber(y)
            if x >= 0 and y >= 0 then
                local sx, sy = x * sw, y * sh
                if px then draw.line(px, py, sx, sy, r, g, b, 235, 3 * s) end
                px, py = sx, sy
            else
                px, py = nil, nil
            end
        end
    end

    local pw, ph = 280 * s, 96 * s
    local px, py = sw - pw - 30 * s, sh * 0.30
    draw.rect(px, py, px + pw, py + ph, 12, 12, 16, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, 255, 200, 60, 255, 2 * s)
    text.draw(font.item, px + 16 * s, py + 10 * s, 245, 245, 250, 255, "BUNGEE")

    if state == 2 or state == 3 then
        local h = f.height or 0
        local hr, hg = 210, 210
        if h < 5 then hr, hg = 255, 120 end
        text.draw(font.small, px + 16 * s, py + 42 * s, hr, hg, 222, 255,
            string.format("%.0fm ABOVE   LOWEST %.1fm", h, f.lowest or 0))
        local tail = state == 3 and "WINCHING UP" or "E CUT THE CORD"
        text.draw(font.small, px + 16 * s, py + 64 * s, 170, 170, 185, 255,
            string.format("BOUNCES %d   %s", math.floor(f.bounces or 0), tail))
    else
        text.draw(font.small, px + 16 * s, py + 42 * s, 210, 210, 222, 255, "STEP OFF A HIGH EDGE")
        local rec = string.format("JUMPS %d", math.floor(f.jumps or 0))
        if f.best_dip then rec = rec .. string.format("   BEST %.1fm", f.best_dip) end
        if f.last_bounces then rec = rec .. string.format("   LAST %d BOUNCES", math.floor(f.last_bounces)) end
        text.draw(font.small, px + 16 * s, py + 64 * s, 170, 170, 185, 255, rec)
    end
end)
