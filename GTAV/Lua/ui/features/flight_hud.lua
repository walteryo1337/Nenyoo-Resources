-- Flight HUD. Published fields: active (bool, flying a plane or helicopter), plane (bool), pitch, roll
-- (degrees), heading (compass degrees, 0 = north, clockwise), speed (km/h), altitude (m above ground),
-- climb (m/s), gear (planes: 0 down, 1 raising, 2 lowering, 3 up; -1 for helicopters).
local G = { 120, 255, 150 }

local function line(x1, y1, x2, y2, a, w)
    draw.line(x1, y1, x2, y2, G[1], G[2], G[3], a, w)
end

local function label(fnt, x, y, str, a, align)
    local w = text.width(fnt, str)
    if align == "center" then x = x - w / 2 elseif align == "right" then x = x - w end
    text.draw(fnt, x, y, G[1], G[2], G[3], a, str)
end

features.on_draw("Flight HUD", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local cx, cy = sw / 2, sh / 2
    local a = 220
    local ppd = sh * 0.012
    local radius = 230 * s
    local th = text.height(font.tiny)

    local pitch, roll = f.pitch or 0, f.roll or 0
    local ang = math.rad(roll)
    local ca, sa = math.cos(ang), math.sin(ang)

    for p = -30, 30, 10 do
        local off = (pitch - p) * ppd
        local hx, hy = cx - sa * off, cy + ca * off
        local dx, dy = hx - cx, hy - cy
        if dx * dx + dy * dy < radius * radius then
            if p == 0 then
                local L = 220 * s
                line(hx - ca * L, hy - sa * L, hx - ca * 40 * s, hy - sa * 40 * s, a, 2 * s)
                line(hx + ca * 40 * s, hy + sa * 40 * s, hx + ca * L, hy + sa * L, a, 2 * s)
            else
                local L, gap = 70 * s, 30 * s
                line(hx - ca * L, hy - sa * L, hx - ca * gap, hy - sa * gap, a, 1.2 * s)
                line(hx + ca * gap, hy + sa * gap, hx + ca * L, hy + sa * L, a, 1.2 * s)
                label(font.tiny, hx + ca * (L + 6 * s), hy + sa * (L + 6 * s) - th / 2, tostring(p), a)
            end
        end
    end

    line(cx - 30 * s, cy, cx - 10 * s, cy, 255, 2 * s)
    line(cx + 10 * s, cy, cx + 30 * s, cy, 255, 2 * s)
    line(cx - 10 * s, cy, cx, cy + 8 * s, 255, 2 * s)
    line(cx, cy + 8 * s, cx + 10 * s, cy, 255, 2 * s)

    local heading = f.heading or 0
    local tape_y = sh * 0.14
    local tape_w = 320 * s
    local ppd_h = tape_w / 80
    line(cx - tape_w / 2, tape_y, cx + tape_w / 2, tape_y, a, 1 * s)
    local base = math.floor(heading / 10) * 10
    for h = base - 40, base + 40, 10 do
        local x = cx + (h - heading) * ppd_h
        if x >= cx - tape_w / 2 and x <= cx + tape_w / 2 then
            local hh = h % 360
            local tall = hh % 30 == 0
            line(x, tape_y, x, tape_y - (tall and 10 or 5) * s, a, 1 * s)
            if tall then
                local names = { [0] = "N", [90] = "E", [180] = "S", [270] = "W" }
                label(font.tiny, x, tape_y - 12 * s - th, names[hh] or string.format("%02d", hh / 10), a, "center")
            end
        end
    end
    line(cx, tape_y + 2 * s, cx - 5 * s, tape_y + 9 * s, 255, 1.5 * s)
    line(cx, tape_y + 2 * s, cx + 5 * s, tape_y + 9 * s, 255, 1.5 * s)
    label(font.small, cx, tape_y + 10 * s, string.format("%03d", math.floor(heading + 0.5) % 360), a, "center")

    local side = 300 * s
    label(font.tiny, cx - side, cy - th * 1.6, "SPD", a, "right")
    label(font.small, cx - side, cy - th * 0.5, string.format("%d", math.floor(f.speed or 0)), a, "right")
    label(font.tiny, cx - side, cy + th * 0.9, "KM/H", a, "right")

    local climb = f.climb or 0
    label(font.tiny, cx + side, cy - th * 1.6, "ALT", a)
    label(font.small, cx + side, cy - th * 0.5, string.format("%d", math.floor(f.altitude or 0)), a)
    label(font.tiny, cx + side, cy + th * 0.9, string.format("%+.1f M/S", climb), a)

    local gear = math.floor(f.gear or -1)
    if f.plane and gear >= 0 then
        local g = gear == 0 and "GEAR DOWN" or (gear == 3 and "GEAR UP" or "GEAR MOVING")
        label(font.tiny, cx, cy + radius + 10 * s, g, a, "center")
    end
end)
