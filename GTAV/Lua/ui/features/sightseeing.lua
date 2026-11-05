-- Sightseeing. Published fields: active (bool), count / total (landmarks photographed), nearest + distance (closest
-- landmark not yet photographed, missing once the album is full), progress (0..1, only while taking a photo),
-- last + last_age (the landmark just photographed, for about 4 seconds).
local function metres(d)
    d = d or 0
    if d >= 1000 then return string.format("%.1f km", d / 1000) end
    return string.format("%d m", math.floor(d))
end

features.on_draw("Sightseeing", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local pad = 10 * s

    local head = string.format("ALBUM %d / %d", math.floor(f.count or 0), math.floor(f.total or 0))
    local sub = f.nearest and string.format("%s  %s", f.nearest, metres(f.distance)) or "Album complete"
    local w = math.max(text.width(font.hud_small, head), text.width(font.hud_tiny, sub)) + pad * 2
    local h = text.height(font.hud_small) + text.height(font.hud_tiny) + pad * 2 + 6 * s
    local x, y = sw - w - 28 * s, sh * 0.27
    draw.rect(x, y, x + w, y + h, 10, 12, 18, 185, 6 * s)
    local frac = (f.total or 0) > 0 and (f.count or 0) / f.total or 0
    draw.rect(x, y + h - 3 * s, x + w * frac, y + h, ar, ag, ab, 255, 0)
    text.draw(font.hud_small, x + pad, y + pad, 240, 240, 248, 255, head)
    text.draw(font.hud_tiny, x + pad, y + pad + text.height(font.hud_small) + 3 * s, 195, 195, 210, 235, sub)

    if f.progress then
        local cx, cy = sw / 2, sh * 0.7
        local bw = 200 * s
        draw.rect(cx - bw / 2, cy, cx + bw / 2, cy + 6 * s, 0, 0, 0, 160, 3 * s)
        draw.rect(cx - bw / 2, cy, cx - bw / 2 + bw * f.progress, cy + 6 * s, ar, ag, ab, 255, 3 * s)
        local msg = "LINING UP THE SHOT"
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, msg) / 2, cy - text.height(font.hud_tiny) - 4 * s, 235, 235, 245, 240, msg)
    end

    local age = f.last_age or 99
    if f.last and age < 4 then
        local a = math.floor(255 * math.min(1, (4 - age) * 1.5))
        if age < 0.25 then
            draw.rect(0, 0, sw, sh, 255, 255, 255, math.floor(180 * (0.25 - age) / 0.25), 0)
        end
        local big = font.display
        text.draw(big, sw / 2 - text.width(big, f.last) / 2, sh * 0.32, ar, ag, ab, a, f.last)
    end
end)
