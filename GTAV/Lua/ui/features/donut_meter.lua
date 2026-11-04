-- Donut Meter. Published fields: active (bool, in a land vehicle), spinning (bool, a donut chain is live), progress (0-1
-- of the current 360), combo (full donuts in this chain), best (longest chain this session), total (donuts this session),
-- dir (1 left, -1 right, 0 none), result (present for a few seconds after a chain ends: its length), new_best (bool).
features.on_draw("Donut Meter", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx, cy = sw / 2, sh * 0.2
    local r = 48 * s

    if f.spinning then
        draw.circle(cx, cy, r + 10 * s, 12, 12, 16, 200)
        draw.circle_outline(cx, cy, r, 50, 50, 60, 255, 8 * s)
        local p = math.max(0, math.min(1, f.progress or 0))
        local segs = math.floor(48 * p)
        local dir = (f.dir or 1) >= 0 and -1 or 1
        for i = 0, segs - 1 do
            local a1 = -math.pi / 2 + dir * (i / 48) * 2 * math.pi
            local a2 = -math.pi / 2 + dir * ((i + 1) / 48) * 2 * math.pi
            draw.line(cx + math.cos(a1) * r, cy + math.sin(a1) * r, cx + math.cos(a2) * r, cy + math.sin(a2) * r, ar, ag, ab, 255, 8 * s)
        end
        local n = tostring(math.floor(f.combo or 0))
        local big = font.display or font.title
        text.draw(big, cx - text.width(big, n) / 2, cy - text.height(big) / 2, 245, 245, 250, 255, n)
        local lbl = "DONUTS"
        text.draw(font.tiny, cx - text.width(font.tiny, lbl) / 2, cy + r + 14 * s, 200, 200, 214, 230, lbl)
    elseif f.result then
        local n = math.floor(f.result)
        local msg = string.format("%d DONUT%s", n, n == 1 and "" or "S")
        local r2, g2, b2 = 245, 245, 250
        if f.new_best then msg = msg .. "  NEW BEST"; r2, g2, b2 = 255, 205, 60 end
        text.draw(font.title, cx - text.width(font.title, msg) / 2, cy - text.height(font.title) / 2, r2, g2, b2, 255, msg)
    end

    if (f.total or 0) > 0 then
        local st = string.format("BEST %d   TOTAL %d", math.floor(f.best or 0), math.floor(f.total or 0))
        text.draw(font.tiny, sw - 30 * s - text.width(font.tiny, st), sh * 0.92, 190, 190, 205, 220, st)
    end
end)
