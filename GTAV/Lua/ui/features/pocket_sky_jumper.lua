-- Pocket Sky Jumper. Published fields: active (bool), state (1 playing, 2 fell), state_age (ms), px / py (jumper, x 0-1
-- across, y up from the bottom of the view), vy (vertical speed, positive rising), facing (1 right, -1 left), score
-- (best height this run), best, view_h (view height in the same units as the 1-wide field), platforms (blob
-- "x,y,w,type,touched_ms;" in view space: type 0 normal, 1 moving, 2 crumbling, 3 spring, 9 crumbled and falling).
features.on_draw("Pocket Sky Jumper", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local vh = f.view_h or 1.5
    local fh = 780 * s
    local fw = fh / vh
    local x0, y0 = sw / 2 - fw / 2, sh / 2 - fh / 2 + 10 * s
    local score = math.floor(f.score or 0)
    local dusk = math.min(1, score / 6000)
    draw.rect(x0 - 12 * s, y0 - 56 * s, x0 + fw + 12 * s, y0 + fh + 44 * s, 12, 12, 18, 235, 10 * s)
    draw.rect_gradient(x0, y0, x0 + fw, y0 + fh,
        math.floor(40 - 30 * dusk), math.floor(110 - 90 * dusk), math.floor(200 - 140 * dusk), 255,
        math.floor(40 - 30 * dusk), math.floor(110 - 90 * dusk), math.floor(200 - 140 * dusk), 255,
        math.floor(150 - 100 * dusk), math.floor(200 - 140 * dusk), math.floor(240 - 160 * dusk), 255,
        math.floor(150 - 100 * dusk), math.floor(200 - 140 * dusk), math.floor(240 - 160 * dusk), 255)
    if dusk > 0.3 then
        for i = 0, 24 do
            local sx = x0 + ((i * 53) % 100) / 100 * fw
            local sy = y0 + ((i * 37 + math.floor(score / 40)) % 100) / 100 * fh
            draw.circle(sx, sy, 1.4 * s, 255, 255, 255, math.floor(200 * (dusk - 0.3)))
        end
    end
    local function P(x, y) return x0 + x * fw, y0 + fh - y * fw end

    for x, y, w, kind, touched in string.gmatch(f.platforms or "", "([%-%d%.]+),([%-%d%.]+),([%d%.]+),(%d+),(%d+);") do
        x, y, w, kind, touched = tonumber(x), tonumber(y), tonumber(w), tonumber(kind), tonumber(touched)
        local px, py = P(x, y)
        local hw = w / 2 * fw
        local th = 10 * s
        if py > y0 - 20 * s and py < y0 + fh + 20 * s then
            local r, g, b = 90, 200, 80
            if kind == 1 then r, g, b = 80, 150, 240
            elseif kind == 2 or kind == 9 then r, g, b = 150, 100, 60 end
            local squash = 0
            if touched < 150 and kind ~= 9 then squash = (1 - touched / 150) * 3 * s end
            local a = 255
            if kind == 9 then a = math.max(0, 255 - math.floor(touched / 4)) end
            draw.rect(px - hw, py + squash, px + hw, py + th + squash, r, g, b, a, 5 * s)
            draw.rect(px - hw + 3 * s, py + squash, px + hw - 3 * s, py + 3 * s + squash, math.min(255, r + 60), math.min(255, g + 50), math.min(255, b + 50), a, 3 * s)
            if kind == 2 or kind == 9 then
                draw.line(px - hw * 0.2, py, px, py + th, 60, 40, 20, a, 2 * s)
                draw.line(px + hw * 0.3, py, px + hw * 0.1, py + th, 60, 40, 20, a, 2 * s)
            elseif kind == 3 then
                local coil = 14 * s
                if touched < 200 then coil = 22 * s end
                for k = 0, 3 do
                    local yy = py - k * coil / 4
                    draw.line(px - 8 * s, yy, px + 8 * s, yy - coil / 8, 200, 200, 210, 255, 2 * s)
                end
                draw.rect(px - 10 * s, py - coil - 3 * s, px + 10 * s, py - coil, 230, 60, 60, 255, 2 * s)
            end
        end
    end

    local state = math.floor(f.state or 0)
    local jx, jy = P(f.px or 0.5, f.py or 0)
    local r = 18 * s
    local stretch = math.max(-0.25, math.min(0.25, (f.vy or 0) * 0.08))
    local function body(x)
        draw.circle(x, jy - r * (1 + stretch), r * (1 - stretch * 0.5), 250, 220, 80, 255)
        local face = (f.facing or 1) > 0 and 1 or -1
        draw.circle(x + face * r * 0.35, jy - r * 1.25, r * 0.22, 255, 255, 255, 255)
        draw.circle(x + face * r * 0.42, jy - r * 1.25, r * 0.1, 20, 20, 24, 255)
        draw.line(x - r * 0.4, jy - r * 0.2, x - r * 0.5, jy + 2 * s, 80, 60, 30, 255, 3 * s)
        draw.line(x + r * 0.4, jy - r * 0.2, x + r * 0.5, jy + 2 * s, 80, 60, 30, 255, 3 * s)
    end
    if state == 1 then
        body(jx)
        if jx < x0 + r then body(jx + fw) elseif jx > x0 + fw - r then body(jx - fw) end
    end

    local hy = y0 - 46 * s
    text.draw(font.item, x0, hy - 4 * s, 245, 245, 250, 255, tostring(score))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.small, x0 + fw - text.width(font.small, best), hy, 255, 200, 60, 255, best)
    local msg, mr, mg, mb = "A / D STEER   BOUNCE AS HIGH AS YOU CAN   EDGES WRAP AROUND", 225, 230, 240
    if state == 2 then
        msg, mr, mg, mb = string.format("YOU FELL!   HEIGHT %d   E TO JUMP AGAIN", score), 255, 140, 110
        local w = text.width(font.title, "SPLAT")
        text.draw(font.title, sw / 2 - w / 2, y0 + fh * 0.4, 255, 255, 255, 255, "SPLAT")
    end
    text.draw(font.small, sw / 2 - text.width(font.small, msg) / 2, y0 + fh + 12 * s, mr, mg, mb, 255, msg)
end)
