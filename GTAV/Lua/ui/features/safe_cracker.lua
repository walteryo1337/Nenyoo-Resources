-- Safe Cracker. Published fields: active (bool), state (1 safe placed, 2 cracking, 3 opened, 4 alarm), state_age (ms),
-- dial (0-100, fractional), number (0-99 under the pointer), stage (numbers found so far, 0-3), set1 / set2 / set3
-- (found numbers, only once found), need_dir (1 turn right with D, -1 turn left with A, for the current number),
-- turn_dir (direction you last turned), listen (0-1, how close the dial is to the number while turning the right way),
-- noise (0-1, alarm risk from wrong tries), time_left (ms), payout ($ on success, Story Mode), near_safe (bool),
-- safe_sx / safe_sy (screen position above the safe, 0-1, -1 when off screen).
features.on_draw("Safe Cracker", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)

    if state == 1 then
        local sx, sy = f.safe_sx or -1, f.safe_sy or -1
        if sx >= 0 and sy >= 0 then
            local x, y = sx * sw, sy * sh - math.abs(math.sin(t * 3)) * 8 * s
            draw.circle(x, y, 9 * s, 255, 200, 60, 230)
            draw.circle(x, y, 4 * s, 20, 20, 24, 255)
            local label = f.near_safe and "E  CRACK THE SAFE" or "SAFE"
            local w = text.width(font.small, label)
            draw.rect(x - w / 2 - 8 * s, y - 40 * s, x + w / 2 + 8 * s, y - 16 * s, 10, 10, 14, 200, 5 * s)
            text.draw(font.small, x - w / 2, y - 38 * s, 255, 220, 120, 255, label)
        end
        return
    end

    local cx, cy = sw / 2, sh * 0.62
    local R = 150 * s
    draw.rect(cx - R - 150 * s, cy - R - 70 * s, cx + R + 150 * s, cy + R + 60 * s, 10, 10, 14, 215, 12 * s)
    draw.circle(cx, cy, R + 10 * s, 70, 70, 78, 255)
    draw.circle(cx, cy, R, 30, 30, 34, 255)
    local dial = f.dial or 0
    for n = 0, 99 do
        local ang = (n - dial) / 100 * math.pi * 2 - math.pi / 2
        local len = (n % 10 == 0) and 18 * s or ((n % 5 == 0) and 12 * s or 7 * s)
        local c1, s1 = math.cos(ang), math.sin(ang)
        draw.line(cx + c1 * (R - len), cy + s1 * (R - len), cx + c1 * (R - 2 * s), cy + s1 * (R - 2 * s), 220, 220, 228, 255, (n % 10 == 0) and 2 * s or 1)
        if n % 10 == 0 then
            local label = tostring(n)
            local tx, ty = cx + c1 * (R - 36 * s), cy + s1 * (R - 36 * s)
            text.draw(font.small, tx - text.width(font.small, label) / 2, ty - text.height(font.small) / 2, 230, 230, 236, 255, label)
        end
    end
    draw.circle(cx, cy, R * 0.42, 55, 55, 62, 255)
    draw.circle(cx, cy, R * 0.34, 80, 80, 90, 255)
    local num = string.format("%02d", math.floor(f.number or 0))
    text.draw(font.title, cx - text.width(font.title, num) / 2, cy - text.height(font.title) / 2, 255, 220, 120, 255, num)
    draw.line(cx, cy - R - 22 * s, cx - 9 * s, cy - R - 38 * s, 255, 80, 60, 255, 3 * s)
    draw.line(cx, cy - R - 22 * s, cx + 9 * s, cy - R - 38 * s, 255, 80, 60, 255, 3 * s)
    draw.line(cx - 9 * s, cy - R - 38 * s, cx + 9 * s, cy - R - 38 * s, 255, 80, 60, 255, 3 * s)

    local lx = cx - R - 90 * s
    local lh = R * 1.6
    local ly = cy - lh / 2
    local listen = math.max(0, math.min(1, f.listen or 0))
    draw.rect(lx, ly, lx + 26 * s, ly + lh, 40, 40, 48, 255, 6 * s)
    if listen > 0 then
        local p = listen
        if listen > 0.9 then p = listen * (0.85 + 0.15 * math.abs(math.sin(t * 18))) end
        draw.rect(lx, ly + lh * (1 - p), lx + 26 * s, ly + lh, 60 + math.floor(195 * listen), 220 - math.floor(60 * listen), 90, 255, 6 * s)
    end
    text.draw(font.tiny, lx + 13 * s - text.width(font.tiny, "LISTEN") / 2, ly + lh + 8 * s, 200, 200, 210, 255, "LISTEN")

    local nx = cx + R + 64 * s
    local noise = math.max(0, math.min(1, f.noise or 0))
    draw.rect(nx, ly, nx + 26 * s, ly + lh, 40, 40, 48, 255, 6 * s)
    if noise > 0 then draw.rect(nx, ly + lh * (1 - noise), nx + 26 * s, ly + lh, 255, 80, 60, 255, 6 * s) end
    text.draw(font.tiny, nx + 13 * s - text.width(font.tiny, "NOISE") / 2, ly + lh + 8 * s, 200, 200, 210, 255, "NOISE")

    local sets = { f.set1, f.set2, f.set3 }
    local stage = math.floor(f.stage or 0)
    for i = 1, 3 do
        local bx = cx + (i - 2) * 70 * s
        local by = cy - R - 62 * s
        local on = sets[i] ~= nil
        local r, g, b = 50, 50, 58
        if on then r, g, b = 90, 220, 120 elseif i == stage + 1 and state == 2 then r, g, b = 200, 170, 60 end
        draw.rect(bx - 28 * s, by - 14 * s, bx + 28 * s, by + 14 * s, r, g, b, 255, 6 * s)
        local label = on and string.format("%02d", math.floor(sets[i])) or "--"
        text.draw(font.small, bx - text.width(font.small, label) / 2, by - text.height(font.small) / 2, 20, 20, 24, 255, label)
    end

    local msg, mr, mg, mb = "", 230, 230, 236
    if state == 2 then
        local need = math.floor(f.need_dir or 1)
        local dir = need > 0 and "TURN RIGHT WITH D" or "TURN LEFT WITH A"
        msg = string.format("%s   PRESS E ON THE CLICK   SHIFT FINE TURN   %ds", dir, math.ceil((f.time_left or 0) / 1000))
        if (f.time_left or 0) < 10000 and math.floor(t * 4) % 2 == 0 then mr, mg, mb = 255, 110, 90 end
    elseif state == 3 then
        if f.payout then msg = string.format("SAFE OPEN!   $%d", math.floor(f.payout)) else msg = "SAFE OPEN!" end
        mr, mg, mb = 120, 240, 140
    elseif state == 4 then
        msg, mr, mg, mb = "ALARM!   RUN", 255, 80, 60
    end
    text.draw(font.small, cx - text.width(font.small, msg) / 2, cy + R + 22 * s, mr, mg, mb, 255, msg)
end)
