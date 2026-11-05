-- Ice Rink. Shown while you are near the rink. Published fields: active (bool), on_ice (bool), speed (m/s right now),
-- best_speed (fastest this session), style (style points), pop (1..0 right after landing a spin jump), pop_points /
-- pop_turns (the jump you just landed).
features.on_draw("Ice Rink", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 230 * s, 132 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 14, 22, 210, 12 * s)
    text.draw(font.hud_small, x0 + 14 * s, y0 + 8 * s, 220, 240, 255, 255, "ICE RINK")
    local kmh = (f.speed or 0) * 3.6
    text.draw(font.display, x0 + 14 * s, y0 + 36 * s, 170, 220, 255, 255, string.format("%.0f", kmh))
    text.draw(font.hud_tiny, x0 + 18 * s + text.width(font.display, string.format("%.0f", kmh)), y0 + 54 * s, 190, 200, 215, 230, "KM/H")
    local bx0, bx1, by = x0 + 14 * s, x0 + w - 14 * s, y0 + 86 * s
    draw.rect(bx0, by, bx1, by + 6 * s, 40, 44, 60, 255, 3 * s)
    local k = math.max(0, math.min(1, (f.speed or 0) / 13))
    if k > 0 then draw.rect(bx0, by, bx0 + (bx1 - bx0) * k, by + 6 * s, 120, 200, 255, 255, 3 * s) end
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + h - 30 * s, 255, 220, 90, 230, string.format("STYLE %d", math.floor(f.style or 0)))
    local best = string.format("TOP %.0f", (f.best_speed or 0) * 3.6)
    text.draw(font.hud_tiny, x0 + w - 14 * s - text.width(font.hud_tiny, best), y0 + h - 30 * s, 190, 200, 215, 230, best)

    local pop = f.pop or 0
    if pop > 0 then
        local turns = math.floor(f.pop_turns or 0)
        local names = { "SINGLE", "DOUBLE", "TRIPLE", "QUAD" }
        local name = names[turns] or string.format("%dx", turns)
        local msg = string.format("%s SPIN!  +%d", name, math.floor(f.pop_points or 0))
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, sh * 0.3 - 26 * s * (1 - pop), 170, 225, 255, math.floor(255 * pop), msg)
    end
    if not f.on_ice then
        local hint = "STEP ONTO THE ICE"
        text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, sh - 120 * s, 200, 210, 225, math.floor(150 + 60 * math.sin(t * 2)), hint)
    else
        local hint = "W A S D  GLIDE   -   SHIFT  PUSH HARDER   -   SPACE AT SPEED  SPIN JUMP"
        text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, hint) / 2, sh - 120 * s, 200, 210, 225, 170, hint)
    end
end)
