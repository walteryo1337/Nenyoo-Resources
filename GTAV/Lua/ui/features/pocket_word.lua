-- Pocket Word Guess. Published fields: active (bool), state (1 playing, 2 solved, 3 out of tries), key (0-25 letters
-- A-Z, 26 ENTER, 27 DELETE: the on-screen key under the cursor), streak / best (words solved in a row this session),
-- rows (blob "GUESS:marks;" per submitted guess, marks per letter: "3" right spot, "2" in the word elsewhere, "1" not in
-- the word), typed (blob, the letters typed on the current row), letters (blob, 26 chars, the best mark seen for each
-- letter A-Z, "0" unused), answer (blob, only once you run out of tries).
local mark_colors = {
    ["0"] = { 60, 60, 70 }, ["1"] = { 50, 50, 56 }, ["2"] = { 200, 170, 50 }, ["3"] = { 80, 160, 80 },
}

features.on_draw("Pocket Word Guess", function(f)
    if not f.active then return end
    local sw, sh = ctx.screen_w(), ctx.screen_h()
    local s = sh / 1080
    local ar, ag, ab = theme.accent()
    local tile, gap = 62 * s, 8 * s
    local gw = 5 * tile + 4 * gap
    local x0 = sw / 2 - gw / 2
    local y0 = sh * 0.12
    draw.rect(x0 - 140 * s, y0 - 30 * s, x0 + gw + 140 * s, y0 + 6 * (tile + gap) + 250 * s, 12, 12, 16, 230, 12 * s)

    local rows = {}
    for g, m in string.gmatch(f.rows or "", "(%u+):(%d+);") do rows[#rows + 1] = { g = g, m = m } end
    local typed = f.typed or ""
    local state = math.floor(f.state or 0)
    for r = 1, 6 do
        local row = rows[r]
        for i = 1, 5 do
            local x = x0 + (i - 1) * (tile + gap)
            local y = y0 + (r - 1) * (tile + gap)
            local ch, col = "", nil
            if row then
                ch = row.g:sub(i, i)
                col = mark_colors[row.m:sub(i, i)]
            elseif r == #rows + 1 and state == 1 then
                ch = typed:sub(i, i)
            end
            if col then draw.rect(x, y, x + tile, y + tile, col[1], col[2], col[3], 255, 4 * s)
            else
                draw.rect(x, y, x + tile, y + tile, 22, 22, 28, 255, 4 * s)
                draw.rect(x, y, x + tile, y + 2 * s, 80, 80, 95, 255, 0)
            end
            if ch ~= "" then text.draw(font.title, x + tile / 2 - text.width(font.title, ch) / 2, y + tile / 2 - text.height(font.title) / 2, 245, 245, 250, 255, ch) end
        end
    end

    local letters = f.letters or ""
    local kw, kh = 46 * s, 54 * s
    local ky = y0 + 6 * (tile + gap) + 24 * s
    local cur = math.floor(f.key or 0)
    for k = 0, 27 do
        local r, c = math.floor(k / 10), k % 10
        local in_row = r == 2 and 8 or 10
        local rx0 = sw / 2 - (in_row * (kw + 6 * s)) / 2
        local x = rx0 + c * (kw + 6 * s)
        local y = ky + r * (kh + 6 * s)
        local label, col
        if k < 26 then
            label = string.char(65 + k)
            col = mark_colors[letters:sub(k + 1, k + 1)] or mark_colors["0"]
        else
            label = k == 26 and "OK" or "<"
            col = mark_colors["0"]
        end
        draw.rect(x, y, x + kw, y + kh, col[1], col[2], col[3], 255, 5 * s)
        if k == cur and state == 1 then draw.rect(x, y + kh - 4 * s, x + kw, y + kh, ar, ag, ab, 255, 0) end
        text.draw(font.item, x + kw / 2 - text.width(font.item, label) / 2, y + kh / 2 - text.height(font.item) / 2, 245, 245, 250, 255, label)
    end

    local foot
    if state == 2 then foot = "SOLVED!   E FOR A NEW WORD"
    elseif state == 3 then foot = "THE WORD WAS " .. (f.answer or "?") .. "   E TO TRY ANOTHER"
    else foot = "W A S D PICK A KEY   E PRESS   Q DELETE" end
    foot = foot .. string.format("   STREAK %d  BEST %d", math.floor(f.streak or 0), math.floor(f.best or 0))
    text.draw(font.small, sw / 2 - text.width(font.small, foot) / 2, ky + 3 * (kh + 6 * s) + 10 * s, 220, 220, 232, 240, foot)
end)
