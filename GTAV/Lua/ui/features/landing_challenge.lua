-- Landing Challenge. Published fields: active (bool), state (1 falling, 2 result), distance (horizontal metres to the
-- target), height (metres above the target), bearing (degrees from the camera to the target, positive = left),
-- chute_open (bool), result (1 bullseye, 2 great, 3 good, 4 ok, 5 close, 6 missed, 7 water, 8 wasted), result_dist
-- (metres from the centre on landing), points, pay, best (closest landing, missing until one), jumps.
features.on_draw("Landing Challenge", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local r = 70 * s
        local px, py = sw - 40 * s - r, sh * 0.5
        draw.circle(px, py, r, 12, 12, 16, 170)
        draw.circle_outline(px, py, r, 255, 255, 255, 60, 1.5 * s)
        draw.circle_outline(px, py, r * 0.5, 255, 255, 255, 35, 1 * s)
        draw.line(px - r, py, px + r, py, 255, 255, 255, 25, 1 * s)
        draw.line(px, py - r, px, py + r, 255, 255, 255, 25, 1 * s)
        local d = f.distance or 0
        local k = math.min(1, d / 300)
        local a = math.rad(f.bearing or 0)
        local tx, ty = px - math.sin(a) * r * k, py - math.cos(a) * r * k
        local pulse = 0.5 + 0.5 * math.sin((ctx.time() or 0) * 6)
        draw.circle(tx, ty, (5 + 2 * pulse) * s, 235, 60, 50, 230)
        draw.circle(px, py, 3 * s, ar, ag, ab, 255)

        local dist = string.format("%d M", math.floor(d))
        text.draw(font.title, px - text.width(font.title, dist) / 2, py + r + 8 * s, 245, 245, 250, 255, dist)
        local alt = string.format("ALT %d M", math.floor(f.height or 0))
        local ay = py + r + 8 * s + text.height(font.title)
        text.draw(font.small, px - text.width(font.small, alt) / 2, ay, 210, 210, 222, 235, alt)
        if not f.chute_open and (f.height or 0) < 250 then
            local warn = "PULL THE CHUTE"
            local wa = math.floor(150 + 105 * pulse)
            text.draw(font.item, cx - text.width(font.item, warn) / 2, sh * 0.7, 255, 90, 70, wa, warn)
        end
        return
    end

    local result = math.floor(f.result or 0)
    local msgs = { "BULLSEYE", "GREAT LANDING", "GOOD LANDING", "ON TARGET", "CLOSE", "MISSED", "SPLASHDOWN", "WASTED" }
    local msg = msgs[result] or ""
    local r, g, b = ar, ag, ab
    if result == 1 then r, g, b = 255, 205, 60 elseif result >= 6 then r, g, b = 240, 80, 70 end
    local y = sh * 0.26
    text.draw(big, cx - text.width(big, msg) / 2, y, r, g, b, 255, msg)
    y = y + text.height(big)
    if result <= 6 then
        local sub = string.format("%.1f M FROM CENTRE", f.result_dist or 0)
        text.draw(font.item, cx - text.width(font.item, sub) / 2, y, 235, 235, 245, 255, sub)
        y = y + text.height(font.item) + 2 * s
    end
    local line = ""
    if (f.pay or 0) > 0 then line = string.format("+$%d", math.floor(f.pay)) end
    if f.best then line = line .. (line ~= "" and "   " or "") .. string.format("BEST %.1f M", f.best) end
    if line ~= "" then text.draw(font.small, cx - text.width(font.small, line) / 2, y, 210, 210, 222, 240, line) end
end)
