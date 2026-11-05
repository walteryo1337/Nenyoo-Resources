-- Paintball. Published fields: active (bool), state (1 countdown, 2 match, 3 result), result (1 won, 2 tagged out,
-- 3 won on time, 4 lost on time, 5 draw, 6 forfeit), my_hits / hits_to_out (you are out when they meet), blue_in /
-- blue_total (your team, including you), red_in / red_total, tags (red players you tagged out), countdown, time_left
-- (seconds), paid.
features.on_draw("Paintball", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 3 then
        local result = math.floor(f.result or 0)
        local msg, r, g, b = "FORFEIT", 200, 200, 210
        if result == 1 then msg, r, g, b = "BLUE TEAM WINS", 90, 170, 255
        elseif result == 2 then msg, r, g, b = "TAGGED OUT", 240, 80, 70
        elseif result == 3 then msg, r, g, b = "WIN ON TIME", 90, 170, 255
        elseif result == 4 then msg, r, g, b = "LOSS ON TIME", 240, 80, 70
        elseif result == 5 then msg, r, g, b = "DRAW", 220, 220, 230 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        local sub = string.format("%d TAGS", math.floor(f.tags or 0))
        if (f.paid or 0) > 0 then sub = sub .. string.format("   +$%d", math.floor(f.paid)) end
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.26 + text.height(big), 245, 245, 250, 255, sub)
        return
    end

    -- team pips: blue on the left, red on the right
    local pip = 14 * s
    local top = sh * 0.05
    local function pips(total, alive, x, dir, r, g, b)
        for i = 1, total do
            local px = x + dir * (i - 1) * (pip + 6 * s)
            if i <= alive then draw.circle(px, top + pip / 2, pip / 2, r, g, b, 255)
            else draw.circle_outline(px, top + pip / 2, pip / 2, r, g, b, 160, 2 * s) end
        end
    end
    pips(math.floor(f.blue_total or 0), math.floor(f.blue_in or 0), cx - 60 * s, -1, 90, 170, 255)
    pips(math.floor(f.red_total or 0), math.floor(f.red_in or 0), cx + 60 * s, 1, 240, 80, 70)

    if state == 2 then
        local t = math.max(0, f.time_left or 0)
        local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
        text.draw(font.hud, cx - text.width(font.hud, clock) / 2, top - 4 * s, 245, 245, 250, 255, clock)
    elseif state == 1 then
        local n = tostring(math.max(1, math.ceil(f.countdown or 0)))
        text.draw(big, cx - text.width(big, n) / 2, sh * 0.3, ar, ag, ab, 255, n)
    end

    local hits = math.floor(f.my_hits or 0)
    local need = math.floor(f.hits_to_out or 2)
    local lives = string.format("HITS %d / %d", hits, need)
    local lr, lg, lb = 220, 220, 232
    if hits >= need - 1 and hits > 0 then lr, lg, lb = 240, 110, 80 end
    text.draw(font.hud_small, cx - text.width(font.hud_small, lives) / 2, top + pip + 10 * s, lr, lg, lb, 255, lives)
    local tags = string.format("TAGS %d", math.floor(f.tags or 0))
    text.draw(font.hud_small, cx - text.width(font.hud_small, tags) / 2, top + pip + 14 * s + text.height(font.hud_small), 200, 200, 214, 230, tags)
end)
