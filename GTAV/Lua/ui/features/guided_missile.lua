-- Guided Missile. The missile camera overlay while one is in the air. Published fields: active (bool), flying (bool),
-- fuel (1..0, flight time left), height (metres above the ground), cooling (bool, the launcher is reloading).
features.on_draw("Guided Missile", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx, cy = sw / 2, sh / 2

    if not f.flying then
        if f.cooling then
            local msg = "MISSILE RELOADING"
            text.draw(font.tiny, cx - text.width(font.tiny, msg) / 2, cy + 40 * s, 255, 160, 80, 200, msg)
        end
        return
    end

    draw.rect(0, 0, sw, sh, 20, 40, 20, 40, 0)
    for i = 0, 7 do
        local y = (t * 120 * s + i * sh / 8) % sh
        draw.rect(0, y, sw, y + 1 * s, 180, 255, 180, 18, 0)
    end
    local g, a = 230, 230
    local len, gap = 26 * s, 10 * s
    draw.line(cx - gap - len, cy, cx - gap, cy, 120, 255, 140, a, 2 * s)
    draw.line(cx + gap, cy, cx + gap + len, cy, 120, 255, 140, a, 2 * s)
    draw.line(cx, cy - gap - len, cx, cy - gap, 120, 255, 140, a, 2 * s)
    draw.line(cx, cy + gap, cx, cy + gap + len, 120, 255, 140, a, 2 * s)
    local box = 90 * s
    for _, c in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
        local x, y = cx + c[1] * box, cy + c[2] * box
        draw.line(x, y, x - c[1] * 18 * s, y, 120, 255, 140, a, 2 * s)
        draw.line(x, y, x, y - c[2] * 18 * s, 120, 255, 140, a, 2 * s)
    end

    text.draw(font.small, 40 * s, 40 * s, 120, 255, 140, g, "GUIDED MISSILE")
    text.draw(font.tiny, 40 * s, 72 * s, 120, 255, 140, 200, string.format("ALT %4.0fM", f.height or 0))
    local fx0, fx1, fy = 40 * s, 260 * s, 96 * s
    draw.rect(fx0, fy, fx1, fy + 8 * s, 20, 50, 25, 220, 2 * s)
    local k = math.max(0, math.min(1, f.fuel or 0))
    local fr, fg = 120, 255
    if k < 0.25 then fr, fg = 255, 90 end
    draw.rect(fx0, fy, fx0 + (fx1 - fx0) * k, fy + 8 * s, fr, fg, 120, 255, 2 * s)
    local hint = "MOUSE  STEER   -   CLICK  DETONATE"
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, sh - 80 * s, 120, 255, 140, 200, hint)
end)
