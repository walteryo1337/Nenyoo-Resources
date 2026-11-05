-- Car Limbo. Shown while you are within 300 m of the bar. Published fields: active (bool), over (bool, you hit the
-- bar), won (bool, you got under the lowest bar), bar (bar height in metres), clearance (gap between the bar and the
-- top of you or your car right now; negative means you would hit it), last_clear (gap on your last pass), passes
-- (clean passes this round), best (best round this session), flash (1..0 right after a pass), flash_good (that pass
-- was clean), distance (metres to the bar).
features.on_draw("Car Limbo", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 250 * s, 176 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 210, 12 * s)
    text.draw(font.hud_small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "CAR LIMBO")
    text.draw(font.hud_tiny, x0 + w - 14 * s - text.width(font.hud_tiny, string.format("%.0fm", f.distance or 0)), y0 + 12 * s,
        170, 170, 185, 230, string.format("%.0fm", f.distance or 0))

    text.draw(font.display, x0 + 14 * s, y0 + 36 * s, 255, 220, 90, 255, string.format("%.2fm", f.bar or 0))
    text.draw(font.hud_tiny, x0 + 14 * s, y0 + 80 * s, 190, 190, 205, 230, "BAR HEIGHT")

    local clear = f.clearance or 0
    local cr, cg, cb = 120, 255, 150
    if clear < 0 then cr, cg, cb = 255, 80, 80 elseif clear < 0.15 then cr, cg, cb = 255, 200, 80 end
    local cs = clear < 0 and string.format("%.0fcm TOO TALL", -clear * 100) or string.format("%.0fcm SPARE", clear * 100)
    text.draw(font.hud, x0 + 14 * s, y0 + 104 * s, cr, cg, cb, 255, cs)

    text.draw(font.hud_small, x0 + 14 * s, y0 + h - 34 * s, 245, 245, 250, 255, string.format("PASSES %d", math.floor(f.passes or 0)))
    local best = string.format("BEST %d", math.floor(f.best or 0))
    text.draw(font.hud_tiny, x0 + w - 14 * s - text.width(font.hud_tiny, best), y0 + h - 30 * s, 255, 220, 90, 230, best)

    local fl = f.flash or 0
    if fl > 0 and not f.over and not f.won then
        local msg = f.flash_good and string.format("CLEAN!  %.0fcm TO SPARE", (f.last_clear or 0) * 100) or "KNOCKED"
        local r, g, b = 130, 255, 160
        if not f.flash_good then r, g, b = 255, 90, 90 end
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, sh * 0.28 - 24 * s * (1 - fl), r, g, b, math.floor(255 * fl), msg)
    end
    if f.over then
        local msg = string.format("YOU HIT THE BAR  -  %d PASSES", math.floor(f.passes or 0))
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, sh * 0.28, 255, 90, 90, 255, msg)
        local sub = "THE BAR RESETS IN A MOMENT"
        text.draw(font.hud_tiny, sw / 2 - text.width(font.hud_tiny, sub) / 2, sh * 0.28 + 48 * s, 210, 210, 220, math.floor(170 + 60 * math.sin(t * 3)), sub)
    elseif f.won then
        local msg = "LIMBO LEGEND!"
        text.draw(font.display, sw / 2 - text.width(font.display, msg) / 2, sh * 0.28, 255, 220, 90, 255, msg)
    end
end)
