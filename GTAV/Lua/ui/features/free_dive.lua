-- Free Dive. Published fields: active (bool), diving (bool), depth (metres below the surface now), max_depth (deepest
-- this dive), air (seconds of breath left), dive_time (seconds underwater), popup_age (seconds since the last dive ended,
-- -1 when no result is showing), result (1 dive, 2 blackout), last_depth, last_time, last_pay, best (deepest dive,
-- missing until one), dives.
features.on_draw("Free Dive", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2

    if f.diving then
        local scale = math.max(40, (f.best or 0) * 1.25, (f.max_depth or 0) * 1.1)
        local gh, gw = 360 * s, 14 * s
        local gx, gy = sw - 70 * s, sh * 0.5 - gh / 2
        draw.rect_gradient(gx, gy, gx + gw, gy + gh, 80, 170, 220, 200, 80, 170, 220, 200, 10, 30, 70, 220, 10, 30, 70, 220)
        local function mark(d, r, g, b, w)
            local y = gy + gh * math.min(1, d / scale)
            draw.rect(gx - w, y - 1.5 * s, gx + gw + w, y + 1.5 * s, r, g, b, 255, 0)
        end
        if f.best then mark(f.best, 255, 205, 60, 6 * s) end
        mark(f.max_depth or 0, 255, 255, 255, 3 * s)
        local d = f.depth or 0
        local y = gy + gh * math.min(1, d / scale)
        draw.circle(gx + gw / 2, y, 9 * s, ar, ag, ab, 255)
        local dstr = string.format("%.1f M", d)
        text.draw(font.display, gx - 14 * s - text.width(font.display, dstr), y - text.height(font.display) / 2, 245, 245, 250, 255, dstr)
        local air = math.max(0, f.air or 0)
        local astr = string.format("AIR %d S", math.floor(air))
        local r, g, b = 210, 225, 240
        if air < 5 then r, g, b = 240, 80, 70 end
        text.draw(font.hud_small, gx + gw / 2 - text.width(font.hud_small, astr) / 2, gy + gh + 10 * s, r, g, b, 255, astr)
        if f.best then
            local bstr = string.format("BEST %.1f", f.best)
            text.draw(font.hud_tiny, gx + gw / 2 - text.width(font.hud_tiny, bstr) / 2, gy - text.height(font.hud_tiny) - 8 * s, 255, 205, 60, 235, bstr)
        end
    end

    local age = f.popup_age or -1
    if age < 0 then return end
    local alpha = 255
    if age > 3.3 then alpha = math.floor(255 * math.max(0, 1 - (age - 3.3) / 0.7)) end
    local result = math.floor(f.result or 0)
    local y = sh * 0.28
    if result == 2 then
        local msg = "BLACKOUT"
        text.draw(big, cx - text.width(big, msg) / 2, y, 240, 80, 70, alpha, msg)
        return
    end
    local depth = f.last_depth or 0
    local record = f.best and math.abs((f.best or 0) - depth) < 0.01
    local msg = string.format("%.1f M", depth)
    local r, g, b = ar, ag, ab
    if record then r, g, b = 255, 205, 60 end
    text.draw(big, cx - text.width(big, msg) / 2, y, r, g, b, alpha, msg)
    y = y + text.height(big)
    local sub = string.format("%s%.1f S UNDERWATER", record and "NEW RECORD   " or "", f.last_time or 0)
    if (f.last_pay or 0) > 0 then sub = sub .. string.format("   +$%d", math.floor(f.last_pay)) end
    text.draw(font.hud, cx - text.width(font.hud, sub) / 2, y, 240, 240, 248, alpha, sub)
end)
