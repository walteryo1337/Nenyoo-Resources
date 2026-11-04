-- Pocket Hangman. Published fields: active (bool), state (1 playing, 2 solved, 3 hanged), wrong / max_wrong (bad
-- guesses), cursor (0-25 letter A-Z under the selector), used (bitmask of guessed letters, bit 0 = A), streak / best
-- (words solved in a row this session), masked (blob: the phrase with unguessed letters as "_"; the full phrase once
-- hanged).
local function has_bit(mask, i)
    return math.floor(mask / 2 ^ i) % 2 == 1
end

features.on_draw("Pocket Hangman", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local cx = sw / 2
    local w, h = 760 * s, 540 * s
    local x0, y0 = cx - w / 2, sh / 2 - h / 2
    local state = math.floor(f.state or 0)
    draw.rect(x0, y0, x0 + w, y0 + h, 12, 12, 16, 225, 12 * s)

    -- gallows and figure
    local gx, gy = x0 + 80 * s, y0 + 40 * s
    local lw = 5 * s
    local c1, c2, c3 = 200, 190, 170
    draw.line(gx, gy + 260 * s, gx + 140 * s, gy + 260 * s, c1, c2, c3, 255, lw)
    draw.line(gx + 30 * s, gy + 260 * s, gx + 30 * s, gy, c1, c2, c3, 255, lw)
    draw.line(gx + 30 * s, gy, gx + 120 * s, gy, c1, c2, c3, 255, lw)
    draw.line(gx + 120 * s, gy, gx + 120 * s, gy + 30 * s, c1, c2, c3, 255, lw * 0.6)
    local wrong = math.floor(f.wrong or 0)
    local pr, pg, pb = 245, 245, 250
    if state == 3 then pr, pg, pb = 240, 80, 70 end
    local hx, hy = gx + 120 * s, gy + 52 * s
    if wrong >= 1 then draw.circle_outline(hx, hy, 22 * s, pr, pg, pb, 255, 4 * s) end
    if wrong >= 2 then draw.line(hx, hy + 22 * s, hx, hy + 110 * s, pr, pg, pb, 255, 4 * s) end
    if wrong >= 3 then draw.line(hx, hy + 45 * s, hx - 34 * s, hy + 80 * s, pr, pg, pb, 255, 4 * s) end
    if wrong >= 4 then draw.line(hx, hy + 45 * s, hx + 34 * s, hy + 80 * s, pr, pg, pb, 255, 4 * s) end
    if wrong >= 5 then draw.line(hx, hy + 110 * s, hx - 30 * s, hy + 160 * s, pr, pg, pb, 255, 4 * s) end
    if wrong >= 6 then draw.line(hx, hy + 110 * s, hx + 30 * s, hy + 160 * s, pr, pg, pb, 255, 4 * s) end

    -- phrase
    local masked = f.masked or ""
    local spaced = masked:gsub(".", function(ch) return ch .. " " end)
    local big = font.title
    local tx = x0 + 280 * s
    local word_r, word_g, word_b = 245, 245, 250
    if state == 2 then word_r, word_g, word_b = 120, 230, 120 elseif state == 3 then word_r, word_g, word_b = 240, 120, 100 end
    local ww = text.width(big, spaced)
    if tx + ww > x0 + w - 20 * s then tx = x0 + w - 20 * s - ww end
    text.draw(big, tx, y0 + 130 * s, word_r, word_g, word_b, 255, spaced)
    local lives = string.format("%d GUESSES LEFT", math.max(0, math.floor(f.max_wrong or 6) - wrong))
    text.draw(font.small, x0 + 280 * s, y0 + 190 * s, 200, 200, 214, 230, lives)

    -- alphabet
    local used = math.floor(f.used or 0)
    local cur = math.floor(f.cursor or 0)
    local kw = 50 * s
    local ky = y0 + 330 * s
    for i = 0, 25 do
        local row = math.floor(i / 13)
        local col = i % 13
        local kx = cx - 13 * kw / 2 + col * kw
        local yy = ky + row * (kw + 8 * s)
        local letter = string.char(65 + i)
        local taken = has_bit(used, i)
        local br, bg, bb, ba = 40, 40, 50, 230
        if i == cur and state == 1 then br, bg, bb, ba = ar, ag, ab, 255 end
        draw.rect(kx + 3 * s, yy, kx + kw - 3 * s, yy + kw, br, bg, bb, ba, 6 * s)
        local lr, lg, lb, la = 245, 245, 250, 255
        if taken then lr, lg, lb, la = 110, 110, 120, 200 end
        text.draw(font.item, kx + kw / 2 - text.width(font.item, letter) / 2, yy + kw / 2 - text.height(font.item) / 2, lr, lg, lb, la, letter)
    end

    local foot
    if state == 1 then foot = "A / D PICK A LETTER     E GUESS"
    elseif state == 2 then foot = "SOLVED!   E FOR THE NEXT WORD"
    else foot = "HANGED   E TO TRY ANOTHER" end
    foot = foot .. string.format("     STREAK %d  BEST %d", math.floor(f.streak or 0), math.floor(f.best or 0))
    text.draw(font.small, cx - text.width(font.small, foot) / 2, y0 + h - 40 * s, 210, 210, 222, 240, foot)
end)
