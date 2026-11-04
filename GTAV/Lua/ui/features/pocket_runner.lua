-- Pocket Runner. Published fields: active (bool), state (1 running, 2 crashed), y (runner height above the
-- ground, in track heights), ducking (bool), scroll (0 to 1 ground scroll phase), score, best (this session),
-- obstacles (blob "kind,x;" per obstacle: kind 0 cone, 1 crate, 2 bird; x runs 0 at the left edge to 1 at the
-- right). Sizes below mirror the game rules in C++.
local RUNNER_X, RUNNER_W, RUNNER_H, DUCK_H = 0.15, 0.035, 0.16, 0.08
local BIRD_LOW, BIRD_H = 0.11, 0.06
local WIDTH = { [0] = 0.03, 0.05, 0.045 }
local HEIGHT = { [0] = 0.07, 0.09, 0.06 }

features.on_draw("Pocket Runner", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local tw, th = 900 * s, 320 * s
    local x0, y0 = sw / 2 - tw / 2, sh / 2 - th / 2 + 20 * s
    local ground = y0 + th * 0.85
    local unit = th
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 20 * s, y0 - 90 * s, x0 + tw + 20 * s, y0 + th + 56 * s, 12, 12, 16, 225, 12 * s)
    draw.rect_gradient(x0, y0, x0 + tw, ground, 120, 90, 160, 255, 120, 90, 160, 255, 255, 170, 110, 255, 255, 170, 110, 255)
    draw.circle(x0 + tw * 0.78, y0 + th * 0.35, 38 * s, 255, 220, 140, 230)
    draw.rect(x0, ground, x0 + tw, y0 + th, 60, 50, 46, 255, 0)
    local phase = (f.scroll or 0) % 0.1
    local x = -phase
    while x < 1 do
        local px = x0 + x * tw
        if px >= x0 then draw.rect(px, ground + 6 * s, math.min(x0 + tw, px + tw * 0.04), ground + 10 * s, 120, 110, 100, 255, 0) end
        x = x + 0.1
    end

    for kind, ox in string.gmatch(f.obstacles or "", "(%d+),(%-?[%d%.]+);") do
        local k, px = tonumber(kind), tonumber(ox)
        local w = WIDTH[k] * tw
        local cx = x0 + px * tw
        if cx - w / 2 >= x0 and cx + w / 2 <= x0 + tw then
            if k == 2 then
                local by = ground - (BIRD_LOW + BIRD_H * 0.5) * unit
                local flap = math.sin(t * 14) * 8 * s
                draw.circle(cx, by, w * 0.32, 40, 40, 50, 255)
                draw.line(cx - w * 0.5, by - flap, cx, by, 40, 40, 50, 255, 3 * s)
                draw.line(cx + w * 0.5, by - flap, cx, by, 40, 40, 50, 255, 3 * s)
            elseif k == 1 then
                local h = HEIGHT[1] * unit
                draw.rect(cx - w / 2, ground - h, cx + w / 2, ground, 170, 120, 60, 255, 2 * s)
                draw.line(cx - w / 2, ground - h, cx + w / 2, ground, 120, 80, 40, 255, 2 * s)
                draw.line(cx + w / 2, ground - h, cx - w / 2, ground, 120, 80, 40, 255, 2 * s)
            else
                local h = HEIGHT[0] * unit
                for i = 0, 5 do
                    local k2 = i / 5
                    local half = w * 0.5 * (1 - k2 * 0.8)
                    local yy = ground - h * k2
                    local r, g, b = 245, 120, 30
                    if i == 2 or i == 3 then r, g, b = 240, 240, 240 end
                    draw.line(cx - half, yy, cx + half, yy, r, g, b, 255, h / 5 + 1)
                end
            end
        end
    end

    local ducking = f.ducking
    local rh = (ducking and DUCK_H or RUNNER_H) * unit
    local rw = RUNNER_W * tw * (ducking and 1.5 or 1)
    local rx = x0 + RUNNER_X * tw
    local ry = ground - (f.y or 0) * unit
    local cr, cg, cb = 40, 40, 52
    if state == 2 and math.floor(t * 6) % 2 == 0 then cr, cg, cb = 230, 60, 60 end
    draw.rect(rx - rw / 2, ry - rh, rx + rw / 2, ry - rh * 0.25, cr, cg, cb, 255, 4 * s)
    draw.circle(rx + (ducking and rw * 0.35 or 0), ry - rh - rw * 0.35, rw * 0.38, cr, cg, cb, 255)
    local stride = (f.y or 0) > 0 and 0 or math.sin(t * 18) * rw * 0.4
    draw.line(rx, ry - rh * 0.3, rx - stride, ry, cr, cg, cb, 255, 4 * s)
    draw.line(rx, ry - rh * 0.3, rx + stride, ry, cr, cg, cb, 255, 4 * s)

    local score = string.format("%05d", math.floor(f.score or 0))
    text.draw(font.title, sw / 2 - text.width(font.title, score) / 2, y0 - 80 * s, 245, 245, 250, 255, score)
    local best = string.format("BEST %05d", math.floor(f.best or 0))
    text.draw(font.small, sw / 2 - text.width(font.small, best) / 2, y0 - 30 * s, 200, 200, 214, 230, best)
    local foot = state == 2 and "CRASHED     W OR SPACE TO RUN AGAIN" or "W OR SPACE JUMP     S DUCK"
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + th + 16 * s, 200, 200, 214, 230, foot)
end)
