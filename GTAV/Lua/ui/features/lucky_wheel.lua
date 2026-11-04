-- Lucky Wheel. Published fields: active (bool), state (1 spinning, 2 result), progress (0..1 through the spin), target
-- (0-based segment the wheel lands on: 0 $500, 1 armor, 2 $2,500, 3 nothing, 4 weapon, 5 full health, 6 $10,000,
-- 7 wanted).
local labels = { "$500", "ARMOR", "$2,500", "NOTHING", "WEAPON", "HEALTH", "$10,000", "WANTED" }
local colours = {
    { 60, 170, 90 }, { 70, 120, 220 }, { 60, 170, 90 }, { 90, 90, 100 },
    { 220, 140, 40 }, { 220, 70, 90 }, { 240, 200, 50 }, { 170, 50, 50 },
}
local turns = 5

local function ease_out(t)
    return 1 - (1 - t) ^ 3
end

features.on_draw("Lucky Wheel", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx, cy = sw / 2, sh * 0.48
    local r = 170 * s
    local n = #labels
    local seg = 360 / n
    local target = math.floor(f.target or 0)
    local final = turns * 360 + (360 - (target + 0.5) * seg)
    local rot = final * ease_out(math.max(0, math.min(1, f.progress or 0)))

    draw.circle(cx, cy, r + 10 * s, 25, 25, 30, 245)
    local lines = 14
    for i = 0, n - 1 do
        local c = colours[i + 1]
        for k = 0, lines - 1 do
            local a = math.rad(i * seg + (k + 0.5) * seg / lines + rot)
            draw.line(cx, cy, cx + math.sin(a) * r, cy - math.cos(a) * r, c[1], c[2], c[3], 255, r * math.rad(seg) / lines + 2 * s)
        end
    end
    for i = 0, n - 1 do
        local a = math.rad(i * seg + rot)
        draw.line(cx, cy, cx + math.sin(a) * r, cy - math.cos(a) * r, 25, 25, 30, 255, 3 * s)
    end
    for i = 0, n - 1 do
        local a = math.rad((i + 0.5) * seg + rot)
        local lx, ly = cx + math.sin(a) * r * 0.66, cy - math.cos(a) * r * 0.66
        local label = labels[i + 1]
        text.draw(font.small, lx - text.width(font.small, label) / 2, ly - text.height(font.small) / 2, 255, 255, 255, 255, label)
    end
    draw.circle(cx, cy, 22 * s, 25, 25, 30, 255)
    draw.circle(cx, cy, 14 * s, ar, ag, ab, 255)

    local py = cy - r - 14 * s
    draw.line(cx - 14 * s, py - 10 * s, cx, py + 18 * s, 255, 255, 255, 255, 5 * s)
    draw.line(cx + 14 * s, py - 10 * s, cx, py + 18 * s, 255, 255, 255, 255, 5 * s)
    draw.line(cx - 14 * s, py - 10 * s, cx + 14 * s, py - 10 * s, 255, 255, 255, 255, 5 * s)

    if math.floor(f.state or 0) == 2 then
        local label = labels[target + 1] or ""
        local msg = target == 3 and "BETTER LUCK TOMORROW" or (target == 7 and "UH OH - WANTED" or ("YOU WON " .. label))
        local c = colours[target + 1] or { 255, 255, 255 }
        text.draw(big, cx - text.width(big, msg) / 2, cy + r + 24 * s, c[1], c[2], c[3], 255, msg)
    end
end)
