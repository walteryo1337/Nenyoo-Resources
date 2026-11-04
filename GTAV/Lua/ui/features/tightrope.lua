-- Tightrope Walk. Published fields: active (bool), state (1 get ready, 2 walking, 3 made it, 4 fell), progress (0..1
-- along the rope), tilt (-1..1; at either end you fall), wind (-1..1, which way the wind is pushing), countdown,
-- height (metres above the ground).
features.on_draw("Tightrope Walk", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local state = math.floor(f.state or 1)

    local w, h = 360 * s, 120 * s
    local x0, y0 = sw / 2 - w / 2, sh - h - 110 * s
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 18, 215, 12 * s)
    text.draw(font.small, x0 + 14 * s, y0 + 8 * s, 235, 235, 245, 255, "TIGHTROPE")
    local ht = string.format("%dm UP", math.floor(f.height or 0))
    text.draw(font.tiny, x0 + w - 14 * s - text.width(font.tiny, ht), y0 + 12 * s, 190, 190, 205, 230, ht)

    local tilt = math.max(-1, math.min(1, f.tilt or 0))
    local danger = math.abs(tilt)
    local bx, by, bw, bh = x0 + 14 * s, y0 + 40 * s, w - 28 * s, 14 * s
    draw.rect(bx, by, bx + bw, by + bh, 40, 40, 52, 255, 7 * s)
    draw.rect(bx + bw * 0.35, by, bx + bw * 0.65, by + bh, 60, 120, 70, 255, 7 * s)
    local cx = bx + bw / 2
    local nx = cx + tilt * bw / 2
    local r, g, b = 130, 255, 160
    if danger > 0.7 then r, g, b = 255, 90, 80 elseif danger > 0.35 then r, g, b = 255, 210, 90 end
    draw.rect(nx - 4 * s, by - 5 * s, nx + 4 * s, by + bh + 5 * s, r, g, b, 255, 3 * s)
    draw.line(cx, by - 4 * s, cx, by + bh + 4 * s, 235, 235, 245, 160, 1)

    local wind = math.max(-1, math.min(1, f.wind or 0))
    if math.abs(wind) > 0.1 then
        local arrow = wind > 0 and "WIND  >>" or "<<  WIND"
        if math.abs(wind) < 0.5 then arrow = wind > 0 and "WIND  >" or "<  WIND" end
        local aw = text.width(font.tiny, arrow)
        local a = math.floor(140 + 100 * math.abs(wind))
        text.draw(font.tiny, cx - aw / 2, by + bh + 8 * s, 170, 210, 255, a, arrow)
    end

    local px, py, pw = x0 + 14 * s, y0 + h - 22 * s, w - 28 * s
    draw.rect(px, py, px + pw, py + 6 * s, 40, 40, 52, 255, 3 * s)
    draw.rect(px, py, px + pw * math.max(0, math.min(1, f.progress or 0)), py + 6 * s, 205, 175, 125, 255, 3 * s)

    local banner, br, bg, bb
    if state == 1 then
        banner, br, bg, bb = string.format("GET READY  %d", math.floor(f.countdown or 0)), 255, 230, 120
    elseif state == 3 then
        banner, br, bg, bb = "MADE IT ACROSS!", 130, 255, 160
    elseif state == 4 then
        banner, br, bg, bb = "YOU FELL", 255, 110, 110
    end
    if banner then
        text.draw(font.title, sw / 2 - text.width(font.title, banner) / 2, y0 - 60 * s, br, bg, bb, 255, banner)
    elseif state == 2 then
        local hint = "W  WALK     A / D  BALANCE"
        text.draw(font.tiny, sw / 2 - text.width(font.tiny, hint) / 2, y0 - 22 * s, 200, 200, 214, math.floor(160 + 60 * math.sin(t * 2)), hint)
    end
    if danger > 0.75 and state == 2 then
        draw.rect_outline(0, 0, sw, sh, 255, 70, 60, math.floor(120 * (danger - 0.75) / 0.25), 0, 10 * s)
    end
end)
