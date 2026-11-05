-- Capture the Flag. Published fields: active (bool), state (1 raiding, 2 carrying the flag home, 3 result), state_age
-- (ms), distance (metres to the flag while raiding, to your home marker while carrying), guards_alive / guards_total,
-- kills, time_left (ms), chasers (bool, a pursuit crew is still alive), result (1 captured, 2 wasted, 3 out of time),
-- pay, captures (this session).
local function clock(ms)
    local secs = math.floor(ms / 1000)
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

features.on_draw("Capture the Flag", function(f)
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
        local msgs = { "FLAG CAPTURED", "WASTED", "OUT OF TIME" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = ar, ag, ab end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        local line = string.format("%d KILLS", math.floor(f.kills or 0))
        if (f.pay or 0) > 0 then line = string.format("+$%d   %s", math.floor(f.pay), line) end
        text.draw(font.hud, cx - text.width(font.hud, line) / 2, sh * 0.28 + text.height(big), 245, 245, 250, 255, line)
        return
    end

    local w = 340 * s
    local x, y = cx - w / 2, sh * 0.05
    local h = 92 * s
    draw.rect(x, y, x + w, y + h, 12, 12, 20, 200, 8 * s)
    local carrying = state == 2
    local fr, fg, fb = 230, 60, 60
    if carrying then fr, fg, fb = 70, 150, 255 end
    draw.line(x + 22 * s, y + 16 * s, x + 22 * s, y + 52 * s, 220, 220, 230, 255, 3 * s)
    local wave = math.sin(t * 6) * 3 * s
    draw.rect(x + 23 * s, y + 16 * s + wave * 0.3, x + 48 * s, y + 32 * s + wave * 0.3, fr, fg, fb, 255, 2 * s)

    local obj = carrying and "BRING THE FLAG HOME" or "STEAL THE ENEMY FLAG"
    text.draw(font.hud, x + 60 * s, y + 10 * s, 245, 245, 250, 255, obj)
    local d = string.format("%d M", math.floor(f.distance or 0))
    text.draw(font.hud_small, x + 60 * s, y + 38 * s, 200, 200, 215, 255, d)

    local left = f.time_left or 0
    local tr, tg, tb = 245, 245, 250
    if left < 60000 then
        local pulse = 0.5 + 0.5 * math.sin(t * 8)
        tr, tg, tb = 255, math.floor(80 + 80 * pulse), 70
    end
    local tl = clock(left)
    text.draw(font.display, x + w - 16 * s - text.width(font.display, tl), y + 12 * s, tr, tg, tb, 255, tl)

    local guards = string.format("GUARDS %d / %d   KILLS %d", math.floor(f.guards_alive or 0), math.floor(f.guards_total or 0), math.floor(f.kills or 0))
    text.draw(font.hud_small, x + 16 * s, y + h - 26 * s, 210, 210, 222, 255, guards)
    if f.chasers then
        local pulse = math.floor(170 + 85 * math.sin(t * 9))
        local c = "PURSUIT"
        text.draw(font.hud_small, x + w - 16 * s - text.width(font.hud_small, c), y + h - 26 * s, 255, 90, 70, pulse, c)
    end
end)
