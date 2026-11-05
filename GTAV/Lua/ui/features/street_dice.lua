-- Street Dice. Published fields: active (bool), state (1 rolling, 2 result), progress (0..1 through the roll), d1 / d2
-- (your dice), d3 / d4 (their dice), outcome (1 win, 2 lose, 3 push), amount (cash won or lost this round), net
-- (session winnings, can be negative), rounds (games played), opponent_rounds (games they can still afford).
local pips = {
    { { 0, 0 } },
    { { -1, -1 }, { 1, 1 } },
    { { -1, -1 }, { 0, 0 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { 0, 0 }, { -1, 1 }, { 1, 1 } },
    { { -1, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 1, 1 } },
}

local function die(x, y, size, value, tilt)
    local h = size / 2
    draw.rect(x - h, y - h + tilt, x + h, y + h + tilt, 245, 242, 235, 255, size * 0.18)
    local spot = pips[value] or pips[1]
    for _, p in ipairs(spot) do
        draw.circle(x + p[1] * size * 0.27, y + p[2] * size * 0.27 + tilt, size * 0.085, 25, 25, 30, 255)
    end
end

features.on_draw("Street Dice", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local t = ctx.time() or 0
    local rolling = state == 1

    -- Tall enough for the dice, their totals and the footer row below them.
    local w, h = 420 * s, 102 * s + text.height(font.display) + text.height(font.hud_tiny) + 12 * s
    local x, y = cx - w / 2, sh * 0.68
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, ar, ag, ab, 255, 0)

    local size = 46 * s
    local dice = { f.d1, f.d2, f.d3, f.d4 }
    local cols = { cx - w / 4, cx + w / 4 }
    local labels = { "YOU", "THEM" }
    for side = 1, 2 do
        local lx = cols[side]
        text.draw(font.hud_small, lx - text.width(font.hud_small, labels[side]) / 2, y + 12 * s, 210, 210, 222, 240, labels[side])
        local total = 0
        for k = 1, 2 do
            local i = (side - 1) * 2 + k
            local v = math.floor(dice[i] or 1)
            local tilt = 0
            if rolling then
                v = math.floor(t * 14 + i * 3) % 6 + 1
                tilt = math.sin(t * 22 + i) * 6 * s * (1 - (f.progress or 0))
            end
            total = total + v
            die(lx + (k == 1 and -1 or 1) * size * 0.65, y + 72 * s, size, v, tilt)
        end
        if not rolling then
            local tot = tostring(total)
            text.draw(font.display, lx - text.width(font.display, tot) / 2, y + 102 * s, 245, 245, 250, 255, tot)
        end
    end

    if not rolling then
        local outcome = math.floor(f.outcome or 0)
        local msg, r, g, b = "PUSH", 220, 220, 230
        if outcome == 1 then msg, r, g, b = string.format("YOU WIN +$%d", math.floor(f.amount or 0)), 120, 230, 120
        elseif outcome == 2 then msg, r, g, b = string.format("YOU LOSE -$%d", math.floor(f.amount or 0)), 240, 80, 70 end
        text.draw(font.display, cx - text.width(font.display, msg) / 2, y - text.height(font.display) - 6 * s, r, g, b, 255, msg)
    end

    local net = math.floor(f.net or 0)
    local foot = string.format("SESSION %s$%d", net < 0 and "-" or "+", math.abs(net))
    local fr, fg, fb = 120, 230, 120
    if net < 0 then fr, fg, fb = 240, 80, 70 end
    text.draw(font.hud_tiny, x + 12 * s, y + h - 8 * s - text.height(font.hud_tiny), fr, fg, fb, 235, foot)
    local left = math.floor(f.opponent_rounds or 0)
    if left > 0 then
        local lstr = string.format("THEY CAN PLAY %d MORE", left)
        text.draw(font.hud_tiny, x + w - 12 * s - text.width(font.hud_tiny, lstr), y + h - 8 * s - text.height(font.hud_tiny), 200, 200, 212, 220, lstr)
    end
end)
