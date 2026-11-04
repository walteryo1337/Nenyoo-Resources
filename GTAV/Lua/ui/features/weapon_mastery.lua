-- Weapon Mastery. Published fields: active (bool), armed (bool, holding a weapon), name (held weapon's name, may be
-- missing), kills (with the held weapon), tier (0 unranked .. 4 platinum) + tier_name, prev_at / next_at (kill counts
-- bounding the current tier; next_at missing once maxed), mastered (weapons at the top tier), tier_up_age + tier_up_tier.
local tier_colours = {
    [0] = { 150, 150, 160 }, { 205, 127, 50 }, { 200, 205, 215 }, { 255, 205, 60 }, { 150, 230, 255 },
}

features.on_draw("Weapon Mastery", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local tier = math.floor(f.tier or 0)
    local c = tier_colours[tier] or tier_colours[0]

    if f.armed then
        local pad = 10 * s
        local title = f.name or "WEAPON"
        local line = string.format("%s   %d KILLS", f.tier_name or "", math.floor(f.kills or 0))
        local w = math.max(text.width(font.small, title), text.width(font.tiny, line), 180 * s) + pad * 2
        local h = text.height(font.small) + text.height(font.tiny) + pad * 2 + 12 * s
        local x, y = 28 * s, sh * 0.62
        draw.rect(x, y, x + w, y + h, 10, 12, 18, 185, 6 * s)
        draw.rect(x, y, x + 3 * s, y + h, c[1], c[2], c[3], 255, 0)
        text.draw(font.small, x + pad, y + pad, 240, 240, 248, 255, title)
        text.draw(font.tiny, x + pad, y + pad + text.height(font.small) + 2 * s, c[1], c[2], c[3], 255, line)
        local by = y + h - pad - 4 * s
        draw.rect(x + pad, by, x + w - pad, by + 4 * s, 0, 0, 0, 150, 2 * s)
        local frac = 1
        if f.next_at then
            local lo, hi = f.prev_at or 0, f.next_at
            frac = math.max(0, math.min(1, ((f.kills or 0) - lo) / math.max(1, hi - lo)))
        end
        draw.rect(x + pad, by, x + pad + (w - pad * 2) * frac, by + 4 * s, c[1], c[2], c[3], 255, 2 * s)
    end

    local age = f.tier_up_age or 99
    if age < 3 then
        local tc = tier_colours[math.floor(f.tier_up_tier or 0)] or tier_colours[0]
        local a = math.floor(255 * math.min(1, (3 - age) * 1.5))
        local names = { "BRONZE", "SILVER", "GOLD", "PLATINUM" }
        local msg = (names[math.floor(f.tier_up_tier or 0)] or "") .. " MASTERY"
        local big = font.display or font.title
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.26, tc[1], tc[2], tc[3], a, msg)
    end
end)
