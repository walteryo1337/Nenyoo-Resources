-- Fight Betting. Published fields: active (bool), state (1 betting, 2 countdown, 3 fighting, 4 result), countdown
-- (seconds), name1 / name2, odds1 / odds2 (payout multiple), health1 / health2 (0..1, 0 = knocked out), pick (-1 none,
-- 0 or 1), stake, winner (-1 until decided, 0 or 1), profit (cash won or lost), interfered (bool, you hit a fighter).
features.on_draw("Fight Betting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local pick = math.floor(f.pick or -1)
    local winner = math.floor(f.winner or -1)

    local w, h = 520 * s, 92 * s
    local x, y = cx - w / 2, sh * 0.06
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 220, 50, 45, 255, 0)
    local vs = "VS"
    text.draw(font.display, cx - text.width(font.display, vs) / 2, y + 14 * s, 230, 60, 55, 255, vs)

    local names = { f.name1 or "", f.name2 or "" }
    local odds = { f.odds1 or 0, f.odds2 or 0 }
    local hp = { f.health1 or 0, f.health2 or 0 }
    for i = 1, 2 do
        local left = i == 1
        local idx = i - 1
        local nx = left and (x + 14 * s) or (x + w - 14 * s)
        local nr, ng, nb = 245, 245, 250
        if pick == idx then nr, ng, nb = ar, ag, ab end
        if winner >= 0 and winner ~= idx then nr, ng, nb = 150, 150, 160 end
        local name = string.upper(names[i])
        local ostr = string.format("%.1fx", odds[i])
        if pick == idx then ostr = ostr .. "  YOUR PICK" end
        if left then
            text.draw(font.hud, nx, y + 12 * s, nr, ng, nb, 255, name)
            text.draw(font.hud_tiny, nx, y + 14 * s + text.height(font.hud), 200, 200, 212, 230, ostr)
        else
            text.draw(font.hud, nx - text.width(font.hud, name), y + 12 * s, nr, ng, nb, 255, name)
            text.draw(font.hud_tiny, nx - text.width(font.hud_tiny, ostr), y + 14 * s + text.height(font.hud), 200, 200, 212, 230, ostr)
        end
        local bw = w / 2 - 40 * s
        local by = y + h - 22 * s
        local bx1 = left and (x + 14 * s) or (x + w - 14 * s - bw)
        draw.rect(bx1, by, bx1 + bw, by + 8 * s, 255, 255, 255, 30, 4 * s)
        local fill = bw * math.max(0, math.min(1, hp[i]))
        local r, g, b = 120, 230, 120
        if hp[i] < 0.3 then r, g, b = 240, 80, 70 elseif hp[i] < 0.6 then r, g, b = 245, 200, 70 end
        if fill > 0 then
            if left then draw.rect(bx1 + bw - fill, by, bx1 + bw, by + 8 * s, r, g, b, 235, 4 * s)
            else draw.rect(bx1, by, bx1 + fill, by + 8 * s, r, g, b, 235, 4 * s) end
        end
    end

    local msg, r, g, b
    if state == 1 then
        msg = string.format("BETS CLOSE IN %d   STAKE $%d", math.ceil(f.countdown or 0), math.floor(f.stake or 0))
        if pick >= 0 then msg = "BET PLACED" end
        r, g, b = 220, 220, 232
    elseif state == 2 then
        local n = math.ceil(f.countdown or 0)
        local c = n > 0 and tostring(n) or "FIGHT"
        text.draw(big, cx - text.width(big, c) / 2, sh * 0.3, 255, 255, 255, 255, c)
        return
    elseif state == 4 then
        local wn = winner >= 0 and string.upper(names[winner + 1]) or ""
        msg = wn .. " WINS"
        r, g, b = 245, 245, 250
        if f.interfered then
            msg, r, g, b = "BETS OFF", 240, 80, 70
        elseif pick >= 0 then
            local p = math.floor(f.profit or 0)
            if p > 0 then msg, r, g, b = string.format("%s  +$%d", msg, p), 120, 230, 120
            else msg, r, g, b = string.format("%s  -$%d", msg, -p), 240, 80, 70 end
        end
    end
    if msg then
        if f.interfered and state ~= 4 then msg, r, g, b = "YOU GOT INVOLVED", 240, 80, 70 end
        text.draw(font.hud_small, cx - text.width(font.hud_small, msg) / 2, y + h + 6 * s, r, g, b, 255, msg)
    end
end)
