-- Trampoline. Shown while you are near it. Published fields: active (bool), on_pad (bool), airborne (bool), height
-- (metres above the bed right now), best (highest bounce this session), spins (full turns so far this jump),
-- last_score / last_spins (the jump you just landed), pop (1..0 right after a landing), total (session score),
-- combo (bounces in a row, multiplies the score up to x5).
features.on_draw("Trampoline", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0

    local w, h = 220 * s, 250 * s
    local x0, y0 = 30 * s, sh * 0.5 - h / 2
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 210, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "TRAMPOLINE")

    local mx0, my0, mw, mh = x0 + 16 * s, y0 + 40 * s, 18 * s, h - 60 * s
    draw.rect(mx0, my0, mx0 + mw, my0 + mh, 40, 40, 52, 255, 6 * s)
    local scale = math.max(20, (f.best or 0) * 1.2)
    local hk = math.max(0, math.min(1, (f.height or 0) / scale))
    draw.rect(mx0, my0 + mh * (1 - hk), mx0 + mw, my0 + mh, 80, 160, 255, 255, 6 * s)
    local bk = math.max(0, math.min(1, (f.best or 0) / scale))
    if bk > 0 then
        local by = my0 + mh * (1 - bk)
        draw.rect(mx0 - 4 * s, by - 1.5 * s, mx0 + mw + 4 * s, by + 1.5 * s, 255, 220, 90, 255, 0)
    end

    local tx = mx0 + mw + 16 * s
    text.draw(font.title, tx, y0 + 40 * s, 245, 245, 250, 255, string.format("%.1fm", math.max(0, f.height or 0)))
    text.draw(font.tiny, tx, y0 + 84 * s, 255, 220, 90, 230, string.format("BEST %.1fm", f.best or 0))
    local spins = math.floor(f.spins or 0)
    if f.airborne and spins > 0 then
        text.draw(font.item, tx, y0 + 108 * s, 170, 210, 255, 255, string.format("%d SPIN%s", spins, spins == 1 and "" or "S"))
    end
    local combo = math.floor(f.combo or 0)
    if combo > 1 then
        text.draw(font.small, tx, y0 + 140 * s, 255, 160, 80, 255, string.format("x%d COMBO", math.min(combo, 5)))
    end
    text.draw(font.tiny, tx, y0 + h - 40 * s, 190, 190, 205, 230, string.format("SCORE %d", math.floor(f.total or 0)))

    local pop = f.pop or 0
    if pop > 0 then
        local msg = string.format("+%d", math.floor(f.last_score or 0))
        local ls = math.floor(f.last_spins or 0)
        if ls > 0 then msg = msg .. string.format("  (%d SPIN%s)", ls, ls == 1 and "" or "S") end
        text.draw(font.title, sw / 2 - text.width(font.title, msg) / 2, sh * 0.3 - 30 * s * (1 - pop), 130, 255, 160, math.floor(255 * pop), msg)
    end
    if f.on_pad and not f.airborne then
        local hint = "SPACE  BOUNCE   -   HOLD SPACE ON LANDING TO GO HIGHER   -   A / D  SPIN"
        text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, sh - 120 * s, 200, 200, 214, math.floor(160 + 60 * math.sin(t * 2)), hint)
    end
end)
