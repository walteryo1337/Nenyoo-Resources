-- Quick-Draw Duel. Published fields: active (bool), state (1 standoff, 2 draw, 3 result), result (1 won,
-- 2 shot first by them, 3 foul: you drew early), reaction (seconds since DRAW, or your last reaction time),
-- best (fastest winning draw, 0 = none), wins, streak.
features.on_draw("Quick-Draw Duel", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx, cy = sw / 2, sh * 0.32
    local state = math.floor(f.state or 0)

    local function centre(fnt, y, str, r, g, b, a)
        text.draw(fnt, cx - text.width(fnt, str) / 2, y, r, g, b, a, str)
    end

    if state == 1 then
        local dots = string.rep(".", math.floor(ctx.time() * 2) % 4)
        centre(big, cy, "WAIT" .. dots, 230, 230, 235, 230)
        centre(font.hud_small, cy + text.height(big) + 6 * s, "HANDS OFF YOUR GUN", 190, 190, 200, 220)
    elseif state == 2 then
        centre(big, cy, "DRAW!", 255, 80, 60, 255)
        centre(font.hud, cy + text.height(big) + 6 * s, string.format("%.2fs", f.reaction or 0), 245, 245, 250, 255)
    elseif state == 3 then
        local result = math.floor(f.result or 0)
        local title, r, g, b = "YOU WIN", ar, ag, ab
        if result == 2 then title, r, g, b = "TOO SLOW", 240, 80, 70
        elseif result == 3 then title, r, g, b = "FOUL! YOU DREW EARLY", 240, 80, 70 end
        centre(big, cy, title, r, g, b, 255)
        local y = cy + text.height(big) + 6 * s
        if result ~= 3 then
            centre(font.hud, y, string.format("REACTION %.2fs", f.reaction or 0), 245, 245, 250, 255)
            y = y + text.height(font.hud) + 2 * s
        end
        local best = (f.best or 0) > 0 and string.format("   BEST %.2fs", f.best) or ""
        centre(font.hud_tiny, y, string.format("WINS %d   STREAK %d%s", math.floor(f.wins or 0), math.floor(f.streak or 0), best), 180, 180, 195, 220)
    end
end)
