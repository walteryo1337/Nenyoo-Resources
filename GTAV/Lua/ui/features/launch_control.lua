-- Launch Control. Published fields: active (bool), state (1 arming, 2 armed, 3 launching),
-- progress (0..1 while arming). Drawn as a small pill above the bottom of the screen.
local shown = 0
local last_state = 1

features.on_draw("Launch Control", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then
        shown = math.min(1, shown + dt * 10)
        last_state = math.floor(f.state or 1)
    else
        shown = math.max(0, shown - dt * 4)
    end
    if shown <= 0 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local a = shown

    local label, r, g, b
    if last_state == 3 then
        label, r, g, b = "LAUNCH!", 120, 230, 140
    elseif last_state == 2 then
        local blink = math.floor(ctx.time() * 6) % 2 == 0
        label, r, g, b = "LAUNCH READY", blink and 255 or 200, blink and 220 or 170, 60
    else
        label, r, g, b = "ARMING", ar, ag, ab
    end

    local pad = 8 * s
    local tw = text.width(font.hud_small, label)
    local th = text.height(font.hud_small)
    local w = math.max(tw + pad * 2, 150 * s)
    local h = th + pad * 2
    local x = (sw - w) / 2
    local y = sh * 0.70

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(170 * a), h / 2)
    if last_state == 1 then
        local p = math.min(1, math.max(0, f.progress or 0))
        draw.rect(x + pad, y + h - 4 * s, x + pad + (w - pad * 2) * p, y + h - 2 * s, ar, ag, ab, math.floor(255 * a), 0)
    end
    text.draw(font.hud_small, x + (w - tw) / 2, y + pad, r, g, b, math.floor(255 * a), label)
end)
