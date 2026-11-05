-- Pocket Asteroids. Published fields: active (bool), state (1 playing, 2 game over), x / y (0-1 ship position), angle
-- (radians, 0 = pointing up, clockwise), thrust (bool), invuln (bool, just respawned), lives, wave, score, best (this
-- session), rocks (blob "x,y,size,seed;" per asteroid: x / y 0-1, size 3 big .. 1 small, seed shapes its outline), shots
-- (blob "x,y;" per bullet). The field is 100 x 75 units; ROCK_R below matches the C++ radii.
local ROCK_R = { 2.2 / 100, 3.8 / 100, 6.0 / 100 }

local function rock_outline(cx, cy, r, seed, s)
    local pts = 9
    local px, py
    for i = 0, pts do
        local k = i % pts
        local a = k / pts * 2 * math.pi
        local jag = 0.75 + 0.25 * ((math.sin(seed * 12.9898 + k * 78.233) * 43758.5453) % 1)
        local x, y = cx + math.cos(a) * r * jag, cy + math.sin(a) * r * jag
        if px then draw.line(px, py, x, y, 220, 220, 230, 255, 2 * s) end
        px, py = x, y
    end
end

features.on_draw("Pocket Asteroids", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local fw = 640 * s
    local fh = fw * 0.75
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 20 * s
    draw.rect(x0 - 10 * s, y0 - 50 * s, x0 + fw + 10 * s, y0 + fh + 10 * s, 12, 12, 16, 225, 10 * s)
    draw.rect(x0, y0, x0 + fw, y0 + fh, 2, 2, 8, 255, 4 * s)

    for x, y, size, seed in string.gmatch(f.rocks or "", "([%d%.%-]+),([%d%.%-]+),(%d+),(%d+);") do
        local r = (ROCK_R[tonumber(size)] or ROCK_R[3]) * fw
        rock_outline(x0 + tonumber(x) * fw, y0 + tonumber(y) * fh, r, tonumber(seed), s)
    end
    for x, y in string.gmatch(f.shots or "", "([%d%.%-]+),([%d%.%-]+);") do
        draw.circle(x0 + tonumber(x) * fw, y0 + tonumber(y) * fh, 2.5 * s, 255, 255, 255, 255)
    end

    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)
    if state == 1 and not (f.invuln and math.floor(t * 10) % 2 == 0) then
        local cx, cy = x0 + (f.x or 0.5) * fw, y0 + (f.y or 0.5) * fh
        local a = f.angle or 0
        local size = 2 / 100 * fw * 1.6
        local function pt(ang, r) return cx + math.sin(a + ang) * r, cy - math.cos(a + ang) * r end
        local nx, ny = pt(0, size)
        local lx, ly = pt(2.5, size)
        local rx, ry = pt(-2.5, size)
        draw.line(nx, ny, lx, ly, 120, 230, 255, 255, 2 * s)
        draw.line(nx, ny, rx, ry, 120, 230, 255, 255, 2 * s)
        draw.line(lx, ly, rx, ry, 120, 230, 255, 255, 2 * s)
        if f.thrust and math.floor(t * 20) % 2 == 0 then
            local tx, ty = pt(math.pi, size * 1.4)
            draw.line(lx, ly, tx, ty, 255, 160, 60, 255, 2 * s)
            draw.line(rx, ry, tx, ty, 255, 160, 60, 255, 2 * s)
        end
    end

    local hud = string.format("SCORE %d   WAVE %d", math.floor(f.score or 0), math.floor(f.wave or 1))
    text.draw(font.hud, x0, y0 - 40 * s, 245, 245, 250, 255, hud)
    for i = 1, math.floor(f.lives or 0) do
        local lx = x0 + fw - i * 26 * s
        draw.line(lx, y0 - 14 * s, lx + 8 * s, y0 - 36 * s, 120, 230, 255, 255, 2 * s)
        draw.line(lx + 16 * s, y0 - 14 * s, lx + 8 * s, y0 - 36 * s, 120, 230, 255, 255, 2 * s)
        draw.line(lx, y0 - 14 * s, lx + 16 * s, y0 - 14 * s, 120, 230, 255, 255, 2 * s)
    end
    local msg
    if state == 2 then msg = string.format("GAME OVER   BEST %d   E TO PLAY AGAIN", math.floor(f.best or 0))
    elseif math.floor(f.score or 0) == 0 then msg = "A / D TURN     W THRUST     E FIRE" end
    if msg then text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + fh * 0.62, 220, 220, 232, 240, msg) end
end)
