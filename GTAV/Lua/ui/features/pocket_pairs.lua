-- Pocket Pairs. Published fields: active (bool), state (1 picking, 2 showing a miss, 3 board cleared), cursor (card index,
-- row * cols + col), moves (pairs turned over), best (fewest moves this session; 0 none yet), seconds (time on this
-- board), cols / rows, cards (blob "v," per card: -1 face down, 0-7 face up, 10-17 matched).
local symbols = {
    { "$", 120, 220, 110 }, { "#", 240, 90, 80 }, { "@", 90, 170, 255 }, { "%", 245, 200, 70 },
    { "&", 190, 120, 240 }, { "?", 245, 150, 60 }, { "!", 90, 220, 220 }, { "+", 245, 120, 200 },
}

features.on_draw("Pocket Pairs", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cols, rows = math.floor(f.cols or 4), math.floor(f.rows or 4)
    local cw, ch = 110 * s, 140 * s
    local gap = 14 * s
    local bw, bh = cols * cw + (cols - 1) * gap, rows * ch + (rows - 1) * gap
    local x0, y0 = sw / 2 - bw / 2, sh / 2 - bh / 2 + 20 * s
    draw.rect(x0 - 24 * s, y0 - 70 * s, x0 + bw + 24 * s, y0 + bh + 60 * s, 12, 12, 16, 225, 12 * s)

    local cards = {}
    for v in string.gmatch(f.cards or "", "(%-?%d+),") do cards[#cards + 1] = tonumber(v) end
    local cur = math.floor(f.cursor or 0)
    local big = font.display or font.title
    for i = 0, cols * rows - 1 do
        local r, c = math.floor(i / cols), i % cols
        local x = x0 + c * (cw + gap)
        local y = y0 + r * (ch + gap)
        local v = cards[i + 1] or -1
        if v < 0 then
            draw.rect(x, y, x + cw, y + ch, 40, 50, 90, 255, 8 * s)
            draw.rect(x + 8 * s, y + 8 * s, x + cw - 8 * s, y + ch - 8 * s, 55, 70, 125, 255, 6 * s)
        else
            local matched = v >= 10
            local sym = symbols[(v % 10) + 1]
            draw.rect(x, y, x + cw, y + ch, 235, 235, 242, matched and 150 or 255, 8 * s)
            text.draw(big, x + cw / 2 - text.width(big, sym[1]) / 2, y + ch / 2 - text.height(big) / 2, sym[2], sym[3], sym[4], matched and 150 or 255, sym[1])
        end
        if i == cur and math.floor(f.state or 0) ~= 3 then
            draw.rect(x - 4 * s, y - 4 * s, x + cw + 4 * s, y - 1 * s, ar, ag, ab, 255, 0)
            draw.rect(x - 4 * s, y + ch + 1 * s, x + cw + 4 * s, y + ch + 4 * s, ar, ag, ab, 255, 0)
            draw.rect(x - 4 * s, y - 4 * s, x - 1 * s, y + ch + 4 * s, ar, ag, ab, 255, 0)
            draw.rect(x + cw + 1 * s, y - 4 * s, x + cw + 4 * s, y + ch + 4 * s, ar, ag, ab, 255, 0)
        end
    end

    local t = f.seconds or 0
    local head = string.format("MOVES %d   %d:%02d", math.floor(f.moves or 0), math.floor(t / 60), math.floor(t % 60))
    text.draw(font.item, x0, y0 - 54 * s, 245, 245, 250, 255, head)
    if (f.best or 0) > 0 then
        local b = string.format("BEST %d", math.floor(f.best))
        text.draw(font.item, x0 + bw - text.width(font.item, b), y0 - 54 * s, 200, 200, 214, 240, b)
    end
    local foot = math.floor(f.state or 0) == 3 and "ALL PAIRS FOUND!   E TO DEAL AGAIN" or "W A S D MOVE     E FLIP"
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, y0 + bh + 20 * s, 220, 220, 232, 240, foot)
end)
