-- Reversing Camera. Published fields: active (bool, the rear camera is showing), speed (m/s).
-- Draws backup-camera guide lines (green far, yellow middle, red close) and a REAR label.
features.on_draw("Reversing Camera", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx = sw / 2
    local bottom = sh * 0.96
    local top = sh * 0.58
    local near_half = sw * 0.30
    local far_half = sw * 0.12

    local bands = {
        { 0.00, 0.33, 235, 70, 70 },
        { 0.33, 0.66, 245, 200, 60 },
        { 0.66, 1.00, 110, 220, 120 },
    }
    for _, b in ipairs(bands) do
        local y1 = bottom + (top - bottom) * b[1]
        local y2 = bottom + (top - bottom) * b[2]
        local h1 = near_half + (far_half - near_half) * b[1]
        local h2 = near_half + (far_half - near_half) * b[2]
        draw.line(cx - h1, y1, cx - h2, y2, b[3], b[4], b[5], 220, 3 * s)
        draw.line(cx + h1, y1, cx + h2, y2, b[3], b[4], b[5], 220, 3 * s)
        draw.line(cx - h2, y2, cx - h2 + 30 * s, y2, b[3], b[4], b[5], 220, 3 * s)
        draw.line(cx + h2, y2, cx + h2 - 30 * s, y2, b[3], b[4], b[5], 220, 3 * s)
    end

    local label = "REAR"
    local pad = 6 * s
    local tw = text.width(font.hud_small, label)
    local th = text.height(font.hud_small)
    local x, y = 32 * s, 32 * s
    draw.rect(x, y, x + tw + pad * 2, y + th + pad * 2, 10, 10, 16, 160, 4 * s)
    text.draw(font.hud_small, x + pad, y + pad, 245, 245, 250, 255, label)
    local kmh = string.format("%d KM/H", math.floor((f.speed or 0) * 3.6 + 0.5))
    text.draw(font.hud_tiny, x, y + th + pad * 3, 230, 230, 235, 230, kmh)
end)
