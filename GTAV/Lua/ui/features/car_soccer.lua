-- Car Soccer. Published fields: active (bool), state (1 kickoff, 2 playing, 3 goal scored, 4 full time), mine, theirs,
-- target (goals to win), seconds (match time left), countdown (seconds to kickoff), scorer (0 you, 1 rival),
-- result (1 won, 0 draw, -1 lost).
features.on_draw("Car Soccer", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)
    local mine, theirs = math.floor(f.mine or 0), math.floor(f.theirs or 0)
    local secs = math.floor(f.seconds or 0)

    local w, h = 320 * s, 70 * s
    local x0, y0 = sw / 2 - w / 2, 36 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 220, 12 * s)
    draw.rect(x0, y0, x0 + w * 0.5, y0 + 4 * s, 80, 150, 255, 255)
    draw.rect(x0 + w * 0.5, y0, x0 + w, y0 + 4 * s, 255, 80, 70, 255)

    text.draw(font.tiny, x0 + 16 * s, y0 + 12 * s, 150, 190, 255, 255, "YOU")
    local rv = "RIVAL"
    text.draw(font.tiny, x0 + w - 16 * s - text.width(font.tiny, rv), y0 + 12 * s, 255, 150, 140, 255, rv)

    local score = string.format("%d  -  %d", mine, theirs)
    text.draw(font.title, sw / 2 - text.width(font.title, score) / 2, y0 + 10 * s, 245, 245, 250, 255, score)

    local sub = string.format("%d:%02d   FIRST TO %d", math.floor(secs / 60), secs % 60, math.floor(f.target or 3))
    text.draw(font.tiny, sw / 2 - text.width(font.tiny, sub) / 2, y0 + h - 20 * s, 190, 190, 205, 220, sub)

    local banner, r, g, b
    if state == 1 then
        local c = math.floor(f.countdown or 0)
        banner, r, g, b = c > 0 and tostring(c) or "GO!", 255, 230, 120
    elseif state == 3 then
        if (f.scorer or 0) == 0 then banner, r, g, b = "GOAL!", 130, 200, 255
        else banner, r, g, b = "RIVAL SCORES", 255, 120, 110 end
    elseif state == 4 then
        local res = math.floor(f.result or 0)
        if res > 0 then banner, r, g, b = "YOU WIN!", 130, 255, 160
        elseif res < 0 then banner, r, g, b = "YOU LOSE", 255, 110, 110
        else banner, r, g, b = "DRAW", 230, 230, 230 end
    end
    if banner then
        local pulse = 1.0 + 0.06 * math.sin(t * 8)
        local a = math.floor(200 + 55 * math.sin(t * 6))
        draw.with_scale(sw / 2, sh * 0.3, pulse, function()
            text.draw(font.title, sw / 2 - text.width(font.title, banner) / 2, sh * 0.3, r, g, b, a, banner)
        end)
    end
end)
