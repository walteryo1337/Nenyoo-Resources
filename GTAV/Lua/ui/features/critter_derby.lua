-- Critter Derby. Published fields: active (bool), state (1 betting, 2 countdown, 3 racing, 4 result), countdown
-- (seconds), pick (-1 none, else 0-based runner), stake, winner (-1 until decided), profit, board (blob:
-- "name|odds|progress;" per runner, progress 0..1 along the course).
local function parse(board)
    local rows = {}
    for name, odds, prog in string.gmatch(board or "", "([^|;]+)|([^|;]+)|([^|;]+);") do
        rows[#rows + 1] = { name = name, odds = tonumber(odds) or 0, prog = tonumber(prog) or 0 }
    end
    return rows
end

features.on_draw("Critter Derby", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local big = font.display
    local cx = sw / 2
    local state = math.floor(f.state or 0)
    local pick = math.floor(f.pick or -1)
    local winner = math.floor(f.winner or -1)
    local rows = parse(f.board)

    if state == 2 then
        local n = math.ceil(f.countdown or 0)
        local msg = n > 0 and tostring(n) or "GO"
        text.draw(big, cx - text.width(big, msg) / 2, sh * 0.3, 255, 255, 255, 255, msg)
    end

    local rh = 26 * s
    local w = 380 * s
    local h = 40 * s + #rows * rh
    local x, y = 30 * s, sh * 0.32
    draw.rect(x, y, x + w, y + h, 12, 12, 16, 205, 8 * s)
    draw.rect(x, y, x + w, y + 3 * s, 120, 200, 90, 255, 0)
    local title = "CRITTER DERBY"
    if state == 1 then title = string.format("BETS CLOSE IN %d   $%d", math.ceil(f.countdown or 0), math.floor(f.stake or 0)) end
    text.draw(font.hud_small, x + 12 * s, y + 10 * s, 235, 235, 245, 255, title)

    for i, row in ipairs(rows) do
        local idx = i - 1
        local ry = y + 34 * s + (i - 1) * rh
        local nr, ng, nb = 235, 235, 245
        if idx == pick then nr, ng, nb = ar, ag, ab end
        if winner >= 0 and idx == winner then nr, ng, nb = 255, 205, 60 end
        local label = string.upper(row.name)
        text.draw(font.hud_small, x + 12 * s, ry, nr, ng, nb, 255, label)
        local ostr = string.format("%.1fx", row.odds)
        text.draw(font.hud_tiny, x + 110 * s, ry + 2 * s, 190, 190, 205, 230, ostr)
        local bx1, bx2 = x + 160 * s, x + w - 14 * s
        local by = ry + 6 * s
        draw.rect(bx1, by, bx2, by + 8 * s, 255, 255, 255, 25, 4 * s)
        local p = math.max(0, math.min(1, row.prog))
        if p > 0 then draw.rect(bx1, by, bx1 + (bx2 - bx1) * p, by + 8 * s, nr, ng, nb, 220, 4 * s) end
    end

    if state == 4 and pick >= 0 then
        local pr = math.floor(f.profit or 0)
        local msg, r, g, b = string.format("+$%d", pr), 120, 230, 120
        if pr <= 0 then msg, r, g, b = string.format("-$%d", -pr), 240, 80, 70 end
        text.draw(font.display, x + 12 * s, y + h + 6 * s, r, g, b, 255, msg)
    end
end)
