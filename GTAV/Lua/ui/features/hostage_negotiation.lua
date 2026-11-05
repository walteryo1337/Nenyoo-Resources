-- Hostage Negotiation. Published fields: active (bool), state (1 approach, 2 picking a line, 3 his reaction, 4 he is
-- shooting, 5 result), result (1 talked down, 2 gunman neutralised, 3 hostage died, 4 you died, 5 abandoned), distance
-- (metres to the gunman), tension / trust (0-100), round_left (seconds to answer), sel (0-2 highlighted line),
-- opt1 / opt2 / opt3 (dialogue lines, only while picking), mood (read on his state of mind, when close), reply (his
-- reaction, during state 3), paid.
features.on_draw("Hostage Negotiation", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local t = ctx.time() or 0
    local state = math.floor(f.state or 0)

    if state == 5 then
        local result = math.floor(f.result or 0)
        local msg, r, g, b = "STANDOFF OVER", 220, 220, 230
        if result == 1 then msg, r, g, b = "TALKED DOWN", 120, 230, 120
        elseif result == 2 then msg, r, g, b = "GUNMAN NEUTRALISED", ar, ag, ab
        elseif result == 3 then msg, r, g, b = "HOSTAGE LOST", 240, 80, 70
        elseif result == 4 then msg, r, g, b = "YOU DIED", 240, 80, 70 end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        if (f.paid or 0) > 0 then
            local p = string.format("+$%d", math.floor(f.paid))
            text.draw(font.hud, cx - text.width(font.hud, p) / 2, sh * 0.26 + text.height(big), 245, 245, 250, 255, p)
        end
        return
    end

    local tension = f.tension or 0
    local trust = f.trust or 0
    local w = 300 * s
    local x = sw - w - 30 * s
    local y = sh * 0.30
    local bar_h = 8 * s
    local lh = text.height(font.hud_small)
    local panel_h = 22 * s + lh * 2 + bar_h * 2 + 14 * s
    draw.rect(x, y, x + w, y + panel_h, 12, 12, 16, 210, 6 * s)
    draw.rect(x, y, x + 3 * s, y + panel_h, 240, 80, 70, 255, 0)

    local function meter(label, v, by, r, g, b)
        text.draw(font.hud_small, x + 14 * s, by, 215, 215, 228, 240, label)
        local val = string.format("%d", math.floor(v + 0.5))
        text.draw(font.hud_small, x + w - 14 * s - text.width(font.hud_small, val), by, 215, 215, 228, 240, val)
        local bx1, bx2 = x + 14 * s, x + w - 14 * s
        local bty = by + lh + 2 * s
        draw.rect(bx1, bty, bx2, bty + bar_h, 40, 40, 50, 220, 3 * s)
        draw.rect(bx1, bty, bx1 + (bx2 - bx1) * math.min(1, v / 100), bty + bar_h, r, g, b, 240, 3 * s)
    end

    local tr, tg, tb = 240, 200, 60
    if tension >= 70 then
        local pulse = 0.5 + 0.5 * math.sin(t * 12)
        tr, tg, tb = 240, math.floor(60 + 40 * pulse), 60
    end
    meter("TENSION", tension, y + 10 * s, tr, tg, tb)
    meter("TRUST", trust, y + 14 * s + lh + bar_h + 4 * s, 120, 200, 240)

    local below = y + panel_h + 8 * s
    if f.mood then
        text.draw(font.hud_tiny, x, below, 200, 200, 214, 230, f.mood)
        below = below + text.height(font.hud_tiny) + 4 * s
    end

    if state == 1 then
        local d = string.format("GUNMAN %d M", math.floor(f.distance or 0))
        text.draw(font.hud_small, x, below, 230, 230, 240, 240, d)
        if state == 1 and (f.distance or 99) < 6 then
            text.draw(font.hud_small, x, below + lh + 2 * s, ar, ag, ab, 255, "E  TALK TO HIM")
        end
        return
    end

    if state == 4 then
        local msg = "HE'S GOING TO SHOOT"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.2, 240, 70, 60, 255, msg)
        return
    end

    local bw = math.min(sw - 60 * s, 760 * s)
    local bx = cx - bw / 2
    local row = text.height(font.hud) + 12 * s
    local bh = row * 3 + 40 * s
    local by = sh * 0.70
    draw.rect(bx, by, bx + bw, by + bh, 10, 10, 14, 220, 8 * s)

    if state == 2 then
        local left = f.round_left or 0
        draw.rect(bx, by, bx + bw * math.min(1, left / 12), by + 3 * s, ar, ag, ab, 255, 0)
        local sel = math.floor(f.sel or 0)
        local opts = { f.opt1, f.opt2, f.opt3 }
        for i = 1, 3 do
            local line = opts[i] or ""
            local ry = by + 14 * s + (i - 1) * row
            if sel == i - 1 then
                draw.rect(bx + 10 * s, ry - 4 * s, bx + bw - 10 * s, ry + row - 8 * s, ar, ag, ab, 60, 4 * s)
                text.draw(font.hud, bx + 22 * s, ry, 255, 255, 255, 255, line)
            else
                text.draw(font.hud, bx + 22 * s, ry, 190, 190, 205, 230, line)
            end
        end
        local hint = "W / S  CHOOSE     E  SAY IT     BACKSPACE  STEP BACK"
        text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, hint) / 2, by + bh - text.height(font.hud_tiny) - 8 * s, 170, 170, 185, 220, hint)
    elseif state == 3 and f.reply then
        text.draw(font.hud, cx - text.width(font.hud, f.reply) / 2, by + bh / 2 - text.height(font.hud) / 2, 240, 240, 248, 255, f.reply)
    end
end)
