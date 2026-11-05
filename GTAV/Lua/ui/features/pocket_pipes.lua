-- Pocket Pipes. Published fields: active (bool), state (1 playing, 2 solved), state_age (ms), n (grid side), tiles (blob,
-- n * n hex digits row by row: bit 1 pipe up, 2 right, 4 down, 8 left), lit (blob, same layout: '1' where water reaches),
-- src_x / src_y (the water tower), cx / cy (cursor), moves, elapsed (ms), best (fastest solve at this size, ms),
-- lit_count / total (tiles with water / all tiles).
local function clock(ms)
    local secs = math.floor((ms or 0) / 1000)
    return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

features.on_draw("Pocket Pipes", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.n or 5)
    local state = math.floor(f.state or 0)
    local c = math.min(90 * s, 620 * s / n)
    local gw = n * c
    local x0, y0 = sw / 2 - gw / 2, sh / 2 - gw / 2 + 16 * s
    draw.rect(x0 - 30 * s, y0 - 76 * s, x0 + gw + 30 * s, y0 + gw + 60 * s, 14, 18, 24, 235, 12 * s)
    draw.rect(x0, y0, x0 + gw, y0 + gw, 30, 36, 44, 255, 6 * s)

    local tiles, lit = f.tiles or "", f.lit or ""
    local sx, sy = math.floor(f.src_x or 0), math.floor(f.src_y or 0)
    local thick = c * 0.22
    for y = 0, n - 1 do
        for x = 0, n - 1 do
            local i = y * n + x + 1
            local m = tonumber(string.sub(tiles, i, i), 16) or 0
            local wet = string.sub(lit, i, i) == "1"
            local cx, cy = x0 + (x + 0.5) * c, y0 + (y + 0.5) * c
            draw.rect(x0 + x * c + 2 * s, y0 + y * c + 2 * s, x0 + (x + 1) * c - 2 * s, y0 + (y + 1) * c - 2 * s, 40, 48, 58, 255, 4 * s)
            local r, g, b = 120, 124, 132
            if wet then
                r, g, b = 60, 160, 255
                if state == 2 then
                    local p = 0.5 + 0.5 * math.sin(t * 6 - (x + y) * 0.6)
                    r, g, b = 60 + math.floor(80 * p), 170 + math.floor(60 * p), 255
                end
            end
            local deg = 0
            if m % 2 == 1 then draw.line(cx, cy, cx, cy - c / 2, r, g, b, 255, thick); deg = deg + 1 end
            if math.floor(m / 2) % 2 == 1 then draw.line(cx, cy, cx + c / 2, cy, r, g, b, 255, thick); deg = deg + 1 end
            if math.floor(m / 4) % 2 == 1 then draw.line(cx, cy, cx, cy + c / 2, r, g, b, 255, thick); deg = deg + 1 end
            if math.floor(m / 8) % 2 == 1 then draw.line(cx, cy, cx - c / 2, cy, r, g, b, 255, thick); deg = deg + 1 end
            draw.circle(cx, cy, thick * 0.5, r, g, b, 255)
            if x == sx and y == sy then
                draw.circle(cx, cy, c * 0.3, 40, 110, 210, 255)
                draw.circle(cx, cy, c * 0.2, 90, 180, 255, 255)
            elseif deg == 1 then
                local hs = c * 0.24
                draw.rect(cx - hs, cy - hs, cx + hs, cy + hs, 90, 70, 60, 255, 3 * s)
                local wr, wg, wb = 50, 50, 56
                if wet then wr, wg, wb = 255, 220, 100 end
                draw.rect(cx - hs * 0.5, cy - hs * 0.5, cx + hs * 0.5, cy + hs * 0.5, wr, wg, wb, 255, 2 * s)
            end
        end
    end
    if state == 1 then
        local cx, cy = math.floor(f.cx or 0), math.floor(f.cy or 0)
        local a = 160 + math.floor(90 * math.abs(math.sin(t * 6)))
        local px, py = x0 + cx * c, y0 + cy * c
        draw.line(px, py, px + c, py, 255, 190, 40, a, 3 * s)
        draw.line(px, py + c, px + c, py + c, 255, 190, 40, a, 3 * s)
        draw.line(px, py, px, py + c, 255, 190, 40, a, 3 * s)
        draw.line(px + c, py, px + c, py + c, 255, 190, 40, a, 3 * s)
    end

    local hy = y0 - 60 * s
    text.draw(font.hud, x0, hy, 245, 245, 250, 255, clock(f.elapsed))
    local mid = string.format("WATER %d/%d   MOVES %d", math.floor(f.lit_count or 0), math.floor(f.total or 0), math.floor(f.moves or 0))
    text.draw(font.hud_small, x0 + gw / 2 - text.width(font.hud_small, mid) / 2, hy + 4 * s, 200, 210, 225, 255, mid)
    if f.best then
        local b = "BEST " .. clock(f.best)
        text.draw(font.hud_small, x0 + gw - text.width(font.hud_small, b), hy + 4 * s, 255, 200, 60, 255, b)
    end
    local msg, mr, mg, mb = "W A S D MOVE   E TURN RIGHT   Q TURN LEFT   GET WATER TO EVERY HOUSE", 220, 220, 232
    if state == 2 then msg, mr, mg, mb = string.format("EVERY HOUSE HAS WATER IN %s!   E FOR A NEW TOWN", clock(f.elapsed)), 120, 240, 140 end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + gw + 22 * s, mr, mg, mb, 255, msg)
end)
