-- Sky Rings. Published fields: active (bool), next (rings passed so far), count (rings in the course),
-- elapsed / par / best (seconds; best is missing until a course of this length is finished),
-- distance (metres to the next ring), on_screen + sx / sy (0..1 screen position of the next ring),
-- finished (bool), pass_age (seconds since the last ring was passed).
local function clock(t)
    t = math.max(0, t or 0)
    return string.format("%d:%05.2f", math.floor(t / 60), t % 60)
end

features.on_draw("Sky Rings", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local count = math.floor(f.count or 0)
    local next = math.floor(f.next or 0)

    local y = sh * 0.06
    local t = clock(f.elapsed)
    local over = (f.elapsed or 0) > (f.par or 0)
    local tr, tg, tb = 245, 245, 250
    if over and not f.finished then tr, tg, tb = 240, 120, 80 end
    text.draw(big, cx - text.width(big, t) / 2, y, tr, tg, tb, 255, t)
    y = y + text.height(big) + 2 * s
    local info = string.format("RING %d / %d    PAR %s", math.min(next + 1, count), count, clock(f.par))
    if f.best then info = info .. "    BEST " .. clock(f.best) end
    text.draw(font.hud_small, cx - text.width(font.hud_small, info) / 2, y, 200, 200, 212, 235, info)
    y = y + text.height(font.hud_small) + 6 * s
    local bw = 240 * s
    draw.rect(cx - bw / 2, y, cx + bw / 2, y + 4 * s, 0, 0, 0, 140, 2 * s)
    if count > 0 then draw.rect(cx - bw / 2, y, cx - bw / 2 + bw * next / count, y + 4 * s, ar, ag, ab, 255, 2 * s) end

    if not f.finished and f.on_screen then
        local x, yy = (f.sx or 0) * sw, (f.sy or 0) * sh
        draw.circle_outline(x, yy, 14 * s, 255, 215, 60, 230, 2 * s)
        local d = string.format("%d M", math.floor(f.distance or 0))
        text.draw(font.hud_tiny, x - text.width(font.hud_tiny, d) / 2, yy + 18 * s, 255, 235, 160, 235, d)
    end

    local age = f.pass_age or 99
    if age < 0.6 and not f.finished then
        local a = math.floor(255 * (0.6 - age) / 0.6)
        draw.circle_outline(cx, sh / 2, (40 + age * 160) * s, ar, ag, ab, a, 3 * s)
    end
    if f.finished then
        local msg = "COURSE COMPLETE"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, ar, ag, ab, 255, msg)
    end
end)
