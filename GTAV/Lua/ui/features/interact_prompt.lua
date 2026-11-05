-- Interaction Prompts HUD. Published fields: active (bool), label (string, what pressing E does now).
local shown = 0
local last_label = ""

features.on_draw("Interaction Prompts", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 8) else shown = math.max(0, shown - dt * 8) end
    if f.label then last_label = f.label end
    if shown <= 0 then return end
    local label = last_label
    if label == "" then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local a = math.floor(255 * shown)
    local pad = 10 * s
    local key = "E"
    local kh = text.height(font.hud_small) + pad * 0.8
    local kw = math.max(kh, text.width(font.hud_small, key) + pad)
    local lw = text.width(font.hud_small, label)
    local w = kw + lw + pad * 3
    local h = kh + pad
    local x = (sw - w) / 2
    local y = sh * 0.78 + (1 - shown) * 12 * s

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(170 * shown), 6 * s)
    local kx, ky = x + pad, y + (h - kh) / 2
    draw.rect(kx, ky, kx + kw, ky + kh, ar, ag, ab, a, 4 * s)
    text.draw(font.hud_small, kx + (kw - text.width(font.hud_small, key)) / 2, ky + pad * 0.4, 10, 10, 16, a, key)
    text.draw(font.hud_small, kx + kw + pad, y + (h - text.height(font.hud_small)) / 2, 240, 240, 245, a, label)
end)
