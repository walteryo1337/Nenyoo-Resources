-- Bull Rodeo. Shown while a ride is on. Published fields: active (bool), settling / riding / thrown (bool, ride
-- phase), ride (seconds on the bull this ride), best (best ride this session, seconds), tilt (-1..1, how far you are
-- leaning; past 1 you are thrown), buck (1..0 right after the bull bucks), qualified (made the eight seconds),
-- countdown (seconds until the gate opens, only while settling).
features.on_draw("Bull Rodeo", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx = sw / 2

    local ride = f.ride or 0
    local goal = 8.0
    local timer = string.format("%.2fs", ride)
    local tr, tg, tb = 245, 245, 250
    if f.qualified then tr, tg, tb = 255, 215, 90 end
    text.draw(font.title, cx - text.width(font.title, timer) / 2, 90 * s, tr, tg, tb, 255, timer)

    local bw, bh = 420 * s, 10 * s
    local bx, by = cx - bw / 2, 150 * s
    draw.rect(bx, by, bx + bw, by + bh, 30, 30, 40, 220, 5 * s)
    local k = math.min(1, ride / goal)
    if k > 0 then
        local r, g, b = 120, 200, 255
        if f.qualified then r, g, b = 255, 215, 90 end
        draw.rect(bx, by, bx + bw * k, by + bh, r, g, b, 255, 5 * s)
    end
    local lbl = f.qualified and "QUALIFIED RIDE!" or "HOLD ON FOR 8 SECONDS"
    text.draw(font.tiny, cx - text.width(font.tiny, lbl) / 2, by + 16 * s, 200, 200, 214, 230, lbl)

    local mw, mh = 360 * s, 26 * s
    local mx, my = cx - mw / 2, sh - 170 * s
    draw.rect(mx, my, mx + mw, my + mh, 14, 14, 20, 220, 13 * s)
    draw.rect(mx + mw * 0.35, my + 3 * s, mx + mw * 0.65, my + mh - 3 * s, 60, 140, 80, 200, 10 * s)
    draw.rect(mx + 3 * s, my + 3 * s, mx + mw * 0.12, my + mh - 3 * s, 150, 40, 40, 200, 10 * s)
    draw.rect(mx + mw * 0.88, my + 3 * s, mx + mw - 3 * s, my + mh - 3 * s, 150, 40, 40, 200, 10 * s)
    local tilt = math.max(-1, math.min(1, f.tilt or 0))
    local px = cx + tilt * (mw / 2 - 10 * s)
    local danger = math.abs(tilt)
    local pr, pg, pb = 240, 240, 250
    if danger > 0.75 then pr, pg, pb = 255, 90, 90 elseif danger > 0.45 then pr, pg, pb = 255, 200, 80 end
    draw.circle(px, my + mh / 2, 11 * s, pr, pg, pb, 255)
    text.draw(font.tiny, mx - 26 * s, my + 4 * s, 200, 200, 214, 230, "A")
    text.draw(font.tiny, mx + mw + 14 * s, my + 4 * s, 200, 200, 214, 230, "D")

    local buck = f.buck or 0
    if buck > 0 and f.riding then
        local msg = "BUCK!"
        draw.with_scale(cx, sh * 0.32, 1 + 0.4 * buck, function()
            text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.32, 255, 170, 60, math.floor(255 * buck), msg)
        end)
    end
    if f.settling then
        local msg = string.format("GATE OPENS IN %d", math.floor(f.countdown or 1))
        text.draw(font.item, cx - text.width(font.item, msg) / 2, sh * 0.32, 245, 245, 250, 255, msg)
    elseif f.thrown then
        local msg = f.qualified and string.format("WHAT A RIDE!  %.2fs", ride) or string.format("THROWN AT %.2fs", ride)
        local r, g, b = 255, 90, 90
        if f.qualified then r, g, b = 255, 215, 90 end
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.32, r, g, b, 255, msg)
        local sub = string.format("BEST %.2fs   -   ANOTHER BULL IN A MOMENT", f.best or 0)
        text.draw(font.tiny, cx - text.width(font.tiny, sub) / 2, sh * 0.32 + 48 * s, 210, 210, 220, math.floor(170 + 60 * math.sin(t * 3)), sub)
    end
end)
