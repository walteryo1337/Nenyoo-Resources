-- Hide and Seek. Published fields: active (bool), state (1 counting with eyes closed, 2 seeking, 3 round result),
-- countdown (seconds left to count), time_left (seconds left to find them), heat (0..1, how close you are),
-- result (1 found, 2 time ran out), found / rounds (session totals), best (fastest find in seconds, missing until one),
-- last (seconds the last find took).
local function heat_label(h)
    if h > 0.85 then return "BURNING HOT", 255, 70, 40 end
    if h > 0.65 then return "HOT", 255, 130, 50 end
    if h > 0.45 then return "WARM", 245, 200, 80 end
    if h > 0.25 then return "COLD", 120, 190, 255 end
    return "FREEZING", 160, 220, 255
end

features.on_draw("Hide and Seek", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local n = math.ceil(f.countdown or 0)
        local msg = tostring(n)
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.42, 255, 255, 255, 255, msg)
        local sub = "COUNTING... NO PEEKING"
        text.draw(font.hud_small, cx - text.width(font.hud_small, sub) / 2, sh * 0.42 + text.height(big) + 6 * s, 200, 200, 210, 230, sub)
        return
    end

    local y = sh * 0.06
    if state == 2 then
        local t = math.max(0, f.time_left or 0)
        local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
        local cr, cg, cb = 245, 245, 250
        if t < 15 then cr, cg, cb = 240, 80, 70 end
        text.draw(big, cx - text.width(big, clock) / 2, y, cr, cg, cb, 255, clock)
        y = y + text.height(big) + 4 * s

        local h = f.heat or 0
        local label, r, g, b = heat_label(h)
        local bw, bh = 260 * s, 8 * s
        draw.rect_gradient(cx - bw / 2, y, cx + bw / 2, y + bh, 120, 190, 255, 220, 255, 70, 40, 220, 255, 70, 40, 220, 120, 190, 255, 220)
        local mx = cx - bw / 2 + bw * h
        draw.rect(mx - 2 * s, y - 4 * s, mx + 2 * s, y + bh + 4 * s, 255, 255, 255, 255, 1 * s)
        y = y + bh + 8 * s
        text.draw(font.hud, cx - text.width(font.hud, label) / 2, y, r, g, b, 255, label)
    elseif state == 3 then
        local found = math.floor(f.result or 0) == 1
        local msg = found and "FOUND!" or "TIME'S UP"
        local r, g, b = 240, 90, 70
        if found then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, r, g, b, 255, msg)
        if found then
            local sub = string.format("%.1f s", f.last or 0)
            text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.3 + text.height(big) + 4 * s, 235, 235, 245, 255, sub)
        end
    end

    local stats = string.format("FOUND %d / %d", math.floor(f.found or 0), math.floor(f.rounds or 0))
    if f.best then stats = stats .. string.format("   BEST %.1f s", f.best) end
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, stats) / 2, sh * 0.94, 200, 200, 212, 220, stats)
end)
