-- Cup Game. Published fields: active (bool), state (2 shuffling, 3 pick a cup, 4 reveal), elapsed_ms (time in the current
-- state), swap_ms (length of one swap), show_ms (how long the ball is shown before the shuffle), start (0-2 slot the ball
-- starts under), final (slot the ball ends under, -1 if the hustler palmed it, -2 until the reveal), pick (0-2 slot you
-- chose, -1 none), outcome (1 win, 2 wrong cup, 3 hustled, 4 too slow), pick_left (seconds), stake, streak, net (session
-- winnings), swaps (blob of "ab;" slot pairs swapped in order).
local function parse(str)
    local out = {}
    for a, b in string.gmatch(str or "", "(%d)(%d);") do out[#out + 1] = { tonumber(a), tonumber(b) } end
    return out
end

local function cup(x, base, w, h, lift, r, g, b)
    local y = base - lift
    draw.rect(x - w * 0.42, y - h, x + w * 0.42, y - h * 0.2, r, g, b, 255, 6)
    draw.rect(x - w * 0.5, y - h * 0.25, x + w * 0.5, y, math.floor(r * 0.8), math.floor(g * 0.8), math.floor(b * 0.8), 255, 4)
    draw.rect(x - w * 0.3, y - h * 0.92, x + w * 0.3, y - h * 0.8, 255, 255, 255, 50, 3)
end

features.on_draw("Cup Game", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display or font.title
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local swaps = parse(f.swaps)
    local swap_ms = f.swap_ms or 400
    local show_ms = f.show_ms or 900
    local t = f.elapsed_ms or 0

    local pw, ph = 520 * s, 230 * s
    local px, py = cx - pw / 2, sh * 0.62
    draw.rect(px, py, px + pw, py + ph, 70, 30, 30, 230, 10 * s)
    draw.rect(px + 8 * s, py + 8 * s, px + pw - 8 * s, py + ph - 8 * s, 30, 90, 50, 240, 8 * s)

    local slot_x = { cx - 150 * s, cx, cx + 150 * s }
    local base = py + ph - 40 * s
    local cw, chh = 90 * s, 100 * s
    local cup_slot = { 0, 1, 2 }
    local ball_cup = math.floor(f.start or 0)
    local cup_x = { slot_x[1], slot_x[2], slot_x[3] }
    local cup_lift = { 0, 0, 0 }
    local cup_raise = { 0, 0, 0 }
    local show_ball_slot = -1

    if state == 2 then
        if t < show_ms then
            local p = t / show_ms
            cup_lift[ball_cup + 1] = math.sin(p * math.pi) * 60 * s
            show_ball_slot = ball_cup
        else
            local st = t - show_ms
            local k = math.floor(st / swap_ms)
            local p = (st - k * swap_ms) / swap_ms
            for i = 1, math.min(k, #swaps) do
                local a, b = swaps[i][1], swaps[i][2]
                for c = 1, 3 do
                    if cup_slot[c] == a then cup_slot[c] = b elseif cup_slot[c] == b then cup_slot[c] = a end
                end
            end
            for c = 1, 3 do cup_x[c] = slot_x[cup_slot[c] + 1] end
            local cur = swaps[k + 1]
            if cur then
                local e = p * p * (3 - 2 * p)
                for c = 1, 3 do
                    if cup_slot[c] == cur[1] or cup_slot[c] == cur[2] then
                        local from = cup_slot[c]
                        local to = from == cur[1] and cur[2] or cur[1]
                        cup_x[c] = slot_x[from + 1] + (slot_x[to + 1] - slot_x[from + 1]) * e
                        cup_raise[c] = math.sin(e * math.pi) * 18 * s * (from < to and 1 or -1)
                    end
                end
            end
        end
    elseif state >= 3 then
        for i = 1, #swaps do
            local a, b = swaps[i][1], swaps[i][2]
            for c = 1, 3 do
                if cup_slot[c] == a then cup_slot[c] = b elseif cup_slot[c] == b then cup_slot[c] = a end
            end
        end
        for c = 1, 3 do cup_x[c] = slot_x[cup_slot[c] + 1] end
        if state == 4 then
            local p = math.min(1, t / 400)
            for c = 1, 3 do cup_lift[c] = p * 70 * s end
            local fin = math.floor(f.final or -1)
            if fin >= 0 then show_ball_slot = fin end
        end
    end

    if show_ball_slot >= 0 then
        draw.circle(slot_x[show_ball_slot + 1], base - 14 * s, 13 * s, 235, 60, 50, 255)
    end
    for c = 1, 3 do
        local r, g, b = 200, 150, 60
        if state == 4 and cup_slot[c] == math.floor(f.pick or -1) then r, g, b = ar, ag, ab end
        cup(cup_x[c], base - cup_raise[c], cw, chh, cup_lift[c], r, g, b)
    end

    if state == 3 then
        local keys = { "A", "W", "D" }
        for i = 1, 3 do
            local k = keys[i]
            text.draw(font.title, slot_x[i] - text.width(font.title, k) / 2, py + 12 * s, 255, 255, 255, 230, k)
        end
        local msg = string.format("PICK A CUP  %d", math.ceil(f.pick_left or 0))
        text.draw(font.item, cx - text.width(font.item, msg) / 2, py - text.height(font.item) - 8 * s, 245, 245, 250, 255, msg)
    elseif state == 2 then
        local msg = "WATCH THE BALL"
        text.draw(font.item, cx - text.width(font.item, msg) / 2, py - text.height(font.item) - 8 * s, 245, 245, 250, 255, msg)
    elseif state == 4 then
        local outcome = math.floor(f.outcome or 0)
        local msgs = { "SHARP EYES", "WRONG CUP", "HUSTLED", "TOO SLOW" }
        local msg = msgs[outcome] or ""
        local r, g, b = 240, 80, 70
        if outcome == 1 then
            r, g, b = 120, 230, 120
            msg = msg .. string.format("  +$%d", math.floor(f.stake or 0))
        else
            msg = msg .. string.format("  -$%d", math.floor(f.stake or 0))
        end
        text.draw(big, cx - text.width(big, msg) / 2, py - text.height(big) - 8 * s, r, g, b, 255, msg)
    end

    local net = math.floor(f.net or 0)
    local foot = string.format("STAKE $%d   SESSION %s$%d", math.floor(f.stake or 0), net < 0 and "-" or "+", math.abs(net))
    if math.floor(f.streak or 0) > 0 then foot = foot .. string.format("   STREAK %d", math.floor(f.streak)) end
    text.draw(font.tiny, px + 14 * s, py + ph - 8 * s - text.height(font.tiny), 230, 230, 235, 230, foot)
end)
