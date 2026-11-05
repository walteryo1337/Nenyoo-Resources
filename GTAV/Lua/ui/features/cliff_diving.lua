-- Cliff Diving. Published fields: active (bool), falling (bool, a scoring drop is under way), drop (metres fallen so far),
-- popup_age (seconds since the last dive, -1 when no result is showing), last_height (metres), last_clean (bool, false =
-- belly flop), last_score, last_pay, best (highest dive, missing until one), dives.
features.on_draw("Cliff Diving", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2

    if f.falling then
        local d = string.format("%d M", math.floor(f.drop or 0))
        text.draw(big, cx - text.width(big, d) / 2, sh * 0.16, 245, 245, 250, 235, d)
        local tag = "DROP"
        text.draw(font.hud_small, cx - text.width(font.hud_small, tag) / 2, sh * 0.16 - text.height(font.hud_small), 200, 200, 212, 220, tag)
    end

    local age = f.popup_age or -1
    if age < 0 then return end
    local alpha = 255
    if age > 2.8 then alpha = math.floor(255 * math.max(0, 1 - (age - 2.8) / 0.7)) end
    local rise = math.min(1, age / 0.25)
    local y = sh * 0.3 - 20 * s * (1 - rise)

    local h = f.last_height or 0
    local label = f.last_clean and "CLEAN ENTRY" or "BELLY FLOP"
    if f.last_clean and h >= 50 then label = "LEGENDARY DIVE" elseif f.last_clean and h >= 30 then label = "DEATH DIVE" end
    local r, g, b = ar, ag, ab
    if not f.last_clean then r, g, b = 240, 120, 70 elseif h >= 50 then r, g, b = 255, 205, 60 end
    text.draw(big, cx - text.width(big, label) / 2, y, r, g, b, alpha, label)
    y = y + text.height(big)
    local line = string.format("%.1f M   %d PTS", h, math.floor(f.last_score or 0))
    if (f.last_pay or 0) > 0 then line = line .. string.format("   +$%d", math.floor(f.last_pay)) end
    text.draw(font.hud, cx - text.width(font.hud, line) / 2, y, 240, 240, 248, alpha, line)
    y = y + text.height(font.hud) + 2 * s
    if f.best then
        local b2 = string.format("BEST %.1f M   DIVES %d", f.best, math.floor(f.dives or 0))
        text.draw(font.hud_small, cx - text.width(font.hud_small, b2) / 2, y, 200, 200, 212, math.floor(alpha * 0.9), b2)
    end
end)
