-- Cash Changes HUD (Story Mode). Published fields: active (bool), duration (s each line stays),
-- net (session total gained or lost), count, amountN (signed dollars), ageN (s since the change).
-- N = 1 is newest.
local function money(v)
    local n = math.floor(math.abs(v) + 0.5)
    local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return (v < 0 and "-$" or "+$") .. s
end

features.on_draw("Cash Changes", function(f)
    if not f.active then return end

    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local duration = f.duration or 4
    local fade = 0.5
    local right = sw - 26 * s
    local y = 112 * s
    local lh = text.height(font.item) + 4 * s
    local newest = f.age1 or duration

    for i = 1, math.floor(f.count or 0) do
        local age = f["age" .. i] or 0
        if age < duration then
            local t = age > duration - fade and (duration - age) / fade or 1
            local drop = age < 0.2 and (1 - age / 0.2) * -10 * s or 0
            local a = math.floor(255 * t)
            local amount = f["amount" .. i] or 0
            local label = money(amount)
            local r, g, b = 114, 204, 114
            if amount < 0 then r, g, b = 224, 50, 50 end
            local w = text.width(font.item, label)
            text.draw(font.item, right - w + 1 * s, y + drop + 1 * s, 0, 0, 0, math.floor(a * 0.6), label)
            text.draw(font.item, right - w, y + drop, r, g, b, a, label)
            y = y + lh
        end
    end

    if newest < duration and f.net then
        local t = newest > duration - fade and (duration - newest) / fade or 1
        local label = "SESSION " .. money(f.net)
        local w = text.width(font.tiny, label)
        text.draw(font.tiny, right - w, y + 2 * s, 220, 220, 228, math.floor(200 * t), label)
    end
end)
