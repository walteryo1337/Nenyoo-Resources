-- Gun Game. Published fields: active (bool), level (0-based rung you are on), levels (rungs in the ladder),
-- kills, seconds (since the game started), weapon / next (display names of the current and next weapon; absent
-- until the weapon list has loaded). Drawn as a banner at the top centre with a ladder of progress pips.
features.on_draw("Gun Game", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local levels = math.floor(f.levels or 10)
    local level = math.floor(f.level or 0)
    local w, h = 460 * s, 96 * s
    local x0, y0 = sw / 2 - w / 2, 40 * s
    local ar, ag, ab = theme.accent()

    draw.rect(x0, y0, x0 + w, y0 + h, 10, 10, 16, 215, 12 * s)
    local title = string.format("GUN GAME   %d / %d", math.min(level + 1, levels), levels)
    text.draw(font.small, x0 + 16 * s, y0 + 10 * s, 235, 235, 245, 255, title)
    local secs = math.floor(f.seconds or 0)
    local clock = string.format("%d:%02d", math.floor(secs / 60), secs % 60)
    text.draw(font.small, x0 + w - 16 * s - text.width(font.small, clock), y0 + 10 * s, 200, 200, 214, 230, clock)

    local weapon = f.weapon or (level == levels - 1 and "Knife" or string.format("Weapon %d", level + 1))
    local final = level == levels - 1
    local wr, wg, wb = 255, 255, 255
    if final then wr, wg, wb = 255, 200, 60 end
    text.draw(font.item, x0 + 16 * s, y0 + 36 * s, wr, wg, wb, 255, final and (weapon .. "  -  FINAL KILL") or weapon)
    if f.next and not final then
        local nxt = "NEXT: " .. f.next
        text.draw(font.tiny, x0 + w - 16 * s - text.width(font.tiny, nxt), y0 + 42 * s, 190, 190, 205, 220, nxt)
    end

    local pip_w = (w - 32 * s) / levels
    for i = 0, levels - 1 do
        local px = x0 + 16 * s + i * pip_w
        local r, g, b, a = 70, 70, 85, 255
        if i < level then r, g, b = ar or 90, ag or 200, ab or 255
        elseif i == level then r, g, b = 255, 255, 255 end
        draw.rect(px + 2 * s, y0 + h - 18 * s, px + pip_w - 2 * s, y0 + h - 10 * s, r, g, b, a, 3 * s)
    end
end)
