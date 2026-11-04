-- Cone Slalom. Published fields: active (bool), state (1 ready at the start, 2 running, 3 result), elapsed (seconds),
-- penalty (seconds added), next_gate / gates (cones passed / total), next_side (-1 pass it on the left, 1 on the right,
-- 0 none left), flash (1 cone hit, 2 wrong side, 3 clean pass), flash_age (0..1, -1 when none), result (1 finished,
-- 2 did not finish), total (final seconds with penalties), par (seconds to beat for pay), best (fastest for this many
-- cones, missing until one), clean (bool), pay.
features.on_draw("Cone Slalom", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)

    if state == 3 then
        local result = math.floor(f.result or 0)
        local msg, r, g, b = "DID NOT FINISH", 240, 80, 70
        if result == 1 then
            msg = string.format("%.2f S", f.total or 0)
            r, g, b = ar, ag, ab
            if (f.total or 0) <= (f.par or 0) then r, g, b = 120, 230, 120 end
        end
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
        local y = sh * 0.26 + text.height(big)
        if result == 1 then
            local sub = string.format("PAR %.1f S", f.par or 0)
            if f.best then sub = sub .. string.format("   BEST %.2f S", f.best) end
            if f.clean then sub = "CLEAN RUN   " .. sub end
            text.draw(font.item, cx - text.width(font.item, sub) / 2, y, 235, 235, 245, 255, sub)
            y = y + text.height(font.item)
            if (f.pay or 0) > 0 then
                local p = string.format("+$%d", math.floor(f.pay))
                text.draw(font.item, cx - text.width(font.item, p) / 2, y, 245, 245, 250, 255, p)
            end
        end
        return
    end

    local w, h = 260 * s, 74 * s
    local x, y = cx - w / 2, sh * 0.05
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 200, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 255, 140, 40, 255, 0)
    local t = state == 2 and (f.elapsed or 0) or 0
    local clock = string.format("%.2f", t)
    text.draw(font.title, x + 14 * s, y + 10 * s, 245, 245, 250, 255, clock)
    local pen = f.penalty or 0
    if pen > 0 then
        local pstr = string.format("+%.0f", pen)
        text.draw(font.item, x + 18 * s + text.width(font.title, clock), y + 14 * s, 240, 90, 70, 255, pstr)
    end
    local gates = string.format("%d/%d", math.floor(f.next_gate or 0), math.floor(f.gates or 0))
    text.draw(font.title, x + w - 14 * s - text.width(font.title, gates), y + 10 * s, 220, 220, 232, 255, gates)

    local side = math.floor(f.next_side or 0)
    local hint = state == 1 and "DRIVE TO THE FIRST CONE" or ""
    if side ~= 0 then
        local word = side < 0 and "LEFT" or "RIGHT"
        hint = (state == 1 and "FIRST CONE: KEEP " or "KEEP ") .. word
    end
    text.draw(font.small, x + 14 * s, y + h - 10 * s - text.height(font.small), 255, 200, 90, 255, hint)

    local age = f.flash_age or -1
    if age >= 0 then
        local fl = math.floor(f.flash or 0)
        local msgs = { "CONE HIT  +1", "WRONG SIDE  +2", "NICE" }
        local msg = msgs[fl] or ""
        local r, g, b = 240, 80, 70
        if fl == 3 then r, g, b = 120, 230, 120 end
        text.draw(font.title, cx - text.width(font.title, msg) / 2, y + h + 10 * s - 14 * s * age, r, g, b, math.floor(255 * (1 - age)), msg)
    end
end)
