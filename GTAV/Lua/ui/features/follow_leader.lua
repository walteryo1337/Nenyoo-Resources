-- Follow the Leader. Shown during a chase and on the result screen. Published fields: active (bool), chasing / won /
-- lost (bool), distance (metres to the leader), time_left (seconds), score, best (best round this session), lose_k
-- (0..1, how close you are to losing the leader; 0 while you are close enough).
features.on_draw("Follow the Leader", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx = sw / 2

    if f.chasing then
        local w, h = 360 * s, 92 * s
        local x0, y0 = cx - w / 2, 40 * s
        draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
        text.draw(font.hud_small, x0 + 16 * s, y0 + 8 * s, 235, 235, 245, 255, "FOLLOW THE LEADER")
        local clock = string.format("%d", math.ceil(f.time_left or 0))
        text.draw(font.hud_small, x0 + w - 16 * s - text.width(font.hud_small, clock), y0 + 8 * s, 245, 245, 250, 255, clock)

        local d = f.distance or 0
        local bx0, bx1, by = x0 + 16 * s, x0 + w - 16 * s, y0 + 44 * s
        draw.rect(bx0, by, bx1, by + 12 * s, 40, 40, 52, 255, 6 * s)
        local k = math.max(0, math.min(1, 1 - d / 70))
        local r, g, b = 255, 90, 80
        if d < 10 then r, g, b = 120, 255, 160 elseif d < 25 then r, g, b = 255, 210, 90 end
        if k > 0 then draw.rect(bx0, by, bx0 + (bx1 - bx0) * k, by + 12 * s, r, g, b, 255, 6 * s) end
        local label = d < 10 and "ON THEIR BUMPER  x2.5" or (d < 25 and "IN RANGE" or "TOO FAR")
        text.draw(font.hud_tiny, bx0, by + 18 * s, r, g, b, 255, string.format("%s   %.0fm", label, d))
        local sc = string.format("%d PTS", math.floor(f.score or 0))
        text.draw(font.hud_tiny, bx1 - text.width(font.hud_tiny, sc), by + 18 * s, 255, 220, 90, 255, sc)

        local lk = f.lose_k or 0
        if lk > 0 then
            local msg = "CATCH UP!"
            text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.26, 255, 90, 80, math.floor(160 + 95 * math.abs(math.sin(t * 6))), msg)
            draw.rect(cx - 120 * s, sh * 0.26 + 50 * s, cx - 120 * s + 240 * s * (1 - lk), sh * 0.26 + 56 * s, 255, 90, 80, 230, 3 * s)
        end
    elseif f.won or f.lost then
        local msg = f.won and string.format("STUCK WITH THEM!  %d PTS", math.floor(f.score or 0)) or "YOU LOST THEM"
        local r, g, b = 255, 90, 80
        if f.won then r, g, b = 255, 215, 90 end
        text.draw(font.display, cx - text.width(font.display, msg) / 2, sh * 0.28, r, g, b, 255, msg)
        local sub = string.format("BEST %d   -   NEXT LEADER IN A MOMENT", math.floor(f.best or 0))
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, sub) / 2, sh * 0.28 + 48 * s, 210, 210, 220, math.floor(170 + 60 * math.sin(t * 3)), sub)
    end
end)
