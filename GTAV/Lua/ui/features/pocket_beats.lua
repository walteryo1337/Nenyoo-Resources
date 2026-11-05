-- Pocket Beats. Published fields: active (bool), state (1 get ready, 2 playing, 3 game over), score, best (this
-- session), combo, max_combo, level, judge (1 perfect, 2 good, 3 miss; 0 none yet), judge_age (ms since the last
-- judgement), countdown (ms left before the first note), health (0 to 1), travel (ms a note takes to fall),
-- lanes (blob "a,b,c,d": ms since each lane's key was last pressed, left/down/up/right), notes (blob "lane,dt;":
-- dt is ms until the note reaches the hit line, negative once it has passed).
local LANE_COLORS = { { 200, 90, 255 }, { 70, 200, 255 }, { 90, 235, 120 }, { 255, 110, 90 } }
local LANE_KEYS = { "A", "S", "W", "D" }

local function arrow(cx, cy, size, lane, r, g, b, a, th)
    local dirs = { { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 0 } }
    local d = dirs[lane + 1]
    local tipx, tipy = cx + d[1] * size, cy + d[2] * size
    local px, py = -d[2], d[1]
    local bx, by = cx - d[1] * size * 0.2, cy - d[2] * size * 0.2
    draw.line(bx + px * size, by + py * size, tipx, tipy, r, g, b, a, th)
    draw.line(bx - px * size, by - py * size, tipx, tipy, r, g, b, a, th)
    draw.line(cx - d[1] * size, cy - d[2] * size, tipx, tipy, r, g, b, a, th)
end

features.on_draw("Pocket Beats", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local lane_w = 96 * s
    local bw, bh = lane_w * 4, 640 * s
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 30 * s
    local hit_y = y0 + bh - 70 * s
    local travel = f.travel or 1600
    local state = math.floor(f.state or 0)

    draw.rect(x0 - 24 * s, y0 - 90 * s, x0 + bw + 24 * s, y0 + bh + 50 * s, 8, 8, 14, 235, 14 * s)

    local flashes = {}
    for v in string.gmatch(f.lanes or "", "(%d+)") do flashes[#flashes + 1] = tonumber(v) end
    for i = 0, 3 do
        local lx = x0 + i * lane_w
        local c = LANE_COLORS[i + 1]
        local age = flashes[i + 1] or 99999
        local glow = age < 180 and (1 - age / 180) or 0
        draw.rect(lx + 3 * s, y0, lx + lane_w - 3 * s, y0 + bh, 18 + math.floor(c[1] * 0.12 * (1 + glow * 2)), 18 + math.floor(c[2] * 0.12 * (1 + glow * 2)), 26 + math.floor(c[3] * 0.12 * (1 + glow * 2)), 255, 6 * s)
        local cx = lx + lane_w / 2
        arrow(cx, hit_y, 22 * s, i, c[1], c[2], c[3], math.floor(110 + 145 * glow), 4 * s)
        draw.circle_outline(cx, hit_y, 34 * s, c[1], c[2], c[3], math.floor(90 + 165 * glow), 3 * s)
        local key = LANE_KEYS[i + 1]
        text.draw(font.hud_small, cx - text.width(font.hud_small, key) / 2, y0 + bh - 30 * s, 200, 200, 214, 230, key)
    end
    draw.line(x0, hit_y, x0 + bw, hit_y, 240, 240, 250, 60, 2 * s)

    for lane, dt in string.gmatch(f.notes or "", "(%d+),(%-?%d+);") do
        local l, d = tonumber(lane), tonumber(dt)
        local y = hit_y - (d / travel) * (hit_y - y0)
        if y >= y0 and y <= y0 + bh then
            local c = LANE_COLORS[l + 1]
            local cx = x0 + l * lane_w + lane_w / 2
            draw.circle(cx, y, 30 * s, c[1], c[2], c[3], 255)
            arrow(cx, y, 15 * s, l, 15, 15, 22, 255, 5 * s)
        end
    end

    local health = math.max(0, math.min(1, f.health or 1))
    local hr, hg, hb = 90, 230, 120
    if health < 0.3 then hr, hg, hb = 235, 70, 70 elseif health < 0.6 then hr, hg, hb = 240, 190, 60 end
    draw.rect(x0, y0 - 18 * s, x0 + bw, y0 - 8 * s, 0, 0, 0, 160, 5 * s)
    draw.rect(x0, y0 - 18 * s, x0 + bw * health, y0 - 8 * s, hr, hg, hb, 255, 5 * s)

    local score = string.format("%07d", math.floor(f.score or 0))
    text.draw(font.display, x0, y0 - 80 * s, 245, 245, 250, 255, score)
    local best = string.format("BEST %07d", math.floor(f.best or 0))
    text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, best), y0 - 70 * s, 200, 200, 214, 230, best)
    local lvl = string.format("LEVEL %d", math.floor(f.level or 1))
    text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, lvl), y0 - 44 * s, 200, 200, 214, 230, lvl)

    local combo = math.floor(f.combo or 0)
    if combo >= 5 and state == 2 then
        local ct = string.format("%d COMBO", combo)
        text.draw(font.display, sw / 2 - text.width(font.display, ct) / 2, y0 + bh * 0.3, 255, 255, 255, 200, ct)
    end

    local judge, age = math.floor(f.judge or 0), f.judge_age or 99999
    if judge > 0 and age < 600 and state == 2 then
        local label, r, g, b = "PERFECT", 120, 230, 255
        if judge == 2 then label, r, g, b = "GOOD", 120, 240, 140 elseif judge == 3 then label, r, g, b = "MISS", 240, 80, 80 end
        local a = math.floor(255 * (1 - age / 600))
        local rise = age / 600 * 18 * s
        text.draw(font.display, sw / 2 - text.width(font.display, label) / 2, hit_y - 110 * s - rise, r, g, b, a, label)
    end

    local banner
    if state == 1 then
        local n = math.ceil((f.countdown or 0) / 1000)
        banner = n > 0 and tostring(n) or "GO!"
    elseif state == 3 then
        banner = "GAME OVER"
    end
    if banner then
        text.draw(font.display, sw / 2 - text.width(font.display, banner) / 2, y0 + bh * 0.42, 255, 225, 60, 255, banner)
    end
    local foot
    if state == 3 then
        foot = string.format("MAX COMBO %d     PRESS A KEY TO PLAY AGAIN", math.floor(f.max_combo or 0))
    else
        foot = "HIT A S W D AS THE NOTES REACH THE LINE"
    end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, foot) / 2, y0 + bh + 16 * s, 200, 200, 214, 230, foot)
end)
