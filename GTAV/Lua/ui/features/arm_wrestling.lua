-- Arm Wrestling. Published fields: active (bool), state (1 get ready, 2 wrestling, 3 result), result (1 won, 2 lost,
-- 3 they said no, 4 called off), meter (-1 they win .. 1 you win), countdown (seconds), time_left (seconds of the bout),
-- surge (bool, they are pushing hard right now), next_key (0 A, 1 D: the key to tap next), strength (1-3 how strong they
-- are), stake, paid, wins / losses (this session).
features.on_draw("Arm Wrestling", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 3 then
        local result = math.floor(f.result or 0)
        local msg, r, g, b = "CALLED OFF", 200, 200, 210
        if result == 1 then msg, r, g, b = "YOU WIN", 120, 230, 120
        elseif result == 2 then msg, r, g, b = "YOU LOSE", 240, 80, 70
        elseif result == 3 then msg, r, g, b = "NOT INTERESTED", 220, 200, 120 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, r, g, b, 255, msg)
        if result == 1 or result == 2 then
            local sub
            if (f.paid or 0) > 0 then sub = string.format("+$%d", math.floor(f.paid))
            elseif (f.stake or 0) > 0 then sub = string.format("-$%d", math.floor(f.stake)) end
            local rec = string.format("RECORD %d-%d", math.floor(f.wins or 0), math.floor(f.losses or 0))
            local y = sh * 0.3 + text.height(big)
            if sub then
                text.draw(font.item, cx - text.width(font.item, sub) / 2, y, 245, 245, 250, 255, sub)
                y = y + text.height(font.item)
            end
            text.draw(font.small, cx - text.width(font.small, rec) / 2, y + 4 * s, 200, 200, 214, 230, rec)
        end
        return
    end

    local w, h = 520 * s, 22 * s
    local x1, y1 = cx - w / 2, sh * 0.72
    draw.rect(x1 - 12 * s, y1 - 50 * s, x1 + w + 12 * s, y1 + h + 64 * s, 12, 12, 16, 215, 10 * s)
    draw.rect_gradient(x1, y1, x1 + w, y1 + h, 240, 80, 70, 230, 90, 170, 255, 230, 90, 170, 255, 230, 240, 80, 70, 230)
    draw.rect(cx - 1 * s, y1 - 4 * s, cx + 1 * s, y1 + h + 4 * s, 255, 255, 255, 160, 0)
    local m = math.max(-1, math.min(1, f.meter or 0))
    local kx = cx + m * w / 2
    draw.circle(kx, y1 + h / 2, 16 * s, 245, 245, 250, 255)
    draw.circle(kx, y1 + h / 2, 11 * s, ar, ag, ab, 255)
    text.draw(font.small, x1, y1 - 30 * s, 240, 120, 100, 240, "THEM")
    text.draw(font.small, x1 + w - text.width(font.small, "YOU"), y1 - 30 * s, 120, 180, 255, 240, "YOU")

    local stars = string.rep("*", math.floor(f.strength or 1))
    text.draw(font.small, cx - text.width(font.small, stars) / 2, y1 - 32 * s, 240, 200, 80, 255, stars)

    if state == 1 then
        local n = tostring(math.max(1, math.ceil(f.countdown or 0)))
        text.draw(big, cx - text.width(big, n) / 2, sh * 0.32, ar, ag, ab, 255, n)
        local hint = "TAP A AND D IN TURN TO PUSH"
        text.draw(font.small, cx - text.width(font.small, hint) / 2, y1 + h + 18 * s, 220, 220, 232, 240, hint)
        return
    end

    local nk = math.floor(f.next_key or 0)
    local kw = 46 * s
    for i = 0, 1 do
        local bx = cx - kw - 8 * s + i * (kw + 16 * s)
        local by = y1 + h + 14 * s
        local hot = nk == i
        draw.rect(bx, by, bx + kw, by + kw * 0.8, hot and ar or 50, hot and ag or 50, hot and ab or 60, hot and 255 or 200, 6 * s)
        local key = i == 0 and "A" or "D"
        text.draw(font.item, bx + kw / 2 - text.width(font.item, key) / 2, by + kw * 0.4 - text.height(font.item) / 2, 255, 255, 255, 255, key)
    end
    local t = math.max(0, f.time_left or 0)
    local clock = string.format("%d", math.ceil(t))
    text.draw(font.small, x1 + w - text.width(font.small, clock), y1 + h + 20 * s, 200, 200, 214, 230, clock)
    if f.surge then
        local msg = "THEY'RE PUSHING HARD"
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.6, 240, 90, 70, 255, msg)
    end
end)
