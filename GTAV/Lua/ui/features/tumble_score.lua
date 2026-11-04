-- Tumble Score. Published fields: active (bool), tumbling (bool, a ragdoll is in progress) with live (score so far),
-- distance (metres travelled), air (seconds airborne), time (seconds); result (last finished score) + result_age,
-- result_distance / result_air / result_time, died (bool, the last tumble was fatal), record (bool, a new best), best.
features.on_draw("Tumble Score", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2

    if f.tumbling then
        local n = string.format("%d", math.floor(f.live or 0))
        local wob = math.sin(ctx.time() * 18) * 3 * s
        text.draw(big, cx - text.width(big, n) / 2 + wob, sh * 0.2, 255, 255, 255, 255, n)
        local sub = string.format("%.1f M   %.1f S AIR", f.distance or 0, f.air or 0)
        text.draw(font.small, cx - text.width(font.small, sub) / 2, sh * 0.2 + text.height(big), 210, 210, 222, 235, sub)
        return
    end

    local age = f.result_age or 99
    if age < 4 then
        local a = math.floor(255 * math.min(1, (4 - age) * 1.5))
        local title = f.died and "FATAL TUMBLE" or "TUMBLE"
        if f.record then title = "NEW BEST TUMBLE" end
        local r, g, b = ar, ag, ab
        if f.died then r, g, b = 240, 80, 70 end
        text.draw(font.small, cx - text.width(font.small, title) / 2, sh * 0.18, r, g, b, a, title)
        local n = string.format("%d", math.floor(f.result or 0))
        text.draw(big, cx - text.width(big, n) / 2, sh * 0.18 + text.height(font.small), 255, 255, 255, a, n)
        local sub = string.format("%.1f M   %.1f S AIR   %.1f S", f.result_distance or 0, f.result_air or 0, f.result_time or 0)
        local y = sh * 0.18 + text.height(font.small) + text.height(big)
        text.draw(font.tiny, cx - text.width(font.tiny, sub) / 2, y, 200, 200, 212, a, sub)
        local best = string.format("BEST %d", math.floor(f.best or 0))
        text.draw(font.tiny, cx - text.width(font.tiny, best) / 2, y + text.height(font.tiny) + 2 * s, 170, 170, 185, a, best)
    end
end)
