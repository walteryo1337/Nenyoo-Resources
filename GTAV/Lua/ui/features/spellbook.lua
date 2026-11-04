-- Spellbook. Published fields: active (bool, fists up with the spell bar on), spell (0-based selected spell),
-- count (number of spells), name1..nameN (spell names), cost1..costN (mana per cast; Life Drain is per second),
-- mana (0..1), unlimited (bool), flash (1..0 right after a successful cast), fail (1..0 right after a failed
-- cast), draining (bool, Life Drain is channelling), frozen (people currently frozen), pack_left (seconds the
-- spirit pack has left, 0 = none), thralls (people under Mind Control), wall_left (seconds the Stone Wall
-- has left, 0 = none).
local COLOURS = {
    { 200, 120, 255 },
    { 120, 210, 255 },
    { 255, 220, 120 },
    { 235, 60, 80 },
    { 140, 255, 200 },
    { 255, 245, 170 },
    { 255, 120, 220 },
    { 190, 160, 120 },
    { 160, 80, 200 },
    { 230, 230, 240 },
}

features.on_draw("Spellbook", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local t = ctx.time() or 0
    local count = math.floor(f.count or 6)
    local sel = math.floor(f.spell or 0)
    local mana = f.mana or 0

    local slot_w, slot_h, gap = 112 * s, 58 * s, 6 * s
    local total = count * slot_w + (count - 1) * gap
    local x0 = sw / 2 - total / 2
    local y0 = sh - 150 * s

    for i = 0, count - 1 do
        local x = x0 + i * (slot_w + gap)
        local c = COLOURS[(i % #COLOURS) + 1]
        local chosen = i == sel
        local cost = f["cost" .. (i + 1)] or 0
        local affordable = f.unlimited or (i == 3 and mana > 0.03) or mana * 100 >= cost
        local bg = chosen and 34 or 16
        draw.rect(x, y0, x + slot_w, y0 + slot_h, bg, bg, bg + 10, chosen and 235 or 190, 8 * s)
        if chosen then
            local glow = 0.6 + 0.4 * math.abs(math.sin(t * 3))
            if f.flash and f.flash > 0 then glow = 1 end
            draw.rect_outline(x, y0, x + slot_w, y0 + slot_h, c[1], c[2], c[3], math.floor(255 * glow), 8 * s, 2 * s)
            if f.fail and f.fail > 0 then
                draw.rect_outline(x - 2 * s, y0 - 2 * s, x + slot_w + 2 * s, y0 + slot_h + 2 * s, 235, 60, 60, math.floor(255 * f.fail), 9 * s, 2 * s)
            end
        end
        draw.circle(x + 16 * s, y0 + slot_h / 2, 7 * s, c[1], c[2], c[3], affordable and 255 or 90)
        local name = f["name" .. (i + 1)] or ("Spell " .. (i + 1))
        local a = affordable and 255 or 120
        text.draw(font.tiny, x + 30 * s, y0 + 10 * s, 240, 240, 248, a, name)
        local cost_s = i == 3 and string.format("%d / s", math.floor(cost)) or tostring(math.floor(cost))
        text.draw(font.tiny, x + 30 * s, y0 + 32 * s, 140, 190, 255, a, cost_s .. " MANA")
    end

    local by = y0 + slot_h + 12 * s
    draw.rect(x0, by, x0 + total, by + 12 * s, 20, 20, 32, 220, 6 * s)
    local fill = math.max(0, math.min(1, mana))
    if fill > 0 then
        draw.rect_gradient(x0, by, x0 + total * fill, by + 12 * s, 60, 120, 255, 255, 140, 90, 255, 255, 140, 90, 255, 255, 60, 120, 255, 255)
    end
    local label = f.unlimited and "MANA  UNLIMITED" or string.format("MANA  %d", math.floor(mana * 100 + 0.5))
    text.draw(font.tiny, x0, by + 16 * s, 200, 210, 240, 230, label)

    local status = {}
    if f.draining then status[#status + 1] = "DRAINING" end
    local frozen = math.floor(f.frozen or 0)
    if frozen > 0 then status[#status + 1] = string.format("%d FROZEN", frozen) end
    local pack = math.floor(f.pack_left or 0)
    if pack > 0 then status[#status + 1] = string.format("PACK %ds", pack) end
    local thralls = math.floor(f.thralls or 0)
    if thralls > 0 then status[#status + 1] = string.format("%d CONTROLLED", thralls) end
    local wall = math.floor(f.wall_left or 0)
    if wall > 0 then status[#status + 1] = string.format("WALL %ds", wall) end
    local hint = "AIM + CLICK  CAST    SCROLL  SWITCH"
    if #status > 0 then hint = table.concat(status, "   ") .. "      " .. hint end
    text.draw(font.tiny, x0 + total - text.width(font.tiny, hint), by + 16 * s, 200, 200, 214, 220, hint)
end)
