-- Trailer Reversing. Published fields: active (bool), state (1 driving, 2 result), state_age (ms), elapsed / time_left
-- (ms), bay_w / bay_l (bay size in metres), c1u..c4v (trailer corners in bay space, metres: u to the right, v forward,
-- bay centred on 0,0; corners run front-left, front-right, rear-right, rear-left), cab_u / cab_v (truck), angle (trailer
-- misalignment in degrees), rear_gap (metres the trailer rear still has to go back), inside (bool, trailer fully in the
-- bay), hold (0-1 progress of holding still in the bay), cones_hit, result (1 docked, 2 trailer lost, 3 wrecked,
-- 4 abandoned, 5 out of time), stars (1-3), pay.
local function clock(ms)
    local secs = math.floor(ms / 1000)
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

features.on_draw("Trailer Reversing", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local state = math.floor(f.state or 0)

    if state == 2 then
        local result = math.floor(f.result or 0)
        local msgs = { "DOCKED", "TRAILER LOST", "WRECKED", "JOB ABANDONED", "OUT OF TIME" }
        local msg = msgs[result] or ""
        local r, g, b = 240, 80, 70
        if result == 1 then r, g, b = ar, ag, ab end
        local cx = sw / 2
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        if result == 1 then
            local stars = math.floor(f.stars or 0)
            for k = 1, 3 do
                local on = k <= stars
                local sx, sy = cx + (k - 2) * 46 * s, sh * 0.26 + text.height(big) + 26 * s
                draw.circle(sx, sy, 17 * s, on and 255 or 70, on and 210 or 70, on and 60 or 80, 255)
                draw.circle(sx, sy, 7 * s, on and 255 or 50, on and 245 or 50, on and 170 or 60, 255)
            end
            local line = string.format("+$%d   %s   %d CONES HIT", math.floor(f.pay or 0), clock(f.elapsed or 0), math.floor(f.cones_hit or 0))
            text.draw(font.item, cx - text.width(font.item, line) / 2, sh * 0.26 + text.height(big) + 56 * s, 245, 245, 250, 255, line)
        end
        return
    end

    local pw, ph = 230 * s, 400 * s
    local px, py = sw - pw - 40 * s, sh / 2 - ph / 2
    draw.rect(px, py, px + pw, py + ph, 12, 12, 20, 210, 10 * s)
    text.draw(font.small, px + 14 * s, py + 10 * s, 220, 220, 235, 255, "REVERSE INTO THE BAY")

    local bw, bl = f.bay_w or 4, f.bay_l or 15
    local v_min, v_max = -bl / 2 - 4, bl / 2 + 34
    local gx1, gy1, gx2, gy2 = px + 12 * s, py + 38 * s, px + pw - 12 * s, py + ph - 70 * s
    local scale = (gy2 - gy1) / (v_max - v_min)
    local ox = (gx1 + gx2) / 2
    local function S(u, v)
        local x = ox + u * scale
        local y = gy2 - (v - v_min) * scale
        if x < gx1 then x = gx1 elseif x > gx2 then x = gx2 end
        if y < gy1 then y = gy1 elseif y > gy2 then y = gy2 end
        return x, y
    end
    draw.rect(gx1, gy1, gx2, gy2, 40, 40, 48, 255, 4 * s)
    local inside = f.inside
    local bx1, by1 = S(-bw / 2, bl / 2)
    local bx2, by2 = S(bw / 2, -bl / 2)
    draw.rect(bx1, by1, bx2, by2, inside and 60 or 255, inside and 200 or 200, inside and 100 or 60, 60)
    draw.line(bx1, by1, bx1, by2, 255, 255, 255, 220, 2 * s)
    draw.line(bx2, by1, bx2, by2, 255, 255, 255, 220, 2 * s)
    draw.line(bx1, by2, bx2, by2, 255, 120, 60, 255, 4 * s)
    for _, c in ipairs({ { -1, 1 }, { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 } }) do
        local cx, cy = S(c[1] * (bw / 2 + 0.3), c[2] * bl / 2)
        draw.circle(cx, cy, 4 * s, 255, 140, 30, 255)
    end

    local pts = {}
    for k = 1, 4 do pts[k] = { S(f["c" .. k .. "u"] or 0, f["c" .. k .. "v"] or 0) } end
    local tr_r, tr_g, tr_b = 220, 220, 235
    if inside then tr_r, tr_g, tr_b = 90, 235, 130 end
    for k = 1, 4 do
        local a, b = pts[k], pts[k % 4 + 1]
        draw.line(a[1], a[2], b[1], b[2], tr_r, tr_g, tr_b, 255, 3 * s)
    end
    local cab_x, cab_y = S(f.cab_u or 0, f.cab_v or 0)
    draw.circle(cab_x, cab_y, 6 * s, ar, ag, ab, 255)
    local fx, fy = (pts[1][1] + pts[2][1]) / 2, (pts[1][2] + pts[2][2]) / 2
    draw.line(fx, fy, cab_x, cab_y, 160, 160, 175, 255, 2 * s)

    local iy = gy2 + 10 * s
    local angle = f.angle or 0
    local ang_ok = math.abs(angle) <= 6
    local a_txt = string.format("ANGLE %+.1f", angle)
    text.draw(font.small, px + 14 * s, iy, ang_ok and 120 or 255, ang_ok and 235 or 200, ang_ok and 140 or 90, 255, a_txt)
    local gap = math.max(0, f.rear_gap or 0)
    local g_txt = string.format("%.1f M", gap)
    text.draw(font.small, px + pw - 14 * s - text.width(font.small, g_txt), iy, 220, 220, 235, 255, g_txt)
    local left = f.time_left or 0
    local tl = clock(left)
    local tr2 = left < 30000 and 255 or 245
    text.draw(font.small, px + 14 * s, iy + 24 * s, tr2, left < 30000 and 110 or 245, left < 30000 and 90 or 250, 255, tl)
    local cones = string.format("CONES %d", math.floor(f.cones_hit or 0))
    text.draw(font.small, px + pw - 14 * s - text.width(font.small, cones), iy + 24 * s, (f.cones_hit or 0) > 0 and 255 or 200, (f.cones_hit or 0) > 0 and 120 or 200, 90, 255, cones)

    local hold = f.hold or 0
    if hold > 0 then
        local w = 300 * s
        local x, y = sw / 2 - w / 2, sh * 0.8
        local l = "HOLD IT THERE..."
        text.draw(font.item, sw / 2 - text.width(font.item, l) / 2, y - 30 * s, 120, 240, 140, 255, l)
        draw.rect(x, y, x + w, y + 10 * s, 255, 255, 255, 40, 5 * s)
        draw.rect(x, y, x + w * hold, y + 10 * s, 120, 240, 140, 255, 5 * s)
    end
end)
