-- Pocket Box Pusher. Published fields: active (bool), state (1 playing, 2 level solved, 3 every level solved),
-- state_age (ms), w / h (level size in cells), grid (blob, w * h chars row by row: '#' wall, ' ' floor, '.' target,
-- '$' crate, '*' crate on a target, '_' outside the level), px / py (you, 0-based cell), facing (0 up, 1 left, 2 down,
-- 3 right), level, levels, moves, pushes, par (fewest moves possible), best (your best for this level, once solved),
-- boxes_left, restart_hold (0-1 while E is held to restart).
features.on_draw("Pocket Box Pusher", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local W, H = math.floor(f.w or 1), math.floor(f.h or 1)
    local c = math.min(70 * s, 620 * s / math.max(W, H))
    local bw, bh = W * c, H * c
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 10 * s
    local state = math.floor(f.state or 0)
    local pw = math.max(bw, 560 * s)
    draw.rect(sw / 2 - pw / 2 - 30 * s, y0 - 80 * s, sw / 2 + pw / 2 + 30 * s, y0 + bh + 64 * s, 16, 14, 12, 235, 12 * s)

    local grid = f.grid or ""
    for y = 0, H - 1 do
        for x = 0, W - 1 do
            local i = y * W + x + 1
            local ch = string.sub(grid, i, i)
            local cx, cy = x0 + x * c, y0 + y * c
            if ch == "#" then
                draw.rect(cx, cy, cx + c, cy + c, 110, 70, 50, 255, 0)
                draw.rect(cx + 2 * s, cy + 2 * s, cx + c / 2 - 1, cy + c / 2 - 1, 140, 92, 66, 255, 0)
                draw.rect(cx + c / 2 + 1, cy + c / 2 + 1, cx + c - 2 * s, cy + c - 2 * s, 140, 92, 66, 255, 0)
            elseif ch ~= "_" and ch ~= "" then
                draw.rect(cx, cy, cx + c, cy + c, 52, 50, 46, 255, 0)
                if (x + y) % 2 == 0 then draw.rect(cx, cy, cx + c, cy + c, 60, 58, 54, 255, 0) end
                if ch == "." or ch == "*" then
                    draw.circle_outline(cx + c / 2, cy + c / 2, c * 0.22, 255, 200, 60, 255, 3 * s)
                    draw.circle(cx + c / 2, cy + c / 2, c * 0.08, 255, 200, 60, 255)
                end
                if ch == "$" or ch == "*" then
                    local on = ch == "*"
                    local r, g, b = 196, 140, 70
                    if on then r, g, b = 110, 200, 110 end
                    local p = c * 0.1
                    draw.rect(cx + p, cy + p, cx + c - p, cy + c - p, r, g, b, 255, 4 * s)
                    draw.rect(cx + p * 2, cy + p * 2, cx + c - p * 2, cy + c - p * 2, r - 30, g - 30, b - 30, 255, 3 * s)
                    draw.line(cx + p * 2, cy + p * 2, cx + c - p * 2, cy + c - p * 2, r, g, b, 255, 3 * s)
                    draw.line(cx + c - p * 2, cy + p * 2, cx + p * 2, cy + c - p * 2, r, g, b, 255, 3 * s)
                end
            end
        end
    end

    local px, py = x0 + ((f.px or 0) + 0.5) * c, y0 + ((f.py or 0) + 0.5) * c
    local bob = math.abs(math.sin(t * 4)) * 2 * s
    draw.circle(px, py - bob, c * 0.32, 70, 150, 240, 255)
    draw.circle(px, py - bob - c * 0.05, c * 0.2, 250, 214, 170, 255)
    local fx = ({ [0] = 0, -1, 0, 1 })[math.floor(f.facing or 2)] or 0
    local fy = ({ [0] = -1, 0, 1, 0 })[math.floor(f.facing or 2)] or 1
    draw.circle(px + fx * c * 0.1 - c * 0.07, py - bob - c * 0.07 + fy * c * 0.06, c * 0.035, 20, 20, 24, 255)
    draw.circle(px + fx * c * 0.1 + c * 0.07, py - bob - c * 0.07 + fy * c * 0.06, c * 0.035, 20, 20, 24, 255)

    local hy = y0 - 64 * s
    local lx = sw / 2 - pw / 2
    text.draw(font.item, lx, hy, 245, 245, 250, 255, string.format("LEVEL %d/%d", math.floor(f.level or 1), math.floor(f.levels or 1)))
    local stats = string.format("MOVES %d   PUSHES %d   PAR %d", math.floor(f.moves or 0), math.floor(f.pushes or 0), math.floor(f.par or 0))
    text.draw(font.small, lx + pw - text.width(font.small, stats), hy + 4 * s, 220, 220, 228, 255, stats)
    if f.best then
        local b = string.format("BEST %d", math.floor(f.best))
        text.draw(font.small, lx + pw - text.width(font.small, b), hy + 30 * s, 255, 200, 60, 255, b)
    end
    local hold = f.restart_hold or 0
    if hold > 0 then
        draw.rect(lx, hy + 36 * s, lx + 160 * s, hy + 42 * s, 50, 50, 56, 255, 3 * s)
        draw.rect(lx, hy + 36 * s, lx + 160 * s * math.min(1, hold), hy + 42 * s, 255, 120, 80, 255, 3 * s)
    end

    local msg, mr, mg, mb = "W A S D WALK AND PUSH   Q UNDO   HOLD E TO RESTART", 220, 220, 232
    if state == 2 then
        local moves, par = math.floor(f.moves or 0), math.floor(f.par or 0)
        local stars = moves <= par and "***" or (moves <= math.floor(par * 1.5) and "**" or "*")
        msg, mr, mg, mb = string.format("SOLVED IN %d MOVES  %s   E NEXT LEVEL   Q UNDO", moves, stars), 120, 240, 140
    elseif state == 3 then
        msg, mr, mg, mb = "EVERY LEVEL SOLVED!   E TO START OVER", 255, 210, 90
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + bh + 24 * s, mr, mg, mb, 255, msg)
end)
