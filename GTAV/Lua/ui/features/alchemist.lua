-- Alchemist. Lists every potion you have active. Published fields: active (bool), and for each active potion its
-- remaining fraction (1..0) plus <name>_secs (seconds left). Potion names: giant, feather, swift, iron, drunk,
-- hiccup. A potion's keys are missing when it is not active.
local potions = {
    { key = "giant",   label = "GIANT STRENGTH", r = 255, g = 120, b = 60 },
    { key = "feather", label = "FEATHER FALL",   r = 200, g = 230, b = 255 },
    { key = "swift",   label = "SWIFTNESS",      r = 120, g = 255, b = 170 },
    { key = "iron",    label = "IRON SKIN",      r = 180, g = 185, b = 200 },
    { key = "drunk",   label = "VERY DRUNK",     r = 230, g = 160, b = 255 },
    { key = "hiccup",  label = "HICCUPS",        r = 255, g = 210, b = 90 },
}

features.on_draw("Alchemist", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local w, rh, gap = 230 * s, 34 * s, 6 * s
    local x0 = sw - w - 30 * s
    local y = sh * 0.36
    for _, p in ipairs(potions) do
        local left = f[p.key]
        if left then
            draw.rect(x0, y, x0 + w, y + rh, 12, 12, 18, 210, 8 * s)
            draw.circle(x0 + 16 * s, y + rh / 2, 8 * s, p.r, p.g, p.b, 255)
            text.draw(font.tiny, x0 + 32 * s, y + 4 * s, 235, 235, 245, 255, p.label)
            local secs = string.format("%ds", math.ceil(f[p.key .. "_secs"] or 0))
            text.draw(font.tiny, x0 + w - 10 * s - text.width(font.tiny, secs), y + 4 * s, 200, 200, 214, 230, secs)
            local bx0, bx1, by = x0 + 32 * s, x0 + w - 10 * s, y + rh - 9 * s
            draw.rect(bx0, by, bx1, by + 4 * s, 40, 40, 52, 255, 2 * s)
            local k = math.max(0, math.min(1, left))
            if k > 0 then draw.rect(bx0, by, bx0 + (bx1 - bx0) * k, by + 4 * s, p.r, p.g, p.b, 255, 2 * s) end
            y = y + rh + gap
        end
    end
end)
