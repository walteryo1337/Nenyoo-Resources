-- Pocket Missile Command. Published fields: active (bool), state (1 wave intro, 2 playing, 3 wave bonus, 4 game over),
-- state_age (ms), cx / cy (crosshair), wave, score, best, bonus (last wave bonus), mult (score multiplier), cities
-- (bitmask of the 6 cities still standing, left to right), batteries (bitmask of the 3 launchers), ammo1 / ammo2 / ammo3,
-- field_h / ground_y / battery_y (field is 1 wide and field_h tall, y down), enemies (blob "sx,sy,x,y;" origin and head
-- of each incoming missile), shots (blob "sx,sy,x,y,tx,ty;" your interceptors and their aim point), booms (blob
-- "x,y,r;" live explosions).
local CITY_X = { 0.17, 0.26, 0.35, 0.65, 0.74, 0.83 }
local BATTERY_X = { 0.06, 0.5, 0.94 }

features.on_draw("Pocket Missile Command", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local fh_n = f.field_h or 0.75
    local fw = 960 * s
    local fh = fw * fh_n
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 16 * s
    local function P(x, y) return x0 + x * fw, y0 + y * fw end
    local state = math.floor(f.state or 0)
    draw.rect(x0 - 12 * s, y0 - 54 * s, x0 + fw + 12 * s, y0 + fh + 42 * s, 8, 8, 14, 235, 10 * s)
    draw.rect_gradient(x0, y0, x0 + fw, y0 + fh, 6, 4, 30, 255, 6, 4, 30, 255, 40, 14, 50, 255, 40, 14, 50, 255)

    local gy = select(2, P(0, f.ground_y or 0.7))
    draw.rect(x0, gy, x0 + fw, y0 + fh, 120, 90, 30, 255, 0)
    local by = f.battery_y or 0.67
    local cities = math.floor(f.cities or 0)
    for i, cx in ipairs(CITY_X) do
        local x, y = P(cx, f.ground_y or 0.7)
        if math.floor(cities / 2 ^ (i - 1)) % 2 == 1 then
            draw.rect(x - 22 * s, y - 10 * s, x + 22 * s, y, 60, 140, 255, 255, 0)
            draw.rect(x - 16 * s, y - 20 * s, x - 6 * s, y - 10 * s, 60, 140, 255, 255, 0)
            draw.rect(x - 2 * s, y - 26 * s, x + 8 * s, y - 10 * s, 90, 180, 255, 255, 0)
            draw.rect(x + 11 * s, y - 16 * s, x + 18 * s, y - 10 * s, 60, 140, 255, 255, 0)
        else
            draw.rect(x - 20 * s, y - 5 * s, x + 20 * s, y, 70, 50, 40, 255, 2 * s)
        end
    end
    local batteries = math.floor(f.batteries or 0)
    local ammo = { f.ammo1 or 0, f.ammo2 or 0, f.ammo3 or 0 }
    for i, bx in ipairs(BATTERY_X) do
        local x, y = P(bx, by)
        draw.rect(x - 34 * s, y, x + 34 * s, gy, 150, 115, 40, 255, 6 * s)
        if math.floor(batteries / 2 ^ (i - 1)) % 2 == 1 then
            local n = math.floor(ammo[i])
            for k = 0, n - 1 do
                local row = k < 4 and 0 or (k < 7 and 1 or (k < 9 and 2 or 3))
                local first = ({ 0, 4, 7, 9 })[row + 1]
                local count = ({ 4, 3, 2, 1 })[row + 1]
                local col = k - first
                local mx = x + (col - (count - 1) / 2) * 9 * s
                local my = y + 8 * s + (3 - row) * 7 * s - 20 * s
                draw.rect(mx - 2 * s, my - 5 * s, mx + 2 * s, my + 2 * s, 60, 220, 255, 255, 0)
            end
        else
            draw.line(x - 14 * s, y - 2 * s, x + 14 * s, y + 4 * s, 90, 60, 40, 255, 3 * s)
        end
    end

    for sx, sy, x, y in string.gmatch(f.enemies or "", "([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+);") do
        local ax, ay = P(tonumber(sx), tonumber(sy))
        local hx, hy = P(tonumber(x), tonumber(y))
        draw.line(ax, ay, hx, hy, 230, 40, 40, 200, 2 * s)
        draw.circle(hx, hy, 2.5 * s, 255, 255, 255, 255)
    end
    for sx, sy, x, y, tx, ty in string.gmatch(f.shots or "", "([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+);") do
        local ax, ay = P(tonumber(sx), tonumber(sy))
        local hx, hy = P(tonumber(x), tonumber(y))
        local mx, my = P(tonumber(tx), tonumber(ty))
        draw.line(ax, ay, hx, hy, 80, 160, 255, 220, 2 * s)
        draw.line(mx - 5 * s, my - 5 * s, mx + 5 * s, my + 5 * s, 255, 255, 255, 200, 2 * s)
        draw.line(mx - 5 * s, my + 5 * s, mx + 5 * s, my - 5 * s, 255, 255, 255, 200, 2 * s)
    end
    local flick = math.floor(t * 20) % 3
    for x, y, r in string.gmatch(f.booms or "", "([%d%.]+),([%d%.]+),([%d%.]+);") do
        local bx, byy = P(tonumber(x), tonumber(y))
        local rad = tonumber(r) * fw
        if rad > 0.5 then
            local cr, cg, cb = 255, 255, 255
            if flick == 1 then cr, cg, cb = 255, 200, 60 elseif flick == 2 then cr, cg, cb = 255, 90, 200 end
            draw.circle(bx, byy, rad, cr, cg, cb, 230)
        end
    end

    if state == 1 or state == 2 then
        local cx, cy = P(f.cx or 0.5, f.cy or 0.35)
        local r = 12 * s
        draw.circle_outline(cx, cy, r, 255, 255, 255, 255, 2 * s)
        draw.line(cx - r * 1.6, cy, cx - r * 0.5, cy, 255, 255, 255, 255, 2 * s)
        draw.line(cx + r * 0.5, cy, cx + r * 1.6, cy, 255, 255, 255, 255, 2 * s)
        draw.line(cx, cy - r * 1.6, cx, cy - r * 0.5, 255, 255, 255, 255, 2 * s)
        draw.line(cx, cy + r * 0.5, cx, cy + r * 1.6, 255, 255, 255, 255, 2 * s)
    end

    local hy = y0 - 44 * s
    text.draw(font.small, x0, hy, 245, 245, 250, 255, string.format("SCORE %d", math.floor(f.score or 0)))
    local mid = string.format("WAVE %d   x%d", math.floor(f.wave or 1), math.floor(f.mult or 1))
    text.draw(font.small, x0 + fw / 2 - text.width(font.small, mid) / 2, hy, 255, 210, 90, 255, mid)
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.small, x0 + fw - text.width(font.small, best), hy, 200, 200, 212, 255, best)

    local banner, br, bg, bb
    if state == 1 then banner, br, bg, bb = string.format("WAVE %d   DEFEND THE CITIES", math.floor(f.wave or 1)), 255, 210, 90
    elseif state == 3 then banner, br, bg, bb = string.format("WAVE CLEAR   BONUS %d", math.floor(f.bonus or 0)), 120, 240, 140
    elseif state == 4 then banner, br, bg, bb = "THE END", 255, 80, 80 end
    if banner then
        local w = text.width(font.item, banner)
        text.draw(font.item, sw / 2 - w / 2, y0 + fh * 0.4, br, bg, bb, 255, banner)
    end
    local msg = "W A S D AIM   HOLD SHIFT FOR FAST AIM   E FIRES FROM THE NEAREST LAUNCHER"
    if state == 4 then msg = string.format("SCORE %d   BEST %d   E TO PLAY AGAIN", math.floor(f.score or 0), math.floor(f.best or 0)) end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + fh + 12 * s, 220, 220, 232, 255, msg)
end)
