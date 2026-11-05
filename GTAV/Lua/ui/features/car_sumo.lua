-- Car Sumo. Published fields: active (bool), state (1 countdown, 2 bout, 3 result), countdown (seconds), time_left
-- (seconds), rivals_left / rivals_total, edge (your distance from the centre as a share of the ring radius, above 1 =
-- out), out_flash (0..1 just after a rival is knocked out, -1 otherwise), result (1 won, 2 you were pushed out,
-- 3 time up), pay, wins.
features.on_draw("Car Sumo", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local t = ctx.time() or 0

    if state == 1 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "PUSH"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
        return
    end

    if state == 3 then
        local result = math.floor(f.result or 0)
        local msgs = { "YOKOZUNA", "PUSHED OUT", "TIME UP" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = 255, 205, 60 elseif result == 3 then r, g, b = 220, 220, 230 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        if (f.pay or 0) > 0 then
            local p = string.format("+$%d", math.floor(f.pay))
            text.draw(font.hud, cx - text.width(font.hud, p) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, p)
        end
        return
    end

    local total = math.floor(f.rivals_total or 0)
    local left = math.floor(f.rivals_left or 0)
    local y = sh * 0.06
    local dot = 12 * s
    local gap = 10 * s
    local width = total * dot * 2 + (total - 1) * gap
    local x = cx - width / 2 + dot
    for i = 1, total do
        local alive = i <= left
        local r, g, b, a = 235, 60, 50, 255
        if not alive then r, g, b, a = 90, 90, 100, 160 end
        draw.circle(x + (i - 1) * (dot * 2 + gap), y + dot, dot, r, g, b, a)
    end
    local tl = math.max(0, f.time_left or 0)
    local clock = string.format("%d:%02d", math.floor(tl / 60), math.floor(tl % 60))
    text.draw(font.hud_small, cx - text.width(font.hud_small, clock) / 2, y + dot * 2 + 6 * s, 220, 220, 232, 240, clock)

    local edge = math.max(0, math.min(1.1, f.edge or 0))
    local bw, bh = 240 * s, 8 * s
    local bx, by = cx - bw / 2, sh * 0.82
    draw.rect(bx, by, bx + bw, by + bh, 255, 255, 255, 30, 4 * s)
    local r, g, b = ar, ag, ab
    if edge > 0.8 then r, g, b = 240, 70, 55 end
    draw.rect(bx, by, bx + bw * math.min(1, edge), by + bh, r, g, b, 235, 4 * s)
    if edge > 0.8 then
        local pulse = 0.5 + 0.5 * math.sin(t * 10)
        local warn = "EDGE"
        text.draw(font.hud, cx - text.width(font.hud, warn) / 2, by - text.height(font.hud) - 4 * s, 240, 70, 55, math.floor(150 + 105 * pulse), warn)
    end

    local flash = f.out_flash or -1
    if flash >= 0 then
        local a = math.floor(255 * (1 - flash))
        local msg = "RIVAL OUT"
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.2 - 20 * s * flash, ar, ag, ab, a, msg)
    end
end)
