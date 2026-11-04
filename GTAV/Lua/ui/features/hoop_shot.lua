-- Hoop Shot. Shown during a round and on the results screen. Published fields: active (bool), over (bool, the
-- buzzer has gone), score, best (best round this session), streak (makes in a row; three or more add a bonus point),
-- makes / shots, time_left (seconds), power (0..1 shot power while charging), charging (bool), three (bool, you are
-- behind the three-point line), distance (metres to the hoop). pop / pop_points / pop_k are only set right after a
-- shot: pop is 1 miss, 2 score, 3 bank shot, 4 swish; pop_k fades 1..0.
features.on_draw("Hoop Shot", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local cx = sw / 2

    local pw, ph = 300 * s, 70 * s
    local px, py = cx - pw / 2, 40 * s
    draw.rect(px, py, px + pw, py + ph, 12, 12, 18, 215, 12 * s)
    local score = string.format("%d", math.floor(f.score or 0))
    text.draw(font.title, px + 18 * s, py + 12 * s, 255, 160, 60, 255, score)
    text.draw(font.tiny, px + 18 * s + text.width(font.title, score) + 8 * s, py + 30 * s, 190, 190, 205, 230, "PTS")
    local tl = f.time_left or 0
    local clock = string.format("%d", math.ceil(tl))
    local cr, cg, cb = 245, 245, 250
    if tl <= 10 and not f.over then cr, cg, cb = 255, 80, 80 end
    text.draw(font.title, px + pw - 18 * s - text.width(font.title, clock), py + 12 * s, cr, cg, cb, 255, clock)
    local acc = string.format("%d / %d", math.floor(f.makes or 0), math.floor(f.shots or 0))
    text.draw(font.tiny, cx - text.width(font.tiny, acc) / 2, py + ph - 24 * s, 190, 190, 205, 230, acc)

    local streak = math.floor(f.streak or 0)
    if streak >= 3 and not f.over then
        local msg = string.format("ON FIRE  x%d", streak)
        text.draw(font.small, cx - text.width(font.small, msg) / 2, py + ph + 10 * s, 255, 120 + math.floor(60 * math.sin(t * 8)), 40, 255, msg)
    end

    if not f.over then
        local zone = f.three and "3PT RANGE" or "2PT RANGE"
        local zr, zg, zb = 170, 210, 255
        if f.three then zr, zg, zb = 255, 215, 90 end
        local line = string.format("%s   %.1fm", zone, f.distance or 0)
        text.draw(font.tiny, cx - text.width(font.tiny, line) / 2, sh - 130 * s, zr, zg, zb, 230, line)

        local mw, mh = 26 * s, 180 * s
        local mx, my = sw * 0.5 + 140 * s, sh * 0.5 - mh / 2
        draw.rect(mx, my, mx + mw, my + mh, 14, 14, 20, 210, 8 * s)
        draw.rect(mx + 2 * s, my + mh * 0.25, mx + mw - 2 * s, my + mh * 0.45, 60, 140, 80, 120, 4 * s)
        local p = math.max(0, math.min(1, f.power or 0))
        if f.charging and p > 0 then
            local r, g, b = 120, 220, 140
            if p > 0.8 then r, g, b = 255, 90, 80 elseif p > 0.55 then r, g, b = 255, 200, 80 end
            draw.rect(mx + 3 * s, my + mh * (1 - p), mx + mw - 3 * s, my + mh - 3 * s, r, g, b, 255, 6 * s)
        end
        if not f.charging then
            local hint = "HOLD LEFT CLICK TO CHARGE  -  RELEASE TO SHOOT"
            text.draw(font.tiny, cx - text.width(font.tiny, hint) / 2, sh - 100 * s, 200, 200, 214, math.floor(150 + 60 * math.sin(t * 2)), hint)
        end
    end

    local pk = f.pop_k or 0
    if pk > 0 then
        local kind = math.floor(f.pop or 0)
        local pts = math.floor(f.pop_points or 0)
        local msg, r, g, b = "BRICK", 255, 90, 90
        if kind == 2 then msg, r, g, b = string.format("BUCKET!  +%d", pts), 130, 255, 160
        elseif kind == 3 then msg, r, g, b = string.format("OFF THE GLASS!  +%d", pts), 170, 210, 255
        elseif kind == 4 then msg, r, g, b = string.format("SWISH!  +%d", pts), 255, 215, 90 end
        draw.with_scale(cx, sh * 0.3, 1 + 0.3 * pk, function()
            text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, r, g, b, math.floor(255 * pk), msg)
        end)
    end

    if f.over then
        local msg = string.format("BUZZER!  %d POINTS", math.floor(f.score or 0))
        text.draw(font.title, cx - text.width(font.title, msg) / 2, sh * 0.3, 255, 215, 90, 255, msg)
        local sub = string.format("BEST %d   -   NEW ROUND IN A MOMENT", math.floor(f.best or 0))
        text.draw(font.tiny, cx - text.width(font.tiny, sub) / 2, sh * 0.3 + 48 * s, 210, 210, 220, math.floor(170 + 60 * math.sin(t * 3)), sub)
    end
end)
