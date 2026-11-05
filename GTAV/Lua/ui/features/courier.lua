-- Courier Job. Published fields: active (bool, a job is running), delivering (bool, package in hand),
-- distance (metres to the marker), time_left (seconds; present while delivering),
-- pay (current payout if delivered now; present while delivering), delivered (jobs done this session).
features.on_draw("Courier Job", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local pad = 10 * s

    local dist = f.distance or 0
    local dist_text = dist >= 1000 and string.format("%.1f KM", dist / 1000) or string.format("%d M", math.floor(dist))
    local title, clock, sub
    if f.delivering then
        local t = math.max(0, f.time_left or 0)
        title = "DELIVER THE PACKAGE"
        clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
        sub = string.format("%s   $%d", dist_text, math.floor(f.pay or 0))
    else
        title = "COLLECT THE PACKAGE"
        clock = nil
        sub = string.format("%s   DELIVERED %d", dist_text, math.floor(f.delivered or 0))
    end

    local tw = text.width(font.hud_tiny, title)
    local cw = clock and text.width(font.display, clock) or 0
    local sw2 = text.width(font.hud_tiny, sub)
    local w = math.max(tw, cw, sw2) + pad * 2
    local h = text.height(font.hud_tiny) * 2 + pad * 2 + 4 * s + (clock and text.height(font.display) or 0)
    local x = sw - w - 28 * s
    local y = sh * 0.42

    draw.rect(x, y, x + w, y + h, 10, 10, 16, 165, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, ar, ag, ab, 255, 0)
    local cy = y + pad
    text.draw(font.hud_tiny, x + w - pad - tw, cy, ar, ag, ab, 255, title)
    cy = cy + text.height(font.hud_tiny) + 2 * s
    if clock then
        local r, g, b = 245, 245, 250
        if (f.time_left or 0) < 20 then r, g, b = 235, 70, 70 end
        text.draw(font.display, x + w - pad - cw, cy, r, g, b, 255, clock)
        cy = cy + text.height(font.display) + 2 * s
    end
    text.draw(font.hud_tiny, x + w - pad - sw2, cy, 200, 200, 210, 230, sub)
end)
