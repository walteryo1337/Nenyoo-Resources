-- Scavenger Hunt. Published fields: active (bool), state (1 hunting, 2 result), time_left (seconds), item1..item5 (what to
-- photograph), found1..found5 (bool), framed (1..5 = that item is in frame right now, 0 = nothing), flash (0..1 camera
-- flash after a photo), pay.
features.on_draw("Scavenger Hunt", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local state = math.floor(f.state or 0)
    local framed = math.floor(f.framed or 0)

    local flash = f.flash or 0
    if flash > 0 then draw.rect(0, 0, sw, sh, 255, 255, 255, math.floor(200 * flash), 0) end

    if state == 1 then
        local cx, cy = sw / 2, sh / 2
        local hx, hy = sw * 0.14, sh * 0.14
        local len = 26 * s
        local r, g, b, a = 255, 255, 255, 120
        if framed > 0 then r, g, b, a = ar, ag, ab, 255 end
        local t = 3 * s
        for _, c in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
            local x, y = cx + c[1] * hx, cy + c[2] * hy
            draw.line(x, y, x - c[1] * len, y, r, g, b, a, t)
            draw.line(x, y, x, y - c[2] * len, r, g, b, a, t)
        end
    end

    local items, found = {}, {}
    for i = 1, 5 do
        items[i] = f["item" .. i] or ""
        found[i] = f["found" .. i] and true or false
    end
    local lh = text.height(font.hud_small) + 6 * s
    local w = 280 * s
    local h = 44 * s + 5 * lh
    local x, y = 30 * s, sh * 0.3
    draw.rect(x, y, x + w, y + h, 245, 240, 225, 235, 4 * s)
    local head = "SCAVENGER HUNT"
    text.draw(font.hud_small, x + 12 * s, y + 10 * s, 60, 50, 40, 255, head)
    if state == 1 then
        local tl = math.max(0, f.time_left or 0)
        local clock = string.format("%d:%02d", math.floor(tl / 60), math.floor(tl % 60))
        local cr, cg, cb = 60, 50, 40
        if tl < 60 then cr, cg, cb = 190, 40, 40 end
        text.draw(font.hud_small, x + w - 12 * s - text.width(font.hud_small, clock), y + 10 * s, cr, cg, cb, 255, clock)
    end
    for i = 1, 5 do
        local ry = y + 38 * s + (i - 1) * lh
        local bx = x + 14 * s
        draw.rect(bx, ry + 2 * s, bx + 14 * s, ry + 16 * s, 60, 50, 40, 255, 2 * s)
        draw.rect(bx + 2 * s, ry + 4 * s, bx + 12 * s, ry + 14 * s, 245, 240, 225, 255, 1 * s)
        local r, g, b = 50, 45, 40
        if framed == i then r, g, b = ar, ag, ab end
        if found[i] then
            draw.line(bx + 3 * s, ry + 9 * s, bx + 6 * s, ry + 13 * s, 40, 140, 60, 255, 3 * s)
            draw.line(bx + 6 * s, ry + 13 * s, bx + 12 * s, ry + 3 * s, 40, 140, 60, 255, 3 * s)
            r, g, b = 140, 135, 125
        end
        local label = items[i]
        text.draw(font.hud_small, bx + 22 * s, ry, r, g, b, 255, label)
        if found[i] then
            local lw = text.width(font.hud_small, label)
            draw.line(bx + 22 * s, ry + text.height(font.hud_small) / 2, bx + 22 * s + lw, ry + text.height(font.hud_small) / 2, 140, 135, 125, 255, 2 * s)
        end
    end

    if state == 2 then
        local n = 0
        for i = 1, 5 do if found[i] then n = n + 1 end end
        local msg = n == 5 and "HUNT COMPLETE" or string.format("%d OF 5 FOUND", n)
        if (f.pay or 0) > 0 then msg = msg .. string.format("  +$%d", math.floor(f.pay)) end
        text.draw(font.hud, x, y + h + 8 * s, 245, 245, 250, 255, msg)
    end
end)
