-- Street Boxing. Published fields: active (bool), state (1 countdown, 2 fighting, 3 result), result (1 knockout win,
-- 2 won on points, 3 lost on points, 4 knocked out, 5 forfeit), tier (0 lightweight, 1 middleweight, 2 heavyweight),
-- stake, paid, my_hp / opp_hp (0-1), countdown (seconds), time_left (seconds of the bout), wins / losses (this session).
local tiers = { "LIGHTWEIGHT", "MIDDLEWEIGHT", "HEAVYWEIGHT" }

features.on_draw("Street Boxing", function(f)
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
        if result == 1 then msg, r, g, b = "KNOCKOUT!", 255, 205, 60
        elseif result == 2 then msg, r, g, b = "WIN ON POINTS", 120, 230, 120
        elseif result == 3 then msg, r, g, b = "LOST ON POINTS", 240, 120, 90
        elseif result == 4 then msg, r, g, b = "KNOCKED OUT", 240, 80, 70 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        local sub
        if (f.paid or 0) > 0 then sub = string.format("+$%d", math.floor(f.paid))
        elseif (f.stake or 0) > 0 then sub = string.format("-$%d", math.floor(f.stake)) end
        local rec = string.format("RECORD %d-%d", math.floor(f.wins or 0), math.floor(f.losses or 0))
        local y = sh * 0.26 + text.height(big)
        if sub then
            text.draw(font.hud, cx - text.width(font.hud, sub) / 2, y, 245, 245, 250, 255, sub)
            y = y + text.height(font.hud)
        end
        text.draw(font.hud_small, cx - text.width(font.hud_small, rec) / 2, y + 4 * s, 200, 200, 214, 230, rec)
        return
    end

    local bw = 300 * s
    local bh = 14 * s
    local top = sh * 0.06
    local gap = 70 * s
    local function bar(x1, frac, r, g, b, flip)
        draw.rect(x1, top, x1 + bw, top + bh, 30, 30, 38, 220, 4 * s)
        local fill = bw * math.max(0, math.min(1, frac))
        if flip then
            draw.rect(x1 + bw - fill, top, x1 + bw, top + bh, r, g, b, 255, 4 * s)
        else
            draw.rect(x1, top, x1 + fill, top + bh, r, g, b, 255, 4 * s)
        end
    end
    bar(cx - gap / 2 - bw, f.my_hp or 0, 90, 170, 255, true)
    bar(cx + gap / 2, f.opp_hp or 0, 240, 90, 70, false)
    text.draw(font.hud_small, cx - gap / 2 - bw, top + bh + 4 * s, 220, 220, 232, 240, "YOU")
    local tname = tiers[math.floor(f.tier or 0) + 1] or "FIGHTER"
    text.draw(font.hud_small, cx + gap / 2 + bw - text.width(font.hud_small, tname), top + bh + 4 * s, 220, 220, 232, 240, tname)

    if state == 2 then
        local t = math.max(0, f.time_left or 0)
        local clock = string.format("%d:%02d", math.floor(t / 60), math.floor(t % 60))
        text.draw(font.hud, cx - text.width(font.hud, clock) / 2, top - 2 * s, 245, 245, 250, 255, clock)
    elseif state == 1 then
        local n = math.max(1, math.ceil(f.countdown or 0))
        local str = tostring(n)
        text.draw(big, cx - text.width(big, str) / 2, sh * 0.3, ar, ag, ab, 255, str)
    end

    if (f.stake or 0) > 0 then
        local st = string.format("STAKE $%d", math.floor(f.stake))
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, st) / 2, top + bh + 6 * s, 190, 190, 205, 230, st)
    end
end)
