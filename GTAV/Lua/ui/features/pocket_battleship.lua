-- Pocket Battleship. Published fields: active (bool), state (1 your turn, 2 enemy aiming, 3 won, 4 lost), n (grid size),
-- cx / cy (your aim on the enemy grid), mine / theirs (blobs, n * n chars row by row: "." water or unknown, "S" ship,
-- "o" miss, "x" hit, "X" part of a sunk ship; enemy ships show as "S" only once the game is over), your_ships /
-- enemy_ships (afloat), your_result / enemy_result (1 miss, 2 hit, 3 sunk) + your_age / enemy_age (ms), enemy_last
-- (cell index of the enemy's last shot), wins, played, can_shuffle (bool, Q re-deals your fleet before your first shot).
local results = { { "MISS", 170, 190, 220 }, { "HIT!", 255, 140, 70 }, { "SUNK!", 255, 80, 80 } }

local function grid(gx, gy, c, n, cells, t, opts)
    draw.rect(gx - 4, gy - 4, gx + n * c + 4, gy + n * c + 4, 10, 40, 80, 255, 6)
    for i = 0, n * n - 1 do
        local x, y = gx + (i % n) * c, gy + math.floor(i / n) * c
        local ch = cells:sub(i + 1, i + 1)
        draw.rect(x + 1, y + 1, x + c - 1, y + c - 1, 18, 70, 130, 255, 2)
        if ch == "S" then
            draw.rect(x + 4, y + 4, x + c - 4, y + c - 4, 150, 155, 165, 255, 3)
        elseif ch == "o" then
            draw.circle(x + c / 2, y + c / 2, c * 0.14, 220, 230, 245, 220)
        elseif ch == "x" or ch == "X" then
            if ch == "X" then draw.rect(x + 4, y + 4, x + c - 4, y + c - 4, 90, 40, 40, 255, 3)
            elseif opts.show_ships then draw.rect(x + 4, y + 4, x + c - 4, y + c - 4, 150, 155, 165, 255, 3) end
            local flick = 0.75 + 0.25 * math.sin(t * 12 + i)
            draw.circle(x + c / 2, y + c / 2, c * 0.28 * flick, 255, 120, 40, 255)
            draw.circle(x + c / 2, y + c / 2, c * 0.14, 255, 220, 90, 255)
        end
        if opts.last == i and opts.last_fresh then draw.circle_outline(x + c / 2, y + c / 2, c * 0.45, 255, 255, 255, 230, 2) end
    end
    if opts.cursor then
        local x, y = gx + opts.cursor[1] * c, gy + opts.cursor[2] * c
        local pulse = 0.6 + 0.4 * math.sin(t * 8)
        draw.rect(x, y, x + c, y + 3, 255, 230, 90, math.floor(255 * pulse), 0)
        draw.rect(x, y + c - 3, x + c, y + c, 255, 230, 90, math.floor(255 * pulse), 0)
        draw.rect(x, y, x + 3, y + c, 255, 230, 90, math.floor(255 * pulse), 0)
        draw.rect(x + c - 3, y, x + c, y + c, 255, 230, 90, math.floor(255 * pulse), 0)
        draw.line(x + c / 2, y + 6, x + c / 2, y + c - 6, 255, 230, 90, 200, 1.5)
        draw.line(x + 6, y + c / 2, x + c - 6, y + c / 2, 255, 230, 90, 200, 1.5)
    end
end

features.on_draw("Pocket Battleship", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.n or 8)
    local c = 34 * s
    local gw = n * c
    local gap = 48 * s
    local pw = gw * 2 + gap + 48 * s
    local ph = gw + 140 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 12, 12, 18, 230, 12 * s)
    local state = math.floor(f.state or 0)

    local lx, rx, gy = x0 + 24 * s, x0 + 24 * s + gw + gap, y0 + 56 * s
    text.draw(font.small, lx, y0 + 22 * s, 200, 200, 212, 255, string.format("YOUR FLEET   %d AFLOAT", math.floor(f.your_ships or 0)))
    text.draw(font.small, rx, y0 + 22 * s, 200, 200, 212, 255, string.format("ENEMY WATERS   %d AFLOAT", math.floor(f.enemy_ships or 0)))
    grid(lx, gy, c, n, f.mine or "", t, { show_ships = true, last = f.enemy_last and math.floor(f.enemy_last), last_fresh = (f.enemy_age or 99999) < 1500 })
    grid(rx, gy, c, n, f.theirs or "", t, { cursor = state == 1 and { math.floor(f.cx or 0), math.floor(f.cy or 0) } or nil })

    local yr = results[math.floor(f.your_result or 0)]
    if yr and (f.your_age or 99999) < 900 then
        local w = text.width(font.title, yr[1])
        text.draw(font.title, rx + gw / 2 - w / 2, gy + gw / 2 - text.height(font.title) / 2, yr[2], yr[3], yr[4], 255, yr[1])
    end
    local er = results[math.floor(f.enemy_result or 0)]
    if er and (f.enemy_age or 99999) < 900 then
        local w = text.width(font.title, er[1])
        text.draw(font.title, lx + gw / 2 - w / 2, gy + gw / 2 - text.height(font.title) / 2, er[2], er[3], er[4], 255, er[1])
    end

    local msg, cr, cg, cb
    if state == 1 then
        msg, cr, cg, cb = "W A S D AIM   E FIRE", 220, 220, 232
        if f.can_shuffle then msg = msg .. "   Q NEW FLEET LAYOUT" end
    elseif state == 2 then msg, cr, cg, cb = "ENEMY IS TAKING AIM...", 255, 180, 90
    elseif state == 3 then msg, cr, cg, cb = "VICTORY!   E TO PLAY AGAIN", 120, 240, 120
    else msg, cr, cg, cb = "YOUR FLEET IS SUNK   E TO PLAY AGAIN", 255, 100, 100 end
    text.draw(font.item, sw / 2 - text.width(font.item, msg) / 2, gy + gw + 28 * s, cr, cg, cb, 255, msg)
    local rec = string.format("WINS %d/%d", math.floor(f.wins or 0), math.floor(f.played or 0))
    text.draw(font.small, x0 + pw - 24 * s - text.width(font.small, rec), y0 + ph - 32 * s, 160, 160, 175, 255, rec)
end)
