-- Game of Chicken. Published fields: active (bool), state (1 countdown, 2 charging, 3 result), countdown (seconds),
-- gap (metres between the cars), drift (-1..1 of the lane you must hold, beyond 1 counts as swerving), speed (m/s
-- towards the rival), result (1 they flinched, 2 you swerved, 3 head-on, 4 called off), pay, streak.
features.on_draw("Game of Chicken", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 1 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "GO"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
        return
    end

    if state == 2 then
        local gap = f.gap or 0
        local danger = math.max(0, math.min(1, 1 - gap / 150))
        local r = math.floor(245)
        local g = math.floor(245 - 175 * danger)
        local b = math.floor(250 - 180 * danger)
        local gstr = string.format("%d M", math.floor(gap))
        text.draw(big, cx - text.width(big, gstr) / 2, sh * 0.12, r, g, b, 255, gstr)
        local kmh = string.format("%d KM/H", math.floor(math.max(0, f.speed or 0) * 3.6))
        text.draw(font.hud_small, cx - text.width(font.hud_small, kmh) / 2, sh * 0.12 + text.height(big), 215, 215, 228, 240, kmh)

        local w, h = 300 * s, 10 * s
        local x, y = cx - w / 2, sh * 0.12 + text.height(big) + text.height(font.hud_small) + 10 * s
        draw.rect(x, y, x + w, y + h, 255, 255, 255, 35, 5 * s)
        draw.rect(cx - 1 * s, y - 3 * s, cx + 1 * s, y + h + 3 * s, 255, 255, 255, 120, 0)
        local d = math.max(-1.2, math.min(1.2, f.drift or 0))
        local dx = cx + d * w / 2
        local mr, mg, mb = ar, ag, ab
        if math.abs(d) > 0.75 then mr, mg, mb = 240, 80, 70 end
        draw.circle(dx, y + h / 2, 8 * s, mr, mg, mb, 255)
        local hold = "HOLD YOUR LINE"
        local pulse = 0.5 + 0.5 * math.sin((ctx.time() or 0) * 8)
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, hold) / 2, y + h + 8 * s, 230, 230, 240, math.floor(150 + 100 * pulse * danger), hold)
        return
    end

    local result = math.floor(f.result or 0)
    local msgs = { "THEY FLINCHED", "CHICKEN!", "HEAD-ON", "CALLED OFF" }
    local msg = msgs[result] or ""
    local r, g, b = 240, 80, 70
    if result == 1 then r, g, b = ar, ag, ab elseif result == 4 then r, g, b = 220, 220, 230 end
    text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
    if (f.pay or 0) > 0 then
        local p = string.format("+$%d", math.floor(f.pay))
        if math.floor(f.streak or 0) > 1 then p = p .. string.format("   STREAK %d", math.floor(f.streak)) end
        text.draw(font.hud, cx - text.width(font.hud, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
    end
end)
