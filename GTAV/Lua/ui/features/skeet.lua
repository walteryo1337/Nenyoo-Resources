-- Skeet Shooting. Published fields: active (bool), results (15 characters, one per bottle: 0 still to
-- come, 1 hit, 2 missed), hits, best (best round), pull_age (seconds since the last launch), finished
-- (bool, round over and the next one is about to start).
features.on_draw("Skeet Shooting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local results = f.results or ""
    local count = #results

    local dot, gap = 12 * s, 6 * s
    local w = count * dot + (count - 1) * gap
    local cx = sw / 2
    local x = cx - w / 2
    local y = sh * 0.08

    local title = string.format("SKEET   %d / %d   BEST %d", math.floor(f.hits or 0), count, math.floor(f.best or 0))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, title) / 2, y - text.height(font.hud_tiny) - 6 * s, 220, 220, 230, 240, title)

    for i = 1, count do
        local c = results:sub(i, i)
        local bx = x + (i - 1) * (dot + gap)
        if c == "1" then
            draw.circle(bx + dot / 2, y + dot / 2, dot / 2, 110, 225, 120, 255)
        elseif c == "2" then
            draw.circle(bx + dot / 2, y + dot / 2, dot / 2, 235, 75, 65, 255)
        else
            draw.circle_outline(bx + dot / 2, y + dot / 2, dot / 2, 150, 150, 165, 200, 1.5)
        end
    end

    local age = f.pull_age or 99
    if not f.finished and age < 0.6 then
        local a = math.floor(255 * (1 - age / 0.6))
        local msg = "PULL!"
        local fnt = font.display
        text.draw(fnt, cx - text.width(fnt, msg) / 2, y + dot + 14 * s, ar, ag, ab, a, msg)
    elseif f.finished then
        local msg = "NEXT ROUND SOON"
        text.draw(font.hud_small, cx - text.width(font.hud_small, msg) / 2, y + dot + 14 * s, 200, 200, 210, 230, msg)
    end
end)
