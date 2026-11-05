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
    local big = font.display
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
            text.draw(font.hud, cx - text.width(font.hud, sub) / 2, y, 235, 235, 245, 255, sub)
            y = y + text.height(font.hud)
            if (f.pay or 0) > 0 then
                local p = string.format("+$%d", math.floor(f.pay))
                text.draw(font.hud, cx - text.width(font.hud, p) / 2, y, 245, 245, 250, 255, p)
            end
        end
        return
    end

    -- Clock and penalty on the left, cones passed on the right, the next-cone call on a row of its own below.
    local dh, sh_ = text.height(font.display), text.height(font.hud_small)
    local w, h = 300 * s, 8 * s + dh + sh_ + 12 * s
    local x, y = cx - w / 2, sh * 0.05
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 200, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 255, 140, 40, 255, 0)
    local t = state == 2 and (f.elapsed or 0) or 0
    local clock = string.format("%.2f", t)
    text.draw(font.display, x + 14 * s, y + 6 * s, 245, 245, 250, 255, clock)
    local gates = string.format("%d/%d", math.floor(f.next_gate or 0), math.floor(f.gates or 0))
    local gw = text.width(font.display, gates)
    text.draw(font.display, x + w - 14 * s - gw, y + 6 * s, 220, 220, 232, 255, gates)
    local pen = f.penalty or 0
    if pen > 0 then
        local pstr = string.format("+%.0fs", pen)
        local px = x + 20 * s + text.width(font.display, clock)
        -- Sits in the gap between the clock and the cone count; drops under the clock if a long run fills it.
        if px + text.width(font.hud, pstr) > x + w - 22 * s - gw then
            text.draw(font.hud, x + w / 2 - text.width(font.hud, pstr) / 2, y + h - 8 * s - text.height(font.hud), 240, 90, 70, 255, pstr)
        else
            text.draw(font.hud, px, y + 6 * s + dh / 2 - text.height(font.hud) / 2, 240, 90, 70, 255, pstr)
        end
    end

    local side = math.floor(f.next_side or 0)
    local hint = state == 1 and "DRIVE TO THE FIRST CONE" or ""
    if side ~= 0 then
        local word = side < 0 and "LEFT" or "RIGHT"
        hint = (state == 1 and "FIRST CONE: KEEP " or "KEEP ") .. word
    end
    local ry = y + h - 8 * s - sh_
    text.draw(font.hud_small, x + 14 * s, ry, 255, 200, 90, 255, hint)
    text.draw(font.hud_tiny, x + w - 14 * s - text.width(font.hud_tiny, "CONES"), ry + sh_ - text.height(font.hud_tiny), 170, 170, 185, 220, "CONES")

    local age = f.flash_age or -1
    if age >= 0 then
        local fl = math.floor(f.flash or 0)
        local msgs = { "CONE HIT  +1", "WRONG SIDE  +2", "NICE" }
        local msg = msgs[fl] or ""
        local r, g, b = 240, 80, 70
        if fl == 3 then r, g, b = 120, 230, 120 end
        text.draw(font.display, cx - text.width(font.display, msg) / 2, y + h + 10 * s - 14 * s * age, r, g, b, math.floor(255 * (1 - age)), msg)
    end
end)
