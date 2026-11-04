-- Weapon Card. Published fields: active (bool), age (0..1 through the display time), name (string, may be
-- empty), damage, speed (fire rate), capacity, accuracy, range (the game's 0..100 HUD ratings), clip.
features.on_draw("Weapon Card", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local age = f.age or 1
    local t = age < 0.1 and age / 0.1 or (age > 0.8 and (1 - age) / 0.2 or 1)
    t = math.max(0, t)
    local a = math.floor(255 * t)
    local ar, ag, ab = theme.accent()
    local fnt = font.display or font.item

    local name = f.name or ""
    if name == "" then name = "WEAPON" end
    local stats = {
        { "DAMAGE", f.damage or 0 },
        { "FIRE RATE", f.speed or 0 },
        { "ACCURACY", f.accuracy or 0 },
        { "RANGE", f.range or 0 },
        { "CAPACITY", f.capacity or 0 },
    }

    local pad = 14 * s
    local th = text.height(font.tiny)
    local label_w = text.width(font.tiny, "FIRE RATE") + 10 * s
    local bar_w = 160 * s
    local w = math.max(text.width(fnt, name) + pad * 2, label_w + bar_w + pad * 2)
    local h = text.height(fnt) + th * 2 + (#stats) * (th + 3 * s) + pad * 1.6
    local x = sw * 0.5 - w * 0.5
    local y = sh - h - 120 * s + (1 - t) * 16 * s

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(170 * t), 8 * s)
    draw.rect(x, y + h - 3 * s, x + w, y + h, ar, ag, ab, a, 0)

    local ty = y + pad * 0.6
    text.draw(fnt, x + pad, ty, 245, 245, 250, a, name)
    ty = ty + text.height(fnt)
    local clip = math.floor(f.clip or 0)
    if clip > 0 then text.draw(font.tiny, x + pad, ty, 190, 190, 200, a, string.format("CLIP %d", clip)) end
    ty = ty + th + 4 * s
    for _, st in ipairs(stats) do
        text.draw(font.tiny, x + pad, ty, 200, 200, 210, a, st[1])
        local bx = x + pad + label_w
        local by = ty + th * 0.35
        local p = math.min(1, math.max(0, st[2] / 100))
        draw.rect(bx, by, bx + bar_w, by + 5 * s, 0, 0, 0, math.floor(160 * t), 0)
        draw.rect(bx, by, bx + bar_w * p, by + 5 * s, ar, ag, ab, a, 0)
        ty = ty + th + 3 * s
    end
end)
