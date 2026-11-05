-- Carnage Score. Published fields: active (bool, driving with the feature on), score, best, combo (0 when
-- no combo is running), combo_left (0..1 of the combo window), gain (last points earned), gain_age (0..1
-- since that gain; 1 or more = old), wreck (bool, the last gain was a wreck bonus).
local function commas(n)
    local s = tostring(math.floor(n))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return out
end

features.on_draw("Carnage Score", function(f)
    if not f.active then return end
    local score = math.floor(f.score or 0)
    local combo = math.floor(f.combo or 0)
    local gain_age = f.gain_age or 1
    if score <= 0 and gain_age >= 1 then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local fnt = font.display
    local cx = sw / 2
    local y = sh * 0.11

    local label = "CARNAGE"
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, label) / 2, y, ar, ag, ab, 230, label)
    y = y + text.height(font.hud_tiny)

    local pop = gain_age < 1 and (1 - gain_age) or 0
    local value = commas(score)
    local vw = text.width(fnt, value)
    local r, g, b = 245, 245, 250
    if pop > 0 then r, g, b = 255, math.floor(245 - 60 * pop), math.floor(250 - 160 * pop) end
    text.draw(fnt, cx - vw / 2, y - pop * 4 * s, r, g, b, 255, value)
    local vh = text.height(fnt)

    if combo > 1 then
        local tag = string.format("x%d", combo)
        text.draw(font.hud, cx + vw / 2 + 8 * s, y + vh * 0.2, 255, 200, 60, 255, tag)
    end
    y = y + vh + 2 * s

    if combo > 0 then
        local bw = 120 * s
        local left = math.max(0, math.min(1, f.combo_left or 0))
        draw.rect(cx - bw / 2, y, cx + bw / 2, y + 3 * s, 0, 0, 0, 150, 0)
        draw.rect(cx - bw / 2, y, cx - bw / 2 + bw * left, y + 3 * s, 255, 200, 60, 255, 0)
        y = y + 6 * s
    end

    if gain_age < 1 then
        local a = math.floor(255 * (1 - gain_age))
        local msg = (f.wreck and "WRECKED! +" or "+") .. commas(f.gain or 0)
        text.draw(font.hud_small, cx - text.width(font.hud_small, msg) / 2, y + gain_age * 10 * s, 255, f.wreck and 120 or 220, 80, a, msg)
    end

    local best = string.format("BEST %s", commas(f.best or 0))
    text.draw(font.hud_tiny, cx - text.width(font.hud_tiny, best) / 2, y + text.height(font.hud_small) + 4 * s, 180, 180, 195, 200, best)
end)
