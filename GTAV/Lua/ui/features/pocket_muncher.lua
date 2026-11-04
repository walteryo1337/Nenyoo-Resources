-- Pocket Muncher. Published fields: active (bool), state (1 ready, 2 playing, 3 caught, 4 level clear,
-- 5 game over), score, best (this session), lives, level, fright_left (ms the ghosts stay frightened),
-- px/py (player cell), pox/poy (previous cell), pdx/pdy (facing), pfrac (0 to 1 progress between the two),
-- grid_w/grid_h, maze (blob, grid_w * grid_h chars row by row: '#' wall, '-' ghost door, '.' dot,
-- 'o' power pellet, ' ' empty), ghosts (blob "x,y,ox,oy,mode,frac;" per ghost: mode 0 in the house,
-- 1 hunting, 2 frightened, 3 eaten and heading home).
local GHOST_COLORS = { { 235, 60, 60 }, { 255, 150, 210 }, { 70, 220, 235 }, { 255, 170, 60 } }

local function lerp_cell(x, y, ox, oy, f)
    if math.abs(x - ox) > 1 then return x, y end
    return ox + (x - ox) * f, oy + (y - oy) * f
end

features.on_draw("Pocket Muncher", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local gw, gh = math.floor(f.grid_w or 19), math.floor(f.grid_h or 21)
    local cell = math.floor(34 * s)
    local bw, bh = gw * cell, gh * cell
    local x0, y0 = math.floor(sw / 2 - bw / 2), math.floor(sh / 2 - bh / 2 + 24 * s)
    local state = math.floor(f.state or 0)
    local ar, ag, ab = 40, 80, 230
    local maze = f.maze or ""

    draw.rect(x0 - 18 * s, y0 - 74 * s, x0 + bw + 18 * s, y0 + bh + 50 * s, 6, 6, 12, 235, 12 * s)
    for y = 0, gh - 1 do
        for x = 0, gw - 1 do
            local i = y * gw + x + 1
            local c = maze:sub(i, i)
            local cx, cy = x0 + x * cell, y0 + y * cell
            if c == "#" then
                draw.rect(cx + 2 * s, cy + 2 * s, cx + cell - 2 * s, cy + cell - 2 * s, 14, 20, 60, 255, 4 * s)
                draw.rect_outline(cx + 2 * s, cy + 2 * s, cx + cell - 2 * s, cy + cell - 2 * s, ar, ag, ab, 255, 4 * s, 2 * s)
            elseif c == "-" then
                draw.rect(cx, cy + cell * 0.42, cx + cell, cy + cell * 0.58, 255, 180, 210, 255, 0)
            elseif c == "." then
                draw.circle(cx + cell / 2, cy + cell / 2, cell * 0.09, 255, 220, 190, 255)
            elseif c == "o" then
                if math.floor(t * 4) % 2 == 0 then draw.circle(cx + cell / 2, cy + cell / 2, cell * 0.28, 255, 220, 190, 255) end
            end
        end
    end

    local fright = f.fright_left or 0
    local n = 0
    for gx, gy, gox, goy, mode, gf in string.gmatch(f.ghosts or "", "(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%d+),([%d%.]+);") do
        n = n + 1
        local lx, ly = lerp_cell(tonumber(gx), tonumber(gy), tonumber(gox), tonumber(goy), tonumber(gf))
        local m = tonumber(mode)
        local cx, cy = x0 + (lx + 0.5) * cell, y0 + (ly + 0.5) * cell
        local r = cell * 0.42
        local col = GHOST_COLORS[n] or GHOST_COLORS[1]
        local gr, gg, gb = col[1], col[2], col[3]
        if m == 2 then
            gr, gg, gb = 50, 70, 230
            if fright < 2000 and math.floor(t * 6) % 2 == 0 then gr, gg, gb = 240, 240, 250 end
        end
        if m ~= 3 and not (state == 3 and math.floor(t * 8) % 2 == 0) then
            draw.circle(cx, cy - r * 0.15, r, gr, gg, gb, 255)
            draw.rect(cx - r, cy - r * 0.15, cx + r, cy + r * 0.85, gr, gg, gb, 255, 0)
            for k = 0, 2 do
                local fx = cx - r + r * 2 / 3 * (k + 0.5)
                draw.circle(fx, cy + r * 0.85, r / 3, gr, gg, gb, 255)
            end
        end
        if m == 2 then
            draw.circle(cx - r * 0.35, cy - r * 0.2, r * 0.12, 255, 220, 190, 255)
            draw.circle(cx + r * 0.35, cy - r * 0.2, r * 0.12, 255, 220, 190, 255)
        else
            draw.circle(cx - r * 0.35, cy - r * 0.2, r * 0.26, 245, 245, 250, 255)
            draw.circle(cx + r * 0.35, cy - r * 0.2, r * 0.26, 245, 245, 250, 255)
            draw.circle(cx - r * 0.3, cy - r * 0.2, r * 0.13, 30, 40, 160, 255)
            draw.circle(cx + r * 0.4, cy - r * 0.2, r * 0.13, 30, 40, 160, 255)
        end
    end

    local plx, ply = lerp_cell(f.px or 0, f.py or 0, f.pox or 0, f.poy or 0, f.pfrac or 1)
    local pcx, pcy = x0 + (plx + 0.5) * cell, y0 + (ply + 0.5) * cell
    local pr = cell * 0.44
    if state == 3 then pr = pr * math.max(0.1, 1 - math.min(1, (t * 2) % 1.5)) end
    draw.circle(pcx, pcy, pr, 255, 225, 40, 255)
    local pdx, pdy = f.pdx or 1, f.pdy or 0
    local facing = 0
    if pdx < 0 then facing = math.pi elseif pdy < 0 then facing = -math.pi / 2 elseif pdy > 0 then facing = math.pi / 2 end
    local open = state == 2 and math.abs(math.sin(t * 12)) * 0.55 or 0.25
    for k = -6, 6 do
        local a = facing + open * k / 6
        draw.line(pcx, pcy, pcx + math.cos(a) * pr * 1.05, pcy + math.sin(a) * pr * 1.05, 6, 6, 12, 255, 3 * s)
    end

    local score = string.format("%06d", math.floor(f.score or 0))
    text.draw(font.title, x0, y0 - 64 * s, 245, 245, 250, 255, score)
    local best = string.format("BEST %06d", math.floor(f.best or 0))
    text.draw(font.small, x0 + bw - text.width(font.small, best), y0 - 52 * s, 200, 200, 214, 230, best)
    for i = 1, math.floor(f.lives or 0) do
        local lx = x0 + bw - (i - 0.5) * 26 * s
        draw.circle(lx, y0 - 16 * s, 9 * s, 255, 225, 40, 255)
    end
    text.draw(font.small, x0, y0 - 26 * s, 200, 200, 214, 230, string.format("LEVEL %d", math.floor(f.level or 1)))

    local banner
    if state == 1 then banner = "READY!"
    elseif state == 4 then banner = "LEVEL CLEAR"
    elseif state == 5 then banner = "GAME OVER" end
    if banner then
        local bx = sw / 2 - text.width(font.title, banner) / 2
        local by = y0 + 11 * cell - text.height(font.title) / 2
        text.draw(font.title, bx, by, 255, 225, 40, 255, banner)
    end
    local foot = state == 5 and "W A S D TO PLAY AGAIN" or "W A S D TO MOVE     EAT A BIG PELLET TO TURN THE TABLES"
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + bh + 16 * s, 200, 200, 214, 230, foot)
end)
