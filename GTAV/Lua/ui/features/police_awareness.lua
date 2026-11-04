-- Police Awareness. Published fields: active (bool, at least one officer within range), nearby (officers
-- within range), watching (officers with a clear view of you), nearest (metres to the closest officer).
-- Drawn as a small badge above the minimap, just over the Stealth Meter.
local shown = 0

features.on_draw("Police Awareness", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 6) else shown = math.max(0, shown - dt * 6) end
    if shown <= 0 then return end

    local sh = ctx.screen_h()
    local s = sh / 1080
    local a = shown
    local nearby = math.floor(f.nearby or 0)
    local watching = math.floor(f.watching or 0)

    local label, r, g, b
    if watching > 0 then
        label = watching == 1 and "POLICE WATCHING" or string.format("POLICE WATCHING x%d", watching)
        if math.floor(ctx.time() * 4) % 2 == 0 then r, g, b = 235, 70, 70 else r, g, b = 80, 140, 255 end
    else
        label = nearby == 1 and "POLICE NEARBY" or string.format("POLICE NEARBY x%d", nearby)
        r, g, b = 120, 170, 255
    end
    local dist = string.format("%dm", math.floor(f.nearest or 0))

    local x = 28 * s
    local y = sh - 336 * s + (1 - shown) * 10 * s
    local pad = 6 * s
    local dot = 6 * s
    local th = text.height(font.tiny)
    local lw = text.width(font.tiny, label)
    local dw = text.width(font.tiny, dist)
    local w = pad * 4 + dot + lw + dw
    local h = th + pad * 2

    draw.rect(x, y, x + w, y + h, 10, 10, 16, math.floor(150 * a), 4 * s)
    draw.circle(x + pad + dot * 0.5, y + h * 0.5, dot * 0.5, r, g, b, math.floor(255 * a))
    text.draw(font.tiny, x + pad * 2 + dot, y + pad, r, g, b, math.floor(255 * a), label)
    text.draw(font.tiny, x + w - pad - dw, y + pad, 180, 180, 195, math.floor(200 * a), dist)
end)
