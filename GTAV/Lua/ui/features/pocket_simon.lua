-- Pocket Simon. Published fields: active (bool), state (1 watch the sequence, 2 your turn, 3 game over), lit (pad lit
-- right now: 0 up / W, 1 right / D, 2 down / S, 3 left / A, -1 none), score (longest sequence repeated), best (this
-- session), pos (presses done this round), len (sequence length), time_left (seconds before the next press times out).
local pads = {
    { dx = 0, dy = -1, r = 70, g = 200, b = 90, key = "W" },
    { dx = 1, dy = 0, r = 230, g = 70, b = 70, key = "D" },
    { dx = 0, dy = 1, r = 240, g = 200, b = 60, key = "S" },
    { dx = -1, dy = 0, r = 70, g = 140, b = 240, key = "A" },
}

features.on_draw("Pocket Simon", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh * 0.5
    local state = math.floor(f.state or 0)
    local lit = math.floor(f.lit or -1)

    local frame = 250 * s
    draw.rect(cx - frame, cy - frame - 50 * s, cx + frame, cy + frame + 40 * s, 12, 12, 16, 220, 14 * s)

    local off = 92 * s
    local rad = 70 * s
    for i, p in ipairs(pads) do
        local px, py = cx + p.dx * off, cy + p.dy * off
        local on = lit == i - 1
        if on then
            draw.circle(px, py, rad * 1.15, p.r, p.g, p.b, 70)
            draw.circle(px, py, rad, p.r, p.g, p.b, 255)
        else
            draw.circle(px, py, rad, math.floor(p.r * 0.35), math.floor(p.g * 0.35), math.floor(p.b * 0.35), 255)
        end
        local kw = text.width(font.display, p.key)
        text.draw(font.display, px - kw / 2, py - text.height(font.display) / 2, 255, 255, 255, on and 255 or 120, p.key)
    end
    draw.circle(cx, cy, 30 * s, 20, 20, 26, 255)
    local n = tostring(math.floor(f.score or 0))
    text.draw(font.hud, cx - text.width(font.hud, n) / 2, cy - text.height(font.hud) / 2, 240, 240, 248, 255, n)

    local title
    if state == 1 then title = "WATCH"
    elseif state == 2 then title = string.format("YOUR TURN  %d / %d", math.floor(f.pos or 0), math.floor(f.len or 0))
    else title = "GAME OVER" end
    text.draw(font.hud, cx - text.width(font.hud, title) / 2, cy - frame - 40 * s, 245, 245, 250, 255, title)

    if state == 2 then
        local ar, ag, ab = theme.accent()
        local t = math.max(0, math.min(1, (f.time_left or 0) / 5))
        local bx1, bx2 = cx - frame + 20 * s, cx + frame - 20 * s
        local by = cy + frame + 10 * s
        draw.rect(bx1, by, bx2, by + 5 * s, 40, 40, 50, 220, 2 * s)
        draw.rect(bx1, by, bx1 + (bx2 - bx1) * t, by + 5 * s, ar, ag, ab, 255, 2 * s)
    end

    local foot = state == 3 and "PRESS W A S D TO PLAY AGAIN" or string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_small, cx - text.width(font.hud_small, foot) / 2, cy + frame + 20 * s, 190, 190, 205, 230, foot)
end)
