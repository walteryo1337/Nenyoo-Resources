-- Race Betting. Published fields: active (bool), state (1 betting, 2 countdown, 3 racing, 4 result), countdown
-- (seconds), pick (0-based car you bet on, -1 none), stake, winner (0-based, -1 until decided), profit (session),
-- board (blob of "name|odds|metres to finish;" per car, in car order 1..3).
local colours = { { 224, 50, 50 }, { 93, 182, 229 }, { 240, 200, 80 } }

local function money(v)
    v = math.floor(v or 0)
    local sign = v < 0 and "-" or ""
    return sign .. "$" .. tostring(math.abs(v))
end

features.on_draw("Race Betting", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local state = math.floor(f.state or 0)
    local pick = math.floor(f.pick or -1)
    local winner = math.floor(f.winner or -1)

    local cars = {}
    for name, odds, dist in string.gmatch(f.board or "", "([^|;]+)|([%d%.]+)|(%-?%d+);") do
        cars[#cars + 1] = { name = name, odds = tonumber(odds), dist = tonumber(dist) }
    end

    local order = {}
    for i = 1, #cars do order[i] = i end
    if state >= 3 then table.sort(order, function(a, b) return cars[a].dist < cars[b].dist end) end

    local pad = 10 * s
    local rowh = text.height(font.hud_small) + 8 * s
    local w = 300 * s
    local h = pad * 2 + text.height(font.hud_tiny) + 6 * s + rowh * #cars + text.height(font.hud_tiny) + 6 * s
    local x, y = sw - w - 28 * s, sh * 0.32
    draw.rect(x, y, x + w, y + h, 10, 12, 18, 200, 8 * s)
    local titles = { "PLACE YOUR BET", "STARTING", "RACE ON", "RESULT" }
    local title = titles[state] or ""
    if state == 1 then title = string.format("PLACE YOUR BET  %d", math.ceil(f.countdown or 0)) end
    text.draw(font.hud_tiny, x + pad, y + pad, ar, ag, ab, 255, title)
    local cy = y + pad + text.height(font.hud_tiny) + 6 * s
    for pos, i in ipairs(order) do
        local c = cars[i]
        local col = colours[i] or colours[1]
        draw.rect(x + pad, cy + 2 * s, x + pad + 6 * s, cy + rowh - 4 * s, col[1], col[2], col[3], 255, 2 * s)
        local label = string.format("%d  %s", i, c.name)
        if state >= 3 then label = string.format("P%d  %s", pos, c.name) end
        local lr, lg, lb = 235, 235, 245
        if i - 1 == pick then lr, lg, lb = 255, 220, 120 end
        if state == 4 and i - 1 == winner then lr, lg, lb = 90, 230, 110 end
        text.draw(font.hud_small, x + pad + 14 * s, cy, lr, lg, lb, 255, label)
        local right = state >= 3 and string.format("%d m", c.dist) or string.format("%.1fx", c.odds)
        text.draw(font.hud_small, x + w - pad - text.width(font.hud_small, right), cy, 210, 210, 222, 240, right)
        cy = cy + rowh
    end
    local foot = pick >= 0 and string.format("BET %s ON #%d", money(f.stake), pick + 1) or string.format("STAKE %s", money(f.stake))
    foot = foot .. "   SESSION " .. money(f.profit)
    text.draw(font.hud_tiny, x + pad, cy + 2 * s, 190, 190, 205, 230, foot)

    if state == 2 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "GO"
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
    elseif state == 4 and winner >= 0 and cars[winner + 1] then
        local msg = string.format("#%d %s WINS", winner + 1, cars[winner + 1].name)
        local r, g, b = 240, 240, 248
        if pick == winner then r, g, b = ar, ag, ab end
        text.draw(big, sw / 2 - text.width(big, msg) / 2, sh * 0.26, r, g, b, 255, msg)
    end
end)
