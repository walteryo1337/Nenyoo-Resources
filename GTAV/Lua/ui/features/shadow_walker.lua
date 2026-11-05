-- Shadow Walker. Published fields: active (bool), hidden (melted into the shadows), crouched (bool),
-- dark (dark enough to hide), reveal (1..0 while you are exposed after shooting or fighting).
features.on_draw("Shadow Walker", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    if f.hidden then
        local band = sh * 0.16
        local a = math.floor(150 + 20 * math.sin(t * 1.5))
        draw.rect_gradient(0, 0, sw, band, 8, 0, 18, a, 8, 0, 18, a, 8, 0, 18, 0, 8, 0, 18, 0)
        draw.rect_gradient(0, sh - band, sw, sh, 8, 0, 18, 0, 8, 0, 18, 0, 8, 0, 18, a, 8, 0, 18, a)
        draw.rect_gradient(0, 0, band, sh, 8, 0, 18, a, 8, 0, 18, 0, 8, 0, 18, 0, 8, 0, 18, a)
        draw.rect_gradient(sw - band, 0, sw, sh, 8, 0, 18, 0, 8, 0, 18, a, 8, 0, 18, a, 8, 0, 18, 0)
    end

    local msg, r, g, b, alpha
    if f.hidden then
        msg, r, g, b, alpha = "IN THE SHADOWS", 180, 140, 255, 220
    elseif f.crouched and (f.reveal or 0) > 0 then
        msg, r, g, b, alpha = "EXPOSED", 255, 120, 110, math.floor(120 + 135 * (f.reveal or 0))
    elseif f.crouched and not f.dark then
        msg, r, g, b, alpha = "TOO BRIGHT TO HIDE", 230, 220, 180, 200
    end
    if not msg then return end

    local tw = text.width(font.hud_small, msg)
    local x0, y0 = sw / 2 - tw / 2 - 16 * s, sh - 150 * s
    draw.rect(x0, y0, x0 + tw + 32 * s, y0 + 30 * s, 10, 6, 18, 190, 15 * s)
    text.draw(font.hud_small, sw / 2 - tw / 2, y0 + 6 * s, r, g, b, alpha, msg)
end)
