-- Car Show. Published fields: active (bool), state (1 judging, 2 result), progress (0..1 through the judging), condition /
-- clean / performance / style / prestige (0-20 each), total (0-100), place (0 best in show, 1 first, 2 second, 3 third,
-- 4 honourable mention), prize (cash won, 0 outside Story Mode).
local categories = {
    { key = "condition", label = "CONDITION" },
    { key = "clean", label = "CLEANLINESS" },
    { key = "performance", label = "PERFORMANCE" },
    { key = "style", label = "STYLE" },
    { key = "prestige", label = "PRESTIGE" },
}
local places = { "BEST IN SHOW", "FIRST PLACE", "SECOND PLACE", "THIRD PLACE", "HONOURABLE MENTION" }
local place_colours = { { 255, 205, 60 }, { 255, 205, 60 }, { 200, 205, 215 }, { 205, 127, 50 }, { 180, 180, 190 } }

features.on_draw("Car Show", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local state = math.floor(f.state or 0)
    local p = f.progress or 1

    local w = 360 * s
    local rh = 34 * s
    local h = 70 * s + #categories * rh + 60 * s
    local x, y = sw - w - 40 * s, sh * 0.25
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 215, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 0)
    text.draw(font.item, x + 16 * s, y + 14 * s, 245, 245, 250, 255, "JUDGES' SCORECARD")

    local total_shown = 0
    for i, c in ipairs(categories) do
        local ry = y + 56 * s + (i - 1) * rh
        local reveal = math.max(0, math.min(1, p * (#categories + 1) - (i - 1)))
        text.draw(font.small, x + 16 * s, ry, 200, 200, 212, 240, c.label)
        local score = math.floor(f[c.key] or 0)
        local shown = math.floor(score * reveal + 0.5)
        total_shown = total_shown + shown
        local bx1, bx2 = x + 170 * s, x + w - 60 * s
        local by = ry + 6 * s
        draw.rect(bx1, by, bx2, by + 8 * s, 255, 255, 255, 25, 4 * s)
        if shown > 0 then draw.rect(bx1, by, bx1 + (bx2 - bx1) * shown / 20, by + 8 * s, ar, ag, ab, 235, 4 * s) end
        local sstr = reveal > 0 and tostring(shown) or "-"
        text.draw(font.small, x + w - 16 * s - text.width(font.small, sstr), ry, 245, 245, 250, 255, sstr)
    end

    local ty = y + 56 * s + #categories * rh + 6 * s
    draw.rect(x + 16 * s, ty, x + w - 16 * s, ty + 1.5 * s, 255, 255, 255, 60, 0)
    local tstr = string.format("%d / 100", state == 2 and math.floor(f.total or 0) or total_shown)
    text.draw(font.title, x + w - 16 * s - text.width(font.title, tstr), ty + 8 * s, 245, 245, 250, 255, tstr)
    text.draw(font.small, x + 16 * s, ty + 14 * s, 200, 200, 212, 240, "TOTAL")

    if state == 2 then
        local place = math.floor(f.place or 4) + 1
        local msg = places[place] or ""
        local c = place_colours[place] or { 255, 255, 255 }
        local cx = sw / 2
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.2, c[1], c[2], c[3], 255, msg)
        if (f.prize or 0) > 0 then
            local pr = string.format("+$%d", math.floor(f.prize))
            text.draw(font.item, cx - text.width(font.item, pr) / 2, sh * 0.2 + text.height(big), 245, 245, 250, 255, pr)
        end
    end
end)
