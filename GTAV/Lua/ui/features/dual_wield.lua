-- Dual Wield. Shown while you hold two guns. Published fields: active (bool); hud (bool, the Ammo Display option);
-- left / right (rounds left in each gun); clip (a full gun); reserve (spare rounds); reloading (bool); empty (bool,
-- both guns are out).
features.on_draw("Dual Wield", function(f)
    if not f.active or not f.hud then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local clip = math.max(1, f.clip or 1)
    local bw, bh, gap = 10 * s, 64 * s, 46 * s
    local right_edge = sw - 48 * s
    local top = 118 * s

    local function bar(x, n)
        local k = math.max(0, math.min(1, n / clip))
        local r, g = 153, 153
        if k < 0.25 then g = math.floor(153 * k * 4) else r = math.floor(153 * (1 - k) * 4 / 3) end
        draw.rect(x, top, x + bw, top + bh, 0, 0, 0, 150, 3 * s)
        local fill = bh * k
        if fill > 0 then draw.rect(x, top + bh - fill, x + bw, top + bh, r + 60, g + 60, 40, 235, 3 * s) end
        local label = string.format("%d", math.floor(n))
        text.draw(font.small, x + bw / 2 - text.width(font.small, label) / 2, top + bh + 6 * s, 240, 240, 245, 245, label)
    end

    local xr = right_edge - bw
    local xl = xr - gap
    bar(xl, f.left or 0)
    bar(xr, f.right or 0)
    local spare = string.format("%d", math.floor(f.reserve or 0))
    text.draw(font.tiny, right_edge - text.width(font.tiny, spare), top - 22 * s, 190, 190, 200, 220, spare)

    local msg
    if f.reloading then msg = "RELOADING"
    elseif f.empty and (math.floor((ctx.time() or 0) * 1.4) % 2 == 0) then msg = "RELOAD" end
    if msg then
        local w = text.width(font.tiny, msg)
        text.draw(font.tiny, (xl + right_edge) / 2 - w / 2, top + bh + 34 * s, 255, 200, 90, 240, msg)
    end
end)
