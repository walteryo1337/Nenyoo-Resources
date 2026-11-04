-- Pocket Keno. Published fields: active (bool), state (1 picking, 2 drawing, 3 result), cursor (0 to 79), spots
-- (numbers picked), hits (picked numbers drawn so far), bet (stake for the next draw), stake (stake of the last
-- draw), win (paid on the last draw), net (session winnings, can be negative), picked (blob of 80 '0'/'1'),
-- drawn (blob "n;" of the numbers revealed so far, 0-based), pays (blob "mult;" indexed by hits for the current
-- number of spots).
local function money(v)
    local n = math.floor(math.abs(v))
    local str = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return (v < 0 and "-$" or "$") .. str
end

local function split(blob)
    local out = {}
    for item in string.gmatch(blob or "", "([^;]+)") do out[#out + 1] = tonumber(item) or 0 end
    return out
end

features.on_draw("Pocket Keno", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)
    local ar, ag, ab = theme.accent()
    ar, ag, ab = ar or 90, ag or 200, ab or 255

    local pw, ph = 860 * s, 560 * s
    local x0, y0 = sw / 2 - pw / 2, sh / 2 - ph / 2
    draw.rect(x0, y0, x0 + pw, y0 + ph, 10, 10, 16, 228, 14 * s)
    text.draw(font.small, x0 + 18 * s, y0 + 12 * s, 235, 235, 245, 255, "POCKET KENO")
    local net = math.floor(f.net or 0)
    local net_s = "SESSION " .. money(net)
    local nr, ng, nb = 200, 200, 214
    if net > 0 then nr, ng, nb = 110, 225, 130 elseif net < 0 then nr, ng, nb = 235, 110, 90 end
    text.draw(font.small, x0 + pw - 18 * s - text.width(font.small, net_s), y0 + 12 * s, nr, ng, nb, 255, net_s)

    local picked = f.picked or ""
    local drawn = {}
    local drawn_list = split(f.drawn)
    for _, n in ipairs(drawn_list) do drawn[n] = true end
    local last = drawn_list[#drawn_list]

    local cw, ch, gap = 52 * s, 50 * s, 4 * s
    local gx, gy = x0 + 18 * s, y0 + 50 * s
    local cursor = math.floor(f.cursor or 0)
    for i = 0, 79 do
        local col, row = i % 10, math.floor(i / 10)
        local cx, cy = gx + col * (cw + gap), gy + row * (ch + gap)
        local is_pick = picked:sub(i + 1, i + 1) == "1"
        local is_drawn = drawn[i]
        local r, g, b = 30, 30, 42
        local tr, tg, tb = 190, 190, 205
        if is_pick and is_drawn then
            r, g, b = 70, 200, 100; tr, tg, tb = 255, 255, 255
        elseif is_drawn then
            r, g, b = 150, 120, 40; tr, tg, tb = 255, 240, 200
        elseif is_pick then
            r, g, b = math.floor(ar * 0.55), math.floor(ag * 0.55), math.floor(ab * 0.55); tr, tg, tb = 255, 255, 255
        end
        draw.rect(cx, cy, cx + cw, cy + ch, r, g, b, 255, 6 * s)
        if i == last and state == 2 then
            draw.rect_outline(cx - 2 * s, cy - 2 * s, cx + cw + 2 * s, cy + ch + 2 * s, 255, 230, 120, 255, 7 * s, 2 * s)
        end
        if i == cursor and state == 1 then
            local pulse = 180 + math.floor(75 * math.abs(math.sin(t * 4)))
            draw.rect_outline(cx, cy, cx + cw, cy + ch, 255, 255, 255, pulse, 6 * s, 2 * s)
        end
        local label = tostring(i + 1)
        text.draw(font.item, cx + cw / 2 - text.width(font.item, label) / 2, cy + ch / 2 - text.height(font.item) / 2, tr, tg, tb, 255, label)
    end

    local rx = gx + 10 * (cw + gap) + 14 * s
    local rw = x0 + pw - 18 * s - rx
    local spots = math.floor(f.spots or 0)
    local hits = math.floor(f.hits or 0)
    draw.rect(rx, gy, rx + rw, gy + 8 * (ch + gap) - gap, 22, 22, 32, 255, 8 * s)
    local yy = gy + 10 * s
    text.draw(font.small, rx + 12 * s, yy, 235, 235, 245, 255, string.format("SPOTS %d / 10", spots))
    yy = yy + 26 * s
    text.draw(font.tiny, rx + 12 * s, yy, 170, 170, 186, 255, "HITS")
    local pays_hdr = "PAYS"
    text.draw(font.tiny, rx + rw - 12 * s - text.width(font.tiny, pays_hdr), yy, 170, 170, 186, 255, pays_hdr)
    yy = yy + 20 * s
    local pays = split(f.pays)
    local bet = math.floor((state == 1 and f.bet or f.stake) or 0)
    for h = #pays - 1, 0, -1 do
        local mult = pays[h + 1] or 0
        if mult > 0 then
            local hl = state ~= 1 and h == hits
            if hl then draw.rect(rx + 6 * s, yy - 2 * s, rx + rw - 6 * s, yy + 20 * s, 70, 200, 100, 90, 4 * s) end
            text.draw(font.tiny, rx + 12 * s, yy, 235, 235, 245, 255, tostring(h))
            local pay = money(mult * bet)
            text.draw(font.tiny, rx + rw - 12 * s - text.width(font.tiny, pay), yy, 235, 220, 150, 255, pay)
            yy = yy + 22 * s
        end
    end
    if spots == 0 then
        text.draw(font.tiny, rx + 12 * s, yy, 170, 170, 186, 255, "PICK UP TO 10")
    end

    local by = gy + 8 * (ch + gap) - gap - 92 * s
    text.draw(font.tiny, rx + 12 * s, by, 170, 170, 186, 255, "STAKE " .. money(math.floor(f.bet or 0)))
    if state ~= 1 then
        text.draw(font.small, rx + 12 * s, by + 24 * s, 235, 235, 245, 255, string.format("MATCHED %d", hits))
    end
    if state == 3 then
        local win = math.floor(f.win or 0)
        local msg = win > 0 and ("WON " .. money(win)) or "NO WIN"
        local wr, wg, wb = 235, 110, 90
        if win > 0 then wr, wg, wb = 110, 225, 130 end
        text.draw(font.small, rx + 12 * s, by + 50 * s, wr, wg, wb, 255, msg)
    end

    local hint
    if state == 1 then hint = "W A S D  MOVE    E  PICK    R  QUICK PICK    SPACE  DRAW"
    elseif state == 2 then hint = "DRAWING..."
    else hint = "SPACE  SAME NUMBERS AGAIN    ANY OTHER KEY  CHANGE PICKS" end
    text.draw(font.tiny, x0 + pw / 2 - text.width(font.tiny, hint) / 2, y0 + ph - 14 * s - text.height(font.tiny), 200, 200, 214, 230, hint)
end)
