-- Freerun Score. Published fields: active (bool), total (banked points), pending (points in the running
-- combo), mult (1..10), combo_left (0..1 of the window to land another trick), trick (last trick: 1 jump,
-- 2 climb, 3 vault, 4 air time, 5 big drop), trick_points, trick_age (seconds since it), best (best
-- combo), result + result_age (0..1) + bailed (true if the last combo ended in a fall and scored nothing).
local NAMES = { "JUMP", "CLIMB", "VAULT", "AIR TIME", "BIG DROP" }

local function commas(n)
    local s = tostring(math.floor(n))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return out
end

features.on_draw("Freerun Score", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local y = sh * 0.14

    local pending = math.floor(f.pending or 0)
    local mult = math.floor(f.mult or 1)
    if pending > 0 then
        local value = commas(pending)
        local vw = text.width(big, value)
        text.draw(big, cx - vw / 2, y, 245, 245, 250, 255, value)
        local tag = string.format("x%d", mult)
        text.draw(font.item, cx + vw / 2 + 8 * s, y + text.height(big) * 0.2, ar, ag, ab, 255, tag)
        y = y + text.height(big) + 4 * s

        local bw = 140 * s
        local left = math.max(0, math.min(1, f.combo_left or 0))
        draw.rect(cx - bw / 2, y, cx + bw / 2, y + 3 * s, 0, 0, 0, 150, 0)
        draw.rect(cx - bw / 2, y, cx - bw / 2 + bw * left, y + 3 * s, ar, ag, ab, 255, 0)
        y = y + 8 * s

        local age = f.trick_age or 99
        local name = NAMES[math.floor(f.trick or 0)]
        if name and age < 1.2 then
            local a = math.floor(255 * (1 - age / 1.2))
            local msg = string.format("%s +%d", name, math.floor(f.trick_points or 0))
            text.draw(font.small, cx - text.width(font.small, msg) / 2, y + age * 10 * s, 255, 210, 90, a, msg)
        end
    else
        local rage = f.result_age or 1
        if rage < 1 and (f.result or 0) > 0 then
            local a = math.floor(255 * math.min(1, (1 - rage) * 2))
            local msg = f.bailed and ("BAILED  -" .. commas(f.result)) or ("+" .. commas(f.result))
            local r, g, b = 120, 230, 120
            if f.bailed then r, g, b = 240, 80, 70 end
            text.draw(big, cx - text.width(big, msg) / 2, y, r, g, b, a, msg)
            y = y + text.height(big) + 4 * s
        end
    end

    local foot = string.format("FREERUN %s   BEST %s", commas(f.total or 0), commas(f.best or 0))
    text.draw(font.tiny, cx - text.width(font.tiny, foot) / 2, sh * 0.14 - text.height(font.tiny) - 4 * s, 180, 180, 195, 210, foot)
end)
