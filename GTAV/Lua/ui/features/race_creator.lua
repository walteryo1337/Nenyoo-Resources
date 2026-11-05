-- Race Creator. Published fields: active (bool), mode (0 recording, 1 racing), points (checkpoints in the
-- route), state (0 waiting at the start, 1 countdown, 2 racing, 3 finished), next (index of the next
-- checkpoint), countdown (seconds), elapsed, best, last, split (seconds; best/last 0 = none yet),
-- distance (metres to the next checkpoint, or to the start while waiting).
local function clock(t)
    t = math.max(0, t or 0)
    return string.format("%d:%05.2f", math.floor(t / 60), t % 60)
end

features.on_draw("Race Creator", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local points = math.floor(f.points or 0)

    if math.floor(f.mode or 0) == 0 then
        local pulse = 160 + math.floor(95 * math.abs(math.sin(ctx.time() * 3)))
        draw.circle(cx - 90 * s, sh * 0.08 + 7 * s, 5 * s, 235, 60, 60, pulse)
        local msg = string.format("RECORDING ROUTE   %d CHECKPOINTS", points)
        text.draw(font.hud_small, cx - 78 * s, sh * 0.08, 240, 240, 245, 255, msg)
        return
    end

    local state = math.floor(f.state or 0)
    local y = sh * 0.07
    if state == 0 then
        local d = math.floor(f.distance or 0)
        local msg = string.format("DRIVE TO THE START   %d M", d)
        text.draw(font.hud_small, cx - text.width(font.hud_small, msg) / 2, y, 240, 240, 245, 255, msg)
    elseif state == 1 then
        local n = math.floor(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "GO"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
    else
        local t = clock(f.elapsed)
        text.draw(big, cx - text.width(big, t) / 2, y, 245, 245, 250, 255, t)
        y = y + text.height(big) + 2 * s
        local info
        if state == 2 then
            info = string.format("CHECKPOINT %d / %d   SPLIT %s", math.floor(f.next or 0), points - 1, clock(f.split))
        else
            info = "FINISHED"
        end
        text.draw(font.hud_small, cx - text.width(font.hud_small, info) / 2, y, ar, ag, ab, 255, info)
        y = y + text.height(font.hud_small) + 2 * s
        if (f.best or 0) > 0 then
            local best = "BEST " .. clock(f.best)
            text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, best) / 2, y, 180, 180, 195, 220, best)
        end
    end
end)
