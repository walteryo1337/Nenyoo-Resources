-- Pocket Penalties. Published fields: active (bool), state (1 playing, 2 shootout over), phase (0 aim left/right,
-- 1 aim up/down, 2 power, 3 your shot flying, 4 keeper waiting for the kick, 5 their shot flying), phase_ms,
-- aim_x (-1 left post to 1 right post), aim_y (0 ground to 1 crossbar), power (0 to 1), shot_x / shot_y (where the
-- ball goes; beyond the posts or bar on a miss), keeper_col (0 left, 1 middle, 2 right), result (0 pending,
-- 1 goal, 2 saved, 3 missed), you_goals / cpu_goals, wins / losses (this session), won (bool),
-- you / cpu (blob, one char per kick: '0' not taken, '1' goal, '2' saved, '3' missed).
local FLY_MS = 650

local function dots(x, y, s, hist, align_right)
    local n = 5
    for i = 6, #hist do if hist:sub(i, i) ~= "0" then n = i end end
    for i = 1, n do
        local c = hist:sub(i, i)
        local r, g, b, a = 90, 90, 100, 255
        if c == "1" then r, g, b = 90, 225, 120 elseif c == "2" or c == "3" then r, g, b = 235, 70, 70 end
        local cx = align_right and (x - (i - 0.5) * 22 * s) or (x + (i - 0.5) * 22 * s)
        draw.circle(cx, y, 8 * s, r, g, b, a)
    end
end

