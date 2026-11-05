-- Pocket Light Cycles. Published fields: active (bool), state (1 ready countdown, 2 racing, 3 round over, 4 match over),
-- state_age (ms), w / h (arena in cells), boost (0-1), boosting (bool), wins / losses (rounds), round, winner (0 you,
-- 1 the phone, 2 draw; last round), win_rounds, trails (blob: per bike "alive,died_ms:" then "x,y;" corner points from
-- the start to the head, ending "/"; bike 1 is you).
local COLS = { { 60, 200, 255 }, { 255, 150, 40 }, { 255, 60, 200 }, { 180, 255, 60 } }

features.on_draw("Pocket Light Cycles", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local W, H = math.floor(f.w or 64), math.floor(f.h or 48)
    local c = 13 * s
    local bw, bh = W * c, H * c
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 14 * s
    local state = math.floor(f.state or 0)
    draw.rect(x0 - 14 * s, y0 - 56 * s, x0 + bw + 14 * s, y0 + bh + 44 * s, 6, 8, 14, 235, 10 * s)
    draw.rect(x0, y0, x0 + bw, y0 + bh, 4, 6, 16, 255, 0)
    for gx = 0, W, 4 do draw.line(x0 + gx * c, y0, x0 + gx * c, y0 + bh, 30, 50, 90, 90, 1) end
    for gy = 0, H, 4 do draw.line(x0, y0 + gy * c, x0 + bw, y0 + gy * c, 30, 50, 90, 90, 1) end
    draw.rect(x0 - 2 * s, y0 - 2 * s, x0 + bw + 2 * s, y0, 90, 150, 255, 255, 0)
    draw.rect(x0 - 2 * s, y0 + bh, x0 + bw + 2 * s, y0 + bh + 2 * s, 90, 150, 255, 255, 0)
    draw.rect(x0 - 2 * s, y0, x0, y0 + bh, 90, 150, 255, 255, 0)
    draw.rect(x0 + bw, y0, x0 + bw + 2 * s, y0 + bh, 90, 150, 255, 255, 0)

    local idx = 0
    for alive, died, pts in string.gmatch(f.trails or "", "(%d),(%d+):([^/]*)/") do
        idx = idx + 1
        alive, died = alive == "1", tonumber(died)
        local a = 255
        if not alive then a = math.floor(255 * math.max(0, 1 - died / 600)) end
        if a > 0 then
            local col = COLS[idx] or COLS[1]
            local px, py
            for vx, vy in string.gmatch(pts, "(%d+),(%d+);") do
                local x, y = x0 + (tonumber(vx) + 0.5) * c, y0 + (tonumber(vy) + 0.5) * c
                if px then
                    draw.line(px, py, x, y, col[1], col[2], col[3], math.floor(a * 0.25), c * 1.1)
                    draw.line(px, py, x, y, col[1], col[2], col[3], a, c * 0.4)
                end
                px, py = x, y
            end
            if px then
                if alive then
                    draw.circle(px, py, c * 0.9, col[1], col[2], col[3], 90)
                    draw.circle(px, py, c * 0.5, 255, 255, 255, 255)
                elseif died < 600 then
                    local u = died / 600
                    for k = 0, 7 do
                        local ang = k * 0.785
                        draw.circle(px + math.cos(ang) * u * 30 * s, py + math.sin(ang) * u * 30 * s, (1 - u) * 4 * s, col[1], col[2], col[3], a)
                    end
                end
            end
        end
    end

    local hy = y0 - 46 * s
    local wins, losses, need = math.floor(f.wins or 0), math.floor(f.losses or 0), math.floor(f.win_rounds or 5)
    text.draw(font.hud_small, x0, hy, 60, 200, 255, 255, string.format("YOU %d", wins))
    local rr = string.format("ROUND %d   FIRST TO %d", math.floor(f.round or 1), need)
    text.draw(font.hud_small, x0 + bw / 2 - text.width(font.hud_small, rr) / 2, hy, 200, 200, 212, 255, rr)
    local ph = string.format("PHONE %d", losses)
    text.draw(font.hud_small, x0 + bw - text.width(font.hud_small, ph), hy, 255, 150, 40, 255, ph)
    local boost = math.max(0, math.min(1, f.boost or 0))
    draw.rect(x0, y0 - 16 * s, x0 + 200 * s, y0 - 9 * s, 30, 40, 60, 255, 3 * s)
    if boost > 0 then
        local br = f.boosting and 255 or 60
        draw.rect(x0, y0 - 16 * s, x0 + 200 * s * boost, y0 - 9 * s, br, 200, 255, 255, 3 * s)
    end

    local banner, br, bg, bb
    if state == 1 then
        banner = tostring(math.max(1, 3 - math.floor((f.state_age or 0) / 834)))
        br, bg, bb = 245, 245, 250
    elseif state == 3 then
        local w = math.floor(f.winner or -1)
        if w == 0 then banner, br, bg, bb = "ROUND WON", 60, 200, 255
        elseif w == 1 then banner, br, bg, bb = "DEREZZED", 255, 90, 80
        else banner, br, bg, bb = "DRAW", 220, 220, 230 end
    elseif state == 4 then
        if wins > losses then banner, br, bg, bb = "YOU WIN THE GRID!", 120, 240, 140
        else banner, br, bg, bb = "THE PHONE WINS", 255, 90, 80 end
    end
    if banner then
        local w = text.width(font.display, banner)
        draw.rect(sw / 2 - w / 2 - 18 * s, y0 + bh / 2 - 32 * s, sw / 2 + w / 2 + 18 * s, y0 + bh / 2 + 32 * s, 6, 8, 14, 220, 8 * s)
        text.draw(font.display, sw / 2 - w / 2, y0 + bh / 2 - text.height(font.display) / 2, br, bg, bb, 255, banner)
    end
    local msg = "W A S D TURN   HOLD SHIFT TO BOOST   DON'T HIT ANY TRAIL"
    if state == 4 then msg = "E TO PLAY AGAIN" end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + bh + 12 * s, 220, 220, 232, 255, msg)
end)
