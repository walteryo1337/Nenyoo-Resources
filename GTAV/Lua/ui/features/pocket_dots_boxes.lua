-- Pocket Dots and Boxes. Published fields: active (bool), state (1 playing, 2 game over), state_age (ms), size (lattice
-- side, 2 x boxes + 1), lattice (blob, size * size chars row by row: '.' a dot; on edges and box centres '0' empty,
-- '1' yours, '2' the phone's), cr / cc (cursor lattice cell, 0-based; edges have row + col odd), turn (1 you, 2 the
-- phone), you / phone (boxes), last_r / last_c (last line drawn, -1 none), wins, played.
features.on_draw("Pocket Dots and Boxes", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local n = math.floor(f.size or 11)
    local boxes = (n - 1) / 2
    local cell = 110 * s
    local bw = boxes * cell
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bw / 2 + 16 * s
    local state = math.floor(f.state or 0)
    draw.rect(x0 - 40 * s, y0 - 80 * s, x0 + bw + 40 * s, y0 + bw + 60 * s, 14, 14, 20, 230, 12 * s)
    draw.rect(x0 - 20 * s, y0 - 20 * s, x0 + bw + 20 * s, y0 + bw + 20 * s, 240, 236, 226, 255, 8 * s)

    local lat = f.lattice or ""
    local function at(r, c)
        local i = r * n + c + 1
        return string.sub(lat, i, i)
    end
    local function px(c) return x0 + c / 2 * cell end
    local function py(r) return y0 + r / 2 * cell end
    local YOU = { 50, 120, 230 }
    local PHONE = { 225, 70, 60 }

    for r = 1, n - 2, 2 do
        for c = 1, n - 2, 2 do
            local o = at(r, c)
            if o == "1" or o == "2" then
                local col = o == "1" and YOU or PHONE
                draw.rect(px(c - 1) + 6 * s, py(r - 1) + 6 * s, px(c + 1) - 6 * s, py(r + 1) - 6 * s, col[1], col[2], col[3], 80, 6 * s)
                local label = o == "1" and "YOU" or "PH"
                text.draw(font.hud_small, px(c) - text.width(font.hud_small, label) / 2, py(r) - text.height(font.hud_small) / 2, col[1], col[2], col[3], 255, label)
            end
        end
    end

    local lr, lc = math.floor(f.last_r or -1), math.floor(f.last_c or -1)
    for r = 0, n - 1 do
        for c = 0, n - 1 do
            if (r + c) % 2 == 1 then
                local o = at(r, c)
                local x1, y1, x2, y2
                if r % 2 == 0 then x1, y1, x2, y2 = px(c - 1), py(r), px(c + 1), py(r)
                else x1, y1, x2, y2 = px(c), py(r - 1), px(c), py(r + 1) end
                if o == "1" or o == "2" then
                    local col = o == "1" and YOU or PHONE
                    local thick = 6 * s
                    if r == lr and c == lc then thick = 6 * s + math.abs(math.sin(t * 6)) * 3 * s end
                    draw.line(x1, y1, x2, y2, col[1], col[2], col[3], 255, thick)
                end
            end
        end
    end
    for r = 0, n - 1, 2 do
        for c = 0, n - 1, 2 do draw.circle(px(c), py(r), 7 * s, 40, 40, 48, 255) end
    end

    if state == 1 then
        local cr, cc = math.floor(f.cr or 0), math.floor(f.cc or 1)
        local pulse = 150 + math.floor(100 * math.abs(math.sin(t * 5)))
        if (cr + cc) % 2 == 1 then
            local x1, y1, x2, y2
            if cr % 2 == 0 then x1, y1, x2, y2 = px(cc - 1) + 10 * s, py(cr), px(cc + 1) - 10 * s, py(cr)
            else x1, y1, x2, y2 = px(cc), py(cr - 1) + 10 * s, px(cc), py(cr + 1) - 10 * s end
            draw.line(x1, y1, x2, y2, 255, 190, 40, pulse, 4 * s)
        else
            draw.circle_outline(px(cc), py(cr), 16 * s, 255, 190, 40, pulse, 3 * s)
        end
    end

    local you, phone = math.floor(f.you or 0), math.floor(f.phone or 0)
    local hy = y0 - 64 * s
    text.draw(font.hud, x0, hy, YOU[1], YOU[2], YOU[3], 255, string.format("YOU %d", you))
    local ps = string.format("PHONE %d", phone)
    text.draw(font.hud, x0 + bw - text.width(font.hud, ps), hy, PHONE[1], PHONE[2], PHONE[3], 255, ps)
    local rec = string.format("WINS %d/%d", math.floor(f.wins or 0), math.floor(f.played or 0))
    text.draw(font.hud_small, x0 + bw / 2 - text.width(font.hud_small, rec) / 2, hy + 4 * s, 200, 200, 210, 255, rec)

    local msg, mr, mg, mb = "", 230, 230, 236
    if state == 1 then
        if math.floor(f.turn or 1) == 1 then msg = "YOUR TURN   W A S D MOVE   E DRAW A LINE   CLOSE A BOX TO GO AGAIN"
        else msg, mr, mg, mb = "THE PHONE IS THINKING...", 255, 160, 150 end
    else
        if you > phone then msg, mr, mg, mb = string.format("YOU WIN %d - %d   E TO PLAY AGAIN", you, phone), 120, 240, 140
        elseif you < phone then msg, mr, mg, mb = string.format("THE PHONE WINS %d - %d   E TO PLAY AGAIN", phone, you), 255, 110, 100
        else msg = "A DRAW   E TO PLAY AGAIN" end
    end
    text.draw(font.hud_small, sw / 2 - text.width(font.hud_small, msg) / 2, y0 + bw + 30 * s, mr, mg, mb, 255, msg)
end)
