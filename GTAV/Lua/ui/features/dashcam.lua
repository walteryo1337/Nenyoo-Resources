-- Dashcam overlay. Published fields: active (bool), speed (km/h), year, month, day,
-- hours, minutes, seconds (in-game clock).
features.on_draw("Dashcam", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local m = 36 * s
    local white = 235

    local blink = math.floor(ctx.time() * 2) % 2 == 0
    if blink then draw.circle(m + 8 * s, m + 10 * s, 7 * s, 230, 40, 40, 255) end
    text.draw(font.hud_small, m + 22 * s, m, white, white, white, 240, "REC")

    local cam = "CAM 01"
    text.draw(font.hud_small, sw - m - text.width(font.hud_small, cam), m, white, white, white, 220, cam)

    local stamp = string.format("%04d/%02d/%02d  %02d:%02d:%02d",
        math.floor(f.year or 0), math.floor(f.month or 1), math.floor(f.day or 1),
        math.floor(f.hours or 0), math.floor(f.minutes or 0), math.floor(f.seconds or 0))
    local th = text.height(font.hud_small)
    text.draw(font.hud_small, sw - m - text.width(font.hud_small, stamp), sh - m - th, white, white, white, 230, stamp)

    local speed = string.format("%03d KM/H", math.floor(f.speed or 0))
    text.draw(font.hud_small, m, sh - m - th, white, white, white, 230, speed)
end)
