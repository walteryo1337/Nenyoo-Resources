-- Briefcase Heist. Published fields: active (bool), state (1 sneaking in, 2 escaping, 3 result), suspicion (0..1),
-- alarm (bool), seen (bool, a guard can see you right now), distance (metres from the briefcase spot), result (1 clean,
-- 2 loud, 3 wasted, 4 abandoned), pay, jobs (completed this session).
features.on_draw("Briefcase Heist", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local t = ctx.time() or 0

    if state == 3 then
        local result = math.floor(f.result or 0)
        local msgs = { "CLEAN GETAWAY", "GOT AWAY LOUD", "WASTED", "JOB ABANDONED" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = ar, ag, ab elseif result == 2 then r, g, b = 245, 200, 70 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if (f.pay or 0) > 0 then
            local p = string.format("+$%d", math.floor(f.pay))
            text.draw(font.hud, cx - text.width(font.hud, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
        end
        return
    end

    local w = 280 * s
    local x, y = cx - w / 2, sh * 0.06
    local sus = math.max(0, math.min(1, f.suspicion or 0))
    local label, lr, lg, lb
    if f.alarm then
        local pulse = 0.5 + 0.5 * math.sin(t * 10)
        label, lr, lg, lb = "ALARM", 240, math.floor(60 + 40 * pulse), 50
        sus = 1
    elseif f.seen then
        label, lr, lg, lb = "SPOTTED", 245, 200, 70
    else
        label, lr, lg, lb = "HIDDEN", 200, 200, 212
    end
    text.draw(font.hud_small, cx - text.width(font.hud_small, label) / 2, y, lr, lg, lb, 255, label)
    local by = y + text.height(font.hud_small) + 4 * s
    draw.rect(x, by, x + w, by + 8 * s, 255, 255, 255, 30, 4 * s)
    if sus > 0 then
        local r, g, b = 245, 200, 70
        if sus > 0.7 or f.alarm then r, g, b = 240, 70, 55 end
        draw.rect(x, by, x + w * sus, by + 8 * s, r, g, b, 240, 4 * s)
    end

    local obj
    if state == 1 then
        obj = string.format("GRAB THE BRIEFCASE   %d M", math.floor(f.distance or 0))
    else
        local left = math.max(0, 200 - (f.distance or 0))
        obj = string.format("GET CLEAR   %d M TO GO", math.floor(left))
    end
    text.draw(font.hud, cx - text.width(font.hud, obj) / 2, by + 14 * s, 240, 240, 248, 255, obj)
end)
