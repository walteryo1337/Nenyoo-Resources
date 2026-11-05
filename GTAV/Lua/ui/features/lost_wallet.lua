-- Lost Wallet. Published fields: active (bool), state (1 find it, 2 deciding, 3 returning, 4 done), decide_left (seconds
-- left to press G and keep it), return_left (seconds left to hand it back), distance (metres to the wallet or owner),
-- cash (inside the wallet), result (1 returned, 2 kept, 3 kept because you took too long), paid, returned / kept (this
-- session).
features.on_draw("Lost Wallet", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local state = math.floor(f.state or 0)

    local w, h = 250 * s, 78 * s
    local x, y = sw - w - 30 * s, sh * 0.42
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 6 * s)
    draw.rect(x, y, x + 3 * s, y + h, 120, 200, 110, 255, 0)

    local title, sub
    if state == 1 then
        title = "LOST WALLET"
        sub = string.format("%d M AWAY", math.floor(f.distance or 0))
    elseif state == 2 or state == 3 then
        title = string.format("$%d INSIDE", math.floor(f.cash or 0))
        local t = math.max(0, f.return_left or 0)
        sub = string.format("OWNER %d M   %d:%02d", math.floor(f.distance or 0), math.floor(t / 60), math.floor(t % 60))
    else
        local result = math.floor(f.result or 0)
        title = result == 1 and "RETURNED" or "KEPT IT"
        sub = string.format("+$%d", math.floor(f.paid or 0))
    end
    text.draw(font.hud, x + 14 * s, y + 10 * s, 245, 245, 250, 255, title)
    text.draw(font.hud_small, x + 14 * s, y + 12 * s + text.height(font.hud), 210, 210, 222, 240, sub)

    local returned = math.floor(f.returned or 0)
    local kept = math.floor(f.kept or 0)
    if returned + kept > 0 then
        local honesty = returned / (returned + kept)
        local bx1, bx2 = x + 14 * s, x + w - 14 * s
        local by = y + h - 12 * s
        draw.rect(bx1, by, bx2, by + 4 * s, 240, 90, 70, 200, 2 * s)
        draw.rect(bx1, by, bx1 + (bx2 - bx1) * honesty, by + 4 * s, 120, 230, 120, 230, 2 * s)
        local hstr = string.format("HONESTY %d%%", math.floor(honesty * 100 + 0.5))
        text.draw(font.hud_tiny, bx2 - text.width(font.hud_tiny, hstr), by - text.height(font.hud_tiny) - 2 * s, 190, 190, 205, 230, hstr)
    end

    if state == 2 then
        local msg = string.format("G  KEEP THE CASH  %d", math.ceil(f.decide_left or 0))
        text.draw(font.hud_small, x + w / 2 - text.width(font.hud_small, msg) / 2, y + h + 6 * s, ar, ag, ab, 255, msg)
    end
end)
