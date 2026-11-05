-- Busking. Published fields: active (bool), act (0 music, 1 dance, 2 muscle show, 3 living statue), act_name, hype (0-1),
-- crowd (people watching now), total (cash made this show), combo (hits in a row), beat / window_lo / window_hi (0-1
-- progress through the current beat and the window where E counts; absent for the statue), judge (1 perfect, 2 good,
-- 3 miss, 4 skipped beat, 5 scared someone, 6 broke character) + judge_age (ms), last_tip (cash) + tip_age (ms),
-- scare_window (bool, statue: someone is right in your face, press E now), seconds (show length).
local judgments = {
    { "PERFECT", 120, 240, 120 }, { "GOOD", 120, 200, 255 }, { "MISS", 255, 90, 90 },
    { "OFF BEAT", 255, 160, 80 }, { "GOTCHA!", 255, 220, 80 }, { "YOU FLINCHED", 255, 90, 90 },
}

features.on_draw("Busking", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local acc = { theme.accent() }
    local pw, ph = 360 * s, 96 * s
    local px, py = sw / 2 - pw / 2, sh - 210 * s
    draw.rect(px, py, px + pw, py + ph, 12, 12, 16, 215, 10 * s)
    draw.rect(px, py, px + 4 * s, py + ph, acc[1] or 255, acc[2] or 255, acc[3] or 255, 255, 2 * s)

    local title = string.upper(f.act_name or "Busking")
    text.draw(font.hud, px + 16 * s, py + 10 * s, 245, 245, 250, 255, title)
    local cash = string.format("$%d", math.floor(f.total or 0))
    text.draw(font.hud, px + pw - 16 * s - text.width(font.hud, cash), py + 10 * s, 120, 230, 120, 255, cash)

    local hype = f.hype or 0
    local bx1, by1, bx2 = px + 16 * s, py + 44 * s, px + pw - 16 * s
    draw.rect(bx1, by1, bx2, by1 + 10 * s, 40, 40, 48, 255, 5 * s)
    if hype > 0 then
        draw.rect_gradient(bx1, by1, bx1 + (bx2 - bx1) * hype, by1 + 10 * s,
            255, 120, 60, 255, 255, 220, 80, 255, 255, 220, 80, 255, 255, 120, 60, 255)
    end
    local crowd = math.floor(f.crowd or 0)
    local info = string.format("HYPE %d%%   CROWD %d", math.floor(hype * 100 + 0.5), crowd)
    local combo = math.floor(f.combo or 0)
    if combo >= 2 then info = info .. string.format("   COMBO x%d", combo) end
    text.draw(font.hud_small, bx1, py + 62 * s, 200, 200, 210, 255, info)

    local cx, cy = sw / 2, py - 70 * s
    if f.beat then
        local target = 26 * s
        local lo, hi = f.window_lo or 0.8, f.window_hi or 0.97
        local mid = (lo + hi) / 2
        local r = target + (mid - f.beat) * 140 * s
        if r < 6 * s then r = 6 * s end
        local inside = f.beat >= lo and f.beat <= hi
        if inside then draw.circle(cx, cy, target, 120, 240, 120, 90) end
        draw.circle_outline(cx, cy, target, 245, 245, 250, 255, 3 * s)
        draw.circle_outline(cx, cy, r, acc[1] or 255, acc[2] or 200, acc[3] or 80, 230, 3 * s)
        text.draw(font.hud, cx - text.width(font.hud, "E") / 2, cy - text.height(font.hud) / 2, 245, 245, 250, 255, "E")
    else
        local msg, cr, cg, cb = "HOLD STILL", 220, 220, 232
        if f.scare_window then
            msg, cr, cg, cb = "PRESS E - SCARE THEM!", 255, 220, 80
            local pulse = 1 + 0.08 * math.sin(t * 20)
            local w = text.width(font.display, msg) * pulse
            draw.rect(cx - w / 2 - 14 * s, cy - 24 * s, cx + w / 2 + 14 * s, cy + 24 * s, 12, 12, 16, 220, 8 * s)
            text.draw(font.display, cx - text.width(font.display, msg) / 2, cy - text.height(font.display) / 2, cr, cg, cb, 255, msg)
        else
            text.draw(font.hud, cx - text.width(font.hud, msg) / 2, cy - text.height(font.hud) / 2, cr, cg, cb, 200, msg)
        end
    end

    local j = math.floor(f.judge or 0)
    local jage = f.judge_age or 99999
    if judgments[j] and jage < 700 then
        local jd = judgments[j]
        local a = math.floor(255 * (1 - jage / 700))
        local w = text.width(font.display, jd[1])
        text.draw(font.display, cx - w / 2, cy - 74 * s - jage / 700 * 20 * s, jd[2], jd[3], jd[4], a, jd[1])
    end

    local tage = f.tip_age or 99999
    if f.last_tip and tage < 1500 then
        local a = math.floor(255 * (1 - tage / 1500))
        local msg = string.format("+$%d", math.floor(f.last_tip))
        text.draw(font.hud, px + pw - 16 * s - text.width(font.hud, msg), py - 30 * s - tage / 1500 * 30 * s, 120, 230, 120, a, msg)
    end
end)
