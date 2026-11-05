-- Counter-Sniper. Published fields: active (bool), state (1 hunting, 2 result), elapsed (seconds), shot_age (0..1 after
-- a shot was fired at you, -1 otherwise), shot_bearing (degrees from the camera to the shooter, positive = left), shots
-- (fired so far), hint_dist (rough metres to the sniper once the hint unlocks, -1 before), result (1 sniper down,
-- 2 wasted, 3 abandoned), pay, time (seconds the hunt took).
features.on_draw("Counter-Sniper", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx, cy = sw / 2, sh / 2
    local state = math.floor(f.state or 0)

    if state == 2 then
        local result = math.floor(f.result or 0)
        local msgs = { "SNIPER DOWN", "WASTED", "MISSION ABANDONED" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if result == 1 then
            local sub = string.format("%.1f S   +$%d", f.time or 0, math.floor(f.pay or 0))
            text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, sub)
        end
        return
    end

    local t = f.elapsed or 0
    local head = string.format("SNIPER  %d:%02d", math.floor(t / 60), math.floor(t % 60))
    text.draw(font.hud_small, cx - text.width(font.hud_small, head) / 2, sh * 0.05, 235, 120, 100, 255, head)
    local info = string.format("SHOTS FIRED %d", math.floor(f.shots or 0))
    if (f.hint_dist or -1) > 0 then info = info .. string.format("   ~%d M AWAY", math.floor(f.hint_dist)) end
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, info) / 2, sh * 0.05 + text.height(font.hud_small), 210, 210, 222, 235, info)

    local age = f.shot_age or -1
    if age >= 0 then
        local a = math.rad(f.shot_bearing or 0)
        local r = sh * 0.22
        local alpha = math.floor(230 * (1 - age))
        for k = -3, 3 do
            local aa = a + k * 0.05
            local x1, y1 = cx - math.sin(aa) * r, cy - math.cos(aa) * r
            local x2, y2 = cx - math.sin(aa) * (r + 18 * s), cy - math.cos(aa) * (r + 18 * s)
            draw.line(x1, y1, x2, y2, 240, 60, 50, alpha, 4 * s)
        end
    end
end)
