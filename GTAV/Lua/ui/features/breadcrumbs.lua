-- Breadcrumbs. Published fields: active (bool), length (metres of trail recorded), to_start (metres straight back to
-- where the trail began), points (crumbs dropped, up to 400 kept).
local function metres(d)
    d = d or 0
    if d >= 1000 then return string.format("%.2f km", d / 1000) end
    return string.format("%d m", math.floor(d))
end

features.on_draw("Breadcrumbs", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local line = string.format("TRAIL %s   START %s", metres(f.length), metres(f.to_start))
    local w = text.width(font.tiny, line) + 22 * s
    local x, y = 28 * s, sh * 0.56
    draw.rect(x, y, x + w, y + text.height(font.tiny) + 10 * s, 10, 12, 18, 170, 5 * s)
    draw.circle(x + 9 * s, y + 5 * s + text.height(font.tiny) / 2, 3 * s, 255, 150, 40, 255)
    text.draw(font.tiny, x + 16 * s, y + 5 * s, 235, 235, 245, 240, line)
end)