features.on_draw("Pocket Penalties", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local bw, bh = 820 * s, 560 * s
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 20 * s
    local state, phase = math.floor(f.state or 0), math.floor(f.phase or 0)
    local pms = f.phase_ms or 0

    draw.rect_gradient(x0, y0, x0 + bw, y0 + bh, 40, 70, 140, 255, 40, 70, 140, 255, 30, 120, 50, 255, 30, 120, 50, 255)
    local grass_y = y0 + bh * 0.62
    draw.rect(x0, grass_y, x0 + bw, y0 + bh, 40, 140, 60, 255, 0)
    for i = 0, 7 do
        if i % 2 == 0 then draw.rect(x0 + i * bw / 8, grass_y, x0 + (i + 1) * bw / 8, y0 + bh, 50, 155, 70, 255, 0) end
    end

    local gw, gh = bw * 0.62, bh * 0.36
    local gx, gy = sw / 2 - gw / 2, grass_y - gh
    for i = 1, 11 do
        local nx = gx + gw * i / 12
        draw.line(nx, gy, nx, grass_y, 230, 230, 240, 60, 1 * s)
    end
    for i = 1, 5 do
        local ny = gy + gh * i / 6
        draw.line(gx, ny, gx + gw, ny, 230, 230, 240, 60, 1 * s)
    end
    draw.line(gx, gy, gx + gw, gy, 250, 250, 255, 255, 7 * s)
    draw.line(gx, gy, gx, grass_y, 250, 250, 255, 255, 7 * s)
    draw.line(gx + gw, gy, gx + gw, grass_y, 250, 250, 255, 255, 7 * s)

    local function goal_xy(nx, ny)
        return sw / 2 + nx * gw / 2, grass_y - ny * gh
    end

    local flying = phase == 3 or phase == 5
    local fly = flying and math.min(1, pms / FLY_MS) or 0
    local kc = math.floor(f.keeper_col or 1)
    local kx = sw / 2
    local ktilt = 0
    if flying or (phase == 4 and kc ~= 1) then
        local dive = flying and math.min(1, pms / 400) or 0.15
        kx = sw / 2 + (kc - 1) * gw * 0.33 * dive
        ktilt = (kc - 1) * dive
    end
    local kh = gh * 0.72
    local kfeet = grass_y
    local kr, kg, kb = 250, 200, 40
    if phase == 4 or phase == 5 then kr, kg, kb = 70, 170, 255 end
    local bodyx = kx + ktilt * kh * 0.4
    local bodyy = kfeet - kh * (0.55 - math.abs(ktilt) * 0.25)
    draw.line(kx, kfeet, bodyx, bodyy, kr, kg, kb, 255, 18 * s)
    draw.circle(bodyx + ktilt * 14 * s, bodyy - 20 * s, 15 * s, 240, 205, 170, 255)
    draw.line(bodyx, bodyy, bodyx - 40 * s + ktilt * 50 * s, bodyy - 30 * s - math.abs(ktilt) * 10 * s, kr, kg, kb, 255, 8 * s)
    draw.line(bodyx, bodyy, bodyx + 40 * s + ktilt * 50 * s, bodyy - 30 * s - math.abs(ktilt) * 10 * s, kr, kg, kb, 255, 8 * s)

    local spot_x, spot_y = sw / 2, y0 + bh - 50 * s
    local ball_x, ball_y, ball_r = spot_x, spot_y, 16 * s
    if flying then
        local tx, ty = goal_xy(f.shot_x or 0, f.shot_y or 0.5)
        local res = math.floor(f.result or 0)
        if res == 2 and fly >= 1 then
            tx, ty = kx + (sw / 2 - kx) * 0.2, grass_y - gh * 0.3
        end
        local arc = math.sin(fly * math.pi) * 40 * s
        ball_x = spot_x + (tx - spot_x) * fly
        ball_y = spot_y + (ty - spot_y) * fly - arc
        ball_r = (16 - 8 * fly) * s
    end
    draw.circle(ball_x, ball_y, ball_r, 250, 250, 250, 255)
    draw.circle_outline(ball_x, ball_y, ball_r, 30, 30, 30, 255, 2 * s)

    if phase <= 2 and state == 1 then
        local ax, ay = goal_xy(f.aim_x or 0, phase == 0 and 0.5 or (f.aim_y or 0.5))
        local lr, lg, lb = 255, 80, 80
        draw.circle_outline(ax, ay, 18 * s, lr, lg, lb, 255, 3 * s)
        draw.line(ax - 26 * s, ay, ax + 26 * s, ay, lr, lg, lb, 255, 2 * s)
        draw.line(ax, ay - 26 * s, ax, ay + 26 * s, lr, lg, lb, 255, 2 * s)
        if phase == 2 then
            local px, py, pw, ph = x0 + bw - 46 * s, y0 + 70 * s, 22 * s, bh - 150 * s
            draw.rect(px, py, px + pw, py + ph, 0, 0, 0, 170, 6 * s)
            local p = math.max(0, math.min(1, f.power or 0))
            local r, g, b = 90, 225, 120
            if p > 0.92 then r, g, b = 235, 70, 70 elseif p < 0.3 then r, g, b = 240, 190, 60 end
            draw.rect(px, py + ph * (1 - p), px + pw, py + ph, r, g, b, 255, 6 * s)
            draw.line(px - 4 * s, py + ph * 0.08, px + pw + 4 * s, py + ph * 0.08, 255, 255, 255, 200, 2 * s)
        end
    end

    local res = math.floor(f.result or 0)
    if flying and fly >= 1 and res > 0 then
        local label, r, g, b = "GOAL!", 90, 225, 120
        if res == 2 then label, r, g, b = "SAVED!", 235, 180, 60 elseif res == 3 then label, r, g, b = "MISSED!", 235, 70, 70 end
        if phase == 5 then
            if res == 1 then r, g, b = 235, 70, 70 else r, g, b = 90, 225, 120 end
        end
        text.draw(font.title, sw / 2 - text.width(font.title, label) / 2, y0 + 30 * s, r, g, b, 255, label)
    end

    draw.rect(x0, y0 - 64 * s, x0 + bw, y0 - 8 * s, 10, 10, 16, 235, 10 * s)
    local you, cpu = math.floor(f.you_goals or 0), math.floor(f.cpu_goals or 0)
    local score = string.format("YOU %d - %d CPU", you, cpu)
    text.draw(font.title, sw / 2 - text.width(font.title, score) / 2, y0 - 58 * s, 245, 245, 250, 255, score)
    dots(x0 + 14 * s, y0 - 36 * s, s, f.you or "", false)
    dots(x0 + bw - 14 * s, y0 - 36 * s, s, f.cpu or "", true)

    local hint
    if state == 2 then
        hint = string.format("%s     WINS %d  LOSSES %d     PRESS SPACE FOR A REMATCH", f.won and "YOU WIN THE SHOOTOUT" or "YOU LOSE THE SHOOTOUT",
            math.floor(f.wins or 0), math.floor(f.losses or 0))
    elseif phase == 0 then hint = "SPACE TO LOCK YOUR AIM LEFT OR RIGHT"
    elseif phase == 1 then hint = "SPACE TO LOCK THE HEIGHT"
    elseif phase == 2 then hint = "SPACE TO STRIKE: TOO HARD AND IT GOES OVER"
    elseif phase == 4 then hint = "YOU ARE IN GOAL: A OR D TO DIVE, W TO STAY CENTRAL"
    else hint = "" end
    if hint ~= "" then
        text.draw(font.small, sw / 2 - text.width(font.small, hint) / 2, y0 + bh + 14 * s, 220, 220, 232, 235, hint)
    end
    if phase == 4 then
        local left = math.max(0, 1700 - pms)
        local bar = bw * 0.3
        draw.rect(sw / 2 - bar / 2, y0 + bh - 18 * s, sw / 2 - bar / 2 + bar * (left / 1700), y0 + bh - 10 * s, 255, 255, 255, 200, 4 * s)
    end
end)
