-- Pocket Artillery. Published fields: active (bool), state (1 your aim, 2 CPU aiming, 3 shell in flight, 4 impact, 5
-- round over), state_age (ms), field_h (field is 1 wide and field_h tall, y UP from the bottom), shooter (0 you, 1 CPU),
-- wind (sideways push, negative blows left), t1x / t1y / t1hp / t1angle / t1power (your tank: ground position, health
-- 0-100, barrel angle in degrees with 0 pointing right, power 0.1-1), t2x..t2power (CPU tank), px / py (shell),
-- boom_x / boom_y (last impact, -1 when the shell flew off the map), dmg1 / dmg2 (damage dealt by the last impact),
-- wins / losses, winner (0 you, 1 CPU, 2 both destroyed), terrain (blob, 160 ground heights in thousandths "h,h,..."),
-- trail (blob "x,y;" of the shell in flight), ghost (blob "x,y;" of your previous shot).
local function parse_points(blob)
    local pts = {}
    for x, y in string.gmatch(blob or "", "([%d%.%-]+),([%d%.%-]+);") do pts[#pts + 1] = { tonumber(x), tonumber(y) } end
    return pts
end

features.on_draw("Pocket Artillery", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    local age = f.state_age or 0
    local fh_n = f.field_h or 0.75
    local fw = 900 * s
    local fh = fw * fh_n
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    local ar, ag, ab = theme.accent()
    local function P(x, y) return x0 + x * fw, y0 + (fh_n - y) * fw end

    draw.rect(x0 - 14 * s, y0 - 74 * s, x0 + fw + 14 * s, y0 + fh + 46 * s, 14, 14, 22, 240, 12 * s)
    draw.rect_gradient(x0, y0, x0 + fw, y0 + fh, 40, 70, 140, 255, 40, 70, 140, 255, 240, 150, 90, 255, 240, 150, 90, 255)
    for k = 0, 5 do
        local cx = x0 + ((k * 0.23 + t * 0.01 * (k % 2 + 1)) % 1.2 - 0.1) * fw
        local cy = y0 + (0.06 + (k % 3) * 0.05) * fw
        draw.circle(cx, cy, 18 * s, 255, 255, 255, 40)
        draw.circle(cx + 20 * s, cy + 4 * s, 14 * s, 255, 255, 255, 40)
    end

    local heights = {}
    for h in string.gmatch(f.terrain or "", "(%d+),") do heights[#heights + 1] = tonumber(h) / 1000 end
    local n = #heights
    if n > 1 then
        local colw = fw / (n - 1)
        for i = 1, n do
            local x = (i - 1) / (n - 1)
            local sx, sy = P(x, heights[i])
            local left, right = sx - colw / 2, sx + colw / 2 + 1
            if left < x0 then left = x0 end
            if right > x0 + fw then right = x0 + fw end
            draw.rect_gradient(left, sy, right, y0 + fh, 120, 90, 50, 255, 120, 90, 50, 255, 60, 40, 25, 255, 60, 40, 25, 255)
            draw.rect(left, sy, right, sy + 4 * s, 80, 170, 70, 255)
        end
    end

    if state == 1 then
        for i, p in ipairs(parse_points(f.ghost)) do
            if i % 2 == 0 then
                local gx, gy = P(p[1], p[2])
                if gy > y0 then draw.circle(gx, gy, 2 * s, 255, 255, 255, 110) end
            end
        end
    end

    local tanks = {
        { f.t1x or 0.1, f.t1y or 0.2, f.t1hp or 100, f.t1angle or 45, f.t1power or 0.6, ar, ag, ab, "YOU", f.dmg1 or 0 },
        { f.t2x or 0.9, f.t2y or 0.2, f.t2hp or 100, f.t2angle or 135, f.t2power or 0.6, 210, 60, 60, "CPU", f.dmg2 or 0 },
    }
    for _, tk in ipairs(tanks) do
        local x, y, hp, ang = tk[1], tk[2], tk[3], tk[4]
        local r, g, b = tk[6], tk[7], tk[8]
        if hp <= 0 then r, g, b = 60, 60, 60 end
        local tx, ty = P(x, y + 0.022)
        local a = math.rad(ang)
        draw.line(tx, ty, tx + math.cos(a) * 0.035 * fw, ty - math.sin(a) * 0.035 * fw, 50, 50, 55, 255, 5 * s)
        draw.circle(tx, ty, 0.011 * fw, r, g, b, 255)
        local bx1, by1 = P(x - 0.022, y + 0.018)
        local bx2, by2 = P(x + 0.022, y + 0.004)
        draw.rect(bx1, by1, bx2, by2, r, g, b, 255, 4 * s)
        local wx1, wy1 = P(x - 0.024, y + 0.008)
        local wx2, wy2 = P(x + 0.024, y)
        draw.rect(wx1, wy1, wx2, wy2, 35, 35, 40, 255, 4 * s)
        for k = -2, 2 do
            local cx, cy = P(x + k * 0.009, y + 0.004)
            draw.circle(cx, cy, 2.5 * s, 120, 120, 130, 255)
        end
        local hx, hy = P(x, y + 0.06)
        local hw = 34 * s
        draw.rect(hx - hw, hy, hx + hw, hy + 6 * s, 30, 30, 30, 220, 3 * s)
        local frac = math.max(0, math.min(1, hp / 100))
        local hr = frac > 0.5 and math.floor(255 * (1 - frac) * 2) or 255
        local hg = frac > 0.5 and 220 or math.floor(220 * frac * 2)
        draw.rect(hx - hw, hy, hx - hw + hw * 2 * frac, hy + 6 * s, hr, hg, 60, 255, 3 * s)
        text.draw(font.tiny, hx - text.width(font.tiny, tk[9]) / 2, hy - 16 * s, 245, 245, 250, 255, tk[9])
        if state == 4 and tk[10] > 0 then
            local rise = age / 900
            local l = string.format("-%d", math.floor(tk[10]))
            text.draw(font.item, hx - text.width(font.item, l) / 2, hy - 40 * s - rise * 30 * s, 255, 90, 70, math.floor(255 * (1 - rise * 0.8)), l)
        end
    end

    if state == 3 then
        local pts = parse_points(f.trail)
        for i, p in ipairs(pts) do
            local px, py = P(p[1], p[2])
            if py > y0 then draw.circle(px, py, 2 * s, 255, 240, 200, math.floor(60 + 160 * i / #pts)) end
        end
        local px, py = P(f.px or 0, f.py or 0)
        if py < y0 then
            local mx = math.max(x0 + 8 * s, math.min(x0 + fw - 8 * s, px))
            draw.line(mx, y0 + 14 * s, mx - 7 * s, y0 + 24 * s, 255, 255, 255, 255, 3 * s)
            draw.line(mx, y0 + 14 * s, mx + 7 * s, y0 + 24 * s, 255, 255, 255, 255, 3 * s)
        else
            draw.circle(px, py, 5 * s, 30, 30, 30, 255)
            draw.circle(px - 1.5 * s, py - 1.5 * s, 1.8 * s, 200, 200, 200, 255)
        end
    end

    if state == 4 and (f.boom_x or -1) >= 0 then
        local u = math.min(1, age / 700)
        local ex, ey = P(f.boom_x, f.boom_y)
        local r = 0.05 * fw
        draw.circle(ex, ey, r * (0.4 + u * 0.9), 255, 140, 40, math.floor(220 * (1 - u)))
        draw.circle(ex, ey, r * (0.25 + u * 0.6), 255, 230, 120, math.floor(255 * (1 - u)))
        draw.circle_outline(ex, ey, r * (0.5 + u * 1.4), 255, 255, 255, math.floor(160 * (1 - u)), 3 * s)
    end

    local hy = y0 - 62 * s
    local wind = f.wind or 0
    local wl = "WIND"
    text.draw(font.small, sw / 2 - text.width(font.small, wl) / 2, hy, 220, 220, 235, 255, wl)
    local len = wind / 0.3 * 70 * s
    local wy = hy + 32 * s
    draw.rect(sw / 2 - 72 * s, wy - 3 * s, sw / 2 + 72 * s, wy + 3 * s, 50, 50, 60, 255, 3 * s)
    if math.abs(len) > 2 * s then
        local tipx = sw / 2 + len
        draw.line(sw / 2, wy, tipx, wy, 120, 200, 255, 255, 5 * s)
        local dir = len > 0 and -1 or 1
        draw.line(tipx, wy, tipx + dir * 9 * s, wy - 7 * s, 120, 200, 255, 255, 4 * s)
        draw.line(tipx, wy, tipx + dir * 9 * s, wy + 7 * s, 120, 200, 255, 255, 4 * s)
    end

    local angle = math.floor((f.t1angle or 45) + 0.5)
    local power = f.t1power or 0.6
    text.draw(font.item, x0, hy - 2 * s, 245, 245, 250, 255, string.format("ANGLE %d", angle))
    text.draw(font.small, x0, hy + 26 * s, 200, 200, 215, 255, "POWER")
    local pbx = x0 + text.width(font.small, "POWER") + 10 * s
    draw.rect(pbx, hy + 30 * s, pbx + 160 * s, hy + 42 * s, 40, 40, 50, 255, 4 * s)
    draw.rect(pbx, hy + 30 * s, pbx + 160 * s * power, hy + 42 * s, 255, math.floor(220 - power * 160), 60, 255, 4 * s)
    local rec = string.format("WINS %d   LOSSES %d", math.floor(f.wins or 0), math.floor(f.losses or 0))
    text.draw(font.small, x0 + fw - text.width(font.small, rec), hy + 4 * s, 255, 200, 60, 255, rec)

    local msg, mr, mg, mb = "A / D AIM   W / S POWER   HOLD SHIFT FOR FINE CONTROL   E FIRE", 225, 225, 240
    if state == 2 then msg = "THE CPU IS LINING UP A SHOT..."
    elseif state == 3 then msg = (f.shooter or 0) == 0 and "SHELL AWAY..." or "INCOMING - TAKE COVER!"
    elseif state == 4 then msg = ""
    elseif state == 5 then
        local w = math.floor(f.winner or 2)
        if w == 0 then msg, mr, mg, mb = "ENEMY TANK DESTROYED - YOU WIN!   E FOR A NEW ROUND", 120, 245, 140
        elseif w == 1 then msg, mr, mg, mb = "YOUR TANK WAS DESTROYED   E FOR A NEW ROUND", 255, 120, 100
        else msg, mr, mg, mb = "BOTH TANKS DESTROYED - DRAW   E FOR A NEW ROUND", 255, 210, 90 end
    end
    if msg ~= "" then text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + fh + 14 * s, mr, mg, mb, 255, msg) end
end)
