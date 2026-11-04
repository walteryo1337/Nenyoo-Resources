-- Lockpicking. Published fields: active (bool), state (1 picking, 2 result), result (1 opened, 2 out of picks, 3 gave up),
-- angle (0-1 pick position along the lock), turn (0-1 how far the cylinder has rotated; 1 opens it), strain (0-100, the
-- pick snaps at 100), picks (left), difficulty (1 easy, 2 sports car, 3 supercar / emergency), just_broke (bool, a pick
-- snapped a moment ago), opened (cars opened this session).
features.on_draw("Lockpicking", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx, cy = sw / 2, sh * 0.52
    local state = math.floor(f.state or 0)

    if state == 2 then
        local result = math.floor(f.result or 0)
        local msg, r, g, b = "GAVE UP", 200, 200, 210
        if result == 1 then msg, r, g, b = "UNLOCKED", 120, 230, 120
        elseif result == 2 then msg, r, g, b = "PICKS BROKEN", 240, 80, 70 end
        local big = font.display or font.title
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, r, g, b, 255, msg)
        return
    end

    local radius = 120 * s
    draw.rect(cx - 220 * s, cy - 190 * s, cx + 220 * s, cy + 200 * s, 12, 12, 16, 215, 12 * s)
    draw.circle(cx, cy, radius, 70, 64, 52, 255)
    draw.circle(cx, cy, radius * 0.86, 150, 132, 96, 255)
    draw.circle_outline(cx, cy, radius, 40, 36, 30, 255, 3 * s)

    -- keyway rotates with the cylinder, up to 90 degrees
    local strain = f.strain or 0
    local shake = strain > 0 and math.sin((ctx.time() or 0) * 60) * strain / 100 * 0.05 or 0
    local rot = (f.turn or 0) * math.pi / 2 + shake
    local kx, ky = math.sin(rot), -math.cos(rot)
    local klen = radius * 0.55
    draw.line(cx - kx * klen, cy - ky * klen, cx + kx * klen, cy + ky * klen, 25, 22, 18, 255, 12 * s)

    -- pick sweeps across the top half of the lock
    local a = math.pi * (1 - (f.angle or 0.5))
    local px, py = math.cos(a), -math.sin(a)
    local pr, pg, pb = 210, 214, 222
    if f.just_broke then pr, pg, pb = 240, 80, 70 end
    draw.line(cx + px * radius * 0.15, cy + py * radius * 0.15, cx + px * radius * 1.45, cy + py * radius * 1.45, pr, pg, pb, 255, 4 * s)

    local bx1, bx2 = cx - 180 * s, cx + 180 * s
    local by = cy + radius + 26 * s
    draw.rect(bx1, by, bx2, by + 6 * s, 40, 40, 50, 220, 3 * s)
    local sr, sg = 240, math.floor(200 - 140 * strain / 100)
    draw.rect(bx1, by, bx1 + (bx2 - bx1) * math.min(1, strain / 100), by + 6 * s, sr, sg, 60, 255, 3 * s)

    local picks = math.floor(f.picks or 0)
    for i = 1, picks do
        local ix = bx1 + (i - 1) * 16 * s
        draw.rect(ix, by + 14 * s, ix + 4 * s, by + 34 * s, 210, 214, 222, 255, 1 * s)
    end
    local diff = ({ "EASY LOCK", "SPORTS LOCK", "HIGH SECURITY" })[math.floor(f.difficulty or 1)] or "LOCK"
    text.draw(font.small, bx2 - text.width(font.small, diff), by + 14 * s, ar, ag, ab, 255, diff)

    local hint = "A / D  MOVE PICK     HOLD W  TURN     BACKSPACE  STOP"
    text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, cy - 180 * s, 180, 180, 195, 230, hint)
end)
