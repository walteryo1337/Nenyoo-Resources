-- Trick Shots. Published fields: active (bool), total (points this session), best (biggest single trick), tricks (count),
-- popups (blob of "flags,points,multi,age;" for recent tricks, oldest first). flags bits: 1 headshot, 2 long shot,
-- 4 extreme range, 8 airborne, 16 no-scope, 32 drive-by, 64 multi-kill, 128 quick chain, 256 point blank.
local names = {
    { 8, "AIRBORNE" }, { 16, "NO-SCOPE" }, { 32, "DRIVE-BY" }, { 4, "EXTREME RANGE" }, { 2, "LONG SHOT" },
    { 256, "POINT BLANK" }, { 1, "HEADSHOT" }, { 128, "QUICK CHAIN" },
}
local multi_names = { [2] = "DOUBLE KILL", [3] = "TRIPLE KILL", [4] = "QUAD KILL" }

local function has(flags, bit)
    return math.floor(flags / bit) % 2 == 1
end

local function label(flags, multi)
    local parts = {}
    if has(flags, 64) then parts[#parts + 1] = multi_names[multi] or "MASSACRE" end
    for _, n in ipairs(names) do
        if has(flags, n[1]) then parts[#parts + 1] = n[2] end
    end
    return table.concat(parts, "  +  ")
end

features.on_draw("Trick Shots", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local y = sh * 0.62

    local list = {}
    for flags, pts, multi, age in string.gmatch(f.popups or "", "(%-?%d+),(%-?%d+),(%-?%d+),([%d%.]+);") do
        list[#list + 1] = { tonumber(flags), tonumber(pts), tonumber(multi), tonumber(age) }
    end
    for i = #list, 1, -1 do
        local p = list[i]
        local age = p[4]
        local a = math.floor(255 * math.min(1, (2.5 - age) * 1.6))
        if a > 0 then
            local rise = math.min(age, 0.3) * 40 * s
            local pts = string.format("+%d", p[2])
            local big = (i == #list) and (font.title) or font.item
            local pw = text.width(big, pts)
            text.draw(big, cx - pw / 2, y - rise, ar, ag, ab, a, pts)
            local l = label(p[1], p[3])
            local ly = y - rise + text.height(big)
            text.draw(font.small, cx - text.width(font.small, l) / 2, ly, 245, 245, 250, a, l)
            y = y + text.height(big) + text.height(font.small) + 6 * s
        end
    end

    local stats = string.format("TRICK POINTS %d", math.floor(f.total or 0))
    local tw = text.width(font.tiny, stats)
    text.draw(font.tiny, sw - tw - 28 * s, sh * 0.16, 220, 220, 230, 220, stats)
end)
