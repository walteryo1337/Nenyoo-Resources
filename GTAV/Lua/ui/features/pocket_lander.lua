-- Pocket Lunar Lander. Published fields: active (bool), state (1 flying, 2 landed, 3 crashed, 4 game over), x / y
-- (lander, 0-1 across the 400 x 300 m world, y up from the bottom), angle (radians, 0 upright, positive leans right),
-- thrust (bool), fuel (0-1), vx / vy (m/s, vy positive up), altitude (m above the ground below), level, lives, score,
-- best, last_points (points for the landing just made), state_age (ms), points (terrain samples), terrain (blob of
-- comma-separated heights, 0-1 of the world height, evenly spaced left to right), pads (blob "first,last,mult;": sample
-- range of each flat landing pad and its score multiplier), safe_vy / safe_vx / safe_angle (limits for a safe landing).
features.on_draw("Pocket Lunar Lander", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local fw = 840 * s
    local fh = fw * 0.75
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    draw.rect(x0 - 10 * s, y0 - 56 * s, x0 + fw + 10 * s, y0 + fh + 40 * s, 12, 12, 16, 230, 10 * s)
    draw.rect(x0, y0, x0 + fw, y0 + fh, 4, 4, 12, 255, 4 * s)
    for i = 0, 40 do
        local sx = x0 + ((i * 97) % 100) / 100 * fw
        local sy = y0 + ((i * 61) % 100) / 100 * fh * 0.6
        draw.circle(sx, sy, 1.2 * s, 220, 220, 240, 120 + (i * 13) % 100)
    end

    local hts = {}
    for v in string.gmatch(f.terrain or "", "([%d%.]+),") do hts[#hts + 1] = tonumber(v) end
    local n = #hts
    local function px(i) return x0 + (i - 1) / math.max(1, n - 1) * fw end
    local function py(h) return y0 + fh - h * fh end
    for i = 1, n - 1 do
        local xa, xb = px(i), px(i + 1)
        local ya, yb = py(hts[i]), py(hts[i + 1])
        local steps = 3
        for k = 0, steps - 1 do
            local u1, u2 = k / steps, (k + 1) / steps
            local top = ya + (yb - ya) * (u1 + u2) / 2
            draw.rect(xa + (xb - xa) * u1, top, xa + (xb - xa) * u2 + 1, y0 + fh, 70, 70, 80, 255, 0)
        end
        draw.line(xa, ya, xb, yb, 200, 200, 215, 255, 2 * s)
    end
    for first, last, mult in string.gmatch(f.pads or "", "(%d+),(%d+),(%d+);") do
        first, last = tonumber(first) + 1, tonumber(last) + 1
        if hts[first] then
            local ya = py(hts[first])
            draw.rect(px(first), ya - 2 * s, px(last), ya + 3 * s, 120, 240, 140, 255, 2 * s)
            local label = "x" .. mult
            text.draw(font.hud_tiny, (px(first) + px(last)) / 2 - text.width(font.hud_tiny, label) / 2, ya + 6 * s, 120, 240, 140, 255, label)
        end
    end

    local state = math.floor(f.state or 0)
    local lx, ly = x0 + (f.x or 0.5) * fw, y0 + fh - (f.y or 0.9) * fh
    local a = f.angle or 0
    local size = 3.5 / 400 * fw
    local function rot(dx, dy) return lx + dx * math.cos(a) - dy * math.sin(a), ly + dx * math.sin(a) + dy * math.cos(a) end
    if state == 3 and (f.state_age or 0) < 1500 then
        local age = (f.state_age or 0) / 1500
        for k = 0, 9 do
            local ang = k * 0.628
            local r = age * 40 * s
            draw.circle(lx + math.cos(ang) * r, ly - 4 * s + math.sin(ang) * r * 0.6, (1 - age) * 5 * s, 255, 160 - k * 8, 60, math.floor(255 * (1 - age)))
        end
    elseif state ~= 3 and state ~= 4 then
        local bx1, by1 = rot(-size, -size * 1.6)
        local bx2, by2 = rot(size, -size * 1.6)
        local bx3, by3 = rot(size, -size * 0.4)
        local bx4, by4 = rot(-size, -size * 0.4)
        draw.line(bx1, by1, bx2, by2, 230, 230, 240, 255, 2 * s)
        draw.line(bx2, by2, bx3, by3, 230, 230, 240, 255, 2 * s)
        draw.line(bx3, by3, bx4, by4, 230, 230, 240, 255, 2 * s)
        draw.line(bx4, by4, bx1, by1, 230, 230, 240, 255, 2 * s)
        local hx, hy = rot(0, -size * 2.2)
        draw.circle(hx, hy, size * 0.55, 230, 230, 240, 255)
        local l1x, l1y = rot(-size * 1.5, 0)
        local l2x, l2y = rot(size * 1.5, 0)
        draw.line(bx4, by4, l1x, l1y, 230, 230, 240, 255, 2 * s)
        draw.line(bx3, by3, l2x, l2y, 230, 230, 240, 255, 2 * s)
        if f.thrust and math.floor(t * 24) % 2 == 0 then
            local fx, fy = rot(0, size * 1.3 + math.random() * size)
            local ex1, ey1 = rot(-size * 0.4, -size * 0.4)
            local ex2, ey2 = rot(size * 0.4, -size * 0.4)
            draw.line(ex1, ey1, fx, fy, 255, 170, 60, 255, 2 * s)
            draw.line(ex2, ey2, fx, fy, 255, 170, 60, 255, 2 * s)
        end
    end

    local safe_vy, safe_vx, safe_a = f.safe_vy or 3, f.safe_vx or 1.6, f.safe_angle or 0.22
    local vy, vx = f.vy or 0, f.vx or 0
    local function col(ok) if ok then return 120, 240, 140 end return 255, 110, 90 end
    local hx = x0
    local hy = y0 - 46 * s
    text.draw(font.hud_small, hx, hy, 245, 245, 250, 255, string.format("SCORE %d   LEVEL %d   LIVES %d", math.floor(f.score or 0), math.floor(f.level or 1), math.floor(f.lives or 0)))
    local r1, g1, b1 = col(math.abs(vy) <= safe_vy)
    local r2, g2, b2 = col(math.abs(vx) <= safe_vx)
    local r3, g3, b3 = col(math.abs(a) <= safe_a)
    local rx = x0 + fw * 0.55
    text.draw(font.hud_small, rx, hy, r1, g1, b1, 255, string.format("V %.1f", -vy))
    text.draw(font.hud_small, rx + 90 * s, hy, r2, g2, b2, 255, string.format("H %.1f", vx))
    text.draw(font.hud_small, rx + 180 * s, hy, r3, g3, b3, 255, string.format("TILT %d", math.floor(math.deg(a))))
    text.draw(font.hud_small, rx + 280 * s, hy, 200, 200, 212, 255, string.format("ALT %d", math.floor(f.altitude or 0)))
    local fuel = f.fuel or 0
    draw.rect(x0, y0 - 18 * s, x0 + fw * 0.4, y0 - 10 * s, 40, 40, 48, 255, 4 * s)
    local fr, fg = 255, 200
    if fuel < 0.2 then fr, fg = 255, 90 end
    if fuel > 0 then draw.rect(x0, y0 - 18 * s, x0 + fw * 0.4 * fuel, y0 - 10 * s, fr, fg, 80, 255, 4 * s) end

    local msg, cr, cg, cb = "A / D TILT   W THRUST   LAND GENTLY ON A GREEN PAD", 220, 220, 232
    if state == 2 then msg, cr, cg, cb = string.format("THE EAGLE HAS LANDED!   +%d", math.floor(f.last_points or 0)), 120, 240, 140
    elseif state == 3 then msg, cr, cg, cb = "CRASHED!", 255, 100, 100
    elseif state == 4 then msg, cr, cg, cb = string.format("GAME OVER   SCORE %d   BEST %d   E TO PLAY AGAIN", math.floor(f.score or 0), math.floor(f.best or 0)), 255, 180, 90 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + fh + 12 * s, cr, cg, cb, 255, msg)
end)
