-- Fragile Cargo. Published fields: active (bool), state (1 delivering, 2 result), cargo (name), explosive (bool),
-- condition (0..100), time_left (seconds), distance (metres to the drop-off), jolt (0..1 flash after a knock),
-- out_of_vehicle (bool), result (1 delivered, 2 ruined, 3 late, 4 abandoned), pay (current offer or final pay),
-- deliveries (completed this session).
features.on_draw("Fragile Cargo", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local cond = math.max(0, math.min(100, f.condition or 0))

    local jolt = f.jolt or 0
    if jolt > 0 then
        local a = math.floor(110 * jolt)
        local e = 90 * s
        draw.rect_gradient(0, 0, e, sh, 230, 50, 40, a, 230, 50, 40, 0, 230, 50, 40, 0, 230, 50, 40, a)
        draw.rect_gradient(sw - e, 0, sw, sh, 230, 50, 40, 0, 230, 50, 40, a, 230, 50, 40, a, 230, 50, 40, 0)
    end

    local w, h = 340 * s, 86 * s
    local x, y = cx - w / 2, sh * 0.05
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 200, 8 * s)
    local tr, tg, tb = ar, ag, ab
    if f.explosive then tr, tg, tb = 240, 140, 40 end
    draw.rect(x, y, x + w, y + 3 * s, tr, tg, tb, 255, 0)

    local name = string.upper(f.cargo or "")
    if f.explosive then name = name .. "  !" end
    text.draw(font.item, x + 14 * s, y + 10 * s, 245, 245, 250, 255, name)

    local r, g, b = 120, 230, 120
    if cond < 35 then r, g, b = 240, 80, 70 elseif cond < 70 then r, g, b = 245, 200, 70 end
    local pct = string.format("%d%%", math.floor(cond + 0.5))
    text.draw(font.item, x + w - 14 * s - text.width(font.item, pct), y + 10 * s, r, g, b, 255, pct)

    local bx1, by1 = x + 14 * s, y + 14 * s + text.height(font.item)
    local bx2, by2 = x + w - 14 * s, by1 + 8 * s
    draw.rect(bx1, by1, bx2, by2, 255, 255, 255, 30, 4 * s)
    if cond > 0 then draw.rect(bx1, by1, bx1 + (bx2 - bx1) * cond / 100, by2, r, g, b, 235, 4 * s) end

    local sub
    if state == 1 then
        local t = math.max(0, f.time_left or 0)
        sub = string.format("%d:%02d   %d M   $%d", math.floor(t / 60), math.floor(t % 60), math.floor(f.distance or 0), math.floor(f.pay or 0))
        if f.out_of_vehicle then sub = "GET BACK TO THE CARGO" end
    else
        local result = math.floor(f.result or 0)
        local msgs = { "DELIVERED", "RUINED", "TOO LATE", "ABANDONED" }
        sub = msgs[result] or ""
        if result == 1 then sub = string.format("%s  +$%d", sub, math.floor(f.pay or 0)) end
    end
    local sr, sg, sb = 215, 215, 228
    if f.out_of_vehicle and state == 1 then sr, sg, sb = 245, 120, 90 end
    text.draw(font.small, x + 14 * s, by2 + 6 * s, sr, sg, sb, 240, sub)
    local done = math.floor(f.deliveries or 0)
    if done > 0 then
        local dstr = string.format("x%d", done)
        text.draw(font.small, x + w - 14 * s - text.width(font.small, dstr), by2 + 6 * s, 190, 190, 205, 220, dstr)
    end
end)
