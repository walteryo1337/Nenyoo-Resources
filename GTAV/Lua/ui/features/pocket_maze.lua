-- Pocket Maze Chase. Published fields: active (bool), state (1 ready, 2 playing, 3 caught, 4 level clear, 5 game over),
-- state_age (ms), w / h (maze size in cells), maze (blob, w * h chars row by row: '#' wall, '.' dot, 'o' power pellet,
-- '-' ghost door, ' ' empty), px / py (you, in cells, fractional while moving), pdir (0 up, 1 left, 2 down, 3 right),
-- pmoving (bool), ghosts (blob "x,y,mode,dir;" per ghost; mode 0 in the house, 1 hunting, 2 frightened, 3 eyes
-- returning home), fright_left (ms of power pellet left), level, lives, score, best, popup_points / popup_age /
-- popup_x / popup_y (points for the last ghost eaten and where).
local GHOST_COLS = { { 255, 40, 40 }, { 255, 170, 230 }, { 40, 230, 255 }, { 255, 170, 70 } }
local DX = { [0] = 0, -1, 0, 1 }
local DY = { [0] = -1, 0, 1, 0 }

features.on_draw("Pocket Maze Chase", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local W, H = math.floor(f.w or 19), math.floor(f.h or 21)
    local c = 34 * s
    local bw, bh = W * c, H * c
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 16 * s
    local state = math.floor(f.state or 0)
    draw.rect(x0 - 14 * s, y0 - 56 * s, x0 + bw + 14 * s, y0 + bh + 44 * s, 6, 6, 10, 235, 10 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 0, 0, 0, 255, 0)

    local maze = f.maze or ""
    local function cell(x, y)
        if x < 0 or y < 0 or x >= W or y >= H then return "#" end
        local i = y * W + x + 1
        return string.sub(maze, i, i)
    end
    local wr, wg, wb = 40, 60, 220
    if state == 4 and math.floor((f.state_age or 0) / 250) % 2 == 1 then wr, wg, wb = 235, 235, 255 end
    local inset = 5 * s
    for y = 0, H - 1 do
        for x = 0, W - 1 do
            local ch = cell(x, y)
            local cx, cy = x0 + x * c, y0 + y * c
            if ch == "#" then
                draw.rect(cx + inset, cy + inset, cx + c - inset, cy + c - inset, wr, wg, wb, 255, 4 * s)
                if x + 1 < W and cell(x + 1, y) == "#" then
                    draw.rect(cx + c - inset - 1, cy + inset, cx + c + inset + 1, cy + c - inset, wr, wg, wb, 255, 0)
                end
                if y + 1 < H and cell(x, y + 1) == "#" then
                    draw.rect(cx + inset, cy + c - inset - 1, cx + c - inset, cy + c + inset + 1, wr, wg, wb, 255, 0)
                end
            elseif ch == "." then
                draw.circle(cx + c / 2, cy + c / 2, 3 * s, 255, 210, 180, 255)
            elseif ch == "o" then
                if math.floor(t * 4) % 2 == 0 then draw.circle(cx + c / 2, cy + c / 2, 8 * s, 255, 210, 180, 255) end
            elseif ch == "-" then
                draw.rect(cx, cy + c / 2 - 2 * s, cx + c, cy + c / 2 + 2 * s, 255, 170, 230, 255, 0)
            end
        end
    end

    local function to_screen(gx, gy)
        if gx < -0.5 then gx = gx + W elseif gx > W - 0.5 then gx = gx - W end
        return x0 + (gx + 0.5) * c, y0 + (gy + 0.5) * c
    end

    local fright = f.fright_left or 0
    local idx = 0
    for gx, gy, mode, dir in string.gmatch(f.ghosts or "", "([%-%d%.]+),([%-%d%.]+),(%d+),(%d+);") do
        idx = idx + 1
        gx, gy, mode, dir = tonumber(gx), tonumber(gy), tonumber(mode), tonumber(dir)
        if state ~= 3 or (f.state_age or 0) < 500 then
            local x, y = to_screen(gx, gy)
            if mode == 0 then y = y + math.sin(t * 6 + idx) * 4 * s end
            local r = c * 0.45
            local col = GHOST_COLS[idx] or GHOST_COLS[1]
            local br, bg, bb = col[1], col[2], col[3]
            if mode == 2 then
                br, bg, bb = 40, 50, 230
                if fright < 2000 and math.floor(t * 6) % 2 == 0 then br, bg, bb = 240, 240, 255 end
            end
            if mode ~= 3 then
                draw.circle(x, y - r * 0.15, r, br, bg, bb, 255)
                draw.rect(x - r, y - r * 0.15, x + r, y + r * 0.85, br, bg, bb, 255, 0)
                local wave = math.floor(t * 8) % 2
                for k = 0, 3 do
                    local fx = x - r + (k + 0.5) * r / 2
                    local fy = y + r * 0.85
                    if (k + wave) % 2 == 0 then draw.circle(fx, fy, r / 4, br, bg, bb, 255)
                    else draw.rect(fx - r / 4, fy - 1, fx + r / 4, fy + 1, 0, 0, 0, 255, 0) end
                end
            end
            if mode == 2 then
                draw.circle(x - r * 0.35, y - r * 0.2, r * 0.12, 255, 210, 180, 255)
                draw.circle(x + r * 0.35, y - r * 0.2, r * 0.12, 255, 210, 180, 255)
                for k = -2, 1 do
                    draw.line(x + k * r * 0.25, y + r * 0.35, x + (k + 0.5) * r * 0.25, y + r * 0.2, 255, 210, 180, 255, 2 * s)
                    draw.line(x + (k + 0.5) * r * 0.25, y + r * 0.2, x + (k + 1) * r * 0.25, y + r * 0.35, 255, 210, 180, 255, 2 * s)
                end
            else
                local ex, ey = DX[dir] or 0, DY[dir] or 0
                for side = -1, 1, 2 do
                    local cx, cy = x + side * r * 0.38, y - r * 0.2
                    draw.circle(cx, cy, r * 0.26, 255, 255, 255, 255)
                    draw.circle(cx + ex * r * 0.1, cy + ey * r * 0.1, r * 0.13, 30, 40, 200, 255)
                end
            end
        end
    end

    local px, py = to_screen(f.px or 9, f.py or 15)
    local pr = c * 0.46
    local face = ({ [0] = -math.pi / 2, math.pi, math.pi / 2, 0 })[math.floor(f.pdir or 1)] or 0
    local mouth = 0.6
    if state == 2 and f.pmoving then mouth = math.abs(math.sin(t * 14)) * 0.8 + 0.05 end
    if state == 1 then mouth = 0.5 end
    if state == 3 then
        local age = math.min(1, (f.state_age or 0) / 1300)
        mouth = 0.3 + age * (math.pi - 0.3)
        face = -math.pi / 2
        pr = pr * (1 - age * 0.3)
    end
    if not (state == 3 and (f.state_age or 0) >= 1300) then
        draw.circle(px, py, pr, 255, 230, 40, 255)
        local steps = math.max(3, math.floor(mouth * 10))
        for k = 0, steps do
            local a = face - mouth + (2 * mouth) * k / steps
            draw.line(px, py, px + math.cos(a) * (pr + 1), py + math.sin(a) * (pr + 1), 0, 0, 0, 255, 3 * s)
        end
    end

    if f.popup_points then
        local x, y = to_screen(f.popup_x or 0, f.popup_y or 0)
        local label = tostring(math.floor(f.popup_points))
        text.draw(font.small, x - text.width(font.small, label) / 2, y - 10 * s - (f.popup_age or 0) / 1000 * 16 * s, 40, 230, 255, 255, label)
    end

    local hy = y0 - 46 * s
    text.draw(font.small, x0, hy, 245, 245, 250, 255, string.format("SCORE %d", math.floor(f.score or 0)))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.small, x0 + bw / 2 - text.width(font.small, best) / 2, hy, 200, 200, 212, 255, best)
    local lvl = string.format("LEVEL %d", math.floor(f.level or 1))
    text.draw(font.small, x0 + bw - text.width(font.small, lvl), hy, 200, 200, 212, 255, lvl)
    for i = 1, math.min(6, math.floor(f.lives or 0)) do
        draw.circle(x0 + (i - 0.5) * 22 * s, y0 - 14 * s, 7 * s, 255, 230, 40, 255)
    end

    local banner, br, bg, bb
    if state == 1 then banner, br, bg, bb = "READY!", 255, 230, 40
    elseif state == 4 then banner, br, bg, bb = "MAZE CLEAR!", 120, 240, 140
    elseif state == 5 then banner, br, bg, bb = "GAME OVER", 255, 80, 80 end
    if banner then
        local w = text.width(font.item, banner)
        text.draw(font.item, x0 + bw / 2 - w / 2, y0 + 11 * c + c / 2 - text.height(font.item) / 2, br, bg, bb, 255, banner)
    end
    local msg = "W A S D STEER   EAT EVERY DOT   POWER PELLETS TURN THE GHOSTS"
    if state == 5 then msg = string.format("SCORE %d   BEST %d   E TO PLAY AGAIN", math.floor(f.score or 0), math.floor(f.best or 0)) end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + bh + 12 * s, 220, 220, 232, 255, msg)
end)
