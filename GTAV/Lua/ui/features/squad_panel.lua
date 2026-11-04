-- Squad Panel. Published fields: active (bool, at least one group member), count, members (blob
-- "animal,dead,in_vehicle,health,armour,distance;" per member: flags are 0/1, health and armour 0 to 1,
-- distance in metres). Drawn as a compact list on the left edge of the screen, above the minimap.
local shown = 0

local function bar(x, y, w, h, frac, r, g, b, a)
    draw.rect(x, y, x + w, y + h, 0, 0, 0, math.floor(a * 0.55), h / 2)
    if frac > 0 then draw.rect(x, y, x + w * frac, y + h, r, g, b, a, h / 2) end
end

features.on_draw("Squad Panel", function(f)
    local dt = ctx.delta and ctx.delta() or 0.016
    if f.active then shown = math.min(1, shown + dt * 6) else shown = math.max(0, shown - dt * 6) end
    if shown <= 0 then return end

    local sh = ctx.screen_h()
    local s = sh / 1080
    local a = shown
    local x = 28 * s
    local row_h = 34 * s
    local w = 210 * s
    local n = math.floor(f.count or 0)
    local y = sh - 400 * s - n * row_h

    draw.rect(x - 8 * s, y - 30 * s, x + w + 8 * s, y + n * row_h + 4 * s, 10, 10, 16, math.floor(170 * a), 8 * s)
    text.draw(font.tiny, x, y - 24 * s, 200, 200, 214, math.floor(230 * a), "SQUAD")

    local i, humans, pets = 0, 0, 0
    for animal, dead, inveh, hp, ar, dist in string.gmatch(f.members or "", "(%d),(%d),(%d),([%d%.]+),([%d%.]+),(%d+);") do
        local ry = y + i * row_h
        local is_pet = animal == "1"
        local label
        if is_pet then
            pets = pets + 1
            label = pets > 1 and string.format("PET %d", pets) or "PET"
        else
            humans = humans + 1
            label = string.format("ALLY %d", humans)
        end
        local dead_now = dead == "1"
        local lr, lg, lb = 235, 235, 245
        if dead_now then lr, lg, lb = 235, 80, 80 end
        text.draw(font.tiny, x, ry, lr, lg, lb, math.floor(240 * a), label)
        local info = dead_now and "DOWN" or string.format("%dm%s", tonumber(dist), inveh == "1" and "  CAR" or "")
        text.draw(font.tiny, x + w - text.width(font.tiny, info), ry, 190, 190, 205, math.floor(220 * a), info)

        local health = tonumber(hp) or 0
        local hr, hg, hb = 90, 225, 120
        if health < 0.3 then hr, hg, hb = 235, 70, 70 elseif health < 0.6 then hr, hg, hb = 240, 190, 60 end
        bar(x, ry + 16 * s, w, 5 * s, health, hr, hg, hb, math.floor(230 * a))
        local armour = tonumber(ar) or 0
        if armour > 0 then bar(x, ry + 23 * s, w, 3 * s, armour, 80, 170, 255, math.floor(220 * a)) end
        i = i + 1
    end
end)
