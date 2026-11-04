-- Stealth Meter. Published fields: active (bool, sneaking or being hunted), sneaking (bool), noise (the
-- game's stealth noise value for you; roughly 0 standing still, single digits sneaking, well above 10
-- running or shooting), hunters (enemies currently in combat with you). Drawn above the minimap.
local shown = 0
local level = 0
local full_scale = 20

features.on_draw("Stealth Meter", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 6) else shown = math.max(0, shown - dt * 6) end
    local target = math.min(1, math.max(0, (f.noise or 0) / full_scale))
    level = level + (target - level) * math.min(1, dt * 8)
    if shown <= 0 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local a = shown
    local hunters = math.floor(f.hunters or 0)

    local label, r, g, b
    if hunters > 0 then
        label = hunters == 1 and "SPOTTED" or string.format("SPOTTED x%d", hunters)
        local pulse = 0.75 + 0.25 * math.sin(ctx.time() * 8)
        r, g, b = math.floor(235 * pulse), 60, 60
    elseif level < 0.1 then
        label, r, g, b = "HIDDEN", 120, 200, 255
    elseif level < 0.4 then
        label, r, g, b = "QUIET", 140, 220, 150
    else
        label, r, g, b = "NOISY", 240, 180, 60
    end

    local x = 28 * s
    local y = sh - 296 * s + (1 - shown) * 10 * s
    local pad = 6 * s
    local bar_w = 150 * s
    local bar_h = 4 * s
    local th = text.height(font.tiny)
    local w = bar_w + pad * 2
    local h = th + bar_h + pad * 3

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(150 * a), 4 * s)
    text.draw(font.tiny, x + pad, y + pad, r, g, b, math.floor(255 * a), label)
    if f.sneaking then
        local tag = "SNEAKING"
        text.draw(font.tiny, x + w - pad - text.width(font.tiny, tag), y + pad, 180, 180, 195, math.floor(200 * a), tag)
    end
    local by = y + pad * 2 + th
    draw.rect(x + pad, by, x + pad + bar_w, by + bar_h, 0, 0, 0, math.floor(160 * a), 0)
    draw.rect(x + pad, by, x + pad + bar_w * level, by + bar_h, r, g, b, math.floor(255 * a), 0)
end)
