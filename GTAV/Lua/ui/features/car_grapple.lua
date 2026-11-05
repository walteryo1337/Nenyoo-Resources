-- Car Grapple. Shown while you drive with Car Grapple on. Published fields: active (bool), hooked (bool, the hook is
-- holding on to something), in_range (bool, the spot under the crosshair can be hooked), length (rope length in metres
-- while hooked).
features.on_draw("Car Grapple", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2

    local r, g, b, a = 200, 200, 214, 140
    if f.hooked then r, g, b, a = 255, 210, 90, 230
    elseif f.in_range then r, g, b, a = 120, 230, 150, 230 end
    local gap, len = 6 * s, 9 * s
    draw.line(cx - gap - len, cy, cx - gap, cy, r, g, b, a, 2 * s)
    draw.line(cx + gap, cy, cx + gap + len, cy, r, g, b, a, 2 * s)
    draw.line(cx, cy - gap - len, cx, cy - gap, r, g, b, a, 2 * s)
    draw.line(cx, cy + gap, cx, cy + gap + len, r, g, b, a, 2 * s)
    draw.circle(cx, cy, 2 * s, r, g, b, a)

    local label
    if f.hooked then label = string.format("HOOKED  %.0fm  -  LET GO OF G TO RELEASE", f.length or 0)
    elseif f.in_range then label = "HOLD G TO HOOK" end
    if label then text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, label) / 2, cy + 26 * s, r, g, b, a, label) end
end)
