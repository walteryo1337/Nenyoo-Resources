-- Pocket Plinko. Published fields: active (bool), stake (per ball; 0 outside Story Mode), last_bucket (0-12 where the
-- last ball landed, -1 none), last_win, flash (bool, a ball just landed), net (session winnings minus stakes), dropped
-- (balls this session), rows (peg rows), balls (blob "row,rights,next_dir,frac;" per ball in play: it has passed `row`
-- rows bouncing right `rights` times, is heading left (0) or right (1) next, and is `frac` of the way there).
local mult = { "16x", "9x", "2x", "1.4x", "1.1x", "0.7x", "0.3x", "0.7x", "1.1x", "1.4x", "2x", "9x", "16x" }

local function bucket_color(i)
    local d = math.abs(i - 6)
    if d >= 5 then return 240, 80, 70 end
    if d >= 3 then return 245, 160, 60 end
    if d >= 1 then return 240, 210, 70 end
    return 120, 200, 110
end

features.on_draw("Pocket Plinko", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local rows = math.floor(f.rows or 12)
    local gap = 44 * s
    local top = sh * 0.17
    local cx = sw / 2
    local width = gap * (rows + 1)
    draw.rect(cx - width / 2 - 20 * s, top - 70 * s, cx + width / 2 + 20 * s, top + gap * (rows + 1) + 70 * s, 12, 12, 16, 225, 12 * s)

    for r = 1, rows do
        for k = 0, r do
            local px = cx + (k - r / 2) * gap
            local py = top + r * gap
            draw.circle(px, py, 4 * s, 200, 200, 214, 255)
        end
    end

    local by = top + (rows + 1) * gap
    local last = math.floor(f.last_bucket or -1)
    for i = 0, rows do
        local bx = cx + (i - rows / 2) * gap
        local r, g, b = bucket_color(i)
        local hot = f.flash and i == last
        local a = hot and 255 or 200
        draw.rect(bx - gap * 0.45, by - 14 * s, bx + gap * 0.45, by + 18 * s, r, g, b, a, 4 * s)
        if hot then draw.rect(bx - gap * 0.45, by - 18 * s, bx + gap * 0.45, by - 14 * s, 255, 255, 255, 255, 0) end
        local m = mult[i + 1] or ""
        text.draw(font.tiny, bx - text.width(font.tiny, m) / 2, by + 2 * s - text.height(font.tiny) / 2, 20, 20, 26, 255, m)
    end

    for row, rights, dir, frac in string.gmatch(f.balls or "", "(%d+),(%d+),(%d+),([%d%.]+);") do
        row, rights, dir, frac = tonumber(row), tonumber(rights), tonumber(dir), tonumber(frac)
        local x1 = (rights - row / 2) * gap
        local x2 = (rights + dir - (row + 1) / 2) * gap
        local y1, y2 = row * gap, (row + 1) * gap
        local x = x1 + (x2 - x1) * frac
        local hop = math.sin(frac * math.pi) * 10 * s
        local y = y1 + (y2 - y1) * frac * frac - hop
        draw.circle(cx + x, top + y - 8 * s, 9 * s, 255, 235, 120, 255)
    end

    local stake = math.floor(f.stake or 0)
    local head = stake > 0 and string.format("E DROP A BALL   $%d EACH", stake) or "E DROP A BALL   (FOR FUN)"
    text.draw(font.small, cx - text.width(font.small, head) / 2, top - 58 * s, 230, 230, 240, 255, head)
    local net = math.floor(f.net or 0)
    local ns = string.format("NET %s$%d", net < 0 and "-" or "+", math.abs(net))
    local nr, ng, nb = 120, 230, 120
    if net < 0 then nr, ng, nb = 240, 90, 80 end
    text.draw(font.item, cx - text.width(font.item, ns) / 2, by + 30 * s, nr, ng, nb, 255, ns)
    if f.flash and (f.last_win or 0) > 0 then
        local w = string.format("+$%d", math.floor(f.last_win))
        text.draw(font.title, cx - text.width(font.title, w) / 2, top - 28 * s, 255, 220, 100, 255, w)
    end
end)
