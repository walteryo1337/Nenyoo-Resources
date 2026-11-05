-- Tag. Published fields: active (bool), role (1 you are it, 2 run, 3 game over), time_left (seconds left in this role),
-- distance (metres to the runner), score (points this game), best (best game this session), role_age (seconds in this role).
features.on_draw("Tag", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local role = math.floor(f.role or 0)
    local age = f.role_age or 99

    if role == 3 then
        local msg = "GAME OVER"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 245, 245, 250, 255, msg)
        local sub = string.format("%d POINTS   BEST %d", math.floor(f.score or 0), math.floor(f.best or 0))
        text.draw(font.hud, cx - text.width(font.hud, sub) / 2, sh * 0.3 + text.height(big) + 4 * s, 210, 210, 220, 255, sub)
        return
    end

    local it = role == 1
    local label = it and "YOU'RE IT" or "RUN!"
    local r, g, b = 240, 70, 60
    if not it then r, g, b = ar, ag, ab end
    if age < 1.5 then
        local pop = 1 + math.max(0, 0.25 - age) * 1.2
        local a = math.floor(255 * math.min(1, (1.5 - age) * 2))
        text.draw(big, cx - text.width(big, label) / 2, sh * 0.32 - (pop - 1) * 30 * s, r, g, b, a, label)
    end

    local t = math.max(0, f.time_left or 0)
    local y = sh * 0.06
    local w, h = 280 * s, 44 * s
    draw.rect(cx - w / 2, y, cx + w / 2, y + h, 12, 12, 18, 195, 6 * s)
    draw.rect(cx - w / 2, y + h - 3 * s, cx + w / 2, y + h, r, g, b, 255, 0)
    text.draw(font.hud, cx - w / 2 + 12 * s, y + h / 2 - text.height(font.hud) / 2, r, g, b, 255, label)
    local clock = string.format("%d", math.ceil(t))
    text.draw(font.display, cx + w / 2 - 12 * s - text.width(font.display, clock), y + h / 2 - text.height(font.display) / 2, 245, 245, 250, 255, clock)
    local sub = string.format("%d M   POINTS %d   BEST %d", math.floor(f.distance or 0), math.floor(f.score or 0), math.floor(f.best or 0))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, sub) / 2, y + h + 4 * s, 200, 200, 212, 225, sub)
end)
